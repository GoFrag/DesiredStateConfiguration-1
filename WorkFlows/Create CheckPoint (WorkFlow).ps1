﻿workflow Checkpoint {

    param(

            [string[]]$Servers
            
            )
                
    foreach -parallel($Server in $Servers){
            
        $vm = InlineScript{
            $date = Get-date -Format g

            Checkpoint-VM -Name $using:server -CimSession 'cc-dyeo' -SnapshotName Vanilla" "$date
        
            }

        $vm.Servers
    }
}

$servers = $null
$Servers =  'DSCLabDC01','DSCLabS01','DSCLabS02','DSCLabS03','DSCLabS04','DSCLabPull01'

Checkpoint -Servers $servers