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
    
    Node $AllNodes.Where{$_.Role -eq "Member Server"}.Nodename
    {
      
        xWaitForADDomain DscForestWait
        {
            DomainName = $Node.DomainName
            DomainUserCredential = $domainCred
            RetryCount = $Node.RetryCount
            RetryIntervalSec = $Node.RetryIntervalSec
        }
        
        xComputer JoinDomain 
        { 
            Name          = $node.HostName
            DomainName    = $Node.DomainName 
            Credential    = $domainCred  # Credential to join to domain 
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
                    DomainName = 'dsclab.local'
                    RetryCount = 30
                    RetryIntervalSec = 60
                    PSDscAllowPlainTextPassword = $true
                    NIC = 'Ethernet0'
                    AddressFamily = 'IPV4'
                    PSDscAllowDomainUser = $true
                },
        
                @{
                    Nodename = "DSCLABDC1"
                    Role = "Primary DC"
                    HostName = "DSCLABDC1"
                },
        
                @{
                    Nodename = "DSCLABDC2"
                    Role = "Replica DC"
                    HostName = "DSCLABDC2"
                },

                @{
                    Nodename = "DSCLABS1"
                    Role = "Member Server"
                    HostName = "DSCLABS1"
                },

                @{
                    Nodename = "DSCLABS2"
                    Role = "Member Server"
                    HostName = "DSCLABS2"
                },

                @{
                    Nodename = "DSCLABS3"
                    Role = "Member Server"
                    HostName = "DSCLABS3"
                },

                @{
                    Nodename = "DSCLABS4"
                    Role = "Member Server"
                    HostName = "DSCLABS4"
                }
            )
        }

DSCLab -ConfigurationData $ConfigData -OutputPath C:\GIT\DesiredStateConfiguration\DSCResource\lab\Config -Verbose

#$creds = Get-Credential
#Start-DscConfiguration -path C:\GIT\DesiredStateConfiguration\DSCResource\lab\config -wait -verbose -credential $Creds