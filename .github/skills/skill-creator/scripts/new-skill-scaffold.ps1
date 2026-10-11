param(
    [Parameter(Mandatory = $true)]
    [ValidatePattern("^[a-z0-9-]+$")]
    [string]$SkillName,

    [string]$BasePath = (Resolve-Path (Join-Path $PSScriptRoot "..\..")).Path,

    [switch]$IncludeExamples
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$skillRoot = Join-Path $BasePath $SkillName
$refsPath = Join-Path $skillRoot "references"
$assetsPath = Join-Path $skillRoot "assets"
$scriptsPath = Join-Path $skillRoot "scripts"
$skillFile = Join-Path $skillRoot "SKILL.md"

if (Test-Path -LiteralPath $skillRoot) {
    throw "La skill ya existe: $skillRoot"
}

if (-not (Test-Path -LiteralPath $BasePath)) {
    throw "No existe BasePath: $BasePath"
}

New-Item -ItemType Directory -Path $refsPath -Force | Out-Null
New-Item -ItemType Directory -Path $assetsPath -Force | Out-Null
New-Item -ItemType Directory -Path $scriptsPath -Force | Out-Null

$skillTemplate = @"
---
name: $SkillName
description: \"Describe que hace y cuando usar esta skill en Power Platform. Incluye keywords: power apps, power automate, power bi, dataverse, copilot studio.\"
argument-hint: \"Indica entorno, artefacto, accion, modo (simulacion/real) y restricciones de publicacion.\"
---

# $SkillName

## Cuando usar esta skill
- Caso de uso principal.

## Alcance Power Platform
- Producto principal: Power Apps | Power Automate | Power BI | Copilot Studio | Dataverse
- Entorno objetivo: Dev/Test/Prod
- Artefacto: app, flujo, reporte, modelo, agente o tabla

## Resultado esperado
- Resultado concreto y verificable.

## Politica de publicacion
- Publicacion automatica solo para agentes de Copilot Studio.
- Para Power Apps, Power Automate, SharePoint y Dataverse: publicacion manual.

## Procedimiento
1. Discovery tecnico.
2. Plan por fases.
3. Ejecucion.
4. Verificacion.

## Validaciones minimas
1. Verificar entorno y conexion correctos.
2. Verificar impacto funcional sin romper dependencias.
3. Registrar trazabilidad del cambio.

## Recursos
- [Referencia](./references/workflow.md)
- [Template](./assets/template.md)
- [Script](./scripts/run.ps1)
"@

Set-Content -Path $skillFile -Value $skillTemplate -Encoding UTF8
Set-Content -Path (Join-Path $refsPath "workflow.md") -Value "# Workflow`n" -Encoding UTF8
Set-Content -Path (Join-Path $assetsPath "template.md") -Value "# Template`n" -Encoding UTF8
Set-Content -Path (Join-Path $scriptsPath "run.ps1") -Value "Write-Host 'Implement me'`n" -Encoding UTF8

if ($IncludeExamples) {
    Set-Content -Path (Join-Path $refsPath "checklist.md") -Value "# Checklist`n- [ ] Objetivo claro`n- [ ] Resultado verificable`n- [ ] Procedimiento probado`n" -Encoding UTF8
}

Write-Host "Skill creada en: $skillRoot"
