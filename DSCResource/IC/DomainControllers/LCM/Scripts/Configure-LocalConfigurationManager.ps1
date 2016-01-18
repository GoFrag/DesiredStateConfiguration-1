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

$Computername = 'icads40' #'ICADS37','ICADS45'#'ICADS41','ICADS45','ICADS38'

# Create the Computer.Meta.Mof in folder
LCMPush -OutputPath \\ic\infrastructure\DSCResource\IC\DomainControllers\LCM

#$creds = Get-Credential
#Set-DscLocalConfigurationManager -ComputerName $computername -Path "\\ic\infrastructure\DSCResource\IC\DomainControllers\LCM" -Verbose