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
            RebootNodeIfNeeded = $True
		}
	}
}

$Computername = 'zxads1','zxads2'

# Create the Computer.Meta.Mof in folder
LCMPush -OutputPath C:\DSCResource\LAB\LCM

#Set-DscLocalConfigurationManager -ComputerName $computername -Path c:\DSCResource\Lab\LCM\ -Verbose -Credential $creds