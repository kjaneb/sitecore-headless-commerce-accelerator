.(".\Helpers.ps1")

function Update-HostEntry() {
    param([string]$IP, [string]$HostName)

    $hostsPath = "$($Env:WinDir)\system32\Drivers\etc\hosts"
    $hostsFileContent = Get-Content $hostsPath
    $escapedHostName = [Regex]::Escape($HostName)
    
    if (($hostsFileContent) -match ".*\s+$escapedHostName$") {
        Write-Host ("Removing {0} record from hosts file." -f $HostName)
        $hostsFileContent -notmatch ".*\s+$escapedHostName$" | Out-File $hostsPath
        # Required to avoid write conflict
        Start-Sleep -Milliseconds 300
    }

    if ($IP) {
        Write-Host ("Adding {0} {1} record to hosts file." -f $IP, $HostName)
        Add-Content -Encoding UTF8 $hostsPath ("{0} {1}" -f $IP, $HostName)
        # Required to avoid write conflict
        Start-Sleep -Milliseconds 300
    }
}

function Get-Ip(){
    param([string]$ContainerName)
    return docker container inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $ContainerName
}

function Update-ContainerHosts(){
    param([string]$ContainerName, [string]$ComposeVariable)
 
    $ip = Get-Ip -ContainerName $ContainerName
    $hosts = (Get-ComposeVariable $ComposeVariable) -split ";"
    $hosts | ForEach-Object {
        Update-HostEntry -IP $ip -HostName $_
    }
}

$projectName = Get-ComposeVariable -Key "COMPOSE_PROJECT_NAME"

Update-ContainerHosts -ContainerName "$($projectName)_sql" -ComposeVariable "HOSTS_SQL"
Update-ContainerHosts -ContainerName "$($projectName)_solr" -ComposeVariable "HOSTS_SOLR"
Update-ContainerHosts -ContainerName "$($projectName)_cm" -ComposeVariable "HOSTS_CM"
Update-ContainerHosts -ContainerName "$($projectName)_cd" -ComposeVariable "HOSTS_CD"
Update-ContainerHosts -ContainerName "$($projectName)_identity" -ComposeVariable "HOSTS_IDENTITY"
Update-ContainerHosts -ContainerName "$($projectName)_bizfx" -ComposeVariable "HOSTS_BIZFX"
Update-ContainerHosts -ContainerName "$($projectName)_commerce-authoring" -ComposeVariable "HOSTS_COMMERCE-AUTHORING"
Update-ContainerHosts -ContainerName "$($projectName)_commerce-ops" -ComposeVariable "HOSTS_COMMERCE-OPS"
Update-ContainerHosts -ContainerName "$($projectName)_commerce-shops" -ComposeVariable "HOSTS_COMMERCE-SHOPS"
Update-ContainerHosts -ContainerName "$($projectName)_commerce-minions" -ComposeVariable "HOSTS_COMMERCE-MINIONS"

Write-Host "Hosts file updated." -fore Green