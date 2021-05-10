function Invoke-FF {
    [CmdletBinding()]
    param (
        [ValidateSet("FFmpeg","FFprobe","ffplay")] #,"FFplay","FFprobe"
        $App = "FFMpeg",
        $arguments,
        [switch]$IgnoreAllErrors
    )
    
    begin {
        #Figure out what log level to use. uses powershell native environment to figure this out
        <#
        ffmpeg docs
        ‘quiet, -8’:Show nothing at all; be silent. 
        ‘panic, 0’:Only show fatal errors which could lead the process to crash, such as an assertion failure. This is not currently used for anything. 
        ‘fatal, 8’:Only show fatal errors. These are errors after which the process absolutely cannot continue. 
        ‘error, 16’:Show all errors, including ones which can be recovered from. 
        ‘warning, 24’:Show all warnings and errors. Any message related to possibly incorrect or unexpected events will be shown. 
        ‘info, 32’:Show informative messages during processing. This is in addition to warnings and errors. This is the default value. 
        ‘verbose, 40’:Same as info, except more verbose. 
        ‘debug, 48’:Show everything, including debugging information. 
        ‘trace, 56’
        #>
        $LogLevel = "info"
        # if($ErrorActionPreference -eq 'stop'){$LogLevel = 'fatal'}
        # if($ErrorActionPreference -eq 'continue'){$LogLevel = 'error'}
        # if($ErrorActionPreference -in 'ignore',"SilentlyContinue"){$LogLevel = 'error'; [switch]$IgnoreAllErrors = $true}
        if($ErrorActionPreference -in 'ignore',"SilentlyContinue"){[switch]$IgnoreAllErrors = $true}
        if($VerbosePreference -ne "silentlycontinue"){$LogLevel = 'verbose'}
        if($DebugPreference -ne "silentlycontinue"){$LogLevel = 'debug'}

    }
    
    process {

        $argstring = @(
            "-hide_banner"
        )
        Foreach($arg in $arguments)
        {
            if($arg -is [hashtable])
            {
                $argstring += $arg.keys|%{
                    "-$($_) $($arg.$_)"   
                }
            }
            elseif($arg -is [string]) {
                if($arg -like "-*")
                {
                    $argstring += $arg
                }
                else {
                    $argstring += "'$arg'"
                }
            }
        }
        $Logpath = join-path $env:TEMP "PsFFmpeg\log"
        new-item -Path $Logpath -ItemType Directory -Force|Out-Null
        $TimeString = [datetime]::Now.ToString('s').Replace(":","-")
        $SessionName = "$App-$TimeString.log"
        $ErrLog = join-path $Logpath "Err-$SessionName"
        $errLogQ = "2>'$errlog'"
        $OkLog = join-path $Logpath "Info-$SessionName"
        $OkLogQ = "3>&1 4>&1 5>&1 6>&1 >>'$oklog'"

        $sb = [scriptblock]::Create("& $((get-command $app).Source) $($argstring -join " ") -v fatal") #-loglevel error 2>$ErrLogPath
        Write-Verbose "Arguments = $argstring"
        Write-Verbose "Command:$sb"
        $Job = Start-Job -Name $SessionName -ScriptBlock $sb

    
        # $Logskip = 0
        while(($Job|Get-Job).State -eq "Running")
        {
            # if(test-path $ErrLogPath)
            # {
            #     $errlog = @(gc $ErrLogPath|select -Skip $Logskip)
            #     if($errlog.count)
            #     {
            #         $Logskip = $logskip + $errlog.Count
            #     }

            #     # if($IgnoreErrors)
            #     # {
            #     #     $errlog|%{
            #     #         Write-Error "FFMPEG Error> $_"
            #     #     }
            #     # }
                
            #     # $errlog
            # }
        }

        $out = $job|Receive-Job -wait
        $out
        # return [System.IO.File]::ReadAllLines($OkLog)
    }
    
    end {
        
    }
}