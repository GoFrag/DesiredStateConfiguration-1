# A configuration to Join MemberServers to Domain
configuration MemberServers
{
   param
    (
        [Parameter(Mandatory)]
        [pscredential]$domainCred
	    )
        
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
            Name          = $node.NodeName
            DomainName    = $Node.DomainName 
            Credential    = $domainCred  # Credential to join to domain 
        }   
                
        WindowsFeature RemoteDifferentialCompression
        {
            Ensure = "Present"
            Name = "RDC"
        }
    }
}

$ConfigData = @{
    AllNodes = @(
                @{
                    Nodename = '*'
                    DomainName = 'dsclab.local'
                    RetryCount = 30
                    RetryIntervalSec = 90
                    PSDscAllowPlainTextPassword = $true
                    PSDscAllowDomainUser = $true
                },
        
                @{
                    Nodename = "DSCLABS01"
                    Role = "MemberServer"
                },
        
                @{
                    Nodename = "DSCLABS02"
                    Role = "MemberServer"
                },

                @{
                    Nodename = "DSCLABS03"
                    Role = "MemberServer"
                },

                @{
                    Nodename = "DSCLABS04"
                    Role = "MemberServer"
                }
            )
        }

$path = "C:\Users\dyeo\OneDrive - Imperial College London\DesiredStateConfiguration\Testing\Application_Servers\Config"

MemberServers -ConfigurationData $ConfigData -OutputPath $path -Verbose

#$creds = Get-Credential
#Start-DscConfiguration -path $path -wait -verbose -credential $Creds