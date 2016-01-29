workflow StartUp {

    param(

            [string[]]$Servers
                    
        )

    foreach -parallel($Server in $Servers){

      $vm = InlineScript{

            Start-VM  -Name $using:Server -CimSession cc-dyeo
            
            }

        $vm.Server

    }
}

$Servers = 'DSCLabDC01','DSCLabDC02','DSCLabS01','DSCLabS02','DSCLabS03','DSCLabS04','DSCLabPull01'

Startup -Servers $Servers