Write-Host 'Building image'
docker build --isolation hyperv -t stannieman/audacity-with-asio-builder:1.3.0 .
Write-Host 'Done building image'
Read-Host
