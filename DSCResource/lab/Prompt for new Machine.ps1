$hvhost = 'cc-dyeo'
$vswitch = get-vmswitch -ComputerName $hvhost
$VPATH = get-vmhost
$VPATH | select virtualharddiskpath,virtualmachinepath | format-table -autosize
Write-Host -foreground "magenta" "This script will walk you through creating a new VM with a Fixed or  Dynamic Hard Disk"
Write-Host -foreground "magenta" "!!! If you do not see any paths listed above, this process will fail !!!"

#Ask for input
Write-Host -foreground "magenta" "-----------------------------------------------------------------"
$SelectedIndex = Read-Host "Type 0 to exit out of this Menu or Enter to Continue”
$Exit = $SelectedIndex

if($EXIT -eq 0)
{exit}
else {
Write-Host -foreground "magenta" "Type in what is asked for: DO NOT USE ANY Quotes to frame answers"
$SelectedIndex1 = Read-Host "New VM Name (TEST1)"
$SelectedIndex2 = Read-Host "RAM in GB (2)"
$SelectedIndex3 = Read-Host "vCPU Count (4)"
$SelectedIndex6 = Read-Host "Virtual hard Disk Size (70GB)"
$SelectedIndex7 = Read-Host "OS ISO file path (C:\iso\2008r2sp1.iso v:\Library\SW_DVD9_Windows_Svr_Std_and_DataCtr_2012_R2_64Bit_English_-3_MLF_X19-53588.ISO)"
Write-Host -foreground "magenta" ""

$1 = "\"
$2 = ".vhdx"
$3 = "\"
$NAME = $SelectedIndex1
$Name1 = $Name
$RAM = [int64]$SelectedIndex2 * 1073741824
$vCPU = $SelectedIndex3
$PATHVM1 = ($VPATH.virtualmachinepath)
$PATHVM = ($PATHVM1 += $1 += $NAME)
$newVHDPATH1 = ($VPATH.virtualharddiskpath)
$newVHDPATH = ($newVHDPATH1 += $1 += $3 +=$NAME1 += $2)
$newVHDsize = [int64]$SelectedIndex6 * 1073741824
$PATHDVD = $SelectedIndex7

#Ask for disk type selection
Write-host -foreground "magenta" "1. Fixed = Static"
Write-host -foreground "magenta" "2. Differencing = Dynamic"
Write-host -foreground "yellow" "NOTE: this step can take several minutes if you choose Fixed"
$SelectedIndex9 = Read-Host "**** Please select a Number For type of VHDx Disk ***"
$Selection = $SelectedIndex9
if($Selection -eq 1)
{New-VHD -Fixed -Path $newVHDPATH -SizeBytes $newVHDsize -ComputerName $hvhost}
elseif ($Selection -eq 2)
{New-VHD -Path $newVHDPATH -SizeBytes $newVHDsize -ComputerName $hvhost}

# create numbered array of vswitches
$i = 1
$vswitch | ForEach-Object {
                Write-Host "$i $($_.Name)”
                $i++
}

#Ask for number selection
Write-Host -foreground "magenta" ""
$SelectedVMIndex = Read-Host "**** Please select a Switch to attach the VM too ***”
$SelectedVMIndex = $SelectedVMIndex - 1
$SelectedVM = $vswitch[$SelectedVMIndex]
$vSwitch = $SelectedVM.name

Write-Host -foreground "magenta" ""
Write-Host -foreground "magenta" "**** Input 1=Start-vm or Press Enter to Leave VM powered off ****"
$SelectedIndex8 = Read-Host "Type Selection”
$Power = $SelectedIndex8

NEW-VM –Name $NAME –MemoryStartupBytes $RAM -Path $PATHVM -ComputerName $hvhost -Generation 2 | Add-VMHardDiskDrive -VMName $NAME -Path $newVHDPATH | Set-VMProcessor $NAME -Count $vCPU | get-vmnetworkadapter -vmname $NAME | connect-vmnetworkadapter -switchname $vSwitch | Set-VMBios $NAME -EnableNumlock | Set-VMDvdDrive -VMName $NAME -ControllerNumber 1 -ControllerLocation 0 –Path $PATHDVD

if($SelectedIndex8 -eq 1)
{start-vm "$Name"

Write-Host -foreground "magenta" "**** Virtual Machine $Name Status *****"
Write-Host -foreground "Yellow" "!!!! It shows $Name Status twice, the bottom one is the true STATE !!!!"
get-vm "$Name"}
else {

Write-Host -foreground "magenta" "**** Virtual Machine $Name is ready to be started ****"
get-vm "$Name" -ComputerName $hvhost}
}

#Get-ChildItem -LiteralPath '\\cc-dyeo\V$\Library' *.iso