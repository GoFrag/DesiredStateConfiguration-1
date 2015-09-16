
$computername = (Get-ADDomainController -filter *).name

<#
foreach($computer in $computername){
invoke-command -ComputerName $computer {Remove-WindowsFeature Telnet-Client,Telnet-Server}
}

#>



foreach($computer in $computername){
Start-DscConfiguration -Path "\\iclondon\SYSVOL\iclondon.org.uk\DSCResource\Config" -ComputerName $computer -Verbose -wait -Force
}