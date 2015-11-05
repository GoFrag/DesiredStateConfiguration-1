# A configuration to Create High Availability Domain Controller 
configuration AssertHADC
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
    
    Install-Module -Name xActiveDirectory,xNetworking,xComputerManagement -Force
    Import-DscResource -ModuleName xActiveDirectory,xNetworking,xComputerManagement,PSDesiredStateConfiguration
    
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
        
        WindowsFeature RSATADDS
        {
            Ensure = "Present"
            Name = "RSAT-ADDS"
            IncludeAllSubFeature = $True
        }
        
        WindowsFeature DSCService
        {
            Ensure = "Present"
            Name = "DSC-Service"
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
            DependsOn = "[xWaitForADDomain]DscForestWait"
        }
        
        WindowsFeature RSATADDS
        {
            Ensure = "Present"
            Name = "RSAT-ADDS"
            IncludeAllSubFeature = $True
        }
        
        WindowsFeature DSCService
        {
            Ensure = "Present"
            Name = "DSC-Service"
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
                    DomainName = 'zx.ac.uk'
                    RetryCount = 30
                    RetryIntervalSec = 45
                    PSDscAllowPlainTextPassword = $true
                    NIC = 'Ethernet0'
                    AddressFamily = 'IPV4'
                    PSDscAllowDomainUser = $true
                },
        
                @{
                    Nodename = "zxads1"
                    Role = "Primary DC"
                    IPAddress = "131.200.2.15"
                    HostName = "zxads1"
                },
        
                @{
                    Nodename = "zxads2"
                    Role = "Replica DC"
                    IPAddress = "131.200.2.20"
                    HostName = "zxads2"
                }
            )
        }

AssertHADC -ConfigurationData $ConfigData -OutputPath C:\DSCResource\lab\Config -Verbose

#$creds = Get-Credential
#Start-DscConfiguration -path .\config -wait -verbose -credential $Creds