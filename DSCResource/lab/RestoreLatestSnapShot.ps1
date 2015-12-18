#Get-VM -ComputerName CC-DYEO | Foreach-Object { $_ | Get-VMSnapshot | Sort CreationTime | Select -Last 1 | Restore-VMSnapshot -Confirm:$false }


#Start-VM -ComputerName CC-DYEO -Name DSC*


#Get-VM -ComputerName CC-DYEO | Foreach-Object { $_ | Get-VMSnapshot | Remove-VMSnapshot -Confirm:$false}

#get-vm DSC* -ComputerName CC-DYEO | checkpoint-vm -SnapshotName "Vanilla $((Get-Date).toshortdatestring())" –AsJob

#Checkpoint-VM -Name Test -SnapshotName Vanilla


$vms = 'DSCLabDC01','DSCLabDC02','DSCLabS01','DSCLabS02','DSCLabS03','DSCLabS04','DSCLabPull01'

foreach ($vm in $vms){

Checkpoint-VM -Name $vm -AsJob -ComputerName cc-dyeo -SnapshotName Master

}