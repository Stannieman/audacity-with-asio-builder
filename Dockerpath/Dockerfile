ARG BASE_IMAGE_VERSION=1909-KB4524570

ARG GIT_INSTALL_DIR=Git
ARG VS_BUILD_TOOLS_INSTALL_DIR=VSBuildTools

FROM mcr.microsoft.com/windows/servercore:$BASE_IMAGE_VERSION as stage_git
SHELL ["powershell.exe"]
ARG GIT_INSTALL_DIR
ARG FILE_NAME=MinGit-2.28.0-busybox-64-bit.zip
ARG FILE_CHECKSUM=1D879A5AEA154676CD2BE8B947DCDFC0991F82B72DD5116A31146BAC923B7CCA
ARG DOWNLOAD_URL=https://github.com/git-for-windows/git/releases/download/v2.28.0.windows.1/$FILE_NAME
RUN [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12;\
(New-Object Net.WebClient).DownloadFile($env:DOWNLOAD_URL, $env:FILE_NAME);\
if ((Get-FileHash $env:FILE_NAME -Algorithm SHA256).Hash -ne $env:FILE_CHECKSUM) { throw \"Checksum of $env:FILE_NAME not correct.\" };\
New-Item -Type Directory -Name $env:GIT_INSTALL_DIR;\
Invoke-Expression \"& tar.exe -xf '$env:FILE_NAME' -C '$env:GIT_INSTALL_DIR'\";\
Remove-Item -Force -Recurse \"$env:GIT_INSTALL_DIR/etc\";\
Remove-Item -Force -Recurse \"$env:GIT_INSTALL_DIR/usr\"


FROM mcr.microsoft.com/windows/servercore:$BASE_IMAGE_VERSION
SHELL ["powershell.exe"]

RUN New-Item Tools -Type Directory
RUN New-Item BuildDir -Type Directory

ARG WINDOWS_SDK_DIR='Program Files (x86)/Windows Kits/10'
ARG WINDOWS_SDK_VERSION=10.0.18362.0

# Install Visual Studio Build Tools 16.7.1
ARG FILE_NAME=vs_BuildTools.exe
ARG FILE_CHECKSUM=DCB113A854B2CB2141755B6A35C4B9AAC6F109081BEE45649EC2FCC594B0D7A6
ARG FILE_UUID=e3850c73-59c6-4c05-9db6-a47a74b67daf
ARG DOWNLOAD_URL=https://download.visualstudio.microsoft.com/download/pr/$FILE_UUID/$FILE_CHECKSUM/$FILE_NAME
ARG VS_BUILD_TOOLS_INSTALL_DIR
RUN (New-Object Net.WebClient).DownloadFile($env:DOWNLOAD_URL, $env:FILE_NAME);\
if ((Get-FileHash $env:FILE_NAME -Algorithm SHA256).Hash -ne $env:FILE_CHECKSUM) { throw \"Checksum of $env:FILE_NAME not correct.\" };\
$process = Start-Process -Wait -PassThru -FilePath $env:FILE_NAME -ArgumentList \"--quiet --wait --norestart --nocache --installPath `\"$env:SYSTEMDRIVE\$env:VS_BUILD_TOOLS_INSTALL_DIR`\" \
--add Microsoft.VisualStudio.Component.VC.Tools.x86.x64 \
--add Microsoft.VisualStudio.Component.Windows10SDK.18362\";\
if (-not ($process.ExitCode -eq 0 -or $process.ExitCode -eq 3010)) { throw \"Installation of Visual Studio Build Tools failed: $($process.ExitCode).\" };\
Remove-Item -Force $env:FILE_NAME;\
Remove-Item -Force -Recurse \"${env:ProgramFiles(x86)}/Microsoft Visual Studio\";\
Remove-Item -Force -Recurse \"$env:LOCALAPPDATA/Microsoft/VisualStudio\";\
Remove-Item -Force -Recurse \"$env:LOCALAPPDATA/Microsoft/VSApplicationInsights\";\
Remove-Item -Force -Recurse \"$env:APPDATA/vstelemetry\";\
Remove-Item -Force -Recurse \"$env:APPDATA/Microsoft Visual Studio\";\
Remove-Item -Force -Recurse \"$env:APPDATA/Visual Studio Setup\";\
Remove-Item -Force -Recurse $env:TEMP;\
Remove-Item -Force -Recurse \"$env:WINDIR/Temp/*\";\
Remove-Item -Force -Recurse \"$env:WINDIR/Installer/*\";\
Remove-Item -Recurse -Force 'Program Files (x86)/Microsoft SDKs';\
Get-ChildItem \"$env:WINDOWS_SDK_DIR\" -Exclude bin, DesignTime, Include, Lib, Platforms, *.* | Remove-Item -Recurse -Force;\
Get-ChildItem \"$env:WINDOWS_SDK_DIR/bin\" -Exclude \"$env:WINDOWS_SDK_VERSION\" | Remove-Item -Recurse -Force;\
Get-ChildItem \"$env:WINDOWS_SDK_DIR/bin/$env:WINDOWS_SDK_VERSION\" -Exclude x86 | Remove-Item -Recurse -Force;\
Remove-Item -Recurse -Force \"$env:WINDOWS_SDK_DIR/Include/$env:WINDOWS_SDK_VERSION/cppwinrt\";\
Get-ChildItem \"$env:WINDOWS_SDK_DIR/Lib/$env:WINDOWS_SDK_VERSION\" -Exclude ucrt, um | Remove-Item -Recurse -Force;\
Get-ChildItem \"$env:WINDOWS_SDK_DIR/Lib/$env:WINDOWS_SDK_VERSION/ucrt\" -Exclude x86 | Remove-Item -Recurse -Force;\
Get-ChildItem \"$env:WINDOWS_SDK_DIR/Lib/$env:WINDOWS_SDK_VERSION/um\" -Exclude x86 | Remove-Item -Recurse -Force;\
Remove-Item -Recurse -Force \"$env:WINDOWS_SDK_DIR/DesignTime/UAP\";\
Get-ChildItem \"$env:VS_BUILD_TOOLS_INSTALL_DIR\" -Exclude MSBuild, VC | Remove-Item -Recurse -Force;\
Remove-Item -Recurse -Force \"$env:VS_BUILD_TOOLS_INSTALL_DIR/MSBuild/Microsoft/VisualStudio\";\
Remove-Item -Recurse -Force \"$env:VS_BUILD_TOOLS_INSTALL_DIR/MSBuild/Current/Bin/amd64\";\
Get-ChildItem \"$env:VS_BUILD_TOOLS_INSTALL_DIR/VC/Redist/MSVC/*/\" -Exclude x86 | Remove-Item -Recurse -Force;\
Get-ChildItem \"$env:VS_BUILD_TOOLS_INSTALL_DIR/VC/Redist/MSVC/*/x86\" -Exclude Microsoft.VC*.CRT | Remove-Item -Recurse -Force;\
Remove-Item -Recurse -Force \"$env:VS_BUILD_TOOLS_INSTALL_DIR/VC/Tools/MSVC/*/BuildInsights\";\
Get-ChildItem \"$env:VS_BUILD_TOOLS_INSTALL_DIR/VC/Tools/MSVC/*/lib\" -Exclude x86 | Remove-Item -Recurse -Force;\
Get-ChildItem \"$env:VS_BUILD_TOOLS_INSTALL_DIR/VC/Tools/MSVC/*/bin\" -Exclude Hostx86 | Remove-Item -Recurse -Force;\
Get-ChildItem \"$env:VS_BUILD_TOOLS_INSTALL_DIR/VC/Tools/MSVC/*/bin/Hostx86\" -Exclude x86 | Remove-Item -Recurse -Force
ENV EXECUTABLE_MSBUILD=C:\\$VS_BUILD_TOOLS_INSTALL_DIR\\MSBuild\\Current\\Bin\\MSBuild.exe

# Git
ARG GIT_INSTALL_DIR
COPY --from=stage_git $GIT_INSTALL_DIR/ $GIT_INSTALL_DIR/
ENV EXECUTABLE_GIT=C:\\$GIT_INSTALL_DIR\\cmd\\git.exe

# NuGet
ARG VERSION=5.7.0
ARG FILE_CHECKSUM=AE3BB02517B52A744833A4777E99D647CD80B29A62FD360E9AABAA34F09AF59C
ARG DOWNLOAD_URL=https://dist.nuget.org/win-x86-commandline/v$VERSION/nuget.exe
RUN (New-Object Net.WebClient).DownloadFile($env:DOWNLOAD_URL, 'Tools/nuget.exe');\
if ((Get-FileHash Tools/nuget.exe -Algorithm SHA256).Hash -ne $env:FILE_CHECKSUM) { throw \"Checksum of nuget.exe not correct.\" }
ENV EXECUTABLE_NUGET=C:\\Tools\\nuget.exe

ENV ASIOSDK_DIR=C:\\BuildDir\\AsioSdk
ENV WXWIN=C:\\BuildDir\\WXWidgets

COPY SteinbergLicensingAgreement.txt .
COPY Build.ps1 C:\\Build.ps1