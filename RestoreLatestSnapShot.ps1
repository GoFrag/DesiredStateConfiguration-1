#Get-VM -ComputerName CC-DYEO | Foreach-Object { $_ | Get-VMSnapshot -Name Master | Restore-VMSnapshot -Confirm:$false }


#Start-VM -ComputerName CC-DYEO -Name DSC*


#Get-VM -ComputerName CC-DYEO -Name dsclab* | Foreach-Object { $_ | Get-VMSnapshot | Remove-VMSnapshot -Confirm:$false}

#get-vm DSC* -ComputerName CC-DYEO | checkpoint-vm -SnapshotName "Master $((Get-Date).toshortdatestring())" -Verbose

#Checkpoint-VM -Name Test -SnapshotName Vanilla


$vms = 'DSCLabDC01','DSCLabDC02','DSCLabS01','DSCLabS02','DSCLabS03','DSCLabS04','DSCLabPull01'

foreach ($vm in $vms){

#Checkpoint-VM -Name $vm -AsJob -ComputerName cc-dyeo -SnapshotName Master
#Get-VM -ComputerName CC-DYEO -Name $vm | Foreach-Object { $_ | Get-VMSnapshot | Remove-VMSnapshot -Confirm:$false}

}

Get-Job | where state -EQ running

Stop-Job *

Get-vm -Name dsclab*