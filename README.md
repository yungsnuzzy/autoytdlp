# autoytdlp
Auto downloads youtube videos per channel, and updates/maintains them automatically. 

There are 3 batch files included for windows. You also need yt-dlp from here: https://github.com/yt-dlp/yt-dlp, and should ideally bundle ffmpeg from here: https://ffmpeg.org/download.html#build-windows. Keep ffmpeg in a folder next to yt-dlp. 


## Using Auto-YT-dlp

This script is designed to tell if you've used it before, or if this is an initial setup. 

### First run (setup)

If this is a new setup, provide the channels root directory. The one that will contain your channel folders. 

You'll then be prompted to provide channel URLs and quality preferences, as well as the start date for channel downloads. If you enter 20250601, everything AFTER June 01, 2025 will be downloaded for that channel. 

### Subsequent runs

This job can be run manually or scheduled with task manager. It will check the files present in your channel folders and download any items newer than the last one, or newer than the start date, if it's present in config.cfg in the channel folder. 



### **cookies** - Make sure you follow the steps below for providing this tool with cookies that it needs to complete downloads. 

1. Open an incognito or private browsing session. 
2. Go to youtube.com and sign in. Do not open any other tabs. 
3. After signin, go to [youtube.com/robots.txt](https://www.youtube.com/robots.txt). 
4. Export your cookies using a tool like : https://chromewebstore.google.com/detail/get-cookiestxt-locally/cclelndahbckbenkjhflpdbgdldlbecc
5. **Switch the export format from JSON to NETSKOPE cookies**
6. Use the Export As button and save the resulting file in your downloads folder. The tool will find it from there. 
