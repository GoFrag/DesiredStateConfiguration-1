# A configuration to Create High Availability Domain Controller 
configuration DSCLab
{
   param
    (
        [Parameter(Mandatory)]
        [pscredential]$safemodeAdministratorCred,
        [Parameter(Mandatory)]
        [pscredential]$domainCred,
	    [Parameter(Mandatory)]
        [pscredential]$NewADUserCred
        )
    
#    Update-Module -Verbose -Force
    Install-Module -Name xActiveDirectory,xNetworking,xComputerManagement,xPSDesiredStateConfiguration -verbose
    Import-DscResource -ModuleName xActiveDirectory,xNetworking,xComputerManagement,PSDesiredStateConfiguration,xPSDesiredStateConfiguration
    
    Node $AllNodes.Where{$_.Role -eq "Primary DC"}.Nodename
    {
        
        Registry EdgeAsAdmin
        {
            Ensure = "Present"
            Key = "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"
            ValueName = "FilterAdministratorToken"
            ValueData = "1"
            ValueType = "Dword"
        }
        
        WindowsFeature ADDSInstall
        {
            Ensure = "Present"
            Name = "AD-Domain-Services"
        }

        xADDomain FirstDS
        {
            DomainName = $Node.DomainName
            DomainAdministratorCredential = $domainCred
            SafemodeAdministratorPassword = $safemodeAdministratorCred
            DomainNetbiosName = $node.NetbiosName
            DependsOn = ("[WindowsFeature]ADDSInstall","[WindowsFeature]RSATADTOOLS")
        }

        xWaitForADDomain DscForestWait
        {
            DomainName = $Node.DomainName
            DomainUserCredential = $domainCred
            RetryCount = $Node.RetryCount
            RetryIntervalSec = $Node.RetryIntervalSec
            DependsOn = "[xADDomain]FirstDS"
        }

        xADUser FirstUser
        {
            DomainName = $Node.DomainName
            DomainAdministratorCredential = $domainCred
            UserName = "PSUser"
            Password = $NewADUserCred
            Ensure = "Present"
            DependsOn = "[xWaitForADDomain]DscForestWait"
        }
        
        WindowsFeature RSATADTOOLS
        {
            Ensure = "Present"
            Name = "RSAT-AD-TOOLS"
            IncludeAllSubFeature = $True
        }

        WindowsFeature TelnetServer
        {
            Ensure = "Present"
            Name = "Telnet-Server"
        }

        WindowsFeature TelnetClient
        {
            Ensure = "Present"
            Name = "Telnet-Client"
        }

        WindowsFeature RemoteDifferentialCompression
        {
            Ensure = "Present"
            Name = "RDC"
        }
    }

    Node $AllNodes.Where{$_.Role -eq "Replica DC"}.Nodename
    {

        Registry EdgeAsAdmin
        {
            Ensure = "Present"
            Key = "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"
            ValueName = "FilterAdministratorToken"
            ValueData = "1"
            ValueType = "Dword"
        }
        
        WindowsFeature ADDSInstall
        {
            Ensure = "Present"
            Name = "AD-Domain-Services"
        }

        xWaitForADDomain DscForestWait
        {
            DomainName = $Node.DomainName
            DomainUserCredential = $domainCred
	        RetryCount = $Node.RetryCount
            RetryIntervalSec = $Node.RetryIntervalSec
            DependsOn = ("[WindowsFeature]ADDSInstall","[WindowsFeature]RSATADTOOLS")
        }

        xADDomainController SecondDC
        {
            DomainName = $Node.DomainName
            DomainAdministratorCredential = $domainCred
            SafemodeAdministratorPassword = $safemodeAdministratorCred
            DependsOn = "[xWaitForADDomain]DscForestWait"
        }
        
       WindowsFeature RSATADTOOLS
        {
            Ensure = "Present"
            Name = "RSAT-AD-TOOLS"
            IncludeAllSubFeature = $True
        }
        
        WindowsFeature TelnetServer
        {
            Ensure = "Present"
            Name = "Telnet-Server"
        }

        WindowsFeature TelnetClient
        {
            Ensure = "Present"
            Name = "Telnet-Client"
        }

        WindowsFeature RemoteDifferentialCompression
        {
            Ensure = "Present"
            Name = "RDC"
        }
    }
   
    Node $AllNodes.Where{$_.Role -eq "Pull Server"}.Nodename
    {
        Registry EdgeAsAdmin
        {
            Ensure = "Present"
            Key = "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"
            ValueName = "FilterAdministratorToken"
            ValueData = "1"
            ValueType = "Dword"
        }
        
        xWaitForADDomain DscForestWait
        {
            DomainName = $Node.DomainName
            DomainUserCredential = $domainCred
            RetryCount = $Node.RetryCount
            RetryIntervalSec = $Node.RetryIntervalSec
            DependsOn = "[WindowsFeature]RSATADPoSH"
        }
        
        xComputer JoinDomain 
        { 
            Name          = $node.NodeName
            DomainName    = $Node.DomainName 
            Credential    = $domainCred  # Credential to join to domain
        }   

        WindowsFeature RSATADPoSH
        {
            Ensure = "Present"
            Name = "RSAT-AD-Powershell"
        }

        WindowsFeature TelnetServer
        {
            Ensure = "Present"
            Name = "Telnet-Server"
        }

        WindowsFeature TelnetClient
        {
            Ensure = "Present"
            Name = "Telnet-Client"
        }

        WindowsFeature RemoteDifferentialCompression
        {
            Ensure = "Present"
            Name = "RDC"
        }
        
        WindowsFeature DSCService
        {
            Ensure = "Present"
            Name = "DSC-Service"
        }

         WindowsFeature IIS{
            Name = "web-server"
            Ensure = "Present"
        }
        
        WindowsFeature IISConsole
        {
            Ensure = "Present"
            Name   = "Web-Mgmt-Console"
            DependsOn = '[WindowsFeature]IIS'
        }

        xDscWebService PSDSCPullServer
        {
            Ensure                  = "Present"
            EndpointName            = "PSDSCPullServer"
            Port                    = '8080'
            PhysicalPath            = "$env:SystemDrive\inetpub\wwwroot\PSDSCPullServer"
            CertificateThumbPrint   = "AllowUnencryptedTraffic"
            ModulePath              = "$env:PROGRAMFILES\WindowsPowerShell\DscService\Modules"
            ConfigurationPath       = "$env:PROGRAMFILES\WindowsPowerShell\DscService\Configuration"
            State                   = "Started"
            DependsOn               = ("[WindowsFeature]DSCService","[WindowsFeature]IIS")
        }

        xDscWebService PSDSCComplianceServer
        {
            Ensure                  = "Present"
            EndpointName            = "PSDSCComplianceServer"
            Port                    = 9080
            PhysicalPath            = "$env:SystemDrive\inetpub\wwwroot\PSDSCComplianceServer"
            CertificateThumbPrint   = "AllowUnencryptedTraffic"
            State                   = "Started"
            IsComplianceServer      = $true
            DependsOn               = ("[WindowsFeature]DSCService","[xDSCWebService]PSDSCPullServer")
        }
    }
        
    Node $AllNodes.Where{$_.Role -eq "Member Server"}.Nodename
    {
      
        Registry EdgeAsAdmin
        {
            Ensure = "Present"
            Key = "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"
            ValueName = "FilterAdministratorToken"
            ValueData = "1"
            ValueType = "Dword"
        }
        
        xWaitForADDomain DscForestWait
        {
            DomainName = $Node.DomainName
            DomainUserCredential = $domainCred
            RetryCount = $Node.RetryCount
            RetryIntervalSec = $Node.RetryIntervalSec
            DependsOn = "[WindowsFeature]RSATADPoSH"
        }
        
        xComputer JoinDomain 
        { 
            Name          = $node.NodeName
            DomainName    = $Node.DomainName 
            Credential    = $domainCred  # Credential to join to domain
        }   

        WindowsFeature RSATADPoSH
        {
            Ensure = "Present"
            Name = "RSAT-AD-Powershell"
        }

         WindowsFeature TelnetClient
        {
            Ensure = "Present"
            Name = "Telnet-Client"
        }

        WindowsFeature RemoteDifferentialCompression
        {
            Ensure = "Present"
            Name = "RDC"
        }
    }
}

# Configuration Data for AD 

$ConfigData = @{
    AllNodes = @(
                @{
                    Nodename = '*'
                    DomainName = 'DSCLab.local'
                    RetryCount = 60
                    RetryIntervalSec = 120
                    PSDscAllowPlainTextPassword = $true
                    PSDscAllowDomainUser = $true
                    },
        
                @{
                    Nodename = "DSCLABDC01"
                    Role = "Primary DC"
                    },
        
                @{
                    Nodename = "DSCLABDC02"
                    Role = "Replica DC"
                    },

                @{
                    Nodename = "DSCLABS01"
                    Role = "Member Server"
                    },

                @{
                    Nodename = "DSCLABS02"
                    Role = "Member Server"
                    },

                @{
                    Nodename = "DSCLABS03"
                    Role = "Member Server"
                    },

                @{
                    Nodename = "DSCLABS04"
                    Role = "Member Server"
                    },
                
                @{
                    Nodename = "DSCLABPull01"
                    Role = "Pull Server"
                    }
            )
        }

DSCLab -ConfigurationData $ConfigData -OutputPath C:\GIT\DesiredStateConfiguration\DSCResource\lab\ -Verbose

#$creds = $null
#$creds = Get-Credential
#Start-DscConfiguration -path C:\GIT\DesiredStateConfiguration\DSCResource\lab\config -wait -verbose -credential $Creds -force
#Start-DscConfiguration -path C:\GIT\DesiredStateConfiguration\DSCResource\lab\config -ComputerName DSCLABPull01 -wait -verbose -credential $Creds -force