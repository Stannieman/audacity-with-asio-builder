Write-Host 'Building image'
docker build --isolation process -t audacity-with-asio-builder:1.2.0 .
Write-Host 'Done building image'
Read-Host
