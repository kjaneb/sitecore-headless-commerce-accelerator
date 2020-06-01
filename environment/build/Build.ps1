.(".\Helpers.ps1")

function Download-Packages {
    $jssCmPackageName = "Sitecore JavaScript Services Server for Sitecore 9.3 XP 13.0.0 rev. 190924.scwdp.zip"
    $jssCdPackageName = "Sitecore JavaScript Services Server for Sitecore 9.3 XP 13.0.0 rev. 190924 CD.scwdp.zip"

    $jssCmPackagePath = "$PSScriptRoot\modules\packages\$jssCmPackageName"
    $jssCdPackagePath = "$PSScriptRoot\modules\packages\$jssCdPackageName"

    $jssCmPackageExists = $false
    if (Test-Path -Path $jssCmPackagePath -PathType Leaf) {
        $jssCmPackageExists = $true
    }

    $jssCdPackageExists = $false
    if (Test-Path -Path $jssCdPackagePath -PathType Leaf) {
        $jssCdPackageExists = $true
    }

    if ($jssCmPackageExists -and $jssCdPackageExists) {
        Write-Host "JSS packages are already downloaded." -fore Green
        return
    }

    # Setup
    $ErrorActionPreference = "STOP"
    $ProgressPreference = "SilentlyContinue"

    $sitecoreDownloadUrl = "https://dev.sitecore.net"
    $sitecoreDownloadSession = $null

    $sitecoreUsername = Read-Host "You sitecore.net username"
    $sitecorePassword = Read-Host "You sitecore.net password"
    
    $loginResponse = Invoke-WebRequest "https://dev.sitecore.net/api/authorization" -Method Post -Body @{
        username   = $sitecoreUsername
        password   = $sitecorePassword
        rememberMe = $true
    } -SessionVariable "sitecoreDownloadSession" -UseBasicParsing

    if ($null -eq $loginResponse -or $loginResponse.StatusCode -ne 200 -or $loginResponse.Content -eq "false")
    {
        throw ("Unable to login to '{0}' with the supplied credentials." -f $sitecoreDownloadUrl)
    }

    Write-Host ("Logged in to '{0}'." -f $sitecoreDownloadUrl)
    
    $jssCmPackageUrl = "https://dev.sitecore.net/~/media/2600ABD110E64C29837637AA32F88C4A.ashx"
    $jssCdPackageUrl = "https://dev.sitecore.net/~/media/D9018CF6F9F1422B882E9C8A904DF38A.ashx"

    Write-Host "Starting to download packages..."

    # Download package using saved session
    Invoke-FileDownload -Url $jssCmPackageUrl -Path $jssCmPackagePath -Cookies $sitecoreDownloadSession.Cookies
    Invoke-FileDownload -Url $jssCdPackageUrl -Path $jssCdPackagePath -Cookies $sitecoreDownloadSession.Cookies
}

Download-Packages

$windowsServerCore = "mcr.microsoft.com/windows/servercore:ltsc2019"
$windowsNanoServer = "mcr.microsoft.com/windows/nanoserver:1809"

$repository = "sitecore-headless-commerce-accelerator"
$modulesImage = "$repository/modules:latest"

docker build `
    --build-arg WORKER_IMAGE=$windowsServerCore `
    --build-arg BASE_IMAGE=$windowsNanoServer `
    --no-cache=true `
    -t $modulesImage `
    .\modules
    
$standalone = "sitecore-xc-standalone:9.3.0-windowsservercore-ltsc2019"
docker build `
    --build-arg BASE_IMAGE=$standalone `
    --build-arg MODULES_IMAGE=$modulesImage `
    --no-cache=true `
    -t "$repository/sitecore-xc-jss-standalone:latest" `
    .\cm

$cd = "sitecore-xc-cd:9.3.0-windowsservercore-ltsc2019"
docker build `
    --build-arg BASE_IMAGE=$cd `
    --build-arg MODULES_IMAGE=$modulesImage `
    --no-cache=true `
    -t "$repository/sitecore-xc-jss-cd:latest" `
    .\cd

$sql = "sitecore-xc-sqldev:9.3.0-windowsservercore-ltsc2019"
docker build `
    --build-arg BASE_IMAGE=$sql `
    --build-arg MODULES_IMAGE=$modulesImage `
    --no-cache=true `
    -t "$repository/sitecore-xc-sql:latest" `
    .\sql