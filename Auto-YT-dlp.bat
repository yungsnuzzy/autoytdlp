@echo off
REM Get script directory
set "scriptDir=%~dp0"
echo [INFO] Started at %Date% @ %time% >> "%scriptdir%Auto-YT-dlp.log"
setlocal enabledelayedexpansion
echo Checking for default.cfg file...

REM --- Read default.cfg as name-value pairs ---
set "channelsRoot="
set "ytDlpPath="
if exist "%scriptDir%default.cfg" (
    for /f "usebackq tokens=1,* delims==" %%A in ("%scriptDir%default.cfg") do (
        if /I "%%A"=="channelsRoot" set "channelsRoot=%%B"
        if /I "%%A"=="ytDlpPath" set "ytDlpPath=%%B"
    )
)

REM --- Validate yt-dlp.exe path ---
if not defined ytDlpPath (
    powershell write-host -fore darkred -back white "yt-dlp.exe path not set in default.cfg."
) else if not exist "!ytDlpPath!" (
    powershell write-host -fore darkred -back white "yt-dlp.exe not found at: !ytDlpPath!"
    set "ytDlpPath="
)

REM --- Prompt for yt-dlp.exe location if missing/invalid ---
if not defined ytDlpPath (
    powershell write-host -fore Magenta "Please select your yt-dlp.exe location."
    for /f "usebackq delims=" %%P in (`powershell -noprofile -command ^
        "Add-Type -AssemblyName System.Windows.Forms; $f = New-Object Windows.Forms.OpenFileDialog; $f.Filter = 'yt-dlp.exe|yt-dlp.exe'; $f.Title = 'Select yt-dlp.exe'; if($f.ShowDialog() -eq 'OK'){ $f.FileName }"`) do (
        set "ytDlpPath=%%P"
    )
    if not defined ytDlpPath (
        powershell write-host -fore Red "No yt-dlp.exe selected. Exiting."
        echo [ERROR] No yt-dlp.exe selected. >> "%scriptdir%Auto-YT-dlp.log"
        exit /b 1
    )
)

REM --- Validate channelsRoot ---
if not defined channelsRoot (
    powershell write-host -fore darkred -back white "channelsRoot not set in default.cfg."
) else if not exist "!channelsRoot!" (
    powershell write-host -fore darkred -back white "Folder in default.cfg does not exist."
    set "channelsRoot="
) else (
    powershell write-host -fore gray [Found channels folder]
)

REM --- Prompt for channelsRoot if missing/invalid ---
if not defined channelsRoot (
    powershell write-host -fore darkred -back white "Please select your channels folder."
    for /f "usebackq delims=" %%I in (`powershell -noprofile -command ^
        "Add-Type -AssemblyName System.Windows.Forms; $f = New-Object Windows.Forms.FolderBrowserDialog; $f.Description = 'Select your default channels folder'; if($f.ShowDialog() -eq 'OK'){ $f.SelectedPath }"`) do (
        set "channelsRoot=%%I"
    )
    if not defined channelsRoot (
        powershell write-host -fore Red "No folder selected. Exiting."
        echo [ERROR] No folder selected. >> "%scriptdir%Auto-YT-dlp.log"
        exit /b 1
    )
)

REM --- Save/Update default.cfg with name-value pairs ---
(
    echo channelsRoot=!channelsRoot!
    echo ytDlpPath=!ytDlpPath!
) > "%scriptDir%default.cfg"

powershell write-host -fore Magenta "Using yt-dlp.exe: !ytDlpPath!"
powershell write-host -fore Magenta "Default channels folder is: !channelsRoot!"

REM --- Check if folder is empty ---
dir /b "!channelsRoot!\*" | findstr . >nul
if errorlevel 1 (
    set "addMoreChannels=Y"
    :addChannelsLoop
    if not defined channelAdded (
        set "channelAdded=0"
    )
    if "!channelAdded!"=="0" (
        echo.
        echo.
        set /p addMoreChannels="No channels found. Would you like to add a channel? (Y/N): "
    ) else (
        echo.
        set /p addMoreChannels="Would you like to add another channel? (Y/N): "
    )
    set "channelAdded=1"
    set "channelFolderName="
    set "channelLink="
    set "qualityPref="
    set "startDate="
    if /I "!addMoreChannels!"=="Y" (
        echo.
        set /p channelLink="Enter YouTube channel URL: "
        REM Ensure URL ends with /videos
        if /I not "!channelLink:~-7!"=="/videos" (
            set "channelLink=!channelLink!/videos"
        )
        REM Extract channel name after @ and before next / from the URL
        set "channelFolderName="
        echo "!channelLink!" | findstr /c:"@" >nul
        if !errorlevel! == 0 (
            for /f "tokens=2 delims=@" %%A in ("!channelLink!") do (
                for /f "delims=/ tokens=1" %%B in ("%%A") do set "channelFolderName=%%B"
            )
        ) else (
            powershell write-host -fore Red "Channel name not found in URL."
            set /p channelFolderName="Please enter a folder name for this channel: "
        )
        mkdir "!channelsRoot!\!channelFolderName!"
        powershell write-host -fore Green "[Created folder: !channelsRoot!\!channelFolderName!]"
        echo [INFO] Created channel folder !channelsRoot!\!channelFolderName! >> "%scriptdir%Auto-YT-dlp.log"
        REM Ask for quality
        echo.
        echo Select video quality:
        echo 1. 1080p
        echo 2. 720p
        set /p qualityPref="Enter 1 or 2: "
        REM Ask for start date
        echo.
        set /p setStartDate="Do you want to choose a start date for videos? ['N' will download all channel videos] (Y/N): "
        if /I "!setStartDate!"=="Y" (
            set /p startDate="Enter start date (YYYYMMDD): "
            (
                echo channelLink=!channelLink!
                echo qualityPref=!qualityPref!
                echo startDate=!startDate!
            ) > "!channelsRoot!\!channelFolderName!\config.cfg"
        ) else (
            (
                echo channelLink=!channelLink!
                echo qualityPref=!qualityPref!
            ) > "!channelsRoot!\!channelFolderName!\config.cfg"
        )
        goto :addChannelsLoop
    )
)

if not defined channelsRoot (
    powershell write-host -fore Red "No channels folder selected. Exiting."
    echo [ERROR] No default channels folder was selected. >> "%scriptdir%Auto-YT-dlp.log"
    exit /b 1
)
echo.
echo.

REM Find cookies.txt in user's Downloads folder
set "cookiesFile="
for %%K in ("%USERPROFILE%\Downloads\*cookies.txt") do (
    if exist "%%K" (
        set "cookiesFile=%%K"
        echo [INFO] Found cookies.txt file. >> "%scriptdir%Auto-YT-dlp.log"
        powershell write-host -fore Yellow "Found cookies file: %%K"
        goto :foundCookies
    )
)
if not defined cookiesFile (
    echo [WARN] Unable to find cookies.txt file. >> "%scriptdir%Auto-YT-dlp.log"
    powershell write-host -fore Red "Unable to find cookies.txt file."
)
:foundCookies

REM Loop through subfolders (channels)
for /d %%C in ("%channelsRoot%\*") do (
    set "channelFolder=%%C"
    set "configFile=%%C\config.cfg"
    powershell write-host -fore darkgreen "**Current channel: %%~nxC"
    echo [INFO] Current Channel: %%~nxC >> "%scriptdir%Auto-YT-dlp.log"
    REM If config.cfg missing, prompt for info and create it
    if not exist "!configFile!" (
        echo "config.cfg not found for %%~nxC."
        set /p channelLink="Enter YouTube channel URL for %%~nxC: "
        echo Select video quality for %%~nxC:
        echo 1. 1080p
        echo 2. 720p
        set /p qualityPref="Enter 1 or 2: "
        (
            echo channelLink=!channelLink!
            echo qualityPref=!qualityPref!
        ) > "!configFile!"
    )

    REM Read config.cfg as name-value pairs
    set "channelLink="
    set "qualityPref="
    set "startDate="
    for /f "usebackq tokens=1,* delims==" %%K in ("!configFile!") do (
        if /I "%%K"=="channelLink" set "channelLink=%%L"
        if /I "%%K"=="qualityPref" set "qualityPref=%%L"
        if /I "%%K"=="startDate" set "startDate=%%L"
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
    powershell write-host -fore darkblue -back darkgray "[Searching for latest video date in folder: !channelFolder!.... please wait]"
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
    powershell write-host -fore DarkCyan "Number of .mp4 files for %%~nxC: !fileCount!"
    powershell write-host -fore Green -back white "Latest video date found: !latestDate!"
    echo [INFO] Latest video date found: !latestDate! >> "%scriptdir%Auto-YT-dlp.log"

    REM If startDate is set (from config.cfg), use it. Otherwise, use latestDate logic.
    if defined startDate (
        powershell write-host -fore Yellow "Using start date from config.cfg: !startDate!"
    ) else (
        REM If no files, set startDate to 19700101, else increment latestDate by 1 day using PowerShell
        if not defined latestDate (
            set "startDate=19700101"
        ) else (
            for /f %%S in ('powershell -noprofile -command "([datetime]'!latestDate!').AddDays(1).ToString('yyyyMMdd')"') do set "startDate=%%S"
        )
    )
    set "startDate=!startDate: =!"
    REM Run yt-dlp for this channel
    echo Link for channel: !channelLink!
    powershell write-host -fore Cyan "Download start date: !startDate!"
    echo Format: !format!
    echo Folder: !channelFolder!
    echo.

    REM Add cookies.txt to yt-dlp command if found
    if defined cookiesFile (
        echo Using cookies file: !cookiesFile!
        "!ytDlpPath!" --output "!channelFolder!\%%(title)s - %%(upload_date>%%Y-%%m-%%d)s.%%(ext)s" --format "!format!" --merge-output-format mp4 --dateafter "!startDate!" "!channelLink!" --add-metadata --break-on-reject --cookies "!cookiesFile!"
    ) else (
        echo [WARN] Running without cookies file. This might cause download failures.  >> "%scriptdir%Auto-YT-dlp.log"
        "!ytDlpPath!" --output "!channelFolder!\%%(title)s - %%(upload_date>%%Y-%%m-%%d)s.%%(ext)s" --format "!format!" --merge-output-format mp4 --dateafter "!startDate!" "!channelLink!" --add-metadata --break-on-reject
    )
    echo.
    echo --------------------------------------------------------------------------------
)
echo [INFO] All channels processed. >> "%scriptdir%Auto-YT-dlp.log"
echo All channels processed.
timeout 15