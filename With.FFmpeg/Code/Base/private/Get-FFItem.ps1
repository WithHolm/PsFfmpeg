
function Get-FfItem {
    [CmdletBinding()]
    [outputtype([system.io.fileinfo],[uri])]
    param (
        [parameter(ValueFromPipeline)]
        $InputItem
    )
    
    begin {
        
    }
    
    process {
        if ($InputItem -is [string]) {
            if($InputItem -like "http*")
            {
                Write-Output ([uri]$InputItem)
                # $InputItem = [uri]$InputItem
            }
            else {
                Write-Output (get-item $InputItem)
                # $InputItem = get-item $InputItem
            }
        }
        elseif ($InputItem -is [System.IO.FileInfo] -or $InputItem -is [uri]) {
            Write-Output $InputItem
        }
        elseif ($InputItem -is [System.IO.DirectoryInfo]) {
            throw "Cannot handle directories yet"
        }
        else {
            throw "Unkown input: $($InputItem.gettype())"
        }
    }
    
    end {
        
    }
}