
$baseVhdPath = 'd:\Hyper-V\Virtual Hard Disks\'
$VMSwitchName = 'NAT'

Configuration NewVM {
      
    param (
        [Parameter(Mandatory)]
        [string]$VMName
        #[Parameter(Mandatory)]
        #[string]$baseVhdPath,
        #[Parameter(Mandatory)]
        #[string]$ParentPath,
        #[Parameter(Mandatory)]
        #[string]$VMSwitchName
        )

    Import-DscResource -module xHyper-V,PSDesiredStateConfiguration

    Node cc-dyeo

{    
    xVMSwitch vmswitch {
        Name = $VMSwitchName
        Ensure = 'Present'
        Type = 'Private'
        }

    xVHD NewHD {
        Ensure = 'Present'
        Name = $VMName
        Path = $baseVhdPath
        MaximumSizeBytes = 40Gb
        Generation = 'Vhdx'
        }

    xVMHyperV CreateVM {
        Name = $VMName
        SwitchName = $VMSwitchName
        VhdPath = "$baseVhdPath\$VMName.vhdx"
        ProcessorCount = 1
        MaximumMemory = 2GB
        MinimumMemory = 512MB
        RestartIfNeeded = $True
        DependsOn = '[xVHD]NewHD','[xVMSwitch]vmswitch'
        State = 'Off'
        Generation = '2'
        }
    }
}

NewVM -OutputPath C:\GIT\DesiredStateConfiguration\DSCResource\lab\Hyper-V\Config -Verbose
Start-DscConfiguration -path C:\GIT\DesiredStateConfiguration\DSCResource\lab\Hyper-V\Config -wait -verbose -Force