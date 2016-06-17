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

        xDscWebService PSDSCPullServerProd
        {
            Ensure                  = "Present"
            EndpointName            = "PSDSCPullServerProd"
            Port                    = '8080'
            PhysicalPath            = "$env:SystemDrive\inetpub\wwwroot\PSDSCPullServerProd"
            CertificateThumbPrint   = "AllowUnencryptedTraffic"
            ModulePath              = "$env:PROGRAMFILES\WindowsPowerShell\DscService\Modules"
            ConfigurationPath       = "$env:PROGRAMFILES\WindowsPowerShell\DscService\Configuration\Prod"
            State                   = "Started"
            DependsOn               = ("[WindowsFeature]DSCService","[WindowsFeature]IIS")
        }

        xDscWebService PSDSCComplianceServerProd
        {
            Ensure                  = "Present"
            EndpointName            = "PSDSCComplianceServerProd"
            Port                    = '8090'
            PhysicalPath            = "$env:SystemDrive\inetpub\wwwroot\PSDSCComplianceServerProd"
            CertificateThumbPrint   = "AllowUnencryptedTraffic"
            State                   = "Started"
            IsComplianceServer      = $true
            DependsOn               = "[xDSCWebService]PSDSCPullServerProd"
        }

        xDscWebService PSDSCPullServerDev
        {
            Ensure                  = "Present"
            EndpointName            = "PSDSCPullServerDev"
            Port                    = '8100'
            PhysicalPath            = "$env:SystemDrive\inetpub\wwwroot\PSDSCPullServerDev"
            CertificateThumbPrint   = "AllowUnencryptedTraffic"
            ModulePath              = "$env:PROGRAMFILES\WindowsPowerShell\DscService\Modules"
            ConfigurationPath       = "$env:PROGRAMFILES\WindowsPowerShell\DscService\Configuration\Dev"
            State                   = "Started"
            DependsOn               = ("[WindowsFeature]DSCService","[WindowsFeature]IIS")
        }

        xDscWebService PSDSCComplianceServerDev
        {
            Ensure                  = "Present"
            EndpointName            = "PSDSCComplianceServerDev"
            Port                    = '8110'
            PhysicalPath            = "$env:SystemDrive\inetpub\wwwroot\PSDSCComplianceServerDev"
            CertificateThumbPrint   = "AllowUnencryptedTraffic"
            State                   = "Started"
            IsComplianceServer      = $true
            DependsOn               = "[xDSCWebService]PSDSCPullServerDev"
        }

        xDscWebService PSDSCPullServerTest
        {
            Ensure                  = "Present"
            EndpointName            = "PSDSCPullServerTest"
            Port                    = '8120'
            PhysicalPath            = "$env:SystemDrive\inetpub\wwwroot\PSDSCPullServerTest"
            CertificateThumbPrint   = "AllowUnencryptedTraffic"
            ModulePath              = "$env:PROGRAMFILES\WindowsPowerShell\DscService\Modules"
            ConfigurationPath       = "$env:PROGRAMFILES\WindowsPowerShell\DscService\Configuration\Test"
            State                   = "Started"
            DependsOn               = ("[WindowsFeature]DSCService","[WindowsFeature]IIS")
        }

        xDscWebService PSDSCComplianceServerTest
        {
            Ensure                  = "Present"
            EndpointName            = "PSDSCComplianceServerTest"
            Port                    = '8130'
            PhysicalPath            = "$env:SystemDrive\inetpub\wwwroot\PSDSCComplianceServerTest"
            CertificateThumbPrint   = "AllowUnencryptedTraffic"
            State                   = "Started"
            IsComplianceServer      = $true
            DependsOn               = "[xDSCWebService]PSDSCPullServerTest"
        }
    }
}

HTTPPullServer -OutputPath "C:\Users\dyeo\OneDrive - Imperial College London\DesiredStateConfiguration\Testing\HTTP_PullServers\Config" -Verbose

#$creds = $null
$creds = Get-Credential
Start-DscConfiguration -path "C:\Users\dyeo\OneDrive - Imperial College London\DesiredStateConfiguration\Testing\HTTP_PullServers\Config" -wait -verbose -credential $Creds -force

