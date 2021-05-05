function Set-FFPath {
    [CmdletBinding()]
    param (
        [String]$Path,
        [System.EnvironmentVariableTarget]$Scope = "Process"
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
            if ($env:Path -notlike "*$Path*")
            {
                Write-Verbose "Setting $scope Environment Variable for path '$Path'"
                [System.Environment]::SetEnvironmentVariable("Path", "$env:Path;$Path", $Scope)
                $env:Path += ";$Path"
            }
        }
    }
    
    end {
        
    }
}