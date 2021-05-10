function Get-FFInfo {
    [CmdletBinding()]
    param (
        [parameter(ValueFromPipeline, Mandatory)]
        $InputItem
    )
    
    begin {
        
    }
    
    process {
        $arguments = 
        Invoke-FF -App FFprobe -arguments @("-print_format json -show_format -show_streams")
    }
    
    end {
        
    }
}