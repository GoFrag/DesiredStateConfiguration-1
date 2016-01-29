configuration Application_Servers
{
    param
    (
        [Parameter(Mandatory)]
        [pscredential]$domainCred
	    )
    
    Import-DscResource -ModuleName xActiveDirectory,xNetworking,xComputerManagement,PSDesiredStateConfiguration,xPSDesiredStateConfiguration
    
    Node $ComputerName
    {

        Registry EdgeAsAdmin
        {
            Ensure = "Present"
            Key = "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"
            ValueName = "FilterAdministratorToken"
            ValueData = "1"
            ValueType = "Dword"
        }
        
        WindowsFeature RemoteDifferentialCompression
        {
            Ensure = "Present"
            Name = "RDC"
        }
        
        xWaitForADDomain DscForestWait
        {
            DomainName = 'DSCLab.local'
            DomainUserCredential = $domainCred
            RetryCount = 30
            RetryIntervalSec = 120
            DependsOn = "[WindowsFeature]RSATADPoSH"
        }
        
        xComputer JoinDomain 
        { 
            Name = $node.NodeName
            DomainName = 'DSCLab.local'
            Credential = $domainCred  # Credential to join to domain
        }   

        WindowsFeature RSATADPoSH
        {
            Ensure = "Present"
            Name = "RSAT-AD-Powershell"
        }
    }
}

$ConfigData= @{ 
    AllNodes = @(     
                @{
                NodeName = '*'
                PSDscAllowPlainTextPassword = $true
                PSDscAllowDomainUser = $true
                },
                
                @{
                Nodename = "DSCLABS01"
                },
                @{
                Nodename = "DSCLABS02"
                },
                @{
                Nodename = "DSCLABS03"
                },
                @{
                Nodename = "DSCLABS04"
                }
            )
        }

#$ComputerName = 'DSCLABS01','DSCLABS02','DSCLABS03','DSCLABS04'

Application_Servers  -ConfigurationData $ConfigData -OutputPath "C:\Users\dyeo\OneDrive - Imperial College London\DesiredStateConfiguration\Testing\Application_Servers\Config" -Verbose

#$creds = $null
#$creds = Get-Credential
#Start-DscConfiguration -path "C:\Users\dyeo\OneDrive - Imperial College London\DesiredStateConfiguration\Testing\Application_Servers\Config" -wait -verbose -credential $Creds -force