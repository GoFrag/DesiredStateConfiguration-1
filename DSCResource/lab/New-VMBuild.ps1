$hostsrv = 'cc-dyeo'
$ParentVHD = 'v:\Library\W2K12R2-Master-Diff.vhdx'
$NewVHDPath = 'V:\Hyper-V\Virtual Hard Disks'
$RemotePath = "\\$hostsrv\V$\Hyper-V\Virtual Hard Disks"
$vms = 'DSCLabDC01','DSCLabDC02','DSCLabS01','DSCLabS02','DSCLabS03','DSCLabS04'
$switch = 'NAT'

 


foreach ($vm in $vms){

####### New VM #######
#Set-VM -ComputerName $hostsrv -Name $vm -DynamicMemory True -MemoryMaximumBytes 2Gb -MemoryMinimumBytes 512Mb -MemoryStartupBytes 1Gb -ProcessorCount 1}

Invoke-command -ComputerName $vm -Credential $creds {Set-DnsClientServerAddress -InterfaceAlias "Ethernet 2" -ServerAddresses ("8.8.8.8","8.8.4.4")}
Invoke-command -ComputerName $vm -Credential $creds {Install-Module -Name xActiveDirectory,xNetworking,xComputerManagement,xPSDesiredStateConfiguration -Force -verbose}
Invoke-command -ComputerName $vm -Credential $creds {Set-DnsClientServerAddress -InterfaceAlias "Ethernet 2" -ResetServerAddresses}
}

#New-VM -ComputerName $hostsrv -Name $vm -VHDPath (New-VHD -ParentPath $ParentVhd -Path "$NewVHDPath\$vm\$vm.vhdx" -ComputerName $hostsrv -Differencing -SizeBytes 40Gb).Path -MemoryStartupBytes 512MB -SwitchName $switch -Generation 2 | Set-VM -ProcessorCount 2 -DynamicMemory -MemoryMinimumBytes 512MB -MemoryMaximumBytes 2GB -Passthru
#New-VM -VHDPath "v:\Hyper-V\Virtual Hard Disks\DSCLabDC01\DSCLabDC01.vhdx" -Generation 2 -MemoryStartupBytes 1024MB -Name DSCLabDC01 -SwitchName nat -computername cc-dyeo
#New-VM -VHDPath "v:\Hyper-V\Virtual Hard Disks\DSCLabDC02\DSCLabDC02.vhdx" -Generation 2 -MemoryStartupBytes 1024MB -Name DSCLabDC02 -SwitchName nat -computername cc-dyeo

# Get-VM –Computername cc-dyeo | Get-VMNetworkAdapter | ft VMName, MACAddress ,ComputerName
# Get-VMNetworkAdapter -All -ComputerName cc-dyeo | ft VMName, MacAddress
# Start-VM -ComputerName $hostsrv -Name $vm -Passthru

<####### Complete Removal #######
Remove-Item -Recurse -Force -verbose -Path $RemotePath\$vm
Get-VM -ComputerName $hostsrv -Name $vm | Remove-VM -Force -verbose #>
}