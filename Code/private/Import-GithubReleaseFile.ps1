function Import-GithubReleaseFile {
    [CmdletBinding()]
    [outputtype([system.io.fileinfo])]
    param (
        [parameter(Mandatory)]
        [String]$Repo,
        [String]$Tag = "latest",
        [parameter(Mandatory)]
        [string[]]$AssetName,
        [parameter(Mandatory)]
        [System.IO.DirectoryInfo]$OutputFolder,
        [Switch]$Force
    )
    
    begin {
        if(!$OutputFolder.Exists)
        {
            $OutputFolder.Create()
        }
    }
    
    process {
        $Uri = "https://api.github.com/repos/$repo/releases/$tag"
        Write-Verbose "$url"
        $request = Invoke-RestMethod $uri
        if($Repo -notmatch "[a-zA-Z0-9-_.]+\/[a-zA-Z0-9-_.]+")
        {
            throw "Need a repo name 'user/repo'"        
        }
        if(@($request.assets).count -eq 0)
        {
            throw "No assets where found for the github release '$repo', tag '$tag'"
        }

        $Todownload = @()
        foreach($AName in $AssetName)
        {
            $asset = $request.assets|where{$_.name -like $AName}
            if(!$asset)
            {
                throw "Could not find asset with the name of '$AName'"
            }

            $Todownload += $asset
        }

        write-verbose "Found $($Todownload.count) assets to download"
        $Todownload|%{
            $OutFile = join-path $OutputFolder $_.name
            if(test-path $outfile)
            {
                Write-Verbose "Found already downloaded file: $outfile"
                Write-Output ([system.io.fileinfo]$OutFile)
            }
            else {
                Write-Verbose "Downloading $($_.name) to $outfile"
                Invoke-WebRequest -Uri $_.browser_download_url -OutFile $OutFile
                Write-Output ([system.io.fileinfo]$OutFile)
            }
        }
    }
    
    end {
        
    }
}
# Import-GithubReleaseFile -Repo "BtbN/FFmpeg-Builds" -Verbose -AssetName '*win64-gpl.zip' -OutputFolder (join-path $pwd.path "test")
