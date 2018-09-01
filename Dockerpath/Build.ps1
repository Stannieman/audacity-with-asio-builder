function DownloadAndExtract ([string]$downloadUrl, [string]$extractedFolderPattern, [string]$destinationName) {
    Write-Host "----DOWNLOADING $downloadUrl TO FILE file.zip"
    (New-Object Net.WebClient).DownloadFile($downloadUrl, 'file.zip')
    Write-Host '----EXTRACTING file.zip'
    if ((Test-Path('extractedZip'))) {
        Remove-Item -Recurse -Force extractedZip
    }
    New-Item extractedZip -Type Directory
    Invoke-Expression "& `"$env:EXECUTABLE_7ZIP`" x file.zip * -oextractedZip"
    Remove-Item file.zip
    New-Item $destinationName -Type Directory
    $extractedFolder = Resolve-Path extractedZip$extractedFolderPattern | Select -ExpandProperty Path
    Write-Host "----RENAMING EXTRACTED FOLDER $extractedFolder TO $destinationName"
    Move-Item $extractedFolder/* $destinationName/
}

function SetWXWidgetsSdkVersion () {
    $files = Get-ChildItem BuildDir/WXWidgets/build/msw -Recurse -Filter '*.vcxproj'
    foreach ($file in $files) {
        Write-Host "----SETTING WINDOWS SDK VERSION IN `"$($file.FullName)`""
        $content = Get-Content $file.FullName

        $content = $content -replace '<PropertyGroup Label="Globals">','<PropertyGroup Label="Globals"><WindowsTargetPlatformVersion>10.0.17134.0</WindowsTargetPlatformVersion>'

        Set-Content -Path $file.FullName -Value $content
    }
}

Write-Host "In order to build Audacity with ASIO support we need to download the Steinberg ASIO SDK.`
Before we do so you need to agree with Steinberg's licensing agreement.`
After you press ENTER the agreement will be shown and you can press SPACE to scroll through it."
Read-Host
try {
	Get-Content SteinbergLicensingAgreement.txt | Out-Host -Paging
}
catch {
	exit;
}

Write-Host "`n`n`n`nIf you agree with this agreement enter YES.`
If you do not agree you can enter anything else and the process will not continue."
$answer = Read-Host

if ($answer -ne 'YES') {
	exit;
}

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

Write-Host "`n`n`n`nDOWNLOADING AND EXTRACTING WXWIDGETS SOURCE"
DownloadAndExtract -downloadUrl "https://github.com/wxWidgets/wxWidgets/releases/download/v$env:WXWIDGETS_VERSION/wxWidgets-$($env:WXWIDGETS_VERSION).7z" `
-extractedFolderPattern '' `
-destinationName 'BuildDir/WXWidgets'

Write-Host "`n`n`n`nDOWNLOADING AND EXTRACTING AUDACITY SOURCE"
DownloadAndExtract -downloadUrl "https://github.com/audacity/audacity/archive/$($env:AUDACITY_COMMIT_HASH).zip" `
-extractedFolderPattern '/audacity-*' `
-destinationName 'BuildDir/Audacity'

Write-Host "`n`n`n`nDOWNLOADING AND EXTRACTING ASIO SDK"
DownloadAndExtract -downloadUrl "https://www.steinberg.net/sdk_downloads/ASIOSDK$($env:ASIO_SDK_VERSION).zip" `
-extractedFolderPattern '/asiosdk*/ASIOSDK*' `
-destinationName 'BuildDir/AsioSdk'

# By default wxWidgets wants to build against 8.1 SDK.
# However including extra Windows SDKs drastically increases the Docker image size.
# I decided to build everything against the same SDK being 10.0.17134.0 (Windows 10 1803)
# to keep image size reasonable. 
Write-Host "`n`n`n`nSETTING WXWIDGETS WINDOWS SDK VERSION"
SetWXWidgetsSdkVersion

Write-Host "`n`n`n`nBUILDING WXWIDGETS"
Invoke-Expression "& `"$env:EXECUTABLE_MSBUILD`" BuildDir\WXWidgets\build\msw\wx_vc15.sln /m /t:Build /p:Configuration='DLL Release' /p:BuildInParallel=True /p:PlatformTraget=x86"

Write-Host "`n`n`n`nRESTORING NUGET PACKAGES FOR AUDACITY"
cd BuildDir/Audacity/win
Invoke-Expression "& `"$env:EXECUTABLE_NUGET`" restore"
cd ../../..

Write-Host "`n`n`n`nBUILDING AUDACITY"
Invoke-Expression "& `"$env:EXECUTABLE_MSBUILD`" BuildDir\Audacity\win\audacity.sln /m /t:Build /p:Configuration=Release /p:BuildInParallel=True /p:PlatformTraget=x86"

Write-Host "`n`n`n`nPREPARING BUILD FOR PACKAGING"
Get-ChildItem BuildDir/Audacity/win/Release -Filter '*.lib' | Remove-Item
Remove-Item BuildDir/Audacity/win/Release/Audacity.exp
Remove-Item BuildDir/Audacity/win/Release/Audacity.iobj
Remove-Item BuildDir/Audacity/win/Release/Audacity.ipdb
Remove-Item BuildDir/Audacity/win/Release/Audacity.pdb
$vcRedistPath = Resolve-Path VSBuildTools/VC/Redist/MSVC/*/x86/Microsoft.VC*.CRT
Copy-Item $vcRedistPath/* BuildDir/Audacity/win/Release/
Copy-Item "$env:WXWIN/lib/vc_dll/wxbase311u_net_vc_custom.dll" BuildDir/Audacity/win/Release/
Copy-Item "$env:WXWIN/lib/vc_dll/wxbase311u_vc_custom.dll" BuildDir/Audacity/win/Release/
Copy-Item "$env:WXWIN/lib/vc_dll/wxmsw311u_adv_vc_custom.dll" BuildDir/Audacity/win/Release/
Copy-Item "$env:WXWIN/lib/vc_dll/wxmsw311u_core_vc_custom.dll" BuildDir/Audacity/win/Release/
Copy-Item "$env:WXWIN/lib/vc_dll/wxmsw311u_html_vc_custom.dll" BuildDir/Audacity/win/Release/
Copy-Item "$env:WXWIN/lib/vc_dll/wxbase311u_xml_vc_custom.dll" BuildDir/Audacity/win/Release/
Copy-Item "$env:WXWIN/lib/vc_dll/wxmsw311u_qa_vc_custom.dll" BuildDir/Audacity/win/Release/
Rename-Item BuildDir/Audacity/win/Release Audacity

Write-Host "`n`n`n`nCREATING ZIP PACKAGING"
if (Test-Path('externalvolume/Audacity.zip')) {
    Remove-Item externalvolume/Audacity.zip
}
Compress-Archive BuildDir/Audacity/win/Audacity externalvolume/Audacity.zip