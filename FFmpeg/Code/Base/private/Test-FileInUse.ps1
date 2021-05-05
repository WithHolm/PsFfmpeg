function Test-FileInUse {
    [CmdletBinding()]
    param (
        [System.IO.FileInfo]$File,
        [switch]$throw
    )
    
    begin {
               <# c# https://stackoverflow.com/questions/876473/is-there-a-way-to-check-if-a-file-is-in-use
         try
        {
            using(FileStream stream = file.Open(FileMode.Open, FileAccess.Read, FileShare.None))
            {
                stream.Close();
            }
        }
        catch (IOException)
        {
            //the file is unavailable because it is:
            //still being written to
            //or being processed by another thread
            //or does not exist (has already been processed)
            return true;
        }

        //file is not locked
        return false;
        #>
    }
    
    process {
        try{
            #basially try to open the file wo/ reading content.
            #If another process has put a lock on the file, then it throws, returning true
            $Filestream = $File.Open("Open","read","none")
            $Filestream.Close()
        }
        catch [System.IO.IOException]{
            if()
            return $true
        }

        #if file is not in use, return false
        return $false
    }
    
    end {
        
    }
}