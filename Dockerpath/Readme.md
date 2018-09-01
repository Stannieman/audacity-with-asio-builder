These instructions are for building the image that will in turn be used to build *Audacity*. If you are just here to build *Audacity* then this is not for you, you can use the instructions in the other readme.

# Building the image
To build the image you need to place 2 additional executables inside this directory: the installer for *Build Tools for Visual Studio 2017* and the standalone version of *7-Zip*. See below for instructions to get the files.
After the files are put in this directory run the *BuildImage.ps1* script to build the image. Remember to set the correct version number.

## Build Tools for Visual Studio 2017
Download the installer for *Build Tools for Visual Studio 2017* from https://my.visualstudio.com/Downloads. Rename the file to *VSBuildToolsInstaller.exe* and put in the same directory as this file.
## 7-Zip
Download *7-Zip Extra: standalone console version, 7z DLL, Plugin for Far Manager* from https://www.7-zip.org/download.html. Extract it and put *7za.exe* from the *x64* folder in the same directory as this file.