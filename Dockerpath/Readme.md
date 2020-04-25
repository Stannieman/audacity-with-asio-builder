These instructions are for building the image that will in turn be used to build *Audacity*. If you are just here to build *Audacity* then this is not for you, you can use the instructions in the other readme.

# Building the image
To build the image you need to place 1 additional executable inside this directory: the standalone version of *7-Zip*. See below for instructions to get the file.
After the file is put in this directory run the *BuildImage.ps1* script to build the image. Remember to set the correct version number.

## 7-Zip
Download *7-Zip Extra: standalone console version, 7z DLL, Plugin for Far Manager* from https://www.7-zip.org/download.html. Extract it and put *7za.exe* from the *x64* folder in the same directory as this file.