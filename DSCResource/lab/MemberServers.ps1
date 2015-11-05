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
                    Nodename = "S1"
                    Role = "MemberServer"
                    HostName = "S1"
                },
        
                @{
                    Nodename = "S2"
                    Role = "MemberServer"
                    HostName = "S2"
                }

                @{
                    Nodename = "S3"
                    Role = "MemberServer"
                    HostName = "S3"
                }

                @{
                    Nodename = "S4"
                    Role = "MemberServer"
                    HostName = "S4"
                }
            )
        }

MemberServers -ConfigurationData $ConfigData -OutputPath C:\DSCResource\lab\MemberServers\Config -Verbose

#$creds = Get-Credential
#Start-DscConfiguration -path .\config -wait -verbose -credential $Creds