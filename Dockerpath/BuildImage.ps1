Write-Host 'Building image'
docker build -t audacity-with-asio-builder:1.0.0 .
Write-Host 'Done building image'
Read-Host