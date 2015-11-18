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

#$creds = Get-Credential
#Set-DscLocalConfigurationManager -ComputerName $Computername -Path c:\GIT\DesiredStateConfiguration\DSCResource\lab\LCM -Verbose -Credential $creds

#Enter-PSSession -ComputerName DSCLABDC1 -Credential DSCLABDC1\Administrator