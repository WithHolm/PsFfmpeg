#Using $psscriptroot\Get-FfItem.ps1
<#
.SYNOPSIS
Short description

.DESCRIPTION
Long description

.PARAMETER InputItem
Item to 

.PARAMETER Force
Parameter description

.PARAMETER OutFolder
Parameter description

.EXAMPLE
An example

.NOTES
General notes
#>
function Convert-FFitem {
    [CmdletBinding()]
    param (
        [parameter(ValueFromPipeline, Mandatory)]
        $InputItem,
        [Switch]$Force,
        [string[]]$Arguments,
        [System.IO.DirectoryInfo]$OutFolder
    )
    dynamicparam {
        $RuntimeParamDic = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary

        #region OutputFormat
        $ParamAttrib = New-Object System.Management.Automation.ParameterAttribute
        $ParamAttrib.Mandatory = $true
        # $ParamAttrib.ParameterSetName = 'Inplace'
        $AttribColl = New-Object  System.Collections.ObjectModel.Collection[System.Attribute]
        $AttribColl.Add($ParamAttrib)
        # Init-FFmpeg
        $Codec = ($global:FFmpeg.Format).extension
        $AttribColl.Add((New-Object  System.Management.Automation.ValidateSetAttribute($Codec)))
        $RuntimeParam = New-Object System.Management.Automation.RuntimeDefinedParameter('OutFormat', [string], $AttribColl)
        $RuntimeParamDic.Add('OutFormat', $RuntimeParam)
        #endregion

        return  $RuntimeParamDic
    }
    begin {
        $list = New-Object System.Collections.Generic.List[object]
    }
    process {
        $OutFormat = $PSBoundParameters.OutFormat
        if ($InputItem -is [string]) {
            $InputItem = get-item $InputItem
        }

        if ($InputItem -is [System.IO.FileInfo]) {
            $list.Add($InputItem)
        }
        elseif ($InputItem -is [System.IO.DirectoryInfo]) {
            throw "Cannot handle directories yet"
        }
        else {
            throw "Unkown input: $($InputItem.gettype())"
        }
        
    }
    
    end {
        $CountLength = $list.Count.ToString().Length
        $ShowProgress = $list.Count -gt 1
        for ($i = 0; $i -le $list.Count; $i++) {

            $item = $list[$i]
            if($null -eq $item)
            {
                continue
            }
            #region Validation
            $arguments = @()

 
            if ($item.Extension.Substring(1) -notin (Get-FfFormat).extension) {
                Write-Error "$($item.name): the extension '$($item.Extension)' is not supported by ffmpeg"
                return
            }
            #endregion
 
            if($ShowProgress)
            {
                $itemCountString = ($i+1).ToString().PadLeft($CountLength,"0")
                Write-Progress -PercentComplete (($i/$list.Count)*100) -Activity "Converting Items to $OutFormat" -Status "[$itemCountString/$($list.Count)] $($Item.Name)"
            }

            # $Item = $InputItem
            $arguments += @{i = "'$($Item.FullName)'" }
 
            if ($OutputFolder) {
                if ( -not $OutputFolder.Exists) {
                    new-item $OutputFolder.FullName -ItemType Directory -Force | Out-Null
                }
            }
            else {
                $OutputFolder = $item.Directory
            }
 
            $outputFileName = [string]::Join(".", $item.BaseName, $OutFormat)
            $OutputItem = [System.IO.FileInfo](join-path $OutputFolder.FullName $outputFileName)
 
            if ($OutputItem.Exists -and $Force) {
                # $OutputItem|remove-item
                $arguments += "-y"
            }
            elseif ($OutputItem.Exists) {
                Write-warning "Skipping $($item.name)"
                return $OutputItem
            }
 
            $arguments += "'$($OutputItem.FullName)'"
 
            if ($OutputItem.Exists -and (Test-FileInUse $OutputItem)) {
                Write-Error "OutputFile '$OutputItem' is in use by another process"
                return  
            }
 
            if ($OutputItem.FullName -eq $input.fullname) {
                Throw "Input and output cannot be the same file"
            }
            Invoke-Ff -App FFmpeg -arguments $arguments
 
            Write-Output $OutputItem
        }
        if($ShowProgress)
        {
            Write-Progress -Activity "Converting Items to $OutFormat" -Completed
        }
    }
}