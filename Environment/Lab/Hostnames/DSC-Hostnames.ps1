configuration DSCLab_Hostnames
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
    {
        xComputer NewName
        { 
            Name = $node.NodeName
        }
    }

Node $AllNodes.Where{$_.Role -eq "Pull Server"}.Nodename
    {
        xComputer NewName
        { 
            Name = $node.NodeName
        }
    }
}

      
$ConfigData = @{
    AllNodes = @(
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


DSCLab_Hostnames -ConfigurationData $ConfigData -OutputPath "C:\Users\dyeo\OneDrive - Imperial College London\DesiredStateConfiguration\Environment\Lab\Hostnames" -Verbose

$Computername = $null
$Computername = 'DSCLabDC01','DSCLabDC02','DSCLabS01','DSCLabS02','DSCLabS03','DSCLabS04','DSCLabPull01'

#$creds = Get-Credential
#Start-DscConfiguration -path "C:\Users\dyeo\OneDrive - Imperial College London\DesiredStateConfiguration\Test\Environment\Lab\Hostnames\" -wait -verbose -credential $Creds -force