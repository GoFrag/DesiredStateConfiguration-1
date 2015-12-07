Get-VM -ComputerName CC-DYEO | Foreach-Object { $_ | Get-VMSnapshot | Sort CreationTime | Select -Last 1 | Restore-VMSnapshot -Confirm:$false }

#Start-VM -ComputerName CC-DYEO -Name DSC*


#Get-VM -ComputerName CC-DYEO | Foreach-Object { $_ | Get-VMSnapshot | Sort CreationTime | Select -Last 1 | Remove-VMSnapshot -Confirm:$false}

#get-vm DSC* -ComputerName CC-DYEO | checkpoint-vm -SnapshotName "Vanilla $((Get-Date).toshortdatestring())" –AsJob

Get-Job