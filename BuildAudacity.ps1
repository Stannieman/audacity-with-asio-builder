$mountedVolumeDir = "$PSScriptRoot/Volume"
$windowsVersionForProcessIsolation = '10.0.17763'

# Defaults
$audacityTag = 'Audacity-2.3.0'
$wxWidgetsVersion = '3.1.2'
$asioSdkVersion = '2.3.2'

function getUserInput ([ref]$value) {
    $userInput = Read-Host
    if ($userInput) {
	    $value.Value= $userInput
    }
}

function canUseProcessIsolation() {
    $version = [System.Environment]::OSVersion.Version
    return "$($version.Major).$($version.Minor).$($version.Build)" -eq $windowsVersionForProcessIsolation
}

Write-Host -NoNewline "Audacity tag or full commit hash (leave blank for default: $audacityTag): "
getUserInput ([ref]$audacityTag)

Write-Host -NoNewline "WXWidgets version (leave blank for default: $wxWidgetsVersion): "
getUserInput ([ref]$wxWidgetsVersion)

Write-Host -NoNewline "ASIO SDK version (leave blank for default: $asioSdkVersion): "
getUserInput ([ref]$asioSdkVersion)

Write-Host "`n`n`n`nResetting mounted volume folder"
if (Test-Path($mountedVolumeDir)) {
    Remove-Item -Recurse -Force $mountedVolumeDir
}
New-Item $mountedVolumeDir -Type Directory

Write-Host "`n`n`n`nStarting Docker container to build Audacity with ASIO support"

$processIsolationPart = 'hyperv'
if (canUseProcessIsolation) {
    $processIsolationPart = 'process'
}

Invoke-Expression "& docker run -it -m 3G --cpus 2 --rm --isolation $processIsolationPart -v=$mountedVolumeDir`:C:\externalVolume -e `"WXWIDGETS_VERSION=$wxWidgetsVersion`" -e `"AUDACITY_COMMIT_HASH=$audacityTag`" -e `"ASIO_SDK_VERSION=$asioSdkVersion`" stannieman/audacity-with-asio-builder:1.1.0 powershell -File Build.ps1"

# Foreground color is changed from inside container.
$Host.UI.RawUI.ForegroundColor = 'White'

Write-Host "`n`n`n`nDone! You can find a file Audacity.zip containing your freshly built Audacity with ASIO support in the Volume folder."
Read-Host