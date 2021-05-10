Enum FFcodectype{
    Video
    Audio
    Subtitle
}
class FFcodec{
    [string]$Name
    [string]$Description
    [FFcodectype]$Type
    [string[]]$Flags = @()
    [string[]]$Conversion = @()
    hidden [string]$raw

    FFcodec([string]$String)
    {
        $this.raw = $string
        $this.ProcessProperties()
    }

    hidden [string[]] getProperties()
    {
        return ($this.raw -split " "|?{![string]::IsNullOrEmpty($_)})
    }
    hidden ProcessProperties()
    {
        if([string]::IsNullOrEmpty($this.raw))
        {
            throw "Cannot process item as no string was provided"
        }
        $props = $this.getProperties()
        $this.name = $props[1]
        $this.Description = $props[2..$props.Count] -join " "
        $this.Flags = $this.getProperties()[0] -split ""|?{$_ -ne "."}|?{![string]::IsNullOrEmpty($_)}
        $this.SetConversionFlags()
        $this.SetType()

    }

    hidden SetConversionFlags()
    {
        if($this.Flags.count -eq 0)
        {
            throw "Flags have not been added yet. cannot process conversion flags"
        }

        if($this.Flags -contains "D")
        {
            $this.Conversion += "Decode"
        }
        if($this.Flags -contains "E")
        {
            $this.Conversion += "Encode"
        }
        $this.Conversion = $this.Conversion|Select-Object -Unique
    }

    hidden SetType()
    {
        if($this.Flags.count -eq 0)
        {
            throw "Flags have not been added yet. cannot process conversion flags"
        }

        if($this.Flags -contains "V")
        {
            $this.Type = "Video"
        }
        if($this.Flags -contains "A")
        {
            $this.Type = "Audio"
        }
        if($this.Flags -contains "S")
        {
            $this.Type = "Subtitle"
        }
    }

}

# Update-TypeData -TypeName "FFcodec" -
function Get-FFCodec {
    [CmdletBinding()]
    param (
        [ValidateSet("Video","Audio","Subtitle","All")]
        [string[]]$Show = "All"
    )
    
    begin {
        Test-FFmpegExists -throw
        if("All" -in $Show)
        {
            $Show = "Video","Audio","Subtitle"
        }
    }
    
    process {
        $EAP = $ErrorActionPreference
        $ErrorActionPreference = "silentlycontinue"
        $Out = & ffmpeg -codecs 2>"$env:TEMP\ffpmegdelete.txt"
        $ErrorActionPreference = $EAP
        $showItems = $false
        for ($i = 0; $i -lt $Out.Count; $i++) {
            if($out[$i] -like " ---*")
            {
                $showItems = $true
                continue
            }

            if($showItems)
            {
                $output = [FFcodec]::new($out[$i])
                if($output.Type -in $Show)
                {
                    Write-Output $output
                }
            }
        }
    }
    
    end {
        
    }
}

# Get-FfCodec # -ErrorAction Stop -Verbose

<#
Codecs:
 D..... = Decoding supported
 .E.... = Encoding supported
 ..V... = Video codec
 ..A... = Audio codec
 ..S... = Subtitle codec
 ...I.. = Intra frame-only codec
 ....L. = Lossy compression
 .....S = Lossless compression

  D.VI.S 012v                 Uncompressed 4:2:2 10-bit
 D.V.L. 4xm                  4X Movie
 D.VI.S 8bps                 QuickTime 8BPS video
#>

<#
-formats            show available formats
-muxers             show available muxers
-demuxers           show available demuxers
-devices            show available devices
-codecs             show available codecs
-decoders           show available decoders
-encoders           show available encoders
#>