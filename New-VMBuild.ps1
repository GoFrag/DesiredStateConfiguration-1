#$viserver = 'cc-dyeo'

#Checks is VMware.VimAutomation.Core Snapin is present and installs if not 
if ( (Get-PSSnapin -Name VMware.VimAutomation.Core -ErrorAction SilentlyContinue) -eq $null )
    {
        Add-PSSnapin -Name VMware.VimAutomation.Core
    }

#Contects to VI Server #
Set-PowerCLIConfiguration -DisplayDeprecationWarnings $false -InvalidCertificateAction Ignore -Scope AllUsers -Confirm:$false
$connection = Connect-VIServer -Server $viserver -User root -Password Yudsey8576!

#Creates a new resource pool
If (Get-ResourcePool -Name DSCLab -ErrorAction SilentlyContinue)
    {
        'Resource Pool already exists'
    }

else

{
    'Creating Resource Pools'
    
    Try 
    {
        New-ResourcePool -Location Resources -Name DSCLab -CpuExpandableReservation $true -CpuReservationMhz 0 -CpuSharesLevel Normal -MemExpandableReservation $true -MemReservationGB 0 -MemSharesLevel Normal
    }
    
    Catch 
    
    {
        'Exiting as unable to create resource pool'
        exit
    }
}



workflow Deploy {

    param(

            [string[]]$Servers
            #[string]$switch = 'NAT'
        
        )

    foreach -parallel($server in $Servers){

      $vm = InlineScript{

            #New-VHD -ParentPath "L:\W2K12R2-Master-Diff.vhdx" -Path "v:\Hyper-V\Virtual Hard Disks\$using:Member\$using:Member.vhdx" -CimSession cc-dyeo -Differencing -SizeBytes 40Gb
            #New-VM -VMName $using:Member -Generation 2 -VHDPath "v:\Hyper-V\Virtual Hard Disks\$using:Member\$using:Member.vhdx" -SwitchName $using:switch -CimSession cc-dyeo
            #Set-VM -Name $using:Member -ProcessorCount 2 -DynamicMemory -MemoryMinimumBytes 512MB -MemoryMaximumBytes 2GB -CimSession cc-dyeo -SmartPagingFilePath L:\SmartPagingFiles\$using:Member
            #Start-VM  -Name $using:Member -CimSession cc-dyeo
            #Stop-VM -Name $using:Member -CimSession cc-dyeo -TurnOff -Force

            Add-PSSnapin -Name VMware.VimAutomation.Core
            $viserver = 'cc-dyeo'
            Connect-VIServer -Server $viserver -User root -Password Yudsey8576!
            
            
            New-VM -Name $using:Server -CD -DiskGB 40 -DiskStorageFormat Thin -MemoryGB 2 -NetworkName 'Private' -NumCpu 2 -ResourcePool 'DSCLab' -Datastore datastore2 -Verbose # -Debug # Don't use debug as prompts for confirmation
            Get-VM -Name $using:Server | Get-CDDrive | Set-CDDrive -StartConnected:$true  -IsoPath '[datastore1] Library/10586.0.151029-1700.TH2_RELEASE_SERVER_OEMRET_X64FRE_EN-US.ISO' -Confirm:$false -Verbose 
            Get-VM -Name $using:Server | Set-VM -GuestId windows8Server64Guest -Confirm:$false  -Verbose -RunAsync
            Get-VM -Name $using:Server | Get-NetworkAdapter | Set-NetworkAdapter -Type Vmxnet3 -Confirm:$false  -Verbose -RunAsync
            Get-VM -Name $using:Server | Get-ScsiController | Set-ScsiController -Type VirtualLsiLogicSAS -Confirm:$false -Verbose
            New-AdvancedSetting -Entity $using:Server -Name 'svga.autodetect' -Value 'true' -Confirm:$false -Force:$true -Verbose -WarningAction SilentlyContinue
            New-AdvancedSetting -Entity $using:Server -Name 'mem.hotadd' -Value 'true' -Confirm:$false -Force:$true -Verbose -WarningAction SilentlyContinue
            New-AdvancedSetting -Entity $using:Server -Name 'vcpu.hotadd' -Value 'true' -Confirm:$false -Force:$true -Verbose -WarningAction SilentlyContinue
            #enable copy/paste into vm
            New-AdvancedSetting -Entity $using:Server -Name 'isolation.tools.copy.disable' -Value FALSE -Confirm:$false -Force:$true -Verbose -WarningAction SilentlyContinue
            New-AdvancedSetting -Entity $using:Server -Name 'isolation.tools.paste.disable' -Value FALSE -Confirm:$false -Force:$true -Verbose -WarningAction SilentlyContinue
            Start-VM $using:server -RunAsync -Server $viserver
            Stop-VM -VM $server -Server $viserver -Kill -RunAsync
            
            }

        $vm.Server

    }
}

$Servers = $null
$Servers = 'DSCLabDC1','DSCLabPull1','DSCLabS1','DSCLabS2','DSCLabS3','DSCLabS4'

Deploy -Servers $Servers