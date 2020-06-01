$ErrorActionPreference = "Stop"

$packagesDirectory = "C:\packages"
$tempDirectory = "C:\packages\temp"

$contentDirectory = "C:\modules\content"
$sqlDirectory = "C:\modules\sql"

New-Item -ItemType Directory -Path $contentDirectory -Force | Out-Null
New-Item -ItemType Directory -Path $sqlDirectory -Force | Out-Null

# find and extract all packages
Get-ChildItem -Path $packagesDirectory -Filter *.zip | ForEach-Object {
    $packageName = $_.BaseName.TrimEnd(".scwdp")
    $currentPackageDirectory = "$tempDirectory\$packageName"

    Expand-Archive -Path "$packagesDirectory\$_" -DestinationPath $currentPackageDirectory -Force
    Write-Host "Extracted $packageName"

    # collect all web application files
    $websiteDirectory = "$contentDirectory\$packageName"
    Copy-Item -Path "$currentPackageDirectory\Content\Website\" -Destination $websiteDirectory -Recurse -ErrorAction SilentlyContinue -ErrorVariable capturedErrors
    $capturedErrors | ForEach-Object {
        if ($_ -notmatch "already exists") { throw $_ }
    }

    # collect all .dacpac files
    Get-ChildItem -Path $currentPackageDirectory -Filter *.dacpac -Recurse | ForEach-Object {
        $filePath = "$sqlDirectory\$packageName\$_"
        New-Item -ItemType File -Path $filePath -Force | Out-Null
        Copy-Item -Path $_.FullName -Destination $filePath -Force
    }
}
