# With.FFMPEG
Handler for ffmpeg

## Usage

This module relies on ffmpeg.exe and needs to have the parent folder registered in `$env:path` to work properly, 

### You dont have FFMPEG?
FFMEG can be installed using `install-ffmpeg -scope {Process|User|Machine}`. 

#### Scope
Define what context you install to.

**For Windows:**  
* `Process` saves ffmpeg in `$env:TEMP\FFmpeg` and sets process environment variable  
* `User` Saves ffmpeg in `$env:LOCALAPPDATA\FFmpeg` and sets user environment variable  
* `Machine` saves ffmpeg in `$env:ProgramData\FFmpeg` and sets machine environment variable

Every install cleans out the directory before continuing. makre sure you don't use ffmpeg if you have it installed and run it again.

### You have already downloaded a version of ffmpeg?
set the path to ffmpeg by using `set-ffpath -scope {Process|User|Machine}`.  

#### Scope
Decieds in what context you set the system variable. defaults to `user`


## Commands

### Convert-FFItem
Converts the selected file to the format of your choosing

**Example:**
``` powershell
#Find every .wav in c:\path (or subfolders)
$Items = Gci 'c:\Path' -recurse -file -filter "*.wav"

#Converts those items in place.
$items|Convert-FFItem -OutFormat mp3

#Converts those items to c:\otherpath
$items|Convert-FFItem -OutFormat mp3 -OutFolder 'c:\Otherpath'

#Converts those items to c:\otherpath AND replaces any files that have been created with the same name
$items|Convert-FFItem -OutFormat mp3 -OutFolder 'c:\Otherpath' -force
```