FROM mcr.microsoft.com/windows/servercore:1903-KB4505057
SHELL ["powershell.exe"]

ARG VS_BUILD_TOOLS_INSTALL_PATH=C:\\VSBuildTools
ARG VS_BUILD_TOOLS_INSTALLER_FILE_NAME=VSBuildToolsInstaller.exe

COPY $VS_BUILD_TOOLS_INSTALLER_FILE_NAME .

RUN New-Item Tools -Type Directory
RUN New-Item BuildDir -Type Directory

RUN $process = Start-Process -Wait -PassThru -FilePath `\"$env:VS_BUILD_TOOLS_INSTALLER_FILE_NAME`\" -ArgumentList \"--quiet --wait --norestart --nocache --installPath `\"$env:VS_BUILD_TOOLS_INSTALL_PATH`\" \
--add Microsoft.VisualStudio.Component.VC.Tools.x86.x64 \
--add Microsoft.VisualStudio.Component.Windows10SDK.18362\";\
if ($process.ExitCode) { throw \"Installation of Visual Studio Build Tools failed: $($process.ExitCode).\" };\
Remove-Item -Force $env:VS_BUILD_TOOLS_INSTALLER_FILE_NAME;\
Remove-Item -Force -Recurse 'Program Files (x86)/Microsoft Visual Studio';\
Remove-Item -Force -Recurse \"$env:LOCALAPPDATA/Microsoft/VisualStudio\";\
Remove-Item -Force -Recurse \"$env:LOCALAPPDATA/Microsoft/VSApplicationInsights\";\
Remove-Item -Force -Recurse \"$env:APPDATA/vstelemetry\";\
Remove-Item -Force -Recurse 'Users/ContainerAdministrator/AppData/Roaming/Visual Studio Setup';\
Remove-Item -Force -Recurse $env:TEMP;\
Remove-Item -Force -Recurse \"$env:WINDIR/Temp\"
ENV EXECUTABLE_MSBUILD=C:\\VSBuildTools\\MSBuild\\15.0\\Bin\\amd64\\MSBuild.exe

# NuGet
ARG VERSION=5.1.0
ARG FILE_CHECKSUM=0ACE4F53493332C9A75291EE96ACD76B371B4E687175E4852BF85948176D7152
ARG DOWNLOAD_URL=https://dist.nuget.org/win-x86-commandline/v$VERSION/nuget.exe
RUN (New-Object Net.WebClient).DownloadFile($env:DOWNLOAD_URL, 'Tools/nuget.exe');\
if ((Get-FileHash Tools/nuget.exe -Algorithm SHA256).Hash -ne $env:FILE_CHECKSUM) { throw \"Checksum of nuget.exe not correct.\" }
ENV EXECUTABLE_NUGET=C:\\Tools\\nuget.exe

# 7zip
COPY 7za.exe Tools/
ENV EXECUTABLE_7ZIP=C:\\Tools\\7za.exe

ENV ASIOSDK_DIR=C:\\BuildDir\\AsioSdk
ENV WXWIN=C:\\BuildDir\\WXWidgets

COPY SteinbergLicensingAgreement.txt .

COPY Build.ps1 C:\\Build.ps1