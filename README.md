# A mod manager/creator for Space Beast Terror Fright, a game by Nornware

SBTF Mod Manager/Creator allows users to create mods and share them without having to share the game's entire assets as well as manage mods through setting a mod folder, enabling and disabling mods, and adjusting the mod load order.

## Requirements

[Microsoft .NET 9.0 Runtime](https://dotnet.microsoft.com/en-us/download/dotnet/9.0)

[SBTFTool](https://github.com/MisterIchor/sbtf_tool_batch/tree/main) by SquidingTin, modified by me.


## Installation
Download the release and extract it whereever you please. Then, download my modified version of [SBTFTool](https://github.com/MisterIchor/sbtf_tool_batch) and extract it inside the sbtftool folder located within the root of the manager/creator folder. 

Upon startup, SBTF Mod Manager/Creator will prompt you to provide a path to the game's sbtf_pub.nwf file. **This must be a file from version 60** as it was the last version supported by SBTFTool. In addition, two folders are created in the root directory: a hidden .temp folder for unpacking/repacking the game's assets, and a mods folder for storing .sbtfmod files created by SBTF Mod Manger/Creator. These can be changed through the settings in the start menu.

### How to get the right version of Space Beast Terror Fright?

1. Enable the steam console by typing ```steam://open/console``` into your web browser.
  - Alternatively, you can type ```steam://open/console``` into run.exe (if you are on windows) or ```steam steam://open/console``` into the terminal (if you are on linux).

2. Type or copy the following line into the console ```download_depot 357330 357331 5505261689257298877``` and hit enter. If done correctly, it will show something like ```Downloading depot 357331 (3 files, 277 MB) ... ```

3. When it is done, it will show the path where it has downloaded Update 60 in the console. Navigate to that path and copy the files into the directory where Space Beast Terror Fight is install. Overwrite all the files in the directory.

## Other Notes

SBTF Mod Manager/Creator creates a backup of the sbtf_pub.nwf file to make changing mods possible. This backup is in the same directory as Space Beast Terror Fright. With this in mind, ensure that you have enough space on your hard drive to hold your mods, the backup, and the modified sbtf_pub.nwf file (which will contain any activated mod file uncompressed).

.sbtfmod is a unique file format, in that it's just a zip file with a renamed extension. You can use any .zip program to open a .sbtfmod file.

If you add or remove mods from your mods folder, you will need to reenter the manager screen for the mod list to refresh.

When switching to switching to the create mods section, there will be a hitch as SBTFTool starts unpacking.
