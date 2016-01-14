[DSCLocalConfigurationManager()]
Configuration LCMPUSH 
{	
	Node $Computername
	{
		Settings
		{
			AllowModuleOverwrite = $True
            ConfigurationMode = 'ApplyAndAutoCorrect'
			RefreshMode = 'Pull'
			RebootNodeIfNeeded = $True
			ConfigurationID = $guid
            RefreshFrequencyMins = 30
		}

        ConfigurationRepositoryWeb DSCHTTP {
                #Name = 'DSCHTTP'
                ServerURL = 'http://DSCLABPull01:8080/PSDSCPullServer.svc'
                AllowUnsecureConnection = $true
        }

	}
}

$Computername = 'DSCLABDC01','DSCLABDC02','DSCLABPULL01'

# Create the Computer.Meta.Mof in folder
LCMPush -OutputPath c:\GIT\DesiredStateConfiguration\DSCResource\lab\LCM

#$creds = Get-Credential
#Set-DscLocalConfigurationManager -ComputerName $Computername -Path c:\GIT\DesiredStateConfiguration\DSCResource\lab\LCM -Verbose -Credential $creds

#Enter-PSSession -ComputerName DSCLABDC1 -Credential DSCLABDC1\Administrator