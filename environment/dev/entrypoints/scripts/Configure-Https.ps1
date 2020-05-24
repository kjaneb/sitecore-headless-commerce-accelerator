Import-Module WebAdministration

function Set-IisBinding {
    param(
        [string]$SiteName,
        [string]$HostHeader
    )
    
    if ($null -eq (Get-WebBinding -Name $SiteName | Where-Object { $_.BindingInformation -eq "*:80:$($HostHeader)" })) {
        Write-Host "Adding a new HTTP binding for $($SiteName)"
        $binding = New-WebBinding -Name $SiteName -Protocol http -IPAddress * -Port 80 -HostHeader $HostHeader
    } else {
        Write-Host "HTTP binding for $($SiteName) already exists"
    }

    if ($null -eq (Get-WebBinding -Name $SiteName | Where-Object { $_.BindingInformation -eq "*:443:$($HostHeader)" })) {
        Write-Host "Adding a new HTTPS binding for $($SiteName)"
        $securePassword = $sslCertPassword | ConvertTo-SecureString -AsPlainText -Force
        $cert = Import-PfxCertificate -Password $securePassword -CertStoreLocation Cert:\LocalMachine\root -FilePath "$certificatesRoot\$sslCertName.pfx"   
        $thumbprint = $cert.Thumbprint
        $binding = New-WebBinding -Name $SiteName -Protocol https -IPAddress * -Port 443 -HostHeader $HostHeader
        $binding = Get-WebBinding -Name $SiteName -Protocol https
        $binding.AddSslCertificate($thumbprint, "root")
    } else {
        Write-Host "HTTPS binding for $($SiteName) already exists"
    }
}

$sslCertName = $env:SSL_CERTIFICATE_NAME
$sslCertPassword = $env:SSL_CERTIFICATE_PASSWORD
$certificatesRoot = "C:\certificates"
$rootExists = Test-Path -Path $certificatesRoot
if (!$rootExists) {
    return
}

$hostNames = $env:IIS_HOSTS -split ";"
$hostNames | ForEach-Object {
    Set-IisBinding -SiteName "Default Web Site" -HostHeader $_
}
