$hostsrv = 'cc-dyeo'
$ParentVHD = 'd:\MasterDisks\W2K12R2-Master-Diff.vhdx'
$NewVHDPath = 'D:\Hyper-V\Virtual Hard Disks'
$RemotePath = "\\$hostsrv\D$\Hyper-V\Virtual Hard Disks"
$vms = 'DSCLabS01','DSCLabS02','DSCLabS03','DSCLabS04'
$switch = 'NAT'

foreach ($vm in $vms){
        
    ####### New VM #######
    New-VM -ComputerName $hostsrv -Name $vm -VHDPath (New-VHD -ParentPath $ParentVhd -Path "$NewVHDPath\$vm\$vm.vhdx" -ComputerName $hostsrv -Differencing -SizeBytes 40Gb).Path -MemoryStartupBytes 512MB -SwitchName $switch -Generation 2 | Set-VM -ProcessorCount 2 -DynamicMemory -MemoryMinimumBytes 512MB -MemoryMaximumBytes 2GB -Passthru
    # Get-VM –Computername $hostsrv | Get-VMNetAdapter | ft VMName, MACAddress ,ComputerName
    # Get-VMNetworkAdapter -All -ComputerName cc-dyeo | ft VMName, MacAddress
    # Start-VM -ComputerName $hostsrv -Name $vm -Passthru

    <####### Complete Removal #######
    Remove-Item -Recurse -Force -verbose -Path $RemotePath\$vm
    Get-VM -ComputerName $hostsrv -Name $vm | Remove-VM -Force -verbose #>

}