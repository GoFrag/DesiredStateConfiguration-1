
workflow DifferencingDisks {

    param(

            [string[]]$DifferencingDisks,
            [string]$switch = 'NAT'
        
        )

    foreach -parallel($Member in $DifferencingDisks){

      $vm = InlineScript{

            New-VHD -ParentPath "v:\Library\W2K12R2-Master-Diff.vhdx" -Path "v:\Hyper-V\Virtual Hard Disks\$using:Member\$using:Member.vhdx" -CimSession cc-dyeo -Differencing -SizeBytes 40Gb
            New-VM -VMName $using:Member -Generation 2 -VHDPath "v:\Hyper-V\Virtual Hard Disks\$using:Member\$using:Member.vhdx" -SwitchName $using:switch -CimSession cc-dyeo
            Set-VM -Name $using:Member -ProcessorCount 2 -DynamicMemory -MemoryMinimumBytes 512MB -MemoryMaximumBytes 2GB -CimSession cc-dyeo
            Start-VM  -Name $using:Member -CimSession cc-dyeo
            Stop-VM -Name $using:Member -CimSession cc-dyeo -TurnOff -Force

            }

        $vm.Member

    }
}

workflow FullDisks {

    param(

            [string[]]$FullDisks,
            [string]$switch = 'NAT'

            )

    foreach -parallel($DC in $Fulldisks){

      $vm = InlineScript{

            New-Item -Path "\\cc-dyeo\v$\Hyper-V\Virtual Hard Disks\$using:DC" -ItemType Directory -Force
            Copy-Item -Destination "\\cc-dyeo\v$\Hyper-V\Virtual Hard Disks\$using:DC\$using:DC.vhdx" -Path "\\cc-dyeo\v$\Library\W2K12R2-Master.vhdx"
            New-VM -cimsession cc-dyeo -VMName $using:DC -Generation 2 -VHDPath "v:\Hyper-V\Virtual Hard Disks\$using:DC\$using:DC.vhdx" -SwitchName $using:switch 
            Set-VM -CimSession cc-dyeo -Name $using:DC -ProcessorCount 2 -DynamicMemory -MemoryMinimumBytes 512MB -MemoryMaximumBytes 2GB
            Start-VM  -Name $using:dc -CimSession cc-dyeo
            Stop-VM -Name $using:dc -CimSession cc-dyeo -TurnOff -Force
        
            }

        $vm.DC
    }
}

$FullDisks = $null
$DifferencingDisks = $null

$FullDisks = 'DSCLabDC01','DSCLabDC02'
$DifferencingDisks = 'DSCLabS01','DSCLabS02','DSCLabS03','DSCLabS04','DSCLabPull01'

DifferencingDisks -DifferencingDisks DSCLabS03
#FullDisks -FullDisks $FullDisks