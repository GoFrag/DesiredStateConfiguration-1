[DSCLocalConfigurationManager()]
Configuration LCMHTTPPull
{
    param
        (
            [Parameter(Mandatory=$true)]
            [string[]]$ComputerName,

            [Parameter(Mandatory=$true)]
            [string]$guid
        )      	
	Node $ComputerName {
	
		Settings{
		
			AllowModuleOverwrite = $True
            ConfigurationMode = 'ApplyAndAutoCorrect'
			RefreshMode = 'Pull'
			ConfigurationID = $guid
            }

            ConfigurationRepositoryWeb DSCHTTP {
            #Name = 'DSCHTTP'
            ServerURL = 'http://DSCLABPull01:8080/PSDSCPullServer.svc'
            AllowUnsecureConnection = $true
            }
		
	    }
    }

# Computer list 
$ComputerName='DSCLABDC01','DSCLABDC02','DSCLABS01','DSCLABS02','DSCLABS03','DSCLABS04'

# Create Guid for the computers
$guid=[guid]::NewGuid()

# Create the Computer.Meta.Mof in folder
LCMHTTPPull -ComputerName $ComputerName -Guid $guid -OutputPath C:\GIT\DesiredStateConfiguration\DSCResource\labrevised\MemberServers\PULLLCM\

#$creds = Get-Credential
#Set-DscLocalConfigurationManager -Path C:\GIT\DesiredStateConfiguration\DSCResource\labrevised\MemberServers\PULLLCM\ -Verbose -Credential $creds