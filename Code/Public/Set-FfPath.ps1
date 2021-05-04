function Set-FfPath {
    [CmdletBinding()]
    param (
        [String]$Path
    )
    
    begin {

    }
    
    process {
        $Item = get-childitem $path -Filter "ffmpeg.exe" -file -Recurse
        if(!$item)
        {
            throw "Could not find ffmpeg.exe"
        }
        else
        {
            Write-Verbose "Found ffmpeg.exe at path $item"
            $env:path+=";$($item.FullName)"
            # $global:_ffmpeg = $item.FullName
        }
    }
    
    end {
        
    }
}