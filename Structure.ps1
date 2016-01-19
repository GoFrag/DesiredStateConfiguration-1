$sot = import-csv -path '\\ic\infrastructure\DSCResource\Setup\Directory Structure\SOT.csv'
$sot.GetType().fullname
$root = $null
$root = "C:\Users\dyeo\OneDrive - Imperial College London\DesiredStateConfiguration"
$ErrorActionPreference = "SilentlyContinue"

##################################################################################
### Where-object {$_.firstlevel} means eliminate any $null value in the column ###
##################################################################################

$Level1 = ($sot | select Firstlevel | Where-Object {$_.firstlevel})
$Level2 = ($sot | select SecondLevel | Where-Object {$_.Secondlevel})
$Level3 = ($sot | select ThirdLevel | Where-Object {$_.Thirdlevel})

##########################################
### Creates Top Level Folder Structure ###
##########################################

foreach ($level in $level1)
    {
        $CreationError = $null
        Try
            {
                [string]$pathToCreateFirstLevel = $null
                [string]$folderToCreateFirstLevel = $null
                $folderToCreateFirstLevel = $level.FirstLevel
                $pathToCreateFirstLevel = "$root\$folderToCreateFirstLevel"
                If(!(Test-path -Path $pathToCreateFirstLevel)){
                new-item -Path $pathToCreateFirstLevel -ItemType directory}
                
            else
                
                {
                Write-Host "Do not need to create directory: $pathToCreateFirstLevel"
                }
            }

        catch
            
            {
                Write-Host "Unable to create directory: $pathToCreateFirstLevel"
                Write-host $error[0].Exception
            }
   
##############################################
#### Creates Second Level Folder Structure ###
##############################################
    
$FirstLevelRoot = $null
$FirstLevelRoot = $pathToCreateFirstLevel 

foreach ($secondLevel in $Level2)
    {
        Try
            {
                [string]$pathToCreateSecondLevel = $null
                [string]$folderToCreateSecondLevel = $null
                $folderToCreateSecondLevel = $secondLevel.SecondLevel
                $pathToCreateSecondLevel = "$FirstLevelRoot\$folderToCreateSecondLevel"
                If(!(Test-path -Path $pathToCreateSecondLevel)){
                new-item -Path $pathToCreateSecondLevel -ItemType directory}
                
            else
                
                {
                Write-Host "Do not need to create directory: $pathToCreateSecondLevel"
                }
            }

        catch
            
            {
                Write-Host "Unable to create directory: $pathToCreateSecondLevel"
                Write-host $error[0].Exception
            }

############################################
### Creates Third Level Folder Structure ###
############################################

$ThirdLevelRoot = $null
$ThirdLevelRoot = $pathToCreateSecondLevel 

foreach ($thirdLevel in $Level3)
    {
        Try
            {
                [string]$pathToCreateThirdLevel = $null
                [string]$folderToCreateThirdLevel = $null
                $folderToCreateThirdLevel = $ThirdLevel.ThirdLevel
                $pathToCreateThirdLevel = "$ThirdLevelRoot\$folderToCreateThirdLevel"
                If(!(Test-path -Path $pathToCreateThirdLevel)){
                new-item -Path $pathToCreateThirdLevel -ItemType directory}
                
            else
                
                {
                Write-Host "Do not need to create directory: $pathToCreateThirdLevel"
                }
            }

        catch
            
            {
                Write-Host "Unable to create directory: $pathToCreateThirdLevel"
                Write-host $error[0].Exception
            }
        }
    }
}

#End