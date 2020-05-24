function Write-Logo() {
    Write-Host @"
.................::::-....---.-::-......-:::-....---..:::....:::...............
..............-########:.-#########+..*#######*..*########=######+.............
........-*:...*##-...=#=.-##=....##=.:##+...+##:.*##-...=##-...##=...:*-.......
......-***:...=##....=##.-##*....=#=.:##:...+##:.*##-...=##....##=...:***-.....
....:***:.....=##....=##.-##*....=#=..---...+##:.*##-...=##....##=.....:***-...
...***:.......=#########.-##*....=#=...:=######:.*##-...=##....##=.......:***..
...***+.......=##+++++++.-##*....=#=.-###*-.+##:.*##-...=##....##=.......+***..
....-***+.....=##........-##*....=#=.:##+...+##:.*##-...=##....##=.....+***-...
......-***:...=##....*##.-##*....=#=.:##+...+##:.*##-...=##....##=...:***-.....
........-*:...*##:...=#=.-##=-..-##=.:##*...*##:.*##-...=##....##=...:*-.......
..............-=#######-.-##=######:..=#####=##:.*##-...=##....##=.............
..................--.....-##*..--.......--.....................................
.........................-##*..................................................
.........................-##*..................................................
"@
    Write-Host
}

function Set-EnvVariable {
    param([string]$Key, [string]$Value)
    [System.Environment]::SetEnvironmentVariable($Key, $Value, "User")
}

function Get-ComposeVariable {
    param([string]$Key)
    $userValue = [System.Environment]::GetEnvironmentVariable($Key, "User")
    if ($null -ne $userValue) {
        return $userValue
    }
    $machineValue = [System.Environment]::GetEnvironmentVariable($Key, "Machine")
    if ($null -ne $machineValue) {
        return $machineValue
    }
    $envLine = (Get-Content ".\.env" | Where-Object { $_.Contains("$Key=") } | Select-Object -First 1)
    if ($null -ne $envLine) {
        $envValue = ($envLine -split "=")[1]
        return $envValue
    }
    Write-Host "Attempting to read undefined environment variable ""$Key""" -fore Yellow
    return $null
}