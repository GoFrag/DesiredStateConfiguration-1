$Computername = 'icads38','icads41','icads45'

Set-DscLocalConfigurationManager -ComputerName $computername -Path c:\DSCResource\IC\LCM\ -Verbose
Get-DscLocalConfigurationManager -CimSession $computername

Set-DscLocalConfigurationManager -ComputerName icads41 -Path c:\DSCResource\IC\LCM\ -Verbose