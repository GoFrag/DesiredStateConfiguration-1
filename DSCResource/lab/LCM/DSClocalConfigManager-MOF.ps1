[DSCLocalConfigurationManager()]
Configuration LCMPUSH 
{	
	Node $Computername
	{
		Settings
		{
			AllowModuleOverwrite = $True
            ConfigurationMode = 'ApplyAndAutoCorrect'
			RefreshMode = 'Push'	
		}
	}
}

$Computername = 'zxads1','zxads2'

# Create the Computer.Meta.Mof in folder
LCMPush -OutputPath C:\DSCResource\Lab\LCM

#Set-DscLocalConfigurationManager -ComputerName $computername -Path C:\DSCResource\Lab\LCM -Verbose -Credential Administrator
#Get-DscLocalConfigurationManager -CimSession $computername