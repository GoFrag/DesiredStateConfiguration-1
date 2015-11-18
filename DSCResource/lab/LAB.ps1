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
    
    Install-Module -Name xActiveDirectory,xNetworking,xComputerManagement,xPSDesiredStateConfiguration -Force
    Import-DscResource -ModuleName xActiveDirectory,xNetworking,xComputerManagement,PSDesiredStateConfiguration,xPSDesiredStateConfiguration
    
    Node $AllNodes.Where{$_.Role -eq "Primary DC"}.Nodename
    {
        xComputer NewName
        { 
            Name = $node.HostName
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
            DependsOn = "[WindowsFeature]ADDSInstall"
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
        xComputer NewName
        { 
            Name = $node.HostName
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
            DependsOn = "[WindowsFeature]ADDSInstall"
        }

        xADDomainController SecondDC
        {
            DomainName = $Node.DomainName
            DomainAdministratorCredential = $domainCred
            SafemodeAdministratorPassword = $safemodeAdministratorCred
            DependsOn = ("[xWaitForADDomain]DscForestWait","[WindowsFeature]ADDSInstall")
        }
        
       WindowsFeature RSATADTOOLS
        {
            Ensure = "Present"
            Name = "RSAT-AD-TOOLS"
            IncludeAllSubFeature = $True
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

        WindowsFeature IISConsole {
            Ensure = "Present"
            Name   = "Web-Mgmt-Console"
        }

        xDscWebService PSDSCPullServer{
            Ensure                  = "Present"
            EndpointName            = "PSDSCPullServer"
            Port                    = '8080'
            PhysicalPath            = "$env:SystemDrive\inetpub\wwwroot\PSDSCPullServer"
            CertificateThumbPrint   = "AllowUnencryptedTraffic"
            ModulePath              = "$env:PROGRAMFILES\WindowsPowerShell\DscService\Modules"
            ConfigurationPath       = "$env:PROGRAMFILES\WindowsPowerShell\DscService\Configuration"
            State                   = "Started"
            DependsOn               = "[WindowsFeature]DSCService"
        }

        xDscWebService PSDSCComplianceServer{
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
      
        xWaitForADDomain DscForestWait
        {
            DomainName = $Node.DomainName
            DomainUserCredential = $domainCred
            RetryCount = $Node.RetryCount
            RetryIntervalSec = $Node.RetryIntervalSec
            DependsOn = '[WindowsFeature]RSATADPoSH'
        }
        
        xComputer JoinDomain 
        { 
            Name          = $node.HostName
            DomainName    = $Node.DomainName 
            Credential    = $domainCred  # Credential to join to domain
            #DependsOn = '[WindowsFeature]RSATADPoSH'
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

        WindowsFeature TelnetServer
        {
            Ensure = "Present"
            Name = "Telnet-Server"
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
                    DomainName = 'dsclab.local'
                    RetryCount = 30
                    RetryIntervalSec = 60
                    PSDscAllowPlainTextPassword = $true
                    NIC = 'Ethernet0'
                    AddressFamily = 'IPV4'
                    PSDscAllowDomainUser = $true
                },
        
                @{
                    Nodename = "DSCLABDC01"
                    Role = "Primary DC"
                    HostName = "DSCLABDC01"
                },
        
                @{
                    Nodename = "DSCLABDC02"
                    Role = "Replica DC"
                    HostName = "DSCLABDC02"
                },

                @{
                    Nodename = "DSCLABS01"
                    Role = "Member Server"
                    HostName = "DSCLABS01"
                },

                @{
                    Nodename = "DSCLABS02"
                    Role = "Member Server"
                    HostName = "DSCLABS02"
                },

                @{
                    Nodename = "DSCLABS03"
                    Role = "Member Server"
                    HostName = "DSCLABS03"
                },

                @{
                    Nodename = "DSCLABS04"
                    Role = "Member Server"
                    HostName = "DSCLABS04"
                }
            )
        }

DSCLab -ConfigurationData $ConfigData -OutputPath C:\GIT\DesiredStateConfiguration\DSCResource\lab\config -Verbose

#$creds = Get-Credential
#Start-DscConfiguration -path C:\GIT\DesiredStateConfiguration\DSCResource\lab\config -wait -verbose -credential $Creds -force