$hostsrv = 'cc-dyeo'
$ParentVHD = 'v:\Library\W2K12R2-Master-Diff.vhdx'
$NewVHDPath = 'V:\Hyper-V\Virtual Hard Disks'
$RemotePath = "\\$hostsrv\V$\Hyper-V\Virtual Hard Disks"
$vms = 'DSCLabDC01','DSCLabDC02','DSCLabS01','DSCLabS02','DSCLabS03','DSCLabS04','DSCLabPull01'
$switch = 'NAT'

foreach ($vm in $vms){

####### New VM #######
New-VM -ComputerName $hostsrv -Name $vm -NewVHDPath "$NewVHDPath\$vm\$vm.vhdx" -NewVHDSizeBytes 40Gb -MemoryStartupBytes 1Gb -SwitchName $switch -Generation 2 | Set-VM -ProcessorCount 2 -DynamicMemory -MemoryMinimumBytes 512MB -MemoryMaximumBytes 2GB -Passthru | Add-VMDvdDrive -Path 'v:\Library\SW_DVD9_Windows_Svr_Std_and_DataCtr_2012_R2_64Bit_English_-3_MLF_X19-53588.ISO' | Start-VM
Get-VM –Computername cc-dyeo | Get-VMNetworkAdapter | ft VMName, MACAddress ,ComputerName

Get-VM –Computername cc-dyeo | Where State -eq off | Start-VM



#Invoke-command -ComputerName $vm -Credential $creds {Set-DnsClientServerAddress -InterfaceAlias "Ethernet 2" -ServerAddresses ("8.8.8.8","8.8.4.4")}
#Invoke-command -ComputerName $vm -Credential $creds {Install-Module -Name xActiveDirectory,xNetworking,xComputerManagement,xPSDesiredStateConfiguration -Force -verbose}
#Invoke-command -ComputerName $vm -Credential $creds {Set-DnsClientServerAddress -InterfaceAlias "Ethernet 2" -ResetServerAddresses}

<####### Complete Removal #######
Remove-Item -Recurse -Force -verbose -Path $RemotePath\$vm
Get-VM -ComputerName $hostsrv -Name $vm | Remove-VM -Force -verbose #>

}