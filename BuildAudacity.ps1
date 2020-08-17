$mountedVolumeDir = "$PSScriptRoot/Volume"

# Defaults
$audacityTag = 'Audacity-2.4.1'
$wxWidgetsVersion = '3.1.3'
$asioSdkDownloadUrl = 'https://download.steinberg.net/sdk_downloads/asiosdk_2.3.3_2019-06-14.zip'

function getUserInput ([ref]$value) {
    $userInput = Read-Host
    if ($userInput) {
	    $value.Value= $userInput
    }
}

Write-Host -NoNewline "Audacity tag or full commit hash (leave blank for default: $audacityTag): "
getUserInput ([ref]$audacityTag)

Write-Host -NoNewline "wxWidgets version (patched version from https://github.com/audacity/wxWidgets) (leave blank for default: $wxWidgetsVersion): "
getUserInput ([ref]$wxWidgetsVersion)

Write-Host -NoNewline "ASIO SDK ZIP file download URL (use `"latest`" for the latest version or leave blank for default: $asioSdkDownloadUrl): "
getUserInput ([ref]$asioSdkDownloadUrl)

Write-Host "`n`n`n`nResetting mounted volume folder"
if (Test-Path($mountedVolumeDir)) {
    Remove-Item -Recurse -Force $mountedVolumeDir
}
New-Item $mountedVolumeDir -Type Directory

Write-Host "`n`n`n`nStarting Docker container to build Audacity with ASIO support"
Invoke-Expression "& docker run -it -m 3G --cpus 2 --rm --isolation hyperv --dns 1.1.1.1 -v='$mountedVolumeDir':C:\externalVolume -e `"WXWIDGETS_VERSION=$wxWidgetsVersion`" -e `"AUDACITY_COMMIT_HASH=$audacityTag`" -e `"ASIO_SDK_DOWNLOAD_URL=$asioSdkDownloadUrl`" stannieman/audacity-with-asio-builder:1.4.0 powershell -File Build.ps1"

# Foreground color is changed from inside container.
$Host.UI.RawUI.ForegroundColor = 'White'

Write-Host "`n`n`nDone! You can find a file Audacity.zip containing your freshly built Audacity with ASIO support in the Volume folder."
Read-Host