$hostsrv = 'cc-dyeo'
$ParentVHD = 'v:\Library\W2K16TP4-Master-Diff.vhdx'
$NewVHDPath = 'V:\Hyper-V\Virtual Hard Disks'
$RemotePath = "\\$hostsrv\V$\Hyper-V\Virtual Hard Disks"
$vms = 'DSCLabS01','DSCLabS02','DSCLabS03','DSCLabS04' #,'DSCLabPull01'
$vmsfull = 'DSCLabDC01','DSCLabDC02'
$switch = 'NAT'

foreach ($vm in $vms){ #Differencing Disk

####### New VM #######
New-VHD -ParentPath v:\Library\W2K16TP4-Master-Diff.vhdx -Path "v:\Hyper-V\Virtual Hard Disks\$vm\$vm.vhdx" -ComputerName $hostsrv -Differencing -SizeBytes 40Gb
New-VM -ComputerName $hostsrv -VMName $vm -Generation 2 -VHDPath "v:\Hyper-V\Virtual Hard Disks\$vm\$vm.vhdx" -SwitchName $switch
Set-VM -ComputerName $hostsrv -Name $vm -ProcessorCount 2 -DynamicMemory -MemoryMinimumBytes 512MB -MemoryMaximumBytes 2GB -Passthru
}

Foreach ($Full in $vmsfull){

New-Item -Path "\\cc-dyeo\v$\Hyper-V\Virtual Hard Disks\$full" -ItemType Directory -Force
Copy-Item -Destination "\\cc-dyeo\v$\Hyper-V\Virtual Hard Disks\$full\$full.vhdx" -Path "\\cc-dyeo\v$\Library\W2k16TP4-Master.vhdx" -Force
New-VM -ComputerName $hostsrv -VMName $full -Generation 2 -VHDPath "v:\Hyper-V\Virtual Hard Disks\$full\$full.vhdx" -SwitchName $switch
Set-VM -ComputerName $hostsrv -Name $full -ProcessorCount 2 -DynamicMemory -MemoryMinimumBytes 512MB -MemoryMaximumBytes 2GB -Passthru
}


#Invoke-Command -ComputerName cc-dyeo -ScriptBlock {Copy-Item -Path v$\Library\W2k16TP4-Master.vhdx -Destination v$\Hyper-V\Virtual Hard Disks\$full\$full.vhdx}