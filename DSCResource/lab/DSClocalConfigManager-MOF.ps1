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

$Computername = 'DSCLABDC1','DSCLABDC2','DSCLABS1','DSCLABS2','DSCLABS3','DSCLABS4'

# Create the Computer.Meta.Mof in folder
LCMPush -OutputPath c:\GIT\DesiredStateConfiguration\DSCResource\lab\LCM

#Set-DscLocalConfigurationManager -ComputerName $computername -Path c:\DSCResource\Lab\LCM\ -Verbose -Credential $creds