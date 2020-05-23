.(".\Helpers.ps1")

Write-Logo

Write-Host "Welcome to DEV environment configuration tool!" -fore Green
Write-Host "Please configure several settings for your environment."
Write-Host "If you want to skip updating a setting, leave an empty value and press Enter." -fore Yellow
Write-Host

Write-Host "1. Full path to the Sitecore license file" -fore Yellow
Write-Host "Example: ""C:\Sitecore\License\license.xml"""
$licensePath = Read-Host "Please specify the path"
if (![string]::IsNullOrEmpty($licensePath)) {
    $isValid = Test-Path $licensePath -PathType Leaf
    if ($isValid) {
        Set-EnvVariable -Key "SITECORE_LICENSE_PATH" -Value $licensePath
        Write-Host "Setting updated." -fore Green
    } else {
        Write-Host "Value not set. The specified path does not point to a file." -fore Red
    }
} else {
    Write-Host "Setting skipped." -fore Yellow
}
Write-Host

Write-Host "2. Full path to Visual Studio remote debugger folder" -fore Yellow
Write-Host "Example: ""C:\Program Files (x86)\Microsoft Visual Studio\2019\Enterprise\Common7\IDE\Remote Debugger"""
$remoteDebuggerPath = Read-Host "Please specify the path"
if (![string]::IsNullOrEmpty($remoteDebuggerPath)){
    $isValid = Test-Path $remoteDebuggerPath
    if ($isValid) {
        Set-EnvVariable -Key "REMOTE_DEBUGGER_PATH" -Value $remoteDebuggerPath
        Write-Host "Setting updated." -fore Green
    } else {
        Write-Host "Value was not set. The specified path does not exist." -fore Red
    }
} else {
    Write-Host "Setting skipped." -fore Yellow
}
Write-Host

Write-Host "DEV environment configuration completed." -fore Green
Write-Host "Please restart PowerShell for the changes to take effect." -fore Yellow
