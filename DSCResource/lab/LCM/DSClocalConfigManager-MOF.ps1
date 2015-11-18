[DSCLocalConfigurationManager()]
Configuration LCMPUSH 
{	
	Node $Computername
	{
		Settings
		{
			AllowModuleOverwrite = $True
            ConfigurationMode = 'ApplyOnly'
			RefreshMode = 'Push'
            RebootNodeIfNeeded = $True
		}
	}
}

$Computername = 'DSCLabDC01','DSCLabDC02','DSCLabS01','DSCLabS02','DSCLabS03','DSCLabS04'

# Create the Computer.Meta.Mof in folder
LCMPush -OutputPath C:\GIT\DesiredStateConfiguration\DSCResource\lab\LCM

#$creds = get-credential
#Set-DscLocalConfigurationManager -ComputerName $computername -Path C:\DSCResource\Lab\LCM -Verbose -Credential $creds
#Get-DscLocalConfigurationManager -CimSession $computername