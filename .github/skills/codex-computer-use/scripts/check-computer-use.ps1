param(
    [string]$CodexHome = $env:CODEX_HOME
)

$ErrorActionPreference = "Stop"

if ([string]::IsNullOrWhiteSpace($CodexHome)) {
    $CodexHome = Join-Path $env:USERPROFILE ".codex"
}

$computerUseDir = Join-Path $CodexHome "computer-use"
$tomlPath = Join-Path $computerUseDir "config.toml"
$jsonPath = Join-Path $computerUseDir "config.json"

[pscustomobject]@{
    CodexHome          = $CodexHome
    ComputerUseDir     = $computerUseDir
    DirectoryExists    = Test-Path -LiteralPath $computerUseDir
    ConfigTomlExists   = Test-Path -LiteralPath $tomlPath
    ConfigJsonExists   = Test-Path -LiteralPath $jsonPath
    ConfigTomlPath     = $tomlPath
    ConfigJsonPath     = $jsonPath
    Recommendation     = if (Test-Path -LiteralPath $tomlPath) {
        "Review allowed/denied apps before changing persistent permissions."
    } elseif (Test-Path -LiteralPath $jsonPath) {
        "Computer Use has local UI/config state, but no current config.toml allowlist was found."
    } else {
        "Install or enable Computer Use from Codex settings, then authorize apps as needed."
    }
} | Format-List

if (Test-Path -LiteralPath $tomlPath) {
    "`n--- config.toml ---"
    Get-Content -LiteralPath $tomlPath
}
