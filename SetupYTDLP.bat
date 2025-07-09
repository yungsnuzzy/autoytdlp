@echo off
setlocal

:: Prompt for the YouTube channel URL
set /p channelURL="Enter the YouTube channel URL: "

:: Auto-detect cookies file in user's Downloads folder
set "userProfile=%USERPROFILE%"
set "cookies="
for %%F in ("%userProfile%\Downloads\*cookies.txt") do (
    set "cookies=%%F"
    goto :foundCookies
)
:foundCookies
if not defined cookies (
    echo No cookies.txt file found in %userProfile%\Downloads. Proceeding without cookies.
) else (
    echo Using cookies file: %cookies%
)

:: Prompt for quality selection
echo Select video quality:
echo 1. 1080p
echo 2. 720p
set /p qualityChoice="Enter 1 for 1080p or 2 for 720p: "

if "%qualityChoice%"=="1" (
    set "format=bestvideo[height=1080]+bestaudio/best[height=1080]/best"
) else if "%qualityChoice%"=="2" (
    set "format=bestvideo[height=720]+bestaudio/best[height=720]/best"
) else (
    echo Invalid selection. Defaulting to best quality.
    set "format=bestvideo+bestaudio/best"
)

:: Use PowerShell to open a folder picker dialog with a default location
set "defaultFolder=D:\VIDEO MEDIA\Youtube"
for /f "usebackq delims=" %%I in (`powershell -noprofile -command ^
    "Add-Type -AssemblyName System.Windows.Forms; $f = New-Object Windows.Forms.FolderBrowserDialog; $f.SelectedPath = '%defaultFolder%'; $f.Description = 'Select folder to save YouTube downloads'; if($f.ShowDialog() -eq 'OK'){ $f.SelectedPath }"`) do (
    set "saveFolder=%%I"
)

if "%saveFolder%"=="" (
    echo No folder selected. Exiting.
    exit /b 1
)
echo %saveFolder% selected for saving videos.

:: Prompt for the start date (format: YYYYMMDD)
set /p startDate="Enter the start date (YYYYMMDD): "

:: Show the yt-dlp command for debugging
echo Running yt-dlp command:
if defined cookies (
    echo "C:\Program Files\ytdlp\yt-dlp.exe" --cookies "%cookies%" "%channelURL%" --output "%saveFolder%\%%(title)s - %%(upload_date>%%Y-%%m-%%d)s.%%(ext)s" --format "%format%" --merge-output-format mp4 --dateafter "%startDate%" --no-check-formats --add-metadata
) else (
    echo "C:\Program Files\ytdlp\yt-dlp.exe" "%channelURL%" --output "%saveFolder%\%%(title)s - %%(upload_date>%%Y-%%m-%%d)s.%%(ext)s" --format "%format%" --merge-output-format mp4 --dateafter "%startDate%" --no-check-formats --add-metadata
)

:: Actually run yt-dlp
if defined cookies (
    "C:\Program Files\ytdlp\yt-dlp.exe" --cookies "%cookies%" "%channelURL%" --output "%saveFolder%\%%(title)s - %%(upload_date>%%Y-%%m-%%d)s.%%(ext)s" --format "%format%" --merge-output-format mp4 --dateafter "%startDate%" --no-check-formats --add-metadata
) else (
    "C:\Program Files\ytdlp\yt-dlp.exe" "%channelURL%" --output "%saveFolder%\%%(title)s - %%(upload_date>%%Y-%%m-%%d)s.%%(ext)s" --format "%format%" --merge-output-format mp4 --dateafter "%startDate%" --no-check-formats --add-metadata
)

endlocal
echo Download completed. Files saved in "%saveFolder%".
timeout 10
