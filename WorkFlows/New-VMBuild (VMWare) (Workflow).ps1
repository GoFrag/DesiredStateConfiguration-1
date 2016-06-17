workflow Deploy {

    param(

            [string[]]$Servers
                                
        )

    foreach -parallel($server in $Servers){

      $vm = InlineScript{

            ### Import VMWare PoSH Tools ###
            
            Add-PSSnapin -Name VMware.VimAutomation.Core
            
            ### Connect to ESX Host ###
            
            Set-PowerCLIConfiguration -DisplayDeprecationWarnings $false -InvalidCertificateAction Ignore -Scope AllUsers -Confirm:$false
            $viserver = 'cc-dyeo'
            Connect-VIServer -Server $viserver -User root -Password Yudsey8576!
            
            ### Standup Virtual Servers ###
            
            New-VM -Name $using:Server -CD -DiskGB 40 -DiskStorageFormat Thin -MemoryGB 2 -NetworkName 'Private' -NumCpu 2 -ResourcePool 'DSCLab' -Datastore datastore2 -Verbose # -Debug # Don't use debug as prompts for confirmation
            Get-VM -Name $using:Server | Get-CDDrive | Set-CDDrive -StartConnected:$true -IsoPath '[datastore1] Library/SW_DVD9_Windows_Svr_Std_and_DataCtr_2012_R2_64Bit_English_-3_MLF_X19-53588.ISO' -Confirm:$false -Verbose
            
            ### Windows 2016 ### Get-VM -Name $using:Server | Get-CDDrive | Set-CDDrive -StartConnected:$true  -IsoPath '[datastore1] Library/10586.0.151029-1700.TH2_RELEASE_SERVER_OEMRET_X64FRE_EN-US.ISO' -Confirm:$false -Verbose
            
            Get-VM -Name $using:Server | Set-VM -GuestId windows8Server64Guest -Confirm:$false  -Verbose
            Get-VM -Name $using:Server | Get-NetworkAdapter | Set-NetworkAdapter -Type Vmxnet3 -Confirm:$false  -Verbose
            Get-VM -Name $using:Server | Get-ScsiController | Set-ScsiController -Type VirtualLsiLogicSAS -Confirm:$false -Verbose
            New-AdvancedSetting $using:server -Name svga.autodetect -value svga.autodetect -Confirm:$false -Force -verbose
            New-AdvancedSetting $using:server -Name isolation.tools.copy.disable -value isolation.tools.copy.disable -Confirm:$false -Force -verbose
            New-AdvancedSetting $using:server -Name isolation.tools.paste.disable -value isolation.tools.paste.disable -Confirm:$false -Force -verbose
            New-AdvancedSetting $using:server -Name mem.hotadd -value mem.hotadd -Confirm:$false -Force -verbose
            New-AdvancedSetting $using:server -Name vcpu.hotadd -value vcpu.hotadd -Confirm:$false -Force -verbose
            Get-AdvancedSetting $using:server -Name svga.autodetect | Set-AdvancedSetting -Value $True -Confirm:$false -verbose
            Get-AdvancedSetting $using:server -Name mem.hotadd | Set-AdvancedSetting -Value $True -Confirm:$false -verbose
            Get-AdvancedSetting $using:server -Name vcpu.hotadd | Set-AdvancedSetting -Value $True -Confirm:$false -verbose
            Get-AdvancedSetting $using:server -Name isolation.tools.copy.disable | Set-AdvancedSetting -Value $False -Confirm:$false -verbose
            Get-AdvancedSetting $using:server -Name isolation.tools.paste.disable | Set-AdvancedSetting -Value $False -Confirm:$false -verbose
            
            
            ## Configure EFI Boot ###
            
            New-AdvancedSetting $using:server -Name firmware -value firmware -Confirm:$false -Force -verbose
            Get-AdvancedSetting $using:server -Name firmware | Set-AdvancedSetting -Value efi -Confirm:$false -Verbose
                   
            ### Start Virtual Servers ###
            
            Start-VM $using:server -Verbose
            Stop-VM -VM $using:server -Kill -Confirm:$false -Verbose
            
            }

        $vm.Server

    }
}

$Servers = $null
$Servers = 'DSCLabDC1','DSCLabPull1','DSCLabS1','DSCLabS2','DSCLabS3','DSCLabS4'

Deploy -Servers $Servers