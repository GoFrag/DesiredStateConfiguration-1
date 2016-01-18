[DSCLocalconfigurationManager()]
Configuration LCM_SMBPULL 
{
    param
        (
            [Parameter(Mandatory=$true)]
            [string[]]$ComputerName,

            [Parameter(Mandatory=$true)]
            [string]$guid
        )
        	
	Node $ComputerName
	{
		Settings {
			AllowModuleOverwrite = $True
            ConfigurationMode = 'ApplyAndAutoCorrect'
			RefreshMode = 'Pull'

			ConfigurationID = $guid
        }
           
            ConfigurationRepositoryShare DSCSMB {
                #Name = 'DSCSMB'
                Sourcepath = "\\DSCLabPull01\DSCSMB"
            }   
	}
}

$Computername = $null
$Computername = 'DSCLabDC01','DSCLabDC02','DSCLabS01','DSCLabS02','DSCLabS03','DSCLabS04'

# Create Guid for the computers
$guid=[guid]::NewGuid()

# Create the Computer.Meta.Mof in folder
LCM_SMBPull -OutputPath C:\GIT\DesiredStateConfiguration\DSCResource\lab\LCM\SMBPull -ComputerName $Computername -guid $guid

#$creds = get-credential
#Set-DscLocalConfigurationManager -ComputerName $computername -Path C:\GIT\DesiredStateConfiguration\DSCResource\lab\LCM\SMBPull -Verbose -Credential $creds