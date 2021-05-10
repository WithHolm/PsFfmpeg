function Install-FFmpeg
{
    [CmdletBinding()]
    param (
        [System.EnvironmentVariableTarget]$Scope = "User"
    )
    
    begin
    {
        $OsOptions = @{
            "Windows_NT" = @{
                Github      = @{
                    Repo      = 'BtbN/FFmpeg-Builds'
                    tag       = 'latest'
                    AssetName = "*win64-gpl-shared.zip"
                }
                Directories = @{
                    Process = "$env:TEMP\FFmpeg"
                    User    = "$env:LOCALAPPDATA\FFmpeg"
                    Machine = "$env:ProgramData\FFmpeg"
                }
            }
        }
    }
    
    process
    {
        if ($env:OS -notin $OsOptions.Keys)
        {
            throw "Have not created options for '$env:os'"
        }

        $GitHubRelease = $OsOptions[$env:OS].github
        # $GitHubRelease
        $GHFile = Import-GithubReleaseFile @GitHubRelease -OutputFolder $env:TEMP

        $PathString = ""
        $UsingPath = $OsOptions[$env:os].Directories[$($Scope.ToString())]

        #Region Handle if FFmpeg Exists from before
        if ($env:path -like "*ffmpeg*")
        {
            $PossiblePath = split-path ($env:path.split(";") | ? {
                $_ -like "*ffmpeg\bin*"
            } | select -first 1) -Parent

            if($PossiblePath -ne $UsingPath)
            {
                $yes = New-Object System.Management.Automation.Host.ChoiceDescription '&Yes', 'Uses the found path'
                $no = New-Object System.Management.Automation.Host.ChoiceDescription '&No', "Uses '$UsingPath'"
                $options = [System.Management.Automation.Host.ChoiceDescription[]]($yes, $no)
                $result = $host.ui.PromptForChoice("Found path '$PossiblePath'", "Would you like to use this instead of '$UsingPath'? (might need Administrator/Elevated access)", $options, 1)
            
                switch ($result)
                {
                    0
                    {
                        $UsingPath = $PossiblePath
                    }
                }
            }
        }
        #endregion

        switch ($env:OS)
        {
            "Windows_NT"
            {
                Write-Verbose "Expanding zip '$($GHFile.FullName)' to '$UsingPath'"
                if (Test-Path $UsingPath)
                {
                    Write-verbose "cleaning $UsingPath"
                    gci $UsingPath | remove-item -Force -Recurse
                }

                Write-Verbose "Expanding zip"
                Expand-Archive -Path $GHFile.FullName -DestinationPath $UsingPath -ErrorAction Stop #-Verbose

                #Unzip sometimes sets directory to {DestinationPath}\{Path.basename}. fixing that below
                $zipdir = [System.IO.DirectoryInfo]"$UsingPath\$($GHFile.BaseName)"
                if ($zipdir.Exists)
                {
                    Write-verbose "moving items to subfolder of $($zipdir.FullName)"
                    #move items from zip destination\{zip.basename} to actual destination
                    gci $zipdir.FullName | Move-Item -Destination $UsingPath
                    $zipdir.Delete()
                }

                Write-Verbose "Getting path to exe"
                $ffmpegexe = gci $UsingPath -Filter "*ffmpeg.exe" -Recurse | select -first 1
                $PathString = $ffmpegexe.Directory.FullName
            }
        }
        
        Set-FFPath -Path $PathString -Scope $Scope
        Initialize-FFmpeg -Force
    }
    
    end
    {
        
    }
}

# Install-FFmpeg -Scope User