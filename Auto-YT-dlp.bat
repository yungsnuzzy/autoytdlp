@echo off
setlocal enabledelayedexpansion
echo Checking for default.cfg file...
REM Get script directory
set "scriptDir=%~dp0"

REM Check for default.cfg and validate its contents
set "channelsRoot="
if exist "%scriptDir%default.cfg" (
    for /f "usebackq delims=" %%D in ("%scriptDir%default.cfg") do set "channelsRoot=%%D"
    if not defined channelsRoot (
        powershell write-host -fore darkred -back white default.cfg is empty. 
    ) else if not exist "!channelsRoot!" (
        powershell write-host -fore darkred -back white Folder in default.cfg does not exist. 
        set "channelsRoot="
    ) else (
        powershell write-host -fore Magenta Default channels folder: !channelsRoot!
    )
)

REM If channelsRoot is not set, prompt user to select folder
if not defined channelsRoot (
    powershell write-host -fore darkred -back white Please select your channels folder.
    for /f "usebackq delims=" %%I in (`powershell -noprofile -command ^
        "Add-Type -AssemblyName System.Windows.Forms; $f = New-Object Windows.Forms.FolderBrowserDialog; $f.Description = 'Select your default channels folder'; if($f.ShowDialog() -eq 'OK'){ $f.SelectedPath }"`) do (
        set "channelsRoot=%%I"
    )
    echo !channelsRoot!>"%scriptDir%default.cfg"
    powershell write-host -fore Magenta Default channels folder is: !channelsRoot!
)

if not defined channelsRoot (
    powershell write-host -fore Red No channels folder selected. Exiting.
    exit /b 1
)
echo.
echo.
REM Loop through subfolders (channels)
for /d %%C in ("%channelsRoot%\*") do (
    set "channelFolder=%%C"
    set "configFile=%%C\config.cfg"
    powershell write-host -fore darkgreen **Current channel: %%~nxC
    REM If config.cfg missing, prompt for info and create it
    if not exist "!configFile!" (
        echo "config.cfg not found for %%~nxC."
        set /p channelLink="Enter YouTube channel URL for %%~nxC: "
        echo Select video quality for %%~nxC:
        echo 1. 1080p
        echo 2. 720p
        set /p qualityPref="Enter 1 or 2: "
        echo !channelLink! > "!configFile!"
        echo !qualityPref! >> "!configFile!"
    )

    REM Read config.cfg (first line: channel link, second line: quality)
    set "lineNum=0"
    for /f "usebackq delims=" %%L in ("!configFile!") do (
        set /a lineNum+=1
        if !lineNum! equ 1 set "channelLink=%%L"
        if !lineNum! equ 2 set "qualityPref=%%L"
    )

    REM Set yt-dlp format string using "contains" logic
    echo "!qualityPref!" | findstr /c:"1" >nul
    if !errorlevel! == 0 (
        set "format=bestvideo[height=1080]+bestaudio/best[height=1080]/best"
    ) else (
        echo "!qualityPref!" | findstr /c:"2" >nul
        if !errorlevel! == 0 (
            set "format=bestvideo[height=720]+bestaudio/best[height=720]/best"
        ) else (
            set "format=bestvideo+bestaudio/best"
        )
    )

    REM Find latest video date in folder (Title - YYYY-MM-DD.mp4) and count files
    echo.
    powershell write-host -fore darkblue -back darkgray [Searching for latest video date in folder: !channelFolder!.... please wait]
    set "latestDate="
    set "fileCount=0"
    for %%F in ("!channelFolder!\*.mp4") do (
        set "fname=%%~nF"
        call set "maybeDate=%%fname:~-10,10%%"
        REM Check if date is in YYYY-MM-DD format
        call echo !maybeDate! | findstr /r "^[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]" >nul
        if !errorlevel! == 0 (
            if "!maybeDate!" GTR "!latestDate!" set "latestDate=!maybeDate!"
        )
        set /a fileCount+=1
    )
    echo.
    powershell write-host -fore DarkCyan Number of .mp4 files for %%~nxC: !fileCount!
    powershell write-host -fore Green -back white Latest video date found: !latestDate!

    REM If no files, set startDate to 19700101, else increment latestDate by 1 day
    if not defined latestDate (
        set "startDate=19700101"
    ) else (
        REM Convert YYYY-MM-DD to YYYYMMDD and increment by 1 day using PowerShell
        for /f %%S in ('powershell -noprofile -command "([datetime]'!latestDate!').AddDays(1).ToString('yyyyMMdd')"') do set "startDate=%%S"
    )

    REM Run yt-dlp for this channel
    echo Link for channel: !channelLink!
    powershell write-host -fore Cyan Download start date: !startDate!
    echo Format: !format!
    echo Folder: !channelFolder!
    echo.
    "C:\Program Files\ytdlp\yt-dlp.exe" --output "!channelFolder!\%%(title)s - %%(upload_date>%%Y-%%m-%%d)s.%%(ext)s" --format "!format!" --merge-output-format mp4 --dateafter "!startDate!" "!channelLink!" --add-metadata --break-on-reject
    echo.
    echo --------------------------------------------------------------------------------
)

echo All channels processed.
timeout 15