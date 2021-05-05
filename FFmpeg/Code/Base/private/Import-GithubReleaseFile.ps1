function Import-GithubReleaseFile
{
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
    
    begin
    {
        if (!$OutputFolder.Exists)
        {
            $OutputFolder.Create()
        }
    }
    
    process
    {
        $Uri = "https://api.github.com/repos/$repo/releases/$tag"
        Write-Verbose "$url"
        $request = Invoke-RestMethod $uri
        if ($Repo -notmatch "[a-zA-Z0-9-_.]+\/[a-zA-Z0-9-_.]+")
        {
            throw "Need a repo name 'user/repo'"        
        }
        if (@($request.assets).count -eq 0)
        {
            throw "No assets where found for the github release '$repo', tag '$tag'"
        }

        $Todownload = @()
        foreach ($AName in $AssetName)
        {
            $asset = $request.assets | where { $_.name -like $AName }
            if (!$asset)
            {
                throw "Could not find asset with the name of '$AName'"
            }

            $Todownload += $asset
        }

        write-verbose "Found $($Todownload.count) assets to download"
        $Todownload | % {
            $OutFile = join-path $OutputFolder $_.name
            if (test-path $outfile)
            {
                Write-Verbose "Found already downloaded file: $outfile"
                Write-Output ([system.io.fileinfo]$OutFile)
            }
            else
            {
                Write-Verbose "Downloading $($_.name) to $outfile"
                Invoke-Download -Uri $_.browser_download_url -OutFile $OutFile
                Write-Output ([system.io.fileinfo]$OutFile)
            }
        }
    }
    
    end
    {
        
    }
}

function Invoke-Download
{
    param(
        [uri]$Url,
        [System.IO.FileInfo]$OutFile
    )
    $request = [System.Net.HttpWebRequest]::Create($uri)
    $request.set_Timeout(15000) #15 second timeout
    $response = $request.GetResponse()
    $totalLength = [System.Math]::Floor($response.get_ContentLength() / 1024)
    $responseStream = $response.GetResponseStream()
    $targetStream = New-Object -TypeName System.IO.FileStream -ArgumentList $OutFile, Create
    $buffer = new-object byte[] 10KB
    $count = $responseStream.Read($buffer, 0, $buffer.length)
    $downloadedBytes = $count
    while ($count -gt 0)
    {
        $targetStream.Write($buffer, 0, $count)
        $count = $responseStream.Read($buffer, 0, $buffer.length)
        $downloadedBytes = $downloadedBytes + $count
        Write-Progress -activity "Downloading file '$($url.split('/') | Select -Last 1)'" -status "Downloaded ($([System.Math]::Floor($downloadedBytes/1024))K of $($totalLength)K): " -PercentComplete ((([System.Math]::Floor($downloadedBytes / 1024)) / $totalLength) * 100)
    }

    Write-Progress -activity "Finished downloading file '$($url.split('/') | Select -Last 1)'" -Completed
    $targetStream.Flush()
    $targetStream.Close()
    $targetStream.Dispose()
    $responseStream.Dispose()
}
