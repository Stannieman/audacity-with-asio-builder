# Building Audacity with ASIO support using the Docker image
In order to build *Audacity* with the *Docker* image you need, well… *Docker*!
In particular you need *Docker* 18.09.1 or higher and *Windows* 10 1903 or higher.
If you are comfortable with *Docker* you can probably stop reading here. You need to switch to *Windows containers* and run the *BuildAudacity.ps1* script. If you have no clue what I'm talking about then don't worry, I'll guide you through.
## Pre-requisites
Because *Docker for Windows* requires *Windows 10 Pro* you are out of luck if you don't have that.
## Installing Docker for Windows
You can download *Docker* from here: https://store.docker.com/editions/community/docker-ce-desktop-windows.
Install it and make sure to select *Use Windows containers instead of Linux containers* during setup. When the setup finishes you can start it. If you have not yet enabled *Hyper-V* it will prompt you to do so. After a reboot you should be good to go and you can start *Docker* again. It could be it's still be set to *Linux* containers because it's stupid and doesn't remember what you selected during setup, so you need to switch to *Windows* containers: Right click on the *Docker* icon in the system tray and click *Switch to Windows containers…*
## Make a Docker hub account
In order to download the image from *Docker hub* (the default repository for public *Docker* images) later you'll need to have an account there. You can make one on https://hub.docker.com/. Remember you *Docker ID* and password because you will be prompted for these later.
## Building Audacity
Download the file *BuildAudacity.ps1* from here, run it and follow the on-screen instructions. It will ask you what versions of *wxWidgets* and the *ASIO SDK* you want to use and what commit or tag of *Audacity* you want to build. A new folder called *Volume* will be created and when the process completes successfully there should appear a file named *Audacity.zip* in there. This contains you *Audacity* with *ASIO* support. Note that the fist time you run this script it will download the *Docker* image which is slightly over 3GB in size, so it can take a while. Before the download can start it will ask you for your credentials for *Docker hub* so enter them. If they are correct the download will start.
## Cleanup
If you don't want to build *Audacity* again you can run the command *docker image ls* in *PowerShell*. You'll see an image named *stannieman/audacity-with-asio-builder* which should have an *IMAGE ID*. Remember the *IMAGE ID* and run the command *docker image rm ID* where ID is the value of the *IMAGE ID* you got from the previous command. Now the image is removed, saving you a few GB on your system. You can now also uninstall *Docker*.
