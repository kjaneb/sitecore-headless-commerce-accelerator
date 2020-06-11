.(".\Helpers.ps1")
.(".\RsaKeyUtility.ps1")

$certName = Get-ComposeVariable -Key "SSL_CERTIFICATE_NAME"
$certPassword = (Get-ComposeVariable -Key "SSL_CERTIFICATE_PASSWORD") | ConvertTo-SecureString -Force -AsPlainText
$dnsNameList = (Get-ComposeVariable -Key "SSL_CERTIFICATE_HOSTS") -split ";"

$outputPath = $PSScriptRoot + "\data\certificates"
$pfxFilePath = $outputPath + "\" + $certName + ".pfx"
$cerFilePath = $outputPath + "\" + $certName + ".cer"
$keyPasswordFilePath = $outputPath + "\" + $certName + ".key"
$certPasswordFilePath = $outputPath + "\" + $certName + ".password.txt"

if (Test-Path -Path $pfxFilePath -PathType Leaf) {
    Write-Host "SSL certificate exists. Skipping."
    return
}

$publicName = $certName
$certificate = New-SelfSignedCertificate `
    -Subject $publicName `
    -DnsName $dnsNameList `
    -KeyAlgorithm RSA `
    -KeyLength 2048 `
    -NotBefore (Get-Date) `
    -NotAfter (Get-Date).AddYears(10) `
    -CertStoreLocation "cert:CurrentUser\My" `
    -FriendlyName $publicName `
    -HashAlgorithm SHA256 `
    -KeyUsage DigitalSignature, KeyEncipherment, DataEncipherment `
    -TextExtension @("2.5.29.37={text}1.3.6.1.5.5.7.3.1") `
    -KeyExportPolicy Exportable `
    -KeySpec KeyExchange `
    -Provider "Microsoft Enhanced RSA and AES Cryptographic Provider"
	
$certificatePath = 'Cert:\CurrentUser\My\' + ($certificate.ThumbPrint)

# Create pfx certificate
Export-PfxCertificate -Cert $certificatePath -FilePath $pfxFilePath -Password $certPassword | Out-Null
Write-Host "SSL certificate exported to file: $($pfxFilePath)" -fore Green

$bstr = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($certPassword)
$unsecuredPassword = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($bstr)
$unsecuredPassword | Out-File -FilePath $certPasswordFilePath

$personalCerts = "Cert:\LocalMachine\My"
# Remove old personal certs
(Get-ChildItem $personalCerts) | Where-Object { $_.FriendlyName -like $publicName } | Remove-Item
# Import new personal cert
Import-PfxCertificate -FilePath $pfxFilePath -CertStoreLocation $personalCerts -Password $certPassword -Exportable | Out-Null

$trustedRootCerts = "Cert:\LocalMachine\Root"
# Remove old trusted root certs
(Get-ChildItem $trustedRootCerts) | Where-Object { $_.FriendlyName -like $publicName } | Remove-Item
# Import new trusted root cert
Import-PfxCertificate -FilePath $pfxFilePath -CertStoreLocation $trustedRootCerts -Password $certPassword -Exportable | Out-Null

$content = @(
    '-----BEGIN CERTIFICATE-----'
    [System.Convert]::ToBase64String($certificate.RawData, 'InsertLineBreaks')
    '-----END CERTIFICATE-----'
)
$content | Out-File -FilePath $cerFilePath -Encoding ascii

$parameters = $certificate.PrivateKey.ExportParameters($true)
$data = [RSAKeyUtils]::PrivateKeyToPKCS8($parameters)
$content = @(
    '-----BEGIN PRIVATE KEY-----'
    [System.Convert]::ToBase64String($data, 'InsertLineBreaks')
    '-----END PRIVATE KEY-----'
)
$content | Out-File -FilePath $keyPasswordFilePath -Encoding ascii

Write-Host "SSL certificate imported to host." -fore Green
