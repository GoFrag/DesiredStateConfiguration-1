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

$Computername = 'ICADS37','ICADS41','ICADS45','ICADS38'

# Create the Computer.Meta.Mof in folder
LCMPush -OutputPath \\ic\infrastructure\DSCResource\IC\DomainControllers\LCM

#$creds = Get-Credential
#Set-DscLocalConfigurationManager -ComputerName icads41 -Path "\\ic\infrastructure\DSCResource\IC\DomainControllers\LCM" -Verbose -Credential Administrator