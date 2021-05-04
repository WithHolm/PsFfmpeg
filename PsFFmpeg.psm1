gci "$PSScriptRoot\code" -Filter "*.ps1" -File -Recurse|%{
    . $_.FullName
}

gci (join-path (get-fftemp) "log")|Remove-Item


if(!(Test-FFmpegExists))
{
    Write-warning "I cannot detect ffmpeg as part of your system. please use either 'Set-FFpath' to define where the exe is or 'Install-FFmpeg' to download the latest version"
}

# Set-FfPath -Path 'C:\handbrake\ffmpeg\bin'