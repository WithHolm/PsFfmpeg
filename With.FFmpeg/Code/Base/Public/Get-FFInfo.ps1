function Get-FFInfo {
    [CmdletBinding()]
    param (
        [parameter(ValueFromPipeline, Mandatory)]
        $InputItem
    )
    
    begin {
        
    }
    
    process {
        $InputItem = $InputItem|Get-FfItem

        # if()
        # $arguments = 
        Invoke-FF -App FFprobe -arguments @($InputItem.tostring(),"-print_format json -show_format -show_streams")
    }
    
    end {
        
    }
}