param(
    [int]$Port = 8000,
    [switch]$ServerOnly,
    [switch]$OpenBrowser
)

$ErrorActionPreference = "Stop"
$RepoRoot = $PSScriptRoot
$PageUrl = "http://127.0.0.1:$Port/_archivos_por_categoria/web/html/index.html"
$IndexUpdater = Join-Path $RepoRoot "_archivos_por_categoria\scripts\ps1\Update-SkillMaestraWebIndex.ps1"

function Test-LocalPort {
    param([int]$PortToCheck)

    $client = [System.Net.Sockets.TcpClient]::new()
    try {
        $task = $client.ConnectAsync("127.0.0.1", $PortToCheck)
        if (-not $task.Wait(500)) {
            return $false
        }
        return $client.Connected
    }
    catch {
        return $false
    }
    finally {
        $client.Dispose()
    }
}

if (-not (Test-LocalPort -PortToCheck $Port)) {
    $python = Get-Command py -ErrorAction SilentlyContinue
    if (-not $python) {
        $python = Get-Command python -ErrorAction SilentlyContinue
    }
    if (-not $python) {
        throw "No se encontro py/python para arrancar el servidor local."
    }

    $argumentString = "-m http.server $Port --bind 127.0.0.1 --directory `"$RepoRoot`""
    Start-Process -FilePath $python.Source -ArgumentList $argumentString -WorkingDirectory $RepoRoot -WindowStyle Hidden | Out-Null

    $ready = $false
    for ($i = 0; $i -lt 30; $i++) {
        Start-Sleep -Milliseconds 200
        if (Test-LocalPort -PortToCheck $Port) {
            $ready = $true
            break
        }
    }

    if (-not $ready) {
        throw "El servidor local no respondio en 127.0.0.1:$Port."
    }
}

Write-Host "Skill Maestra web lista: $PageUrl"

if (Test-Path -LiteralPath $IndexUpdater) {
    & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $IndexUpdater -RepoRoot $RepoRoot | Out-Host
}

try {
    $response = Invoke-WebRequest -Uri $PageUrl -UseBasicParsing -TimeoutSec 5
    if ($response.StatusCode -ne 200) {
        throw "Status: $($response.StatusCode)"
    }
}
catch {
    throw "La web no responde correctamente en $PageUrl. $($_.Exception.Message)"
}

if ($ServerOnly) {
    exit 0
}

if ($OpenBrowser) {
    Start-Process $PageUrl | Out-Null
    exit 0
}

$openedInsideVsCode = $false
try {
    $encodedArgs = [uri]::EscapeDataString("[`"$PageUrl`"]")
    Start-Process "vscode://command/workbench.action.browser.open?$encodedArgs"
    $openedInsideVsCode = $true
}
catch {
    Write-Warning "No se pudo abrir la vista interna de VS Code automaticamente: $($_.Exception.Message)"
}

if ($openedInsideVsCode) {
    Write-Host "Skill Maestra abierta en la vista interna de VS Code:"
    Write-Host $PageUrl
}
else {
    Write-Host "Abre esta URL en la vista interna de VS Code:"
    Write-Host $PageUrl
}
