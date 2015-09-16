$computername = (Get-ADDomainController -filter *).name

Configuration DCPackages{

    Node $computername{

        Package adreplstatusInstaller{
            Ensure = 'Present'  # You can also set Ensure to "Absent'
            Path  = '\\iclondon\sysvol\iclondon.org.uk\Apps\ADReplStatus\adreplstatusInstaller.msi'
            Name = 'AD Replication Status Tool 1.0'
            #ProductId = '7FCB1973-7847-4D8A-A114-356FD406071B'
            ProductId = 'EEC6F66A-3D90-450A-B177-FFF3A1DA82E9'
        }
    }
}

DCPackages -OutputPath C:\dscr
#DCPackages -OutputPath "\\icdev\SYSVOL\icdev.ic.ac.uk\DSCResource\Packages"

foreach($computer in $computername){
Start-DscConfiguration -Path "\\iclondon\SYSVOL\iclondon.org.uk\DSCResource\Packages" -ComputerName $computer -Verbose -wait -Force
}