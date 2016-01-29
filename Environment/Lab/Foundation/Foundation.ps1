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
    
    Import-DscResource -ModuleName xActiveDirectory,xNetworking,xComputerManagement,PSDesiredStateConfiguration,xPSDesiredStateConfiguration,xRemoteDesktopAdmin
    
    Node $AllNodes.Where{$_.Role -eq "Primary DC"}.Nodename
    {

        xRemoteDesktopAdmin RemoteDesktopSettings
        {
           Ensure = 'Present'
           UserAuthentication = 'NonSecure'
        }
        
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

        WindowsFeature RemoteDifferentialCompression
        {
            Ensure = "Present"
            Name = "RDC"
        }
    }

    Node $AllNodes.Where{$_.Role -eq "Replica DC"}.Nodename
    {

        xRemoteDesktopAdmin RemoteDesktopSettings
        {
           Ensure = 'Present'
           UserAuthentication = 'NonSecure'
        }
        
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

        WindowsFeature RemoteDifferentialCompression
        {
            Ensure = "Present"
            Name = "RDC"
        }
    }
   
    Node $AllNodes.Where{$_.Role -eq "Pull Server"}.Nodename
    {
        xRemoteDesktopAdmin RemoteDesktopSettings
        {
           Ensure = 'Present'
           UserAuthentication = 'NonSecure'
        }
        
        Registry EdgeAsAdmin
        {
            Ensure = "Present"
            Key = "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"
            ValueName = "FilterAdministratorToken"
            ValueData = "1"
            ValueType = "Dword"
        }
        
        WindowsFeature RSATADPoSH
        {
            Ensure = "Present"
            Name = "RSAT-AD-Powershell"
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
            Port                    = '8090'
            PhysicalPath            = "$env:SystemDrive\inetpub\wwwroot\PSDSCComplianceServer"
            CertificateThumbPrint   = "AllowUnencryptedTraffic"
            State                   = "Started"
            IsComplianceServer      = $true
            DependsOn               = "[xDSCWebService]PSDSCPullServer"
        }
    }
}

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
                    Nodename = "DSCLABPull01"
                    Role = "Pull Server"
                    }
                )
            }

DSCLab -ConfigurationData $ConfigData -OutputPath "C:\Users\dyeo\OneDrive - Imperial College London\DesiredStateConfiguration\Environment\Lab\Foundation" -Verbose

#$creds = $null
#$creds = Get-Credential
#Start-DscConfiguration -path "C:\Users\dyeo\OneDrive - Imperial College London\DesiredStateConfiguration\Environment\Lab\Foundation" -wait -verbose -credential $Creds -force
