<#
.SYNOPSIS
Sets environment variable path to ffmpeg

.DESCRIPTION
sets enviornment variable in accorance to the selected scope

.PARAMETER Path
Parameter description

.PARAMETER Scope
Parameter description

.EXAMPLE
An example

.NOTES
General notes
#>
function Set-FFPath {
    [CmdletBinding()]
    param (
        [String]$Path,
        [System.EnvironmentVariableTarget]$Scope = "User"
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
            else {
                Write-Verbose "Not adding to env, as its already set"
            }
        }
    }
    
    end {
    }
}