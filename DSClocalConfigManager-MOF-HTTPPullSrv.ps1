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

$Computername = 'DSCLabDC01','DSCLabDC02'

#Create Guid for Computers

#$guid = [guid]::NewGuid()
$guid = (Get-ADOrganizationalUnit -Filter 'Name -eq "Domain Controllers"').ObjectGUID | OGV -PassThru

# Create the Computer.Meta.Mof in folder

LCMPull -guid $guid -ComputerName $Computername -OutputPath "C:\DSCSource\Domain Controllers\PULLLCM\"


#$creds = Get-Credential
#Set-DscLocalConfigurationManager -Path C:\GIT\DesiredStateConfiguration\DSCResource\labrevised\MemberServers\PULLLCM\ -Verbose -Credential $creds