[DSCLocalConfigurationManager()]
Configuration LCMPUSH
    {
        Node $computername
        {
            Settings
            {
                AllowModuleOverwrite = $True
                ConfigurationMode = 'ApplyAndAutoCorrect'
                RefreshMode = 'Push'
            }
        }
    }

$computername = (Get-ADDomainController -filter *).name

LCMPUSH -OutputPath "\\icdev\SYSVOL\icdev.ic.ac.uk\DSCResource\LCM"