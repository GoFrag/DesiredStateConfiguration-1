configuration HTTPPullServer
{
    
    Import-DscResource -ModuleName PSDesiredStateConfiguration,xPSDesiredStateConfiguration,xRemoteDesktopAdmin
   
    Node "DSCLABPull01" #$AllNodes.Where{$_.Role -eq "Pull Server"}.Nodename
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

HTTPPullServer -OutputPath "C:\Users\dyeo\OneDrive - Imperial College London\DesiredStateConfiguration\Testing\HTTP_PullServers\Config" -Verbose

#$creds = $null
#$creds = Get-Credential
#
