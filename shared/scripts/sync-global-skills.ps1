param(
    [string]$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\..\.github\skills")).Path,
    [string]$GlobalSkillsRoot = "$env:USERPROFILE\.agents\skills",
    [switch]$WhatIf
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path -Path $RepoRoot)) {
    throw "RepoRoot no existe: $RepoRoot"
}

New-Item -ItemType Directory -Path $GlobalSkillsRoot -Force | Out-Null

# Detecta skills de primer nivel en el repo (carpetas que contienen SKILL.md)
$skillDirs = Get-ChildItem -Path $RepoRoot -Directory |
    Where-Object { Test-Path (Join-Path $_.FullName "SKILL.md") } |
    Sort-Object Name

if (-not $skillDirs) {
    Write-Host "No se encontraron skills en: $RepoRoot"
    exit 0
}

$results = @()

foreach ($skill in $skillDirs) {
    $sourcePath = $skill.FullName
    $targetPath = Join-Path $GlobalSkillsRoot $skill.Name

    try {
        if (Test-Path $targetPath) {
            if ($WhatIf) {
                Write-Host "[WhatIf] Remove-Item $targetPath"
            }
            else {
                Remove-Item -Path $targetPath -Recurse -Force
            }
        }

        if ($WhatIf) {
            Write-Host "[WhatIf] Copy-Item $sourcePath -> $targetPath"
        }
        else {
            Copy-Item -Path $sourcePath -Destination $targetPath -Recurse -Force
        }

        $skillFileExists = if ($WhatIf) { $true } else { Test-Path (Join-Path $targetPath "SKILL.md") }

        $results += [pscustomobject]@{
            Skill  = $skill.Name
            Estado = if ($skillFileExists) { "OK" } else { "FAIL" }
            Ruta   = $targetPath
        }
    }
    catch {
        $results += [pscustomobject]@{
            Skill  = $skill.Name
            Estado = "FAIL"
            Ruta   = $targetPath
        }
        Write-Host "Error en $($skill.Name): $($_.Exception.Message)"
    }
}

$results | Format-Table -AutoSize

$failCount = ($results | Where-Object { $_.Estado -eq "FAIL" }).Count
if ($failCount -gt 0) {
    exit 1
}

Write-Host "Sincronizacion completada. Skills sincronizadas: $($results.Count)"
exit 0
