function Test-FFmpegExists {
    [CmdletBinding()]
    param (
        [switch]$Throw
    )
    
    begin {
        
    }
    
    process {
        try{
            $cmd = command ffmpeg -ErrorAction Stop
        }   
        catch{
            if($throw)
            {
                throw "FFmpeg not installed or found. Use either 'Set-FFpath' to define where the exe is or 'Install-FFmpeg' to download the latest version"
            }
            return $false
        }

        if($throw){
            return
        }
        return $true
    }
    
    end {
        
    }
}