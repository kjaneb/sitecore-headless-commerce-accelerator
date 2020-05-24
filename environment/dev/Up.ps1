.(".\Helpers.ps1")

Write-Logo
.(".\Set-LicenseVariable.ps1")
docker-compose up -d
.(".\Set-Hosts.ps1")
