# A configuration to Join MemberServers to Domain
configuration MemberServers
{
   param
    (
        [Parameter(Mandatory)]
        [pscredential]$domainCred
	    )
    
    Install-Module -Name xActiveDirectory,xNetworking,xComputerManagement -Force
    Import-DscResource -ModuleName xActiveDirectory,xNetworking,xComputerManagement,PSDesiredStateConfiguration
    
    Node $AllNodes.Where{$_.Role -eq "MemberServer"}.Nodename
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
                    RetryIntervalSec = 90
                    PSDscAllowPlainTextPassword = $true
                    NIC = 'Ethernet0'
                    AddressFamily = 'IPV4'
                    PSDscAllowDomainUser = $true
                },
        
                @{
                    Nodename = "DSCLABS01"
                    Role = "MemberServer"
                    HostName = "DSCLABS01"
                },
        
                @{
                    Nodename = "DSCLABS02"
                    Role = "MemberServer"
                    HostName = "DSCLABS02"
                }

                @{
                    Nodename = "DSCLABS03"
                    Role = "MemberServer"
                    HostName = "DSCLABS03"
                }

                @{
                    Nodename = "DSCLABS04"
                    Role = "MemberServer"
                    HostName = "DSCLABS04"
                }
            )
        }

MemberServers -ConfigurationData $ConfigData -OutputPath C:\GIT\DesiredStateConfiguration\DSCResource\lab\MemberServers\Config -Verbose

#$creds = Get-Credential
#Start-DscConfiguration -path .\config -wait -verbose -credential $Creds