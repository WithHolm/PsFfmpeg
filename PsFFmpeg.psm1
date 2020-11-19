gci "$PSScriptRoot\code" -Filter "*.ps1" -File -Recurse|%{
    . $_
}

gci (join-path (get-fftemp) "log")|Remove-Item
    
Set-FfPath -Path 'C:\handbrake\ffmpeg\bin'