# A configuration to Create High Availability Domain Controller
# This configuration is for standing up a new domain over two DC's
# RDP will be Enabled, IE Enhanced Security will be disabled
# 


configuration Domain_Controllers
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
    
    #Install-Module -Name xActiveDirectory,xNetworking,xComputerManagement,xPSDesiredStateConfiguration,xRemoteDesktopAdmin -verbose
    Import-DscResource -ModuleName xActiveDirectory,xNetworking,xComputerManagement,PSDesiredStateConfiguration,xPSDesiredStateConfiguration,xRemoteDesktopAdmin
    
    Node $AllNodes.Where{$_.Role -eq "Primary DC"}.Nodename
    {

        xRemoteDesktopAdmin RemoteDesktopSettings
        {
           Ensure = 'Present'
           UserAuthentication = 'Secure'
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
                    }
                )
            }

$OutPutPath = "C:\Users\dyeo\OneDrive - Imperial College London\DesiredStateConfiguration\Testing\Active_Directory_Domain_Services\Config"


Domain_Controllers -ConfigurationData $ConfigData -OutputPath $OutPutPath -Verbose

$creds = $null
#$creds = Get-Credential
#$OutPutPath = "C:\Users\dyeo\OneDrive - Imperial College London\DesiredStateConfiguration\Testing\Active_Directory_Domain_Services\Config"
#Start-DscConfiguration -path $OutPutPath -wait -verbose -credential $Creds