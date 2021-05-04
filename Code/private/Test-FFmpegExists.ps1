function Test-FFmpegExists {
    [CmdletBinding()]
    param (
        
    )
    
    begin {
        
    }
    
    process {
        try{
            command ffmpeg -ErrorAction Stop
            return $true
        }   
        catch{
            return $false
        }
    }
    
    end {
        
    }
}