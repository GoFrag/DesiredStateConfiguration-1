[DSCLocalConfigurationManager()]
Configuration LCMPUSH 
{	
	Node $computername
	{
		Settings
		{
			AllowModuleOverwrite = $True
            ConfigurationMode = 'ApplyAndMonitor'
			RefreshMode = 'Push'
            RebootNodeIfNeeded = $True
            ActionAfterReboot = 'ContinueConfiguration'
		}
	}
}

$Computername = $null
$Computername = 'DSCLabDC01','DSCLabDC02','DSCLabPull01' #,'DSCLabS01','DSCLabS02','DSCLabS03','DSCLabS04'

# Create the Computer.Meta.Mof in folder
LCMPush -OutputPath "C:\Users\dyeo\OneDrive - Imperial College London\DesiredStateConfiguration\Environment\Lab\LCM"

$creds = get-credential
#Set-DscLocalConfigurationManager -ComputerName $computername -Path "C:\Users\dyeo\OneDrive - Imperial College London\DesiredStateConfiguration\Environment\Lab\LCM" -Verbose -Credential $creds
#Start-DscConfiguration -computername $computername -path "C:\Users\dyeo\OneDrive - Imperial College London\DesiredStateConfiguration\Environment\Lab\Hostnames\" -wait -verbose -credential $Creds -force