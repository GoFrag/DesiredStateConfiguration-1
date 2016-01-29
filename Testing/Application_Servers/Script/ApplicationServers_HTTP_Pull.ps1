[DSCLocalConfigurationManager()]
Configuration ApplicationServers_HTTP_Pull
{
    $guid=[guid]::NewGuid()
	Node $ComputerName {
	
		Settings{
		
			AllowModuleOverwrite = $True
            ConfigurationMode = 'ApplyAndAutoCorrect'
			RefreshMode = 'Pull'
			ConfigurationID = $guid
            RebootNodeIfNeeded = $True
            ActionAfterReboot = 'ContinueConfiguration'
            }

            ConfigurationRepositoryWeb DSCHTTP {
            #Name = 'DSCHTTP'
            ServerURL = 'http://DSCLABPull01:8080/PSDSCPullServer.svc'
            AllowUnsecureConnection = $true
            }
		
	    }
    }

# Computer list 
$ComputerName = 'DSCLABS01','DSCLABS02','DSCLABS03','DSCLABS04'

# Create Guid for the computers
#$guid=[guid]::NewGuid()

# Create the Computer.Meta.Mof in folder
ApplicationServers_HTTP_Pull -Guid $guid -OutputPath "C:\Users\dyeo\OneDrive - Imperial College London\DesiredStateConfiguration\Testing\Application_Servers\LCM"

#$creds = Get-Credential
#Set-DscLocalConfigurationManager -Path "C:\Users\dyeo\OneDrive - Imperial College London\DesiredStateConfiguration\Testing\Application_Servers\LCM" -Verbose -Credential $creds