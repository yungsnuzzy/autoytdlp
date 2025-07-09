# autoytdlp
Auto downloads youtube videos per channel, and updates/maintains them automatically. 

There are 3 batch files included for windows. You also need yt-dlp from here: https://github.com/yt-dlp/yt-dlp, and should ideally bundle ffmpeg from here: https://ffmpeg.org/download.html#build-windows. Keep ffmpeg in a folder next to yt-dlp. 

## Initial setup:

Start by creating folders for each channel you want to download videos for. 
Your folder structure should look like this:

D:\Videos\Youtube\Channel1\\
**Channel2\\

------------------Channel3\\

Once that's done, run script SetupYTDLP.bat.

Start by providing the tool with the default location to save files. This is the "Youtube" folder in the structure example above. 
It will create a default.cfg file next to wherever you placed the script, containing the location you provided. 

The script will then loop through the folders, in this case, channel1, channel2, and channel3. 

For each channel, it will ask for the channel link, and your quality preference. It will then save that info in config.cfg for future use. 

Since this is your first run, provide the tool with the "start" date. If you want the entire channel, use 19700101. 

After the files are downloaded, you can switch to used Auto-YT-dlp.bat. 

## Using Auto-YT-dlp

This job can be run manually or scheduled with task manager. It will check the files present in your channel folders and download any items newer than the last one. 

