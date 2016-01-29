workflow Checkpoint {

    param(

            [string[]]$Servers
            
            )

    
    foreach -parallel($doom in $Servers){

        
        $vm = InlineScript{

            Checkpoint-VM -Name $doom -CimSession 'cc-dyeo' -SnapshotName Gold
        
            }

        $vm.Servers
    }
}

$servers = $null

$Servers = 'DSCLabDC01','DSCLabDC02','DSCLabS01','DSCLabS02','DSCLabS03','DSCLabS04','DSCLabPull01'

Checkpoint -Servers $servers -Verbose