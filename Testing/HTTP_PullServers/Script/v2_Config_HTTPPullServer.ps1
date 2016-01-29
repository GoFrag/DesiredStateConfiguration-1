
Configuration V2PullServer
{

    Import-DscResource -ModuleName xPsDesiredStateConfiguration,xWebAdministration,PSDesiredStateConfiguration

    node DSCLabPull01
    {
        WindowsFeature DSCServiceFeature
        {
            Ensure = "Present"
            Name   = "DSC-Service"            
        }

        xDscWebService PSDSCPullServer
        {
            Ensure                       = "Present"
            EndpointName                 = "PSDSCService"
            PhysicalPath                 = "c:\inetpub\PullServer"
            State                        = "Started"
            DependsOn                    = "[WindowsFeature]DSCServiceFeature"
            CertificateThumbPrint        = "AllowUnencryptedTraffic"
        }

        File RegistrationKeyFile
        {
            Ensure           ='Present'
            Type             = 'File'
            DestinationPath  = "$env:ProgramFiles\WindowsPowerShell\DscService\RegistrationKeys.txt"
            Contents         = '9a28a925-18d9-4689-a591-5a0c53ab73b2'
        }

        #Install WebApp for managing Configurations / resources
        File AdminSite
        {
            Ensure          = 'Present'
            Type            = 'Directory'
            DestinationPath = 'c:\inetpub\DscAdmin'
        }
    
        xArchive SiteContents
        {
            Path            = 'c:\inetpub\temp\site.zip'
            Destination     = 'c:\inetpub\DscAdmin\'
            DestinationType = 'Directory'
        }

        xWebAppPool PSWS
        {
             Ensure                = 'Present'
             Name                  = 'PSWS'
             State                 = 'Started'
        }

        xWebApplication DscAdmin
        {
            Ensure          = 'Present'
            Name            = 'Admin'
            Website         = 'Default Web Site'
            PhysicalPath    = 'c:\Inetpub\DSCAdmin'
            WebAppPool      = 'PSWS'
        }
    }
}

V2PullServer -OutputPath "C:\Users\dyeo\OneDrive - Imperial College London\DesiredStateConfiguration\Testing\HTTP_PullServers\Config" -Verbose

#$creds = $null
#$creds = Get-Credential
#Start-DscConfiguration -path "C:\Users\dyeo\OneDrive - Imperial College London\DesiredStateConfiguration\Testing\HTTP_PullServers\Config" -wait -verbose -credential $Creds