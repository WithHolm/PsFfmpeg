function Get-FfPath {
    [CmdletBinding()]
    param (
        
    )
    
    begin {
        
    }
    
    process {
        if([String]::IsNullOrEmpty($Global:_ffmpeg))
        {
            throw "path to ffmpeg not set. please use set-ffPath to define where ffmpeg is"
        }
        else {
            return $Global:_ffmpeg
        }
    }
    
    end {
        
    }
}