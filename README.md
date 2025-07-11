# autoytdlp
Auto downloads youtube videos per channel, and updates/maintains them automatically. 

This is a single batch file designed to automatically collect, or process new youtube videos. Naming and metadata are designed for adding content to emby, plex, etc. 

Currently only built for windows, but could be converted for linux, mac, etc. It's really just a heap of file commands and lazy code to make downloads simple. 

### Requirements
1. You need a windows exe version of yt-dlp from here: https://github.com/yt-dlp/yt-dlp
2. You should ideally bundle ffmpeg from here: https://ffmpeg.org/download.html#build-windows. Keep ffmpeg in a folder next to yt-dlp. 
3. Put the downloaded script somewhere safe. It will write a few files next to itself during runs. 
4. Check out the cookies section below. You'll need those to avoid errors. 

As a note, I've scraped large channels with this script without issue/ban/etc. 

PLEASE don't run 2 scripts at the same time. Really bad stuff could happen. 


## Using Auto-YT-dlp

This script is designed to tell if you've used it before, or if this is an initial setup. 

### First run (setup)

If this is a new setup, provide the channels root directory. The one that will contain your channel folders. 

You'll then be prompted to provide channel URLs and quality preferences, as well as the start date for channel downloads. If you enter 20250601, everything AFTER June 01, 2025 will be downloaded for that channel. 

### Subsequent runs

This job can be run manually or scheduled with task scheduler. It will check the files present in your channel folders and download any items newer than the last one, or newer than the start date, if it's present in config.cfg in the channel folder. 

### Adding a new channel after your initial run

To add a new channel later, simply create an empty folder alongside your existing channel folders. The tool will pick it up, ask for the URL and quality preference, and then download immediately. 

*this appears to, at the moment, download all files for the channel. I'll put in a start date check here in the future*. 


### **cookies** - Make sure you follow the steps below for providing this tool with cookies that it needs to complete downloads. 

1. Open an incognito or private browsing session. 
2. Go to youtube.com and sign in. Do not open any other tabs. 
3. After signin, go to [youtube.com/robots.txt](https://www.youtube.com/robots.txt). 
4. Export your cookies using a tool like : https://chromewebstore.google.com/detail/get-cookiestxt-locally/cclelndahbckbenkjhflpdbgdldlbecc
5. **Switch the export format from JSON to NETSKOPE cookies**
6. Use the Export As button and save the resulting file in your downloads folder. The tool will find it from there. 
