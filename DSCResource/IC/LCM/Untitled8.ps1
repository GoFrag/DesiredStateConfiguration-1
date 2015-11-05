$Computername = 'icads38','icads41','icads45'

Install-Module xDisk -Force -verbose | Import-Module xDisk


configuration DomainControllers {
    Node $computername {
        WindowsFeature TelnetServer{
            Name = 'Telnet-Server'
            Ensure = 'Present'
        }
        WindowsFeature TelnetClient{
            Name = 'Telnet-Client'
            Ensure = 'Present'
        }
        #WindowsFeature ActiveDirectoryDomainServices{
        #    Name = 'AD-Domain-Services'
        #    Ensure = 'Present'
        #}
        #WindowsFeature DNSServer{
        #    Name = 'DNS'
        #    Ensure = 'Present'            
        #}
        #WindowsFeature GroupPolicyManagement{
        #    Name = 'GPMC'
        #    Ensure = 'Present'
        #}
        WindowsFeature RemoteDiffentialCompression{
            Name = 'RDC'
            Ensure = 'Present'
        }
        WindowsFeature DSCService{
            Name = 'DSC-Service'
            Ensure = 'Present'
        }
        #WindowsFeature RemoteServerAdministrationTools{
        #    Name = 'RSAT'
        #    Ensure = 'Present'
        #    IncludeAllSubFeature = 'True'
        #    DependsOn = 'ActiveDirectoryDomainServices'
        }
     
        xWaitforDisk Disk2
        {
             DiskNumber = 2
             RetryIntervalSec = 60
             Count = 60
        }
        xDisk GVolume
        {
             DiskNumber = 2
             DriveLetter = 'G'
        }
    }
}
 
DataDisk -outputpath C:\DataDisk

    }
}


DomainControllers -OutputPath c:\DSCResource\Config

Remove-WindowsFeature DSC-Service -Remove

restart