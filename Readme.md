# Building Audacity with ASIO support using the Docker image
In order to build *Audacity* with the *Docker* image you need, well… *Docker*!
If you are comfortable with *Docker* you can probably stop reading here. You need to be running a *Windows* machine, switch to *Windows containers* and run the *BuildAudacity.ps1* script. If you have no clue what the previous sentence means then don't worry, I'll guide you through.
## Pre-requisites
Because *Docker for Windows* requires *Windows 10 Pro* you are out of luck if you don't have that.
## Installing Docker for Windows
You can download *Docker* from here: https://store.docker.com/editions/community/docker-ce-desktop-windows.
Install it and make sure to select *Use Windows containers instead of Linux containers* during setup. When the setup finishes you can start it. If you have not yet enabled *Hyper-V* it will prompt you to do so. After a reboot you should be good to go and you can start *Docker* again.
## Make a Docker hub account
In order to download the image from *Docker hub* (the default repository for public *Docker* images) later you'll need to have an account there. You can make one on https://hub.docker.com/. Remember you *Docker ID* and password because you will be prompted for these later.
## Building Audacity
Download the files *BuildAudacity.ps1* and *docker-compose.yml* from here and put them together in a folder. Now run the *BuildAudacity.ps1* script and follow the on-screen instructions. A new folder called *Volume* will be created and when the process completes successfully there should appear a file named *Audacity.zip* in there. This contains you *Audacity* with *ASIO* support. Note that the fist time you run this script it will download the *Docker* image which is slightly over 4GB in size, so it can take a while. Before the download can start it will ask you for your credentials for *Docker hub* so enter them. If they are correct the download will start.
## Configuration
In the *docker-compose.yml* file there are 3 environment variables set: *WXWIDGETS_VERSION*, *AUDACITY_COMMIT_HASH* and *ASIO_SDK_VERSION*. You can use these variables to control which version of the respective components is used. Especially *AUDACITY_COMMIT_HASH* is interesting because it is set to the hash of the latest available commit of the *master* branch at the time that I updated this project the last time. You probably want to build a newer version of the *Audacity* source than what was available back then.
## Cleanup
If you don't want to build *Audacity* again you can run the command *docker image ls* in *PowerShell*. You'll see an image named *stannieman/audacity-with-asio-builder* which should have an *IMAGE ID*. Remember the *IMAGE ID* and run the command *docker image rm ID* where ID is the value of the *IMAGE ID* you got from the previous command. Now the image is removed, saving you a few GB on your system. You can now also uninstall *Docker*.
