Function Publish-MOF {
<#
.SYNOPSIS
    This function renames a .MOF that was generated from
    a configuration into a valid GUID (For a node to use),
    copies it to the DSC store ready to be pulled, and
    creates a checksum for it (required).
#>

    param (
        [string]$FilePath = "$path\$role\Config"
    )

    if (!(Test-Path($FilePath))) { Throw 'Invalid file path' }

    Write-Host 'Renaming MOF file to GUID, moving to DSC store and creating checksum...'

    ###     
    
    $ouroot = Get-ADOrganizationalUnit -Filter * -SearchScope OneLevel -SearchBase "OU=test,DC=ic,DC=ac,DC=uk"
    $menu = @{}

    for ($i=1;$i -le $ouroot.count; $i++){
        Write-Host "$i. $($ouroot[$i-1].name)"
        $menu.Add($i,($ouroot[$i-1].DistinguishedName))
        }

    [int]$ans = Read-Host "Select Role"
    $Selection = $menu.Item($ans)
    $NewGUID = (Get-ADOrganizationalUnit $selection).ObjectGUID
    $Role = (Get-ADOrganizationalUnit $selection).Name
    $Path = C:\DSCResource\Testing

    Write-Host "New GUID - $NewGuid will be used in $path\$Role"  -ForegroundColor Yellow
    
}
    # Rename our MOF file
    Rename-Item -Path $FilePath -NewName $NewGUID

    # Record the new path (including new file name)
    $NewPath = "{0}\{1}" -f (Split-Path -Path $FilePath), $NewGuid

    #Copy renamed MOF to our DSC folder
    #Copy-Item $NewPath 'C:\Program Files\WindowsPowerShell\DscService\Configuration'
    Copy-Item $FilePath -Force

    # Verify the file with a checksum
    #New-DscChecksum "C:\Program Files\WindowsPowerShell\DscService\Configuration\$NewGuid"
    New-DscChecksum $FilePath\new\$NewGuid

    Return $NewGuid



<#
.SYNOPSIS
    This function renames a .MOF that was generated from
    a configuration into a valid GUID (For a node to use),
    copies it to the DSC store ready to be pulled, and
    creates a checksum for it (required).
#>


[DSCLocalConfigurationManager()]
Configuration ConfigurePullNode {

    param (
        [string]$ComputerName,
        [string]$Guid,
        [string]$DownloadServer
    )

    Node $ComputerName {
	
		Settings{
		
			AllowModuleOverwrite = $True
            ConfigurationMode = 'ApplyAndAutoCorrect'
			RefreshMode = 'Pull'
			ConfigurationID = $NewGUID
            RebootNodeIfNeeded = $True
            ActionAfterReboot = 'ContinueConfiguration'
            }

            ConfigurationRepositoryWeb DSCHTTP {
            #Name = 'DSCHTTP'
            ServerURL = "http://$DownloadServer:8080/PSDSCPullServer.svc"
            AllowUnsecureConnection = $true
            }
        }
    }

#region VARIABLES
#################################################################

# Path to .MOF we have created
$MofPath = ".\MyMof\SERVER01.mof"

# The computer to convert to a pull node
$PullNode = '**PULLNODE**'

# Server to pull from
$DownloadServer = 'DSCLabPull01'

#################################################################
#endregion


#region
configuration NewWebSite{

    #Install IIS Role
    WindowsFeature IIS
        {
            Ensure = 'Present'
            Name = 'Web-Server'
        }
}
#endregion


#region

# Rename, move and checksum our existing MOF
$Guid = Publish-Mof -FilePath $MofPath

Write-Host "Create our pull server MOF (For DSCLocalConfigurationManager)" -ForegroundColor Yellow
ConfigurePullNode -ComputerName $PullNode -Guid $Guid -DownloadServer $DownloadServer

# Create credential
$Credential = New-Object System.Management.Automation.PSCredential("Baysgarthschool\administrator",(ConvertTo-SecureString "**PASSWORD**" -AsPlainText -Force))

Write-Host "Start CIM Session to remote machine - $PullNode" -ForegroundColor Yellow
$CimSession = New-CimSession -ComputerName $PullNode -Credential $Credential

Write-Host "Set DSCLocalConfigurationManager config on remote machine - $PullNode" -ForegroundColor Yellow
Set-DSCLocalConfigurationManager -CimSession $CimSession -Path '.\ConfigurePullNode' -Verbose
# NOTE: This appears light blue instead of yellow as it's in a CIMSession

Write-host "Check DSCLocalConfigurationManager config" -ForegroundColor Yellow
Get-DSCLocalConfigurationManager -CimSession $CimSession

#endregion