$ErrorActionPreference = "Stop"

$dataPath = "C:\data"
$installPath = "C:\install"
$databasePrefix = "Sitecore"
$dacpacsDirectory = "C:\temp"

$timeFormat = "HH:mm:ss:fff"

[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.SMO") | Out-Null

$server = New-Object Microsoft.SqlServer.Management.Smo.Server($env:COMPUTERNAME)
$server.Properties["DefaultFile"].Value = $installPath
$server.Properties["DefaultLog"].Value = $installPath
$server.Alter()

$sqlPackageExePath = Get-Item "C:\Program Files\Microsoft SQL Server\*\DAC\bin\SqlPackage.exe" | Select-Object -Last 1 -Property FullName -ExpandProperty FullName

# attach
Get-ChildItem -Path $installPath -Filter "*.mdf" | ForEach-Object {
    $databaseName = $_.BaseName.Replace("_Primary", "")
    $mdfPath = $_.FullName
    $ldfPath = $mdfPath.Replace(".mdf", ".ldf")
    $sqlcmd = "IF EXISTS (SELECT 1 FROM SYS.DATABASES WHERE NAME = '$databaseName') BEGIN EXEC sp_detach_db [$databaseName] END;CREATE DATABASE [$databaseName] ON (FILENAME = N'$mdfPath'), (FILENAME = N'$ldfPath') FOR ATTACH;"

    Write-Host "$(Get-Date -Format $timeFormat): Attaching '$databaseName'..."

    Invoke-Sqlcmd -Query $sqlcmd
}

# deploy packages
$textInfo = (Get-Culture).TextInfo
Get-ChildItem -Path $dacpacsDirectory -Filter "*.dacpac" -Recurse | ForEach-Object {
    Write-Host $_.DirectoryName

    $dacpacPath = $_.FullName
    $databaseName = "$databasePrefix`." + $textInfo.ToTitleCase($_.BaseName)

    # Install
    & $sqlPackageExePath /a:Publish /sf:$dacpacPath /tdn:$databaseName /tsn:$env:COMPUTERNAME /q
}

# detach DB
Get-ChildItem -Path $InstallPath -Filter "*.mdf" | ForEach-Object {
    $databaseName = $_.BaseName.Replace("_Primary", "")

    Write-Host "$(Get-Date -Format $timeFormat): Detach: $databaseName"

    Invoke-Sqlcmd -Query "EXEC MASTER.dbo.sp_detach_db @dbname = N'$databaseName', @keepfulltextindexfile = N'false'"
}

$server = New-Object Microsoft.SqlServer.Management.Smo.Server($env:COMPUTERNAME)
$server.Properties["DefaultFile"].Value = $dataPath
$server.Properties["DefaultLog"].Value = $dataPath
$server.Alter()
