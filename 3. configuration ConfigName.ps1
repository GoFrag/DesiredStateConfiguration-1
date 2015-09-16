$computername = (Get-ADDomainController -filter *).name

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
        WindowsFeature ActiveDirectoryDomainServices{
            Name = 'AD-Domain-Services'
            Ensure = 'Present'
        }
        WindowsFeature DNSServer{
            Name = 'DNS'
            Ensure = 'Present'            
        }
        WindowsFeature GroupPolicyManagement{
            Name = 'GPMC'
            Ensure = 'Present'
        }
        WindowsFeature RemoteDiffentialCompression{
            Name = 'RDC'
            Ensure = 'Present'
        }
        WindowsFeature RemoteServerAdministrationTools{
            Name = 'RSAT'
            Ensure = 'Present'
            #IncludeAllSubFeature = 'True'
            DependsOn = 
        }
    }
}


DomainControllers -OutputPath c:\DSCResource\Config

Remove-WindowsFeature DSC-Service -Remove

restart