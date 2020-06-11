$nodeVersion = "12.18.0"
$packageUrl = "https://nodejs.org/dist/v$nodeVersion/node-v$nodeVersion-win-x64.zip"

$filePath = "C:\temp\node\node.zip"

New-Item -Path "C:\temp\node" -ItemType Directory | Out-Null
Write-Host "Downloading Node Js package."
Invoke-WebRequest -Method Get -Uri $packageUrl -OutFile $filePath

Write-Host "Expanding Node Js package."
Expand-Archive -Path $filePath -DestinationPath "C:\temp\node"
Remove-Item $filePath
New-Item "C:\node" -ItemType Directory | Out-Null
Copy-Item "C:\temp\node\*\*" "C:\node" -Recurse -Force

Write-Host "Adding C:\node to PATH."
$pathValue = "C:\node;" + $env:PATH
[System.Environment]::SetEnvironmentVariable("PATH", $pathValue, [System.EnvironmentVariableTarget]::Machine)
