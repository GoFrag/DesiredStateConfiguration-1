$hostsrv = 'cc-dyeo'
$ParentVHD = 'v:\Library\W2K12R2-Master-Diff.vhdx'
$NewVHDPath = 'V:\Hyper-V\Virtual Hard Disks'
$RemotePath = "\\$hostsrv\V$\Hyper-V\Virtual Hard Disks"
$vms =  '1','2','3','4','5','6' #'DSCLabS01','DSCLabS02','DSCLabS03','DSCLabS04' ,'DSCLabPull01'
$vmsfull = 'DSCLabDC01','DSCLabDC02'
$switch = 'NAT'

foreach ($vm in $vms){ #Differencing Disk

New-VHD -ParentPath v:\Library\W2K12R2-Master-Diff.vhdx -Path "v:\Hyper-V\Virtual Hard Disks\$vm\$vm.vhdx" -ComputerName $hostsrv -Differencing -SizeBytes 40Gb
    New-VM -ComputerName $hostsrv -VMName $vm -Generation 2 -VHDPath "v:\Hyper-V\Virtual Hard Disks\$vm\$vm.vhdx" -SwitchName $switch
    Set-VM -ComputerName $hostsrv -Name $vm -ProcessorCount 2 -DynamicMemory -MemoryMinimumBytes 512MB -MemoryMaximumBytes 2GB -Passthru

    }
foreach ($vm in $vmsfull){    

####### New VM #######
New-VHD -ParentPath v:\Library\W2K12R2-Master-Diff.vhdx -Path "v:\Hyper-V\Virtual Hard Disks\$vm\$vm.vhdx" -ComputerName $hostsrv -Differencing -SizeBytes 40Gb
New-VM -ComputerName $hostsrv -VMName $vm -Generation 2 -VHDPath "v:\Hyper-V\Virtual Hard Disks\$vm\$vm.vhdx" -SwitchName $switch
Set-VM -ComputerName $hostsrv -Name $vm -ProcessorCount 2 -DynamicMemory -MemoryMinimumBytes 512MB -MemoryMaximumBytes 2GB -Passthru
}


#Get-vm -ComputerName cc-dyeo -Name DSCLab* | Sort VMName | Start-vm  -Verbose -Confirm:$false -Passthru
#Get-vm -ComputerName cc-dyeo -Name DSCLab* | Sort VMName |Stop-VM -TurnOff -Force -Confirm:$false -Passthru
#Get-VMNetworkAdapter -ComputerName cc-dyeo -VMName DSCLab* | select VMName,MacAddress | Sort VMName


<#
Foreach ($Full in $vmsfull){

New-Item -Path "\\cc-dyeo\v$\Hyper-V\Virtual Hard Disks\$full" -ItemType Directory -Force
Copy-Item -Destination "\\cc-dyeo\v$\Hyper-V\Virtual Hard Disks\$full\$full.vhdx" -Path "\\cc-dyeo\v$\Library\W2K12R2-Master.vhdx" -Force
New-VM -ComputerName $hostsrv -VMName $full -Generation 2 -VHDPath "v:\Hyper-V\Virtual Hard Disks\$full\$full.vhdx" -SwitchName $switch
Set-VM -ComputerName $hostsrv -Name $full -ProcessorCount 2 -DynamicMemory -MemoryMinimumBytes 512MB -MemoryMaximumBytes 2GB -Passthru
}



 
}


#>


#Invoke-Command -ComputerName cc-dyeo -ScriptBlock {Copy-Item -Path v$\Library\W2K12R2-Master.vhdx -Destination v$\Hyper-V\Virtual Hard Disks\$full\$full.vhdx}