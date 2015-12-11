Configuration SplunkForwarder
{
    Import-DscResource –ModuleName ’PSDesiredStateConfiguration'
    Node $Computername
        {
            File CopyMSI{
                SourcePath = '\\ic\infrastructure\DSCResource\IC\DomainControllers\Applications\splunkforwarder-6.3.1-f3e41e4b37b2-x64-release.msi'
                DestinationPath = "C:\ic-utils\"
                Type = "File"
                Force = $True
                MatchSource = $true
            } 
            Package SplunkInstaller{
                Ensure = "Present"
                Name = "UniversalForwarder"
                Path = 'C:\ic-utils\splunkforwarder-6.3.1-f3e41e4b37b2-x64-release.msi'
                ProductId = ''
                Arguments = 'DEPLOYMENT_SERVER="splunkdep1.cc.ic.ac.uk:xxx8089" AGREETOLICENSE=Yes' # /quiet' # args for silent mode
                DependsOn = "[File]CopyMSI"
        }
    }
}

$Computername = 'icads40' #'ICADS37','ICADS45'#'ICADS41','ICADS45','ICADS38'

SplunkForwarder -OutputPath \\ic\infrastructure\DSCResource\IC\DomainControllers\Applications
#Start-DscConfiguration -ComputerName $computername -Path \\ic\infrastructure\DSCResource\IC\DomainControllers\Applications -wait -verbose #-force
