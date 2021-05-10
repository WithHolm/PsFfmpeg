class FFFormat{
    [parameter(HelpMessage = "List of extensions supported by this format")]
    [String]$Extension
    
    [parameter(HelpMessage = "
    Multiplexer/DeMultiplexer (Many to one/One to many).
    Defines if the format supports conversion from many possible data points to one (or reverse). 
    IE a file with video, audio and subtitles that supports demuxing could be split to a video file, audio file and subtitles file. The reverse would be muxing.")]
    [string[]]$Muxing = @()

    [string]$Description = ""

    [bool]IsFormat([System.IO.FileInfo]$Path)
    {
        return ($this.Extension -contains $Path.Extension.substring(1))
    }
}

function Get-FfFormat {
    [CmdletBinding()]
    param (

    )
    
    begin {
        Test-FFmpegExists -throw
    }
    
    process {
        $Out = & ffmpeg -formats -hide_banner 2>"$env:TEMP\ffpmegdelete.txt"
        $showItems = $false
        for ($i = 0; $i -lt $Out.Count; $i++) {
            if($out[$i] -like " -*")
            {
                $showItems = $true
                continue
            }
            if($showItems)
            {
                $line = $Out[$i] -split " "|?{![string]::IsNullOrEmpty($_)}
                $item = [FFFormat]::new()
                $item.Description = $line[2..$line.count]
                $item.Extension = $line[1] -split ","
                if($line[0] -like "*D*")
                {
                    $item.Muxing += "Demux"
                }
                if($line[0] -like "*E*")
                {
                    $item.Muxing += "Mux"
                }
                Write-Output $item
            }
        }
    }
    
    end {
        
    }
}