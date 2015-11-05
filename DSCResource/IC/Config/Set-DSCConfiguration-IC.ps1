$Computername = (Get-ADDomainController -Filter *).name

configuration DomainControllers {

        Import-DscResource –ModuleName ’PSDesiredStateConfiguration’

        Node $computername {
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
    }
}
     
DomainControllers -OutputPath \\ic\infrastructure\DSCResource\IC\DomainControllers\Config
#Start-DscConfiguration -ComputerName $Computername -Path c:\DSCResource\IC\Config -wait -verbose