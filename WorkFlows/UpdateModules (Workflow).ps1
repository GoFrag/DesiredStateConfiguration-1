$creds = Get-Credential

workflow Modules {

    param(

            [string[]]$Servers
                    
        )

    foreach -parallel($Server in $Servers){

      $vm = InlineScript{

            Invoke-Command -computername $server -Credential $creds -ScriptBlock {Set-PSRepository -Name PSGallery -PackageManagementProvider NuGet -SourceLocation "https://www.powershellgallery.com/api/v2/" -InstallationPolicy Trusted -verbose}
            Invoke-Command -computername $server -Credential $creds -ScriptBlock {update-module -verbose}
            
            }

        $vm.Server

    }
}

$Servers = 'DSCLabDC01','DSCLabS01','DSCLabS02','DSCLabS03','DSCLabS04','DSCLabPull01'

Modules -Servers $Servers