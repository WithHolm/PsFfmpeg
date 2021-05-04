function Install-FFmpeg {
    [CmdletBinding()]
    param (
        # [parameterset(
        #     "User",
        #     "Machine",
        #     "Process"
        # )]
        [System.EnvironmentVariableTarget]$Scope = "Process"
    )
    
    begin {
        $OutputFolder = "$env:LOCALAPPDATA\ffmpeg"
        $FileFilter= "*win64-gpl-shared.zip"
    }
    
    process {
        $OsOptions = @{
            "Windows_NT" = @{
                Github = @{
                    Repo = 'BtbN/FFmpeg-Builds'
                    tag = 'latest'
                    AssetName = "*win64-gpl-shared.zip"
                }
                Directories =@{
                    Process="$env:TEMP\FFmpeg"
                    User="$env:LOCALAPPDATA\FFmpeg"
                    Machine="$env:ProgramData\FFmpeg"
                }
            }
        }
        if($env:OS -notin $OsOptions.Keys)
        {
            throw "Have not created options for '$env:os'"
        }

        $GitHubRelease = $OsOptions[$env:OS].github
        # $GitHubRelease
        $GHFile = Import-GithubReleaseFile @GitHubRelease -OutputFolder $env:TEMP

        $PathString = ""
        $UsingPath = $OsOptions[$env:os].Directories[$($Scope.ToString())]
        switch($env:OS)
        {
            "Windows_NT"{
                Write-Verbose "Expanding zip to '$UsingPath'"
                if(Test-Path $UsingPath)
                {
                    Write-verbose "cleaning $UsingPath"
                    gci $UsingPath|remove-item -Force -Recurse
                }
                Expand-Archive -Path $GHFile -DestinationPath $UsingPath -ErrorAction Stop

                #Unzip sometimes sets directory to {DestinationPath}\{Path.basename}. fixing that below
                $zipdir = [System.IO.DirectoryInfo]"$UsingPath\$($GHFile.BaseName)"
                if($zipdir.Exists)
                {
                    #move items from zip destination\{zip.basename} to actual destination
                    gci $zipdir.FullName|Move-Item -Destination $UsingPath
                    $zipdir.Delete()
                }

                $ffmpegexe = gci $UsingPath -Filter "*ffmpeg.exe" -Recurse|select -first 1

                # $ffmpegexe
                $PathString = $ffmpegexe.Directory.FullName
            }
        }
        
        if($env:Path -notlike "*;$PathString;*")
        {
            Write-Verbose "Setting $scope Environment Variable for path"
            [System.Environment]::SetEnvironmentVariable("Path","$env:Path;$PathString",$Scope)
            $env:Path+=";$PathString"
        }
    }
    
    end {
        
    }
}