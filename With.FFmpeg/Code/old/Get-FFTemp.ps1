function Get-FFTemp {
    [CmdletBinding()]
    param (
        
    )
    
    begin {
        
    }
    
    process {
        $path = (Join-Path $env:TEMP "psffmpeg")
        new-item $path -ItemType Directory -Force|Out-Null
        new-item (join-path $path "Log") -ItemType Directory -Force|Out-Null

        return (Join-Path $env:TEMP "psffmpeg")
    }
    
    end {
        
    }
}