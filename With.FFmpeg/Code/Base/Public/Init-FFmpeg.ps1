function Initialize-FFmpeg {
    [CmdletBinding()]
    param (
        [switch]$Force
    )
    
    begin {
        
    }
    
    process {
        #if variable is already defined and force is not used
        if ($Global:FFmpeg -and !$Force) {
            return
        }
        $Global:FFmpeg = @{
            Format = (Get-FfFormat)
            Codec  = (Get-FFCodec)
        }
    }
    
    end {
        
    }
}