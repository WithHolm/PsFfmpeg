#Using $psscriptroot\Get-FfItem.ps1
function Convert-Ffitem
{
    [CmdletBinding()]
    param (
        [parameter(ValueFromPipeline, Mandatory)]
        $InputItem,
        
        [parameter(ParameterSetName = "Inplace")]
        [Switch]$InPlace,
        
        [parameter(
            ParameterSetName = "Inplace", 
            HelpMessage = "append a name to the conversion. this will be applied as a suffix to the name Name.wav -> Name{appendname}.wav"
        )]
        [string]$AppendName,

        [Switch]$Force,

        [Switch]$IgnoreExisting,

        [System.IO.FileInfo]$OutputItem,

        [switch]$Passthru
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
        $ParamAttrib.ParameterSetName = 'Inplace'
        $AttribColl = New-Object  System.Collections.ObjectModel.Collection[System.Attribute]
        $AttribColl.Add($ParamAttrib)
        $Codec = (Get-FfFormat).extension
        $AttribColl.Add((New-Object  System.Management.Automation.ValidateSetAttribute($Codec)))
        $RuntimeParam = New-Object System.Management.Automation.RuntimeDefinedParameter('Format', [string], $AttribColl)
        $RuntimeParamDic.Add('Format', $RuntimeParam)
        #endregion

        return  $RuntimeParamDic
    }
    
    begin
    {
        if ([string]::IsNullOrEmpty($script:_cancel))
        {
            $script:_cancel = $false
        }

        if ($Force -and $IgnoreExisting)
        {
            throw "Cannot enable -Force and -IgnoreExisting as the same time."
        }
    }
    
    process
    {
        #If cancel was enabled in a previous pipeline run
        if ($script:_cancel)
        {
            Write-Verbose "ignoring conversion of $inputitem because cancel was triggered"
            return
        }

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
            Write-Error "$($item.name): the extension '$($item.Extension.Substring(1))' is not supported by ffmpeg"
            return
        }

        # $Item = $InputItem
        $arguments += @{i = "'$Item'" }

        if ($PSCmdlet.ParameterSetName -eq "Inplace")
        {
            $OutputName = "$($item.basename)"
            if(![string]::IsNullOrEmpty($AppendName))
            {
                $OutputName += $AppendName
            }
            $OutputName += ".$($PSBoundParameters.Format)"

            $OutputItem = [System.IO.FileInfo]"$($item.Directory.FullName)\$OutputName"
        }
        $arguments += "'$($OutputItem.FullName)'"
        if ($OutputItem.Exists -and !$Force)
        {
            $Title = "File already exists"
            $Info = "Do you want to overwrite?"
            $options = [System.Management.Automation.Host.ChoiceDescription[]] @("&Yes", "&No", "&Cancel")
            [int]$defaultchoice = 0
            $opt = $host.UI.PromptForChoice($Title, $Info, $Options, $defaultchoice)
            switch ($opt)
            {
                0
                {
                    $arguments += "-y"
                }
                1
                {
                    Write-Verbose "No, canceling this run."
                    return
                }
                2
                {
                    $script:_cancel = $true
                    return  
                }
            }
        }
        elseif ($Force)
        {
            $arguments += "-y"
        }

        if ($OutputItem.Exists -and (Test-FileInUse $OutputItem))
        {
            Write-Error "OutputFile '$OutputItem' is in use by another process"
            return  
        }
        Invoke-Ff -App FFmpeg -arguments $arguments

        if ($Passthru)
        {
            $OutputItem
        }
    }
    
    end
    {
        $script:_cancel = $false
    }
}