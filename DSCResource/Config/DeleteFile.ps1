$computer = 'localhost'

Configuration DeleteFile

{
    Node $computer
    
    {
     
        Import-DscResource –ModuleName PSDesiredStateConfiguration
        
        File DeleteFile

        {
            DestinationPath = "C:\Users\Public\Desktop\lynda.com.url"
            Ensure = "Absent"
            Force = $true
            Type = 'File'
        }
    }
}

DeleteFile -OutputPath c:\DSCResource\Config\

Start-DscConfiguration -Path "c:\DSCResource\Config" -ComputerName $computer -Verbose -wait -Force