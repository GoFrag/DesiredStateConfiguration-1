#####################################################################
###
### Prompt for Role OU choice --- ($selection)
### Obtains Role OU GUID --- ($ouguid)
### 

$OUs = Get-ADOrganizationalUnit -Filter * -SearchScope OneLevel -SearchBase 'OU=Servers,DC=DSCLab,DC=local'

$menu = @{}

for ($i=1;$i -le $ous.count; $i++) {
    Write-Host "$i. $($ous[$i-1].name)"
    #$menu.Add($i,($ous[$i-1].name))
    $menu.Add($i,($ous[$i-1].DistinguishedName))
    }

[int]$ans = Read-Host 'Select Role'
$selection = $menu.Item($ans)

$ouguid = (Get-ADOrganizationalUnit $selection).ObjectGUID
$role = (Get-ADOrganizationalUnit $selection).Name
$computername = (Get-ADComputer -searchbase "$selection" -Filter *).name
$path = "C:\DSCSource\"


[DSCLocalConfigurationManager()]
Configuration LCMHTTPPULL 
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

LCMHTTPPull -guid $ouguid -ComputerName $Computername -OutputPath "$path\$role\LCMHTTPPull\"

<#
$creds = $null
$creds = Get-credential

Set-DscLocalConfigurationManager -Path "$path\$role\LCMHTTPPull" -Verbose -Credential $creds
#>