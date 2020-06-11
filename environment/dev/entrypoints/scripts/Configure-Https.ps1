Import-Module WebAdministration

$sslCertName = $env:SSL_CERTIFICATE_NAME
$sslCertPassword = $env:SSL_CERTIFICATE_PASSWORD
$certificatesRoot = "C:\certificates"
$rootExists = Test-Path -Path $certificatesRoot
if (!$rootExists) {
    return
}

$siteName = "Default Web Site"
$trustedRootLocation = "Cert:\LocalMachine\root"
$certificateFilePath = "$certificatesRoot\$sslCertName.pfx"
$publicName = $sslCertName

$existingCert = (Get-ChildItem $trustedRootLocation) | Where-Object { $_.FriendlyName -eq $publicName }
if ($null -eq $existingCert) {
    Write-Host "Certificate is not imported. Importing..."
    $securePassword = $sslCertPassword | ConvertTo-SecureString -AsPlainText -Force
    $existingCert = Import-PfxCertificate -Password $securePassword -CertStoreLocation $trustedRootLocation -FilePath $certificateFilePath
} else {
    Write-Host "Certificate is already imported."
}

$binding = Get-WebBinding -Name $siteName -Protocol https
if ($null -ne $binding) {
    Write-Host "Removing the existing HTTPS binding"
    $binding | Remove-WebBinding
}

Write-Host "Creating a new HTTPS binding"
New-WebBinding -Name $siteName -Protocol https -IPAddress * -Port 443 -HostHeader *
$binding = Get-WebBinding -Name $siteName -Protocol https

$thumbprint = $existingCert.Thumbprint
$binding.AddSslCertificate($thumbprint, "root")
