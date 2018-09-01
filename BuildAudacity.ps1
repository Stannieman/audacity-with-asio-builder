Write-Host 'Press ENTER to start!'
Read-Host

Write-Host "`n`n`n`nMaking sure previous instances are cleaned up correctly…"
docker-compose down

Write-Host "`n`n`n`nResetting mounted volume folder…"
if (Test-Path('Volume')) {
    Remove-Item -Recurse -Force Volume
}
New-Item Volume -Type Directory

Write-Host "`n`n`n`nStarting Docker container to build Audacity with ASIO support…"
# Getting user input and showing the Steinberg Licensing Agreement does not work well when just
# running it from docker-compose as entrypoint. Instead we use this hack where the container is
# started first and then we exec into it.
docker-compose up -d
docker exec -it audacity-asio-builder powershell -File Build.ps1
docker-compose down

Write-Host "`n`n`n`nDone! You can find a file Audacity.zip containing your freshly built Audacity with ASIO support in the Volume folder."
Read-Host
Write-Host "And remember remember: Be rowdy and keep fuckin smashin it!"
Read-Host