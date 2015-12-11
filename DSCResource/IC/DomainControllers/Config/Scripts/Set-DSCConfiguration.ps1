#$Computername = (Get-ADDomainController -Filter *).name
$Computername = 'ICADS39' #'','',

configuration DomainControllers {

        Import-DscResource –ModuleName ’PSDesiredStateConfiguration’

        Node $computername
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
            Arguments = 'DEPLOYMENT_SERVER="splunkdep1.cc.ic.ac.uk:8089" AGREETOLICENSE=Yes' # /quiet' # args for silent mode
            DependsOn = "[File]CopyMSI"
        }
        WindowsFeature TelnetServer{
            Name = 'Telnet-Server'
            Ensure = 'Present'
        }
        WindowsFeature TelnetClient{
            Name = 'Telnet-Client'
            Ensure = 'Present'
        }
        WindowsFeature RemoteDiffentialCompression{
            Name = 'RDC'
            Ensure = 'Present'
        }
        WindowsFeature DSCService{
            Name = 'DSC-Service'
            Ensure = 'Present'
        }
        WindowsFeature WINSServerTools{
            Name = 'RSAT-WINS'
            Ensure = 'Present'
        }
         WindowsFeature FileServicesTools{
            Name = 'RSAT-File-Services'
            Ensure = 'Present'
        }
         WindowsFeature ManagementODataIISExtension{
            Name = 'ManagementOdata'
            Ensure = 'Present'
        }
         WindowsFeature SNMPService{
            Name = 'SNMP-Service'
            Ensure = 'Present'
        }
         WindowsFeature SNMPWMIProvider{
            Name = 'SNMP-WMI-Provider'
            Ensure = 'Present'
        }
        WindowsFeature GroupPolicyManagement{
            Name = 'GPMC'
            Ensure = 'Present'
        }
        WindowsFeature DFSNamespace{
            Name = 'FS-DFS-Namespace'
            Ensure = 'Present'
        }
        WindowsFeature DFSReplication{
            Name = 'FS-DFS-Replication'
            Ensure = 'Present'
        }
        WindowsFeature FileServer{
            Name = 'FS-FileServer'
            Ensure = 'Present'
        }
        WindowsFeature ADDS{
            Name = 'AD-Domain-Services'
            Ensure = 'Present'
        }
        WindowsFeature WebServer{
            Name = 'Web-WebServer'
            Ensure = 'Present'
        }
        WindowsFeature DFSManagementTools{
            Name = 'RSAT-DFS-Mgmt-Con'
            Ensure = 'Present'
        }
        Registry IEEnhanchedSecurity{
        # When "Present" then "IE Enhanced Security" will be "Disabled"
        Ensure = "Present"
        Key = "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A7-37EF-4b3f-8CFC-4F3A74704073}"
        ValueName = "IsInstalled"
        ValueType = "DWord"
        ValueData = "0"
        }
    }
}
     
DomainControllers -OutputPath \\ic\infrastructure\DSCResource\IC\DomainControllers\Config
#$creds = Get-Credential
#Start-DscConfiguration -ComputerName $computername -Path \\ic\infrastructure\DSCResource\IC\DomainControllers\Config -wait -verbose -force