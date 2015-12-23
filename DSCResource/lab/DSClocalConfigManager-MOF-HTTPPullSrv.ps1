[DSCLocalConfigurationManager()]
Configuration LCMPULL 
    {	
    param
            (
                [Parameter(Mandatory=$true)]
                [string[]]$ComputerName,

                [Parameter(Mandatory=$true)]
                [string]$guid
            )

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

$Computername = 'DSCLABS01','DSCLABS02','DSCLABS03','DSCLABS04'#,'DSCLABPULL01'

#Create Guid for Computers

$guid = [guid]::NewGuid()

# Create the Computer.Meta.Mof in folder

#LCMPull -guid $guid -ComputerName $Computername -OutputPath c:\GIT\DesiredStateConfiguration\DSCResource\lab\LCM\HTTPPullSrv

LCMPull -guid $guid -ComputerName $Computername -OutputPath C:\GIT\DesiredStateConfiguration\DSCResource\labrevised\MemberServers\PULLLCM\


#$creds = Get-Credential
#Set-DscLocalConfigurationManager -Path C:\GIT\DesiredStateConfiguration\DSCResource\labrevised\MemberServers\PULLLCM\ -Verbose -Credential $creds