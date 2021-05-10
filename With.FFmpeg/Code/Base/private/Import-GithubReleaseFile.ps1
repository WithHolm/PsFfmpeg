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
            $asset = $request.assets | Where-Object { $_.name -like $AName }|Where-Object {$_}
            if (!$asset)
            {
                throw "Could not find asset with the name of '$AName'"
            }

            $Todownload += $asset
        }

        write-verbose "Found $($Todownload.count) assets to download"
        $Todownload | ForEach-Object {
            $OutFile = join-path $OutputFolder $_.name
            if (test-path $outfile)
            {
                Write-Verbose "already downloaded file: $outfile"
                Write-Output ([System.IO.FileInfo]$OutFile)
            }
            else
            {
                Write-Verbose "Downloading $($_.name) to $outfile"
                Invoke-Download -Url $_.browser_download_url -OutFile $OutFile
                Write-Output ([System.IO.FileInfo]$OutFile)
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
        [ValidateNotNullOrEmpty()]
        [parameter(Mandatory)]
        [uri]$Url,
        
        [ValidateNotNullOrEmpty()]
        [parameter(Mandatory)]
        [System.IO.FileInfo]$OutFile
    )
    Write-verbose "Downloading $url"
    $request = [System.Net.HttpWebRequest]::Create($url)
    $request.set_Timeout(15000) #15 second timeout
    $EAP = $ErrorActionPreference
    try{
        $ErrorActionPreference = "stop"
        $response = $request.GetResponse()
    }catch{
        throw $_
    }
    $ErrorActionPreference = $EAP
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
        Write-Progress -activity "Downloading file '$($url.Query | Select -Last 1)'" -status "Downloaded ($([System.Math]::Floor($downloadedBytes/1024))K of $($totalLength)K): " -PercentComplete ((([System.Math]::Floor($downloadedBytes / 1024)) / $totalLength) * 100)
    }

    Write-Progress -activity "Finished downloading file '$($url.split('/') | Select -Last 1)'" -Completed
    $targetStream.Flush()
    $targetStream.Close()
    $targetStream.Dispose()
    $responseStream.Dispose()
}

# Install-FFmpeg -Scope User