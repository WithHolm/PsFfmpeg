#Using $psscriptroot\Get-FfItem.ps1
function Convert-FFitem
{
    [CmdletBinding()]
    param (
        [parameter(ValueFromPipeline, Mandatory)]
        $InputItem,
        [Switch]$Force,
        [System.IO.DirectoryInfo]$OutputFolder
    )
    dynamicparam
    {
        $RuntimeParamDic = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary

        # #region OutputCodec
        # $ParamAttrib = New-Object System.Management.Automation.ParameterAttribute
        # $ParamAttrib.Mandatory = $false
        # $ParamAttrib.ParameterSetName = '__AllParameterSets'
        # $AttribColl = New-Object  System.Collections.ObjectModel.Collection[System.Attribute]
        # $AttribColl.Add($ParamAttrib)
        # $Codec = (Get-FfCodec).name
        # $AttribColl.Add((New-Object  System.Management.Automation.ValidateSetAttribute($Codec)))
        # $RuntimeParam = New-Object System.Management.Automation.RuntimeDefinedParameter('OutputCodec', [string], $AttribColl)
        # $RuntimeParamDic.Add('OutputCodec', $RuntimeParam)
        # #endregion

        #region OutputFormat
        $ParamAttrib = New-Object System.Management.Automation.ParameterAttribute
        $ParamAttrib.Mandatory = $true
        # $ParamAttrib.ParameterSetName = 'Inplace'
        $AttribColl = New-Object  System.Collections.ObjectModel.Collection[System.Attribute]
        $AttribColl.Add($ParamAttrib)
        $Codec = (Get-FfFormat).extension
        $AttribColl.Add((New-Object  System.Management.Automation.ValidateSetAttribute($Codec)))
        $RuntimeParam = New-Object System.Management.Automation.RuntimeDefinedParameter('Format', [string], $AttribColl)
        $RuntimeParamDic.Add('Format', $RuntimeParam)
        #endregion

        return  $RuntimeParamDic
    }
    begin{}
    process
    {
        #region Validation
        $arguments = @()
        if ($InputItem -is [string])
        {
            $InputItem = get-item $InputItem
        }

        if ($InputItem -is [System.IO.FileInfo])
        {
            $item = $InputItem
        }
        elseif ($InputItem -is [System.IO.DirectoryInfo])
        {
            throw "Cannot handle directories yet"
        }
        else
        {
            throw "Unkown input: $($inputitem.gettype())"
        }

        if ($item.Extension.Substring(1) -notin (Get-FfFormat).extension)
        {
            Write-Error "$($item.name): the extension '$($item.Extension)' is not supported by ffmpeg"
            return
        }
        #endregion

        # $Item = $InputItem
        $arguments += @{i="'$Item'"}

        if($OutputFolder)
        {
            if( -not $OutputFolder.Exists)
            {
                new-item $OutputFolder.FullName -ItemType Directory -Force|Out-Null
            }
        }
        else {
            $OutputFolder = $item.Directory
        }

        $outputFileName = [string]::Join(".",$item.BaseName,$PSBoundParameters.Format)
        $OutputItem = [System.IO.FileInfo](join-path $OutputFolder.FullName $outputFileName)

        if($OutputItem.Exists -and $Force)
        {
            # $OutputItem|remove-item
            $arguments += "-y"
        }
        elseif($OutputItem.Exists){
            Write-warning "Skipping $($item.name)"
            return $OutputItem
        }

        $arguments += "'$($OutputItem.FullName)'"

        if ($OutputItem.Exists -and (Test-FileInUse $OutputItem))
        {
            Write-Error "OutputFile '$OutputItem' is in use by another process"
            return  
        }
        Invoke-Ff -App FFmpeg -arguments $arguments

        $OutputItem
    }
    
    end
    {
        $script:_cancel = $false
    }
}