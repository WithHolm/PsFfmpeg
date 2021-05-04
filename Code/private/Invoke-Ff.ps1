function Invoke-FF {
    [CmdletBinding()]
    param (
        [ValidateSet("FFmpeg")] #,"FFplay","FFprobe"
        $App = "FFMpeg",
        $arguments
    )
    
    begin {
        
    }
    
    process {
        $argstring = @()
        Foreach($arg in $arguments)
        {
            if($arg -is [hashtable])
            {
                $argstring += $arg.keys|%{
                    "-$($_) $($arg.$_)"   
                }
            }
            else {
                $argstring += $arg
            }
        }
        $Logpath = join-path $env:TEMP "PsFFmpeg\log"
        new-item -Path $Logpath -ItemType Directory -Force|Out-Null
        $SessionName = "InvokeFF-$([System.IO.Path]::GetRandomFileName()).log"
        $ErrLogPath = join-path $Logpath "Temp-$SessionName"



        $sb = [scriptblock]::Create("& $(Get-FfPath) $($argstring -join " ") -loglevel error 2>$ErrLogPath")
        Write-Verbose "Arguments = $argstring"
        Write-Verbose "Command:$sb"
        $Job = Start-Job -Name $SessionName -ScriptBlock $sb

    
        $Logskip = 0
        while(($Job|Get-Job).State -eq "Running")
        {
            if(test-path $ErrLogPath)
            {
                $errlog = @(gc $ErrLogPath|select -Skip $Logskip)
                if($errlog.count)
                {
                    $Logskip = $logskip + $errlog.Count
                }

                $errlog|%{
                    Write-Error "FFMPEG Error> $_"
                }
                
                # $errlog
            }
        }

        $out = $job|Receive-Job -wait
        $out
    }
    
    end {
        
    }
}