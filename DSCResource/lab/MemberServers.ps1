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
                    DomainName = 'dsclab.local'
                    RetryCount = 30
                    RetryIntervalSec = 90
                    PSDscAllowPlainTextPassword = $true
                    NIC = 'Ethernet0'
                    AddressFamily = 'IPV4'
                    PSDscAllowDomainUser = $true
                },
        
                @{
                    Nodename = "DSCLABS1"
                    Role = "MemberServer"
                    HostName = "DSCLABS1"
                },
        
                @{
                    Nodename = "DSCLABS2"
                    Role = "MemberServer"
                    HostName = "DSCLABS2"
                }

                @{
                    Nodename = "DSCLABS3"
                    Role = "MemberServer"
                    HostName = "DSCLABS3"
                }

                @{
                    Nodename = "DSCLABS4"
                    Role = "MemberServer"
                    HostName = "DSCLABS4"
                }
            )
        }

MemberServers -ConfigurationData $ConfigData -OutputPath C:\GIT\DesiredStateConfiguration\DSCResource\lab\MemberServers\Config -Verbose

#$creds = Get-Credential
#Start-DscConfiguration -path .\config -wait -verbose -credential $Creds