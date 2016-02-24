workflow CopyFolders {

    param(

            [string[]]$Source
                    
        )

    foreach -parallel($Directory in $Source){

      $directory = InlineScript{

            #Start-VM  -Name $using:Server -CimSession cc-dyeo
            Copy-Item -Path $using:directory -Recurse -Destination 'e:\Hyper-v'
            
            }

        $directory.Source

    }
}

$Source = (Get-ChildItem -Path E:\Library).FullName

CopyFolders -Source $Source