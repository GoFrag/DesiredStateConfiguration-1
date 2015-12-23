configuration DSCLab
{
    Install-Module -Name xComputerManagement
    Import-DscResource -ModuleName xComputerManagement

Node $AllNodes.Where{$_.Role -eq "Primary DC"}.Nodename
    {
        xComputer NewName
        { 
            Name = $node.NodeName
        }
    }
    
Node $AllNodes.Where{$_.Role -eq "Replica DC"}.Nodename
    {
        xComputer NewName
        { 
            Name = $node.NodeName
        }
    }
    
Node $AllNodes.Where{$_.Role -eq "Member Server"}.Nodename
    {xComputer NewName
        { 
            Name = $node.NodeName
        }
    }

Node $AllNodes.Where{$_.Role -eq "Pull Server"}.Nodename
    {xComputer NewName
        { 
            Name = $node.NodeName
        }
    }
      
$ConfigData = @{
    AllNodes = @(
                @{
                    PSDscAllowPlainTextPassword = $true
                },
        
                @{
                    Nodename = "DSCLABDC01"
                    Role = "Primary DC"
                },
        
                @{
                    Nodename = "DSCLABDC02"
                    Role = "Replica DC"
                },

                @{
                    Nodename = "DSCLABS01"
                    Role = "Member Server"
                },

                @{
                    Nodename = "DSCLABS02"
                    Role = "Member Server"
                },

                @{
                    Nodename = "DSCLABS03"
                    Role = "Member Server"
                },

                @{
                    Nodename = "DSCLABS04"
                    Role = "Member Server"
                },

                @{
                    Nodename = "DSCLABPULL01"
                    Role = "Pull Server"
                }
            )
        }
    }


DSCLab -ConfigurationData $ConfigData -OutputPath C:\GIT\DesiredStateConfiguration\DSCResource\lab\HostNames -Verbose


#$creds = Get-Credential
#Start-DscConfiguration -path C:\GIT\DesiredStateConfiguration\DSCResource\lab\HostNames -wait -verbose -credential $Creds -force