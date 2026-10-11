param(
    [string]$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\..\..")).Path,
    [string]$IndexPath = "_archivos_por_categoria\web\html\index.html",
    [string]$MarkdownCatalogPath = "_archivos_por_categoria\web\md\catalogo-skills.md",
    [string]$UserSkillRoot = (Join-Path $env:USERPROFILE ".agents\skills"),
    [string]$ClaudeSkillRoot = (Join-Path $env:USERPROFILE ".claude\skills")
)

$ErrorActionPreference = "Stop"

function Html {
    param([AllowNull()][string]$Value)
    return [System.Net.WebUtility]::HtmlEncode([string]$Value)
}

function Read-Utf8Text {
    param([string]$Path)
    $encoding = New-Object System.Text.UTF8Encoding($false, $true)
    try {
        return [System.IO.File]::ReadAllText($Path, $encoding)
    } catch {
        return [System.IO.File]::ReadAllText($Path, [System.Text.Encoding]::Default)
    }
}

function Write-Utf8Text {
    param([string]$Path, [string]$Value)
    $encoding = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($Path, $Value, $encoding)
}

function Shorten {
    param([AllowNull()][string]$Value, [int]$Max = 260)
    $clean = ([string]$Value -replace "\s+", " ").Trim()
    if ($clean.Length -le $Max) { return $clean }
    return $clean.Substring(0, $Max - 1).TrimEnd() + "..."
}

function Get-RepoRelativePath {
    param([string]$BasePath, [string]$TargetPath)
    $base = (Resolve-Path -LiteralPath $BasePath).Path
    $target = (Resolve-Path -LiteralPath $TargetPath).Path
    if (-not $base.EndsWith([IO.Path]::DirectorySeparatorChar)) {
        $base += [IO.Path]::DirectorySeparatorChar
    }
    $baseUri = New-Object System.Uri($base)
    $targetUri = New-Object System.Uri($target)
    return [Uri]::UnescapeDataString($baseUri.MakeRelativeUri($targetUri).ToString()).Replace("/", "\").Replace("\", "/")
}

function Get-FrontMatterValue {
    param([string]$Raw, [string]$Key)
    if ($Raw -notmatch "(?s)^---\s*\r?\n(.*?)\r?\n---") { return $null }
    $front = $Matches[1]
    $lines = $front -split "\r?\n"
    for ($i = 0; $i -lt $lines.Count; $i++) {
        $line = $lines[$i]
        if ($line -match "^(\s*)$([regex]::Escape($Key))\s*:\s*(.*)\s*$") {
            $keyIndent = $Matches[1].Length
            $value = $Matches[2].Trim()
            # Bloque YAML multilinea (folded ">" o literal "|", con o sin indicador de chomping
            # como ">-"/"|+"): el valor real vive en las lineas siguientes, mas indentadas que la
            # clave, no en esta misma linea. Sin esto, "description: >" se quedaba con el simple
            # caracter ">" como descripcion (hallado 2026-09-19 al instalar las skills HyperFrames,
            # que usan este estilo con frecuencia).
            if ($value -match '^[>|][+-]?$') {
                $bloque = @()
                for ($j = $i + 1; $j -lt $lines.Count; $j++) {
                    $siguiente = $lines[$j]
                    if ($siguiente -match '^\s*$') { continue }
                    if ($siguiente -notmatch '^(\s+)\S') { break }
                    if ($Matches[1].Length -le $keyIndent) { break }
                    $bloque += $siguiente.Trim()
                }
                return ($bloque -join ' ').Trim()
            }
            if (($value.StartsWith('"') -and $value.EndsWith('"')) -or ($value.StartsWith("'") -and $value.EndsWith("'"))) {
                $value = $value.Substring(1, $value.Length - 2)
            }
            return $value
        }
    }
    return $null
}

function Get-FirstHeading {
    param([string]$Raw, [string]$Fallback)
    foreach ($line in ($Raw -split "\r?\n")) {
        if ($line -match "^\s*#\s+(.+?)\s*$") { return $Matches[1].Trim() }
    }
    return $Fallback
}

function Get-Category {
    param([string]$Name, [string]$Description)
    if ($Name -match '^(gws-|recipe-|persona-)|google-analytics') { return "Google y productividad" }
    if ($Name -match 'dataverse|sharepoint|canvas|copilot-studio|code-app|model-driven|power-') { return "Power Platform" }
    if ($Name -match '^azure-|^entra-|^appinsights|^airunway|^microsoft-foundry|^python-appservice|^(deploy|prepare|scaffold|capacity|customize|preset|finetuning|deploy-model)$') { return "Azure e inteligencia artificial" }
    if ($Name -match '^(pdf|frontend-design|design-md|impeccable)$') { return "Documentos y diseño" }
    if ($Name -match 'skill|agent-customization|using-superpowers|codex-computer-use|brainstorming|plans|parallel-agents|subagent') { return "Organizar el trabajo de la IA" }
    if ($Name -match '^hyperframes|^video-|-video$|^(embedded-captions|faceless-explainer|figma|media-use|motion-graphics|remotion-to-hyperframes|slideshow|talking-head-recut)$') { return "Vídeo y motion graphics" }
    return "Código, pruebas y seguridad"
}

# Skills escritas o adaptadas a mano por el equipo Skill Maestra, a diferencia de
# los paquetes genéricos que vienen de marketplaces (Azure, Google Workspace, HyperFrames, recipes,
# personas, auth0, etc.). Lista fijada a mano tras la auditoria del 2026-09-21; si se crea o se retira
# una skill propia, actualizar tambien esta lista.
$customSkillNames = @(
    'agent-customization','code-app','codex-computer-use','design-md','find-skills','model-driven-apps','power-bi-modeling-mcp-server','skill-creator'
)

function Get-Origin {
    param([string]$Name)
    if ($Name -in $customSkillNames) { return "Propia" }
    return "Terceros"
}

# Origen real de cada skill de terceros: lo registra el instalador en ~/.agents/.skill-lock.json.
$skillLockPath = Join-Path $env:USERPROFILE '.agents\.skill-lock.json'
$skillLock = @{}
if (Test-Path -LiteralPath $skillLockPath) {
    $lockJson = Get-Content -LiteralPath $skillLockPath -Raw -Encoding UTF8 | ConvertFrom-Json
    foreach ($entry in $lockJson.skills.PSObject.Properties) { $skillLock[$entry.Name] = $entry.Value }
}
# Nombres amigables de los repos mas frecuentes; el que no este aqui sale como "owner/repo".
$packageFriendlyNames = @{
    'heygen-com/hyperframes'        = 'HyperFrames · HeyGen'
    'microsoft/azure-skills'        = 'Azure Skills · Microsoft'
    'googleworkspace/cli'           = 'Google Workspace CLI · Google'
    'anthropics/skills'             = 'Skills de Anthropic'
    'openai/skills'                 = 'Skills de OpenAI'
    'obra/superpowers'              = 'Superpowers · obra'
    'vercel-labs/agent-skills'      = 'Agent Skills · Vercel Labs'
    'pbakaus/impeccable'            = 'Impeccable · pbakaus'
    'davila7/claude-code-templates' = 'Claude Code Templates · davila7'
}

function Get-SkillPackage {
    param([string]$Name, [string]$Origin, [string]$Path = '')
    if ($Origin -eq 'Propia') {
        return [pscustomobject]@{ Key = 'propia'; Label = 'Propia de Skill Maestra'; Repo = ''; Url = '' }
    }
    $entry = $skillLock[$Name]
    if (-not $entry -or -not $entry.source) {
        # Pista por carpeta: una sub-skill anidada hereda el paquete de su skill padre si esta si figura
        # en el lock; las de la carpeta "synced" vienen sincronizadas, sin repositorio registrado.
        if ($Path -and $Path.StartsWith($UserSkillRoot, [StringComparison]::OrdinalIgnoreCase)) {
            $parts = @($Path.Substring($UserSkillRoot.Length).Trim('\', '/') -split '[\\/]')
            if ($parts.Count -gt 2 -and $parts[0] -eq 'synced') {
                return [pscustomobject]@{ Key = 'sincronizada'; Label = 'Sincronizada (carpeta synced) · sin repositorio'; Repo = ''; Url = '' }
            }
            if ($parts.Count -gt 2 -and $skillLock.ContainsKey($parts[0]) -and $skillLock[$parts[0]].source) {
                $entry = $skillLock[$parts[0]]
            }
        }
    }
    if (-not $entry -or -not $entry.source) {
        return [pscustomobject]@{ Key = 'sin-registrar'; Label = 'Origen sin registrar'; Repo = ''; Url = '' }
    }
    $source = [string]$entry.source
    $label = if ($packageFriendlyNames.ContainsKey($source)) { $packageFriendlyNames[$source] } else { $source }
    $url = ''
    if ($entry.sourceUrl) { $url = ([string]$entry.sourceUrl) -replace '\.git$', '' }
    $key = ($source.ToLowerInvariant() -replace '[^a-z0-9]+', '-').Trim('-')
    return [pscustomobject]@{ Key = $key; Label = $label; Repo = $source; Url = $url }
}

function Get-InstructionSections {
    param([string]$Path, [string]$RepoRoot)

    $raw = Read-Utf8Text -Path $Path
    $relative = Get-RepoRelativePath -BasePath $RepoRoot -TargetPath $Path
    $lines = $raw -split "\r?\n"
    $sections = @()
    $currentTitle = $null
    $buffer = New-Object System.Collections.Generic.List[string]

    foreach ($line in $lines) {
        if ($line -match "^\s*##\s+(.+?)\s*$") {
            if ($currentTitle) {
                $sections += [pscustomobject]@{
                    Title   = $currentTitle
                    Summary = Shorten (($buffer | Where-Object { $_.Trim() } | Select-Object -First 4) -join " ")
                    File    = $relative
                }
            }
            $currentTitle = $Matches[1].Trim()
            $buffer.Clear()
            continue
        }
        if ($currentTitle) { $buffer.Add($line.Trim()) }
    }

    if ($currentTitle) {
        $sections += [pscustomobject]@{
            Title   = $currentTitle
            Summary = Shorten (($buffer | Where-Object { $_.Trim() } | Select-Object -First 4) -join " ")
            File    = $relative
        }
    }

    return $sections
}

function Get-SkillInventory {
    param(
        [string]$SkillRoot,
        [string]$RepoRoot,
        [string]$Scope,
        [bool]$IsRepoPath
    )

    $items = @()
    if (-not (Test-Path $SkillRoot)) { return $items }

    Get-ChildItem -Path $SkillRoot -Recurse -Filter SKILL.md -File | Sort-Object FullName | ForEach-Object {
        $raw = Read-Utf8Text -Path $_.FullName
        $folder = Split-Path -Leaf (Split-Path -Parent $_.FullName)
        $frontMatter = $raw -match "(?s)^---\s*\r?\n(.*?)\r?\n---"
        $frontMatterName = Get-FrontMatterValue -Raw $raw -Key "name"
        $frontMatterDescription = Get-FrontMatterValue -Raw $raw -Key "description"
        $name = $frontMatterName
        if (-not $name) { $name = $folder }
        $description = $frontMatterDescription
        if (-not $description) { $description = Shorten $raw 260 }

        if ($IsRepoPath) {
            $relative = Get-RepoRelativePath -BasePath $RepoRoot -TargetPath $_.FullName
            $folderRelative = Get-RepoRelativePath -BasePath $RepoRoot -TargetPath (Split-Path -Parent $_.FullName)
        } else {
            $relative = $_.FullName
            $folderRelative = Split-Path -Parent $_.FullName
        }

        $issues = @()
        if (-not $frontMatter) { $issues += "Sin frontmatter" }
        if (-not $frontMatterName) { $issues += "Sin name" }
        if (-not $frontMatterDescription) { $issues += "Sin description" }

        $items += [pscustomobject]@{
            Name           = $name
            Title          = Get-FirstHeading -Raw $raw -Fallback $name
            Description    = Shorten $description 340
            Category       = Get-Category -Name $name -Description $description
            Origin         = Get-Origin -Name $name
            Relative       = $relative
            Folder         = $folderRelative
            FolderName     = $folder
            Scope          = $Scope
            IsRepoPath     = $IsRepoPath
            HasFrontMatter = $frontMatter
            HasName        = [bool]$frontMatterName
            HasDescription = [bool]$frontMatterDescription
            Issues         = $issues
        }
    }

    return $items
}

Set-Location $RepoRoot

$skillRoot = Join-Path $RepoRoot ".github\skills"
$skills = Get-SkillInventory -SkillRoot $skillRoot -RepoRoot $RepoRoot -Scope "Proyecto" -IsRepoPath $true
$globalSkills = Get-SkillInventory -SkillRoot $UserSkillRoot -RepoRoot $RepoRoot -Scope "Global" -IsRepoPath $false
$claudeSkills = Get-SkillInventory -SkillRoot $ClaudeSkillRoot -RepoRoot $RepoRoot -Scope "Claude" -IsRepoPath $false

$instructionFiles = @(
    ".github\copilot-instructions.md",
    "AGENTS.md"
) | ForEach-Object { Join-Path $RepoRoot $_ } | Where-Object { Test-Path $_ }

$instructionFiles += Get-ChildItem -Path (Join-Path $RepoRoot ".github") -Recurse -Include "*.instructions.md","*.prompt.md","*.agent.md" -File -ErrorAction SilentlyContinue |
    Select-Object -ExpandProperty FullName

$instructionFiles = $instructionFiles | Sort-Object -Unique
$instructionSections = @()
foreach ($file in $instructionFiles) {
    $instructionSections += Get-InstructionSections -Path $file -RepoRoot $RepoRoot
}

# Una entrada por identidad de skill; la copia global es la principal cuando existe.
$catalogSkills = @($globalSkills)
foreach ($projectSkill in $skills) {
    if ($projectSkill.Name -notin $globalSkills.Name) { $catalogSkills += $projectSkill }
}
$catalogSkills = @($catalogSkills | Sort-Object Name -Unique)
$displayNames = @{}
$displayPath = Join-Path $RepoRoot '_archivos_por_categoria/web/data/skill-descriptions.es.tsv'
foreach ($entry in (Import-Csv -LiteralPath $displayPath -Delimiter "`t" -Encoding UTF8)) { $displayNames[$entry.Name] = $entry }
$missingDescriptions = @($catalogSkills | Where-Object { -not $displayNames.ContainsKey($_.Name) })
$skillsByCategory = $catalogSkills | Group-Object Category | Sort-Object Name
$now = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$extensionCount = 71
$startMarker = "<!-- AUTO-INDEX-SKILL-MAESTRA:START -->"
$endMarker = "<!-- AUTO-INDEX-SKILL-MAESTRA:END -->"
$cssStartMarker = "/* AUTO-INDEX-SKILL-MAESTRA-CSS:START */"
$cssEndMarker = "/* AUTO-INDEX-SKILL-MAESTRA-CSS:END */"

$projectFrontMatterIssues = @($skills | Where-Object { -not $_.HasFrontMatter -or -not $_.HasName -or -not $_.HasDescription })
$globalFrontMatterIssues = @($globalSkills | Where-Object { -not $_.HasFrontMatter -or -not $_.HasName -or -not $_.HasDescription })
$frontMatterIssueCount = $projectFrontMatterIssues.Count + $globalFrontMatterIssues.Count
$projectSkillFolderNames = @($skills | Select-Object -ExpandProperty FolderName)
$globalOnlySkills = @($globalSkills | Where-Object { $_.FolderName -notin $projectSkillFolderNames })
$claudeSkillCount = $claudeSkills.Count
$claudeStatus = if ($claudeSkillCount -eq $globalSkills.Count -and $claudeSkillCount -gt 0) { "OK" } elseif ($claudeSkillCount -gt 0) { "$claudeSkillCount visibles" } else { "No detectado" }
$claudeHealthClass = if ($claudeSkillCount -eq $globalSkills.Count -and $claudeSkillCount -gt 0) { "ops-kpi" } else { "ops-kpi ops-kpi-alert" }

$healthClass = if ($frontMatterIssueCount -gt 0) { "ops-kpi ops-kpi-alert" } else { "ops-kpi" }
$healthLabel = if ($frontMatterIssueCount -gt 0) { "$frontMatterIssueCount avisos" } else { "OK" }
$frontMatterSummary = if ($frontMatterIssueCount -gt 0) {
    $issueNames = @($projectFrontMatterIssues + $globalFrontMatterIssues | Select-Object -First 8 | ForEach-Object {
        "<span class=""auto-badge"">$(Html $_.Name): $(Html (($_.Issues -join ', ')))</span>"
    })
    "<div class=""auto-summary"">$($issueNames -join "`n        ")</div>"
} else {
    "<div class=""ops-empty"">Todas las skills revisadas tienen frontmatter, name y description.</div>"
}

$globalOnlySummary = if ($globalOnlySkills.Count -gt 0) {
    $globalOnlyNames = @($globalOnlySkills | Sort-Object Name | Select-Object -First 18 | ForEach-Object {
        "<span class=""auto-badge"">$(Html $_.Name)</span>"
    })
    $suffix = if ($globalOnlySkills.Count -gt 18) { "<p class=""auto-muted"">Y $($globalOnlySkills.Count - 18) skills globales mas en el catalogo Markdown.</p>" } else { "" }
    "<div class=""auto-summary"">$($globalOnlyNames -join "`n        ")</div>$suffix"
} else {
    "<div class=""ops-empty"">Todas las skills globales estan representadas en el proyecto.</div>"
}

$categoryOrder = @{ 'Power Platform' = 0; 'Documentos y diseño' = 1; 'Código, pruebas y seguridad' = 2; 'Google y productividad' = 3; 'Azure e inteligencia artificial' = 4; 'Organizar el trabajo de la IA' = 5; 'Vídeo y motion graphics' = -1 }  # va primero a propósito (antes salía primero por accidente al no estar en la tabla)

# Las skills del paquete HyperFrames (lock: heygen-com/hyperframes) se muestran en UNA ficha que lleva a su guía.
$hyperframesPageExists = Test-Path (Join-Path $RepoRoot '_archivos_por_categoria\web\html\hyperframes.html')
$hyperframesSkills = @($catalogSkills | Where-Object { $_.Origin -ne 'Propia' -and (Get-SkillPackage -Name $_.Name -Origin $_.Origin -Path $_.Relative).Key -eq 'heygen-com-hyperframes' } | Sort-Object Name)
if (-not $hyperframesPageExists) { Write-Warning 'Falta hyperframes.html: no se agrupan las skills de HyperFrames'; $hyperframesSkills = @() }
$hyperframesNames = @($hyperframesSkills.Name)

$hyperframesCard = $null
if ($hyperframesSkills.Count -gt 0) {
    $hfCount = $hyperframesSkills.Count
    $hfPkg = Get-SkillPackage -Name $hyperframesSkills[0].Name -Origin $hyperframesSkills[0].Origin -Path $hyperframesSkills[0].Relative
    $hfProjectCopy = @($hyperframesSkills | Where-Object { $n = $_.Name; @($skills | Where-Object Name -eq $n).Count -gt 0 }).Count -gt 0
    $hfScope = if ($hfProjectCopy) { 'project' } else { 'global' }
    $hfAvailability = if ($hfProjectCopy) { 'Global · También tiene copia en este proyecto' } else { 'Global · Disponible desde otros proyectos' }
    $hfTexts = @($hyperframesSkills | ForEach-Object {
        $d = $displayNames[$_.Name]
        $t = if ($d) { $d.Title } else { $_.Name }
        $pp = if ($d) { $d.Purpose } else { '' }
        ("$t $pp $($_.Name) $($_.Description)" -replace '\s+', ' ' -replace '\|', ' ')
    })
    # Texto común de la ficha (no cuenta para el total por skill) y palabras clave que solo ayudan a encontrarla.
    $hfCommon = "$($hfPkg.Label) $($hfPkg.Repo) HyperFrames HeyGen vídeo"
    $hfSearch = "$($hfTexts -join ' ') $hfCommon voz narración volumen música sonido subtítulos animación"
    $hfMembers = $hfTexts -join '|'
    $hfList = ($hyperframesSkills | ForEach-Object {
        $d = $displayNames[$_.Name]
        $t = if ($d) { $d.Title } else { $_.Name }
        "<li><code>$(Html $_.Name)</code> — $(Html $t)</li>"
    }) -join "`n            "
    $hfRepoLink = if ($hfPkg.Url) { "<p><strong>Repositorio:</strong> <a href=""$(Html $hfPkg.Url)"" target=""_blank"" rel=""noopener noreferrer"">$(Html $hfPkg.Repo)</a></p>" } else { '' }
    $hfExample = 'Usa la skill hyperframes para crear un vídeo corto que explique lo que te indique, con voz y subtítulos.'
    $hyperframesCard = @"
      <article class="auto-card skill-group-card" data-skill-name="hyperframes-paquete" data-skill-count="$hfCount" data-skill-members="$(Html $hfMembers)" data-skill-common="$(Html $hfCommon)" data-skill-scope="$hfScope" data-skill-origin="terceros" data-skill-package="heygen-com-hyperframes" data-skill-category="$(Html 'Vídeo y motion graphics')" data-skill-search="$(Html $hfSearch)">
        <div class="skill-card-head">
          <span class="skill-topic">$(Html 'Vídeo y motion graphics')</span>
          <span class="skill-origin-badge origin-terceros" title="$(Html "Paquete de terceros · repositorio $($hfPkg.Repo)")">$(Html $hfPkg.Label)</span>
        </div>
        <h3>HyperFrames: vídeos con IA ($hfCount skills)</h3>
        <p class="skill-slug"><code>hyperframes</code> y $($hfCount - 1) skills más</p>
        <p>Crea vídeos, animaciones, subtítulos y presentaciones con IA. Cada skill sirve para un tipo de vídeo distinto; la guía explica cuál elegir y qué opciones hay de voz, música y volumen.</p>
        <p class="skill-availability">$(Html $hfAvailability)</p>
        <div class="skill-example"><strong>Ejemplo para pedirlo en el chat</strong><p class="skill-prompt">$(Html $hfExample)</p></div>
        <a class="btn btn-primary" href="./hyperframes.html">Abrir la guía de HyperFrames</a>
        <button type="button" class="btn btn-ghost" data-copy-prompt>Copiar ejemplo</button>
        <details class="skill-details"><summary>Skills incluidas</summary>
          <ul>
            $hfList
          </ul>
          $hfRepoLink
        </details>
      </article>
"@
}

$skillCards = @(if ($hyperframesCard) { $hyperframesCard }) + @(foreach ($skill in ($catalogSkills | Where-Object { $_.Name -notin $hyperframesNames } | Sort-Object @{Expression = { $categoryOrder[$_.Category] }}, Name)) {
    $display = $displayNames[$skill.Name]
    $title = if ($display) { $display.Title } else { $skill.Name }
    $purpose = if ($display) { $display.Purpose } else { $skill.Description }
    $projectCopy = @($skills | Where-Object Name -eq $skill.Name).Count -gt 0
    $scopeKey = if ($projectCopy) { 'project' } else { 'global' }
    $availability = if ($skill.Scope -eq 'Proyecto') { 'Disponible en este proyecto' } elseif ($projectCopy) { 'Global · También tiene copia en este proyecto' } else { 'Global · Disponible desde otros proyectos' }
    $originKey = if ($skill.Origin -eq 'Propia') { 'propia' } else { 'terceros' }
    $pkg = Get-SkillPackage -Name $skill.Name -Origin $skill.Origin -Path $skill.Relative
    $originLabel = $pkg.Label
    $repoTitle = if ($pkg.Repo) { "Paquete de terceros · repositorio $($pkg.Repo)" } else { 'Paquete de terceros · sin entrada en el registro de instalación' }
    $originBadge = if ($skill.Origin -eq 'Propia') { "<span class=""skill-origin-badge origin-propia"" title=""Escrita o adaptada a mano por el equipo Skill Maestra"">&#9733; Propia de Skill Maestra</span>" } else { "<span class=""skill-origin-badge origin-terceros"" title=""$(Html $repoTitle)"">$(Html $pkg.Label)</span>" }
    $originDetail = if ($skill.Origin -eq 'Propia') { Html $pkg.Label } elseif ($pkg.Url) { "$(Html $pkg.Label) · repositorio <a href=""$(Html $pkg.Url)"" target=""_blank"" rel=""noopener noreferrer"">$(Html $pkg.Repo)</a>" } else { Html $pkg.Label }
    $example = "Usa la skill $($skill.Name) para $($title.Substring(0,1).ToLowerInvariant() + $title.Substring(1)). Te indicaré los archivos o datos con los que trabajar."
    if ($skill.Name -eq 'pdf') { $example = 'Usa la skill pdf para extraer el texto y las tablas del PDF que te indique y preparar un resumen.' }
    if ($skill.Name -eq 'frontend-design') { $example = 'Usa la skill frontend-design para diseñar una web clara, fácil de usar y adaptada al móvil.' }
    if ($skill.Name -eq 'gws-calendar-agenda') { $example = 'Usa la skill gws-calendar-agenda para mostrar mis próximas reuniones en Google Calendar.' }
    if ($skill.Name -in @('deploy','prepare','scaffold')) { $example = "Usa azure-app-onboard para llevar mi aplicación a Azure e incluir el paso de $title." }
@"
      <article class="auto-card" data-skill-name="$(Html $skill.Name)" data-skill-scope="$scopeKey" data-skill-origin="$originKey" data-skill-package="$(Html $pkg.Key)" data-skill-category="$(Html $skill.Category)" data-skill-search="$(Html "$title $purpose $example $($skill.Name) $($skill.Category) $($skill.Description) $originLabel $($pkg.Repo)")">
        <div class="skill-card-head">
          <span class="skill-topic">$(Html $skill.Category)</span>
          $originBadge
        </div>
        <h3>$(Html $title)</h3>
        <p class="skill-slug"><code>$(Html $skill.Name)</code></p>
        <p>$(Html $purpose)</p>
        <p class="skill-availability">$(Html $availability)</p>
        <div class="skill-example"><strong>Ejemplo para pedirlo en el chat</strong><p class="skill-prompt">$(Html $example)</p></div>
        <button type="button" class="btn btn-primary" data-copy-prompt>Copiar ejemplo</button>
        <details class="skill-details"><summary>Detalles técnicos</summary>
          <p><strong>Nombre de la skill:</strong> <code>$(Html $skill.Name)</code></p>
          <p><strong>Origen:</strong> $originDetail</p>
          <p><strong>Descripción de origen:</strong> $(Html $skill.Description)</p>
          <p><strong>Archivo:</strong> <code>$(Html $skill.Relative)</code></p>
        </details>
      </article>
"@
})

$instructionCards = foreach ($section in ($instructionSections | Sort-Object File, Title)) {
@"
      <article class="auto-card instruction">
        <div class="auto-card-head">
          <span class="auto-icon auto-icon-instruction" aria-hidden="true"></span>
          <div>
            <h3>$(Html $section.Title)</h3>
            <span>$(Html $section.File)</span>
          </div>
        </div>
        <p>$(Html $section.Summary)</p>
        <button class="btn btn-primary" onclick="openSkill('$(Html $section.File)')">Abrir instrucciones</button>
      </article>
"@
}

$categoryOptions = foreach ($group in $skillsByCategory) {
    "<option value=""$(Html $group.Name)"">$(Html $group.Name) ($($group.Count))</option>"
}

$packageGroups = @($catalogSkills | ForEach-Object { Get-SkillPackage -Name $_.Name -Origin $_.Origin -Path $_.Relative } | Group-Object Key | Sort-Object @{Expression = 'Count'; Descending = $true}, Name)
$packageOptions = foreach ($group in $packageGroups) {
    "<option value=""$(Html $group.Name)"">$(Html $group.Group[0].Label) ($($group.Count))</option>"
}
$customCount = @($catalogSkills | Where-Object Origin -eq 'Propia').Count
$thirdPartyCount = $catalogSkills.Count - $customCount

$hfIntro = if ($hyperframesSkills.Count -gt 0) { " Las $($hyperframesSkills.Count) skills de HyperFrames (vídeo) se muestran juntas en una ficha que lleva a su guía." } else { '' }
$hfFoot = if ($hyperframesSkills.Count -gt 0) { " y las $($hyperframesSkills.Count) de HyperFrames se agrupan en una sola ficha" } else { '' }

$hfNavLink = if ($hyperframesPageExists) { '<a href="./hyperframes.html">HyperFrames</a>' } else { '' }

$generated = @"
$startMarker
  <section id="inventario-vivo" class="catalog-intro">
    <h2>Qué tienes y qué puedes hacer</h2>
    <p>Encuentra una herramienta, entiende para qué sirve y aprende a usarla. Tus <strong>$($catalogSkills.Count) skills</strong> están reunidas aquí, sin contar dos veces las copias del proyecto.$hfIntro <strong>$customCount</strong> están escritas o adaptadas a mano por el equipo Skill Maestra (marcadas con &#9733; <strong>Propia de Skill Maestra</strong>) y <strong>$thirdPartyCount</strong> son paquetes de terceros (Azure, Google Workspace, HyperFrames, recetas, personas...).</p>
  </section>

  <nav class="catalog-tabs" aria-label="Tipos de herramientas">
    <button type="button" data-panel="panel-skills" aria-controls="panel-skills" aria-pressed="true" class="active">Skills ($($catalogSkills.Count))</button>
    <button type="button" class="tab-origin-shortcut" onclick="showOnlyOrigin('propia')" title="Ver solo las skills escritas o adaptadas a mano por el equipo Skill Maestra">&#9733; Solo propias ($customCount)</button>
    <button type="button" data-panel="panel-instructions" aria-controls="panel-instructions" aria-pressed="false">Tus instrucciones ($($instructionSections.Count))</button>
    <button type="button" data-panel="panel-scripts" aria-controls="panel-scripts" aria-pressed="false">Scripts</button>
    <button type="button" data-panel="panel-extensions" aria-controls="panel-extensions" aria-pressed="false">Extensiones</button>
    <a href="./comandos.html">Comandos del chat</a>
    <a href="./trucos.html">Trucos</a>
    $hfNavLink
  </nav>

  <section id="panel-skills" class="portal-panel">
    <div class="auto-panel-head"><div><h2>Qué puedes pedirle a la IA</h2>
      <p class="catalog-explanation">Una skill es una guía que enseña al agente a hacer una tarea. Copia un ejemplo, pégalo en tu chat y añade tus datos. El agente utiliza las herramientas y conexiones disponibles en esa sesión.</p>
    </div></div>
    <div class="catalog-toolbar">
      <div class="catalog-fields">
        <label>¿Qué necesitas hacer?<input id="skill-search" type="search" placeholder="Por ejemplo: PDF, flujos, correo, web…" /></label>
        <label>Tema<select id="skill-category"><option value="">Todos los temas</option>$($categoryOptions -join '')</select></label>
        <label>Origen<select id="skill-origin-filter"><option value="">Propias y de terceros</option><option value="propia">Solo propias de Skill Maestra ($customCount)</option><option value="terceros">Solo paquetes de terceros ($thirdPartyCount)</option></select></label>
        <label>Paquete<select id="skill-package-filter"><option value="">Todos los paquetes</option>$($packageOptions -join '')</select></label>
        <label>Disponibilidad<select id="skill-scope"><option value="">Todas las skills</option><option value="project">Con copia en este proyecto</option><option value="global">Solo en la carpeta global</option></select></label>
      </div>
      <div class="catalog-examples"><span>Prueba con:</span><button type="button" data-search-example="PDF">Documentos PDF</button><button type="button" data-search-example="flujos">Flujos de Power Automate</button><button type="button" data-search-example="web">Crear una web</button><button type="button" data-search-example="correo">Correo</button></div>
    </div>
    <div id="skill-results-start" class="catalog-results" tabindex="-1"><p id="skill-search-count" role="status" aria-live="polite">$($catalogSkills.Count) skills en $(@($skillCards).Count) fichas.</p><button type="button" class="btn btn-ghost" data-reset-skills>Limpiar filtros</button></div>
    <div class="auto-card-grid">$($skillCards -join "`n")</div>
    <div id="skill-empty" class="ops-empty" hidden><p>Prueba con otra palabra o elimina los filtros para explorar el catálogo completo.</p><button type="button" class="btn btn-ghost" data-reset-skills>Ver todas las skills</button></div>
    <nav id="skill-pagination" class="catalog-pagination" aria-label="Páginas del catálogo"><button id="skill-prev" type="button" class="btn btn-ghost">Anterior</button><span id="skill-page"></span><button id="skill-next" type="button" class="btn btn-ghost">Siguiente</button></nav>
  </section>

  <section id="panel-scripts" class="portal-panel" hidden>
    <div class="auto-panel-head">
      <div>
        <p class="auto-eyebrow">Automatizaciones y utilidades</p>
        <h2>Scripts: código para tareas concretas</h2><p class="catalog-explanation">Son archivos que automatizan un trabajo cuando se ejecutan. Abre el visor para consultar su código y las opciones disponibles.</p>
      </div>
    </div>
    <div class="auto-card-grid">
      <article class="auto-card">
        <div class="auto-card-head">
          <span class="auto-icon auto-icon-scripts" aria-hidden="true"></span>
          <div>
            <h3>Actualizar este catálogo</h3>
            <span>Inventario de herramientas</span>
          </div>
        </div>
        <p>Lee las skills instaladas y regenera esta página con los nombres, descripciones y contadores actuales.</p>
        <details class="skill-details"><summary>Archivo del script</summary><code>_archivos_por_categoria/scripts/ps1/Update-SkillMaestraWebIndex.ps1</code></details>
        <a class="btn btn-primary" href="./scripts-viewer.html?file=_archivos_por_categoria/scripts/ps1/Update-SkillMaestraWebIndex.ps1&amp;readonly=1">Consultar código</a>
      </article>
      <article class="auto-card">
        <div class="auto-card-head">
          <span class="auto-icon auto-icon-scripts" aria-hidden="true"></span>
          <div>
            <h3>Sincronizar skills al catálogo global</h3>
            <span>Copia de .github/skills a ~/.agents/skills</span>
          </div>
        </div>
        <p>Copia cada skill del proyecto a la carpeta global del usuario para que esté disponible en todos los repositorios. Prueba primero con -WhatIf.</p>
        <details class="skill-details"><summary>Archivo del script</summary><code>shared/scripts/sync-global-skills.ps1</code></details>
        <a class="btn btn-primary" href="./scripts-viewer.html?file=shared/scripts/sync-global-skills.ps1&amp;readonly=1">Consultar código</a>
      </article>
    </div>
  </section>

  <section id="panel-extensions" class="portal-panel extension-panel" hidden>
    <div class="auto-panel-head">
      <div>
        <p class="auto-eyebrow">Extensiones y herramientas</p>
        <h2>Extensiones: herramientas añadidas a VS Code</h2><p class="catalog-explanation">Añaden funciones al editor, como trabajar con Git, Azure, depurar código o hablar con la IA. El inventario explica para qué sirve cada una.</p>
      </div>
      <button class="btn btn-primary" onclick="location.href='./extensiones.html'">Ver extensiones instaladas</button>
    </div>
    <div class="extension-callout">
      <strong>Incluye IA, Azure, Power Platform, Git, linting, diseno y utilidades.</strong>
      <p>Usa este bloque cuando quieras comprobar que capacidades tiene el entorno antes de pedirle una tarea a la IA.</p>
    </div>
  </section>

  <section id="panel-instructions" class="portal-panel" hidden>
    <div class="auto-panel-head">
      <div>
        <p class="auto-eyebrow">Instrucciones dadas a la IA</p>
        <h2>Cómo debe trabajar la IA en este proyecto</h2><p class="catalog-explanation">Estas $($instructionSections.Count) reglas indican al agente cómo actuar, qué comprobar y qué límites respetar.</p>
      </div>
      <button class="btn btn-ghost" onclick="openSkill('.github/copilot-instructions.md')">Abrir archivo completo</button>
    </div>
    <div class="auto-card-grid instructions-grid">
$($instructionCards -join "`n")
    </div>
  </section>

  <details id="panel-skill-health" class="catalog-technical">
    <summary>Detalles técnicos del catálogo y diagnóstico</summary>
    <p>Actualizado: $now. Las skills se leen de las carpetas locales cuando se ejecuta el actualizador de la web.</p>
    <dl><dt>$($catalogSkills.Count) skills distintas</dt><dd>$($globalSkills.Count) en la carpeta global y $($skills.Count) en el proyecto. Las copias con el mismo nombre aparecen en una sola ficha$hfFoot.</dd>
      <dt>Comprobación de nombre y descripción: $healthLabel</dt><dd>Comprueba los datos de identificación de los archivos. No verifica que cada conexión o herramienta esté lista para ejecutarse.</dd>
      <dt>Carpeta global</dt><dd>$(Html $UserSkillRoot)</dd><dt>Carpeta de Claude</dt><dd>$(Html $ClaudeSkillRoot) — $claudeSkillCount skills detectadas.</dd></dl>
    <p><button class="btn btn-ghost" onclick="openSkill('_archivos_por_categoria/web/md/catalogo-skills.md')">Ver inventario técnico completo</button></p>
  </details>
  <p id="copy-status" class="catalog-toast" role="status" aria-live="polite"></p>
  <dialog id="copy-dialog" aria-labelledby="copy-title"><h2 id="copy-title">Copia el ejemplo al chat</h2><p>El navegador no permite copiar automáticamente. Selecciona el texto y usa Copiar.</p><textarea aria-label="Ejemplo para copiar" readonly></textarea><button type="button" class="btn btn-primary">Cerrar</button></dialog>
  <script src="./skill-catalog.js" defer></script>
$endMarker
"@

$fullIndexPath = Join-Path $RepoRoot $IndexPath
$html = Read-Utf8Text -Path $fullIndexPath

$legacyCardsPattern = "(?s)\r?\n\s*<div class=""stats"">.*?\r?\n\s*<!-- EXTENSIONES -->"
if ([regex]::IsMatch($html, $legacyCardsPattern)) {
    $html = [regex]::Replace($html, $legacyCardsPattern, "`r`n`r`n  <!-- EXTENSIONES -->", 1)
}

$autoCss = @"

    $cssStartMarker
    .container > .stats, .container > .grid { display: none; }
    .auto-hero { background: #ffffff; border: 1px solid #d7e4ff; border-radius: 14px; padding: 24px; margin-bottom: 18px; box-shadow: 0 8px 24px rgba(15,52,96,0.08); display: grid; grid-template-columns: minmax(0, 1fr) minmax(260px, 430px); gap: 22px; align-items: start; }
    .auto-hero h2 { font-size: 1.7rem; color: #0f3460; margin-bottom: 8px; }
    .auto-hero p { color: #45546b; line-height: 1.55; }
    .auto-eyebrow { color: #7a4d00 !important; font-size: .78rem !important; text-transform: uppercase; font-weight: 800; letter-spacing: .06em; margin-bottom: 6px !important; }
    .auto-summary { display: flex; flex-wrap: wrap; justify-content: flex-end; gap: 8px; min-width: 0; margin-top: 14px; }
    .auto-badge { display: inline-flex; align-items: center; background: #e8eef7; color: #0f3460; border-radius: 999px; padding: 5px 10px; font-size: .78rem; font-weight: 700; max-width: 100%; white-space: normal; }
    .auto-badge-link { border: 0; cursor: pointer; font-family: inherit; transition: transform .15s, box-shadow .15s, background .15s; }
    .auto-badge-link:hover { transform: translateY(-1px); background: #dbe7fb; box-shadow: 0 4px 12px rgba(15,52,96,0.12); }
    .portal-menu { display: grid; grid-template-columns: repeat(3, minmax(0, 1fr)); gap: 16px; margin: 18px 0 22px; }
    .portal-card { min-height: 138px; display: flex; flex-direction: column; align-items: flex-start; justify-content: space-between; gap: 10px; border: 1px solid #dce5f2; border-radius: 14px; padding: 18px; background: #fff; color: #18253b; text-align: left; box-shadow: 0 4px 16px rgba(15,52,96,0.07); }
    .portal-card:hover, .portal-card.active { background: #eef5ff; border-color: #0f3460; box-shadow: 0 10px 26px rgba(15,52,96,0.14); }
    .portal-card strong { font-size: 1.15rem; color: #0f3460; }
    .portal-card em { color: #59677c; font-style: normal; font-size: .86rem; line-height: 1.35; }
    .portal-icon { width: 44px; height: 44px; border-radius: 12px; display: inline-flex; align-items: center; justify-content: center; background: #0f3460; color: #fff; position: relative; overflow: hidden; }
    .portal-icon::before, .portal-icon::after, .auto-icon::before, .auto-icon::after { content: ""; position: absolute; display: block; }
    .portal-icon-instructions::before { width: 20px; height: 24px; border: 2px solid #fff; border-radius: 3px; background: transparent; }
    .portal-icon-instructions::after { width: 12px; height: 2px; background: #fff; box-shadow: 0 6px 0 #fff, 0 12px 0 #fff; left: 16px; top: 13px; }
    .portal-icon-skills::before { width: 7px; height: 7px; border-radius: 50%; background: #fff; box-shadow: 12px 0 0 #fff, 6px 10px 0 #fff, 18px 10px 0 #fff; left: 10px; top: 11px; }
    .portal-icon-skills::after { width: 22px; height: 2px; background: #fff; transform: rotate(27deg); left: 11px; top: 22px; box-shadow: 0 9px 0 #fff; }
    .portal-icon-extensions::before { width: 20px; height: 17px; border: 2px solid #fff; border-radius: 4px; left: 10px; top: 15px; }
    .portal-icon-extensions::after { width: 3px; height: 10px; background: #fff; left: 17px; top: 8px; box-shadow: 8px 0 0 #fff; }
    .portal-icon-scripts::before { width: 18px; height: 22px; border: 2px solid #fff; border-radius: 4px; left: 13px; top: 11px; }
    .portal-icon-scripts::after { width: 10px; height: 2px; background: #fff; left: 17px; top: 16px; box-shadow: 0 5px 0 #fff, 0 10px 0 #fff; }
    .portal-icon-functions::before { width: 18px; height: 18px; border: 2px solid #fff; border-radius: 6px; left: 13px; top: 13px; }
    .portal-icon-functions::after { width: 12px; height: 12px; border-right: 2px solid #fff; border-bottom: 2px solid #fff; transform: rotate(-45deg); left: 16px; top: 15px; }
    .portal-icon-commands::before { width: 3px; height: 3px; border-radius: 50%; background: #fff; left: 15px; top: 21px; box-shadow: 8px 0 0 #fff, 16px 0 0 #fff; }
    .portal-icon-commands::after { content: "/"; position: absolute; left: 16px; top: 6px; font-size: 20px; font-weight: 800; color: #fff; background: none; }
    .portal-panel { display: block; background: white; border: 1px solid #dce5f2; border-radius: 14px; padding: 22px; margin: 20px 0 28px; box-shadow: 0 6px 22px rgba(15,52,96,0.07); scroll-margin-top: 20px; }
    .auto-panel-head { display: flex; justify-content: space-between; gap: 14px; align-items: center; margin-bottom: 18px; }
    .auto-panel-head h2 { color: #0f3460; font-size: 1.35rem; margin: 0; }
    .skill-panel-actions { display: flex; gap: 10px; align-items: center; justify-content: flex-end; flex-wrap: wrap; }
    .auto-search { width: min(100%, 360px); border: 1px solid #cfd8e6; border-radius: 8px; padding: 9px 11px; font: inherit; font-size: .86rem; color: #18253b; background: #fff; }
    .auto-search:focus { outline: 3px solid #bfdbfe; border-color: #2563eb; }
    .auto-card-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(275px, 1fr)); gap: 14px; }
    .instructions-grid { grid-template-columns: repeat(auto-fill, minmax(310px, 1fr)); }
    .auto-card { border: 1px solid #e3e9f3; border-radius: 12px; padding: 16px; min-height: 210px; display: flex; flex-direction: column; gap: 12px; background: #fbfcff; }
    .auto-card.instruction { background: #fffdf7; border-color: #f1dfae; }
    .auto-card-head { display: flex; gap: 12px; align-items: flex-start; }
    .auto-card h3 { margin: 0 0 4px; font-size: .98rem; color: #18253b; }
    .auto-card span:not(.auto-icon) { color: #69758a; font-size: .76rem; }
    .auto-card p { color: #3b4658; font-size: .86rem; line-height: 1.45; }
    .auto-icon { width: 34px; height: 34px; border-radius: 10px; display: inline-flex; align-items: center; justify-content: center; color: #0f3460; background: #e8eef7; flex: 0 0 auto; position: relative; }
    .auto-icon-instruction::before { width: 15px; height: 18px; border: 2px solid #0f3460; border-radius: 3px; left: 8px; top: 7px; }
    .auto-icon-instruction::after { width: 9px; height: 2px; background: #0f3460; left: 12px; top: 12px; box-shadow: 0 5px 0 #0f3460, 0 10px 0 #0f3460; }
    .auto-icon-skill::before { width: 6px; height: 6px; border-radius: 50%; background: #0f3460; left: 8px; top: 8px; box-shadow: 10px 0 0 #0f3460, 5px 9px 0 #0f3460, 15px 9px 0 #0f3460; }
    .auto-icon-skill::after { width: 18px; height: 2px; background: #0f3460; transform: rotate(27deg); left: 8px; top: 18px; box-shadow: 0 8px 0 #0f3460; }
    .auto-icon-scripts::before { width: 14px; height: 18px; border: 2px solid #0f3460; border-radius: 4px; left: 9px; top: 7px; }
    .auto-icon-scripts::after { width: 8px; height: 2px; background: #0f3460; left: 13px; top: 12px; box-shadow: 0 5px 0 #0f3460, 0 10px 0 #0f3460; }
    .auto-icon-function::before { width: 14px; height: 14px; border: 2px solid #0f3460; border-radius: 5px; left: 9px; top: 9px; }
    .auto-icon-function::after { width: 9px; height: 9px; border-right: 2px solid #0f3460; border-bottom: 2px solid #0f3460; transform: rotate(-45deg); left: 12px; top: 11px; }
    .auto-path { margin-top: auto; background: #edf2f8; border-radius: 7px; padding: 8px; color: #59677c; font-family: Consolas, monospace; font-size: .72rem; overflow-wrap: anywhere; }
    .extension-callout { border-radius: 12px; background: #fff8df; border: 1px solid #f2d57d; padding: 18px; color: #5f4300; }
    .extension-callout p { margin-top: 8px; color: #6b5a25; }
    .auto-muted { color: #667085; font-size: .82rem; line-height: 1.45; }
    .ops-panel { display: grid; grid-template-columns: 1fr; gap: 16px; margin: 0 0 24px; }
    .ops-card { background: #fff; border: 1px solid #dce5f2; border-radius: 14px; box-shadow: 0 6px 22px rgba(15,52,96,0.07); padding: 18px; }
    .ops-card h3 { font-size: 1rem; color: #0f3460; margin-bottom: 6px; }
    .ops-kpis { display: grid; grid-template-columns: repeat(4, minmax(0,1fr)); gap: 10px; margin-top: 14px; }
    .ops-kpi { border: 1px solid #e5ebf5; border-radius: 12px; padding: 12px; background: #fbfcff; min-height: 88px; }
    button.ops-kpi { text-align: left; font: inherit; cursor: pointer; }
    .ops-kpi-link, .ops-item-link, .ops-mini-link { cursor: pointer; transition: transform .15s, box-shadow .15s, border-color .15s, background .15s; }
    .ops-kpi-link:hover, .ops-item-link:hover, .ops-mini-link:hover { transform: translateY(-1px); box-shadow: 0 8px 20px rgba(15,52,96,0.10); border-color: #b9cae4; background: #f7faff; }
    .ops-kpi-link:focus-visible, .ops-item-link:focus-visible, .ops-mini-link:focus-visible, .auto-badge-link:focus-visible { outline: 3px solid #93c5fd; outline-offset: 2px; }
    .ops-kpi-alert { background: #fff1f2; border-color: #fecdd3; }
    .ops-kpi-detail { grid-column: span 2; }
    .ops-kpi .ops-list { margin-top: 10px; }
    .ops-kpi .ops-empty { padding: 10px 12px; font-size: .92rem; }
    .ops-kpi-label { color: #667085; font-size: .72rem; text-transform: uppercase; letter-spacing: .05em; margin-bottom: 8px; font-weight: 800; }
    .ops-kpi-value { font-size: 1.5rem; font-weight: 800; color: #18253b; }
    .ops-kpi-sub { color: #667085; font-size: .78rem; margin-top: 6px; overflow-wrap: anywhere; }
    .ops-kpi-sub strong { color: #0f3460; font-weight: 800; }
    .ops-list { display: flex; flex-direction: column; gap: 10px; margin-top: 14px; }
    .ops-item { border: 1px solid #e5ebf5; border-radius: 12px; padding: 12px; background: #fbfcff; }
    .ops-item-alert { background: #fff1f2; border-color: #fecdd3; }
    .ops-item-head { display: flex; justify-content: space-between; gap: 10px; align-items: flex-start; margin-bottom: 6px; }
    .ops-item-title { font-weight: 700; color: #18253b; }
    .ops-item-meta { color: #667085; font-size: .8rem; }
    .ops-item-pill { border-radius: 999px; padding: 3px 8px; font-size: .73rem; font-weight: 700; white-space: nowrap; }
    .pill-bad { background: #fee2e2; color: #991b1b; }
    .ops-note { color: #475467; font-size: .84rem; line-height: 1.5; margin-top: 8px; }
    .ops-empty { border: 1px dashed #cbd5e1; border-radius: 12px; padding: 14px; color: #667085; background: #f8fafc; font-size: .84rem; }
    @media (max-width: 900px) { .auto-hero { grid-template-columns: 1fr; } .auto-summary { justify-content: flex-start; } }
    @media (max-width: 980px) { .ops-kpis { grid-template-columns: repeat(2, minmax(0,1fr)); } .ops-kpi-detail { grid-column: span 2; } }
    @media (max-width: 760px) { .portal-menu { grid-template-columns: 1fr; } .auto-panel-head { align-items: flex-start; flex-direction: column; } .skill-panel-actions, .auto-search { width: 100%; justify-content: flex-start; } .ops-kpis { grid-template-columns: 1fr; } .ops-kpi-detail { grid-column: span 1; } }
    $cssEndMarker
"@

$cssPattern = "(?s)" + [regex]::Escape($cssStartMarker) + ".*?" + [regex]::Escape($cssEndMarker) + "\s*"
if ([regex]::IsMatch($html, $cssPattern)) {
    $html = [regex]::Replace($html, $cssPattern, $autoCss)
} elseif ($html -notmatch "\.auto-hero") {
    $html = $html -replace "</style>", "$autoCss`r`n  </style>"
}

$pattern = "(?s)" + [regex]::Escape($startMarker) + ".*?" + [regex]::Escape($endMarker) + "\s*"
if ($html.Contains($startMarker) -and $html.Contains($endMarker)) {
    $html = [regex]::Replace($html, $pattern, "")
}

$insertAfterContainer = "(?s)(<div class=""container"">\s*)"
if ([regex]::IsMatch($html, $insertAfterContainer)) {
    $html = [regex]::Replace(
        $html,
        $insertAfterContainer,
        [System.Text.RegularExpressions.MatchEvaluator]{ param($m) $m.Value + "`r`n" + $generated + "`r`n" },
        1
    )
} else {
    $insertBefore = "  <!-- EXTENSIONES -->"
    if ($html.Contains($insertBefore)) {
        $html = $html.Replace($insertBefore, "$generated`r`n`r`n  <!-- EXTENSIONES -->")
    } else {
        $html = $html -replace "</div>\s*</div>\s*<footer>", "$generated`r`n  </div>`r`n</div>`r`n`r`n<footer>"
    }
}

if (-not $html.Contains('href="./skill-catalog.css"')) {
    $html = $html.Replace('</head>', '  <link rel="stylesheet" href="./skill-catalog.css" />' + "`r`n</head>")
}
$html = [regex]::Replace($html, '<title>.*?</title>', '<title>Skill Maestra — Tus herramientas</title>', 1)
$html = [regex]::Replace($html, '(?s)(<header>.*?<h1>Skill Maestra</h1>\s*)<p>.*?</p>', '$1<p>Tus herramientas, explicadas para usarlas</p>', 1)
$html = [regex]::Replace($html, '(?s)<footer>.*?</footer>', "<footer>Skill Maestra · $($catalogSkills.Count) skills distintas · Inventario actualizado el $now</footer>", 1)
# Remove the old duplicated extensions panel; the dedicated inventory page is the canonical view.
$html = [regex]::Replace($html, '(?s)  <!-- EXTENSIONES -->.*?(?=<footer>)', "</div>`r`n`r`n")
# The legacy banner was visible even when served correctly through Live Preview.
$html = [regex]::Replace($html, '(?s)<div class="http-banner" role="note">.*?</div>\s*</div>', '')
$html = [regex]::Replace($html, [regex]::Escape($endMarker) + '\s*(?:</div>\s*)?<footer>', "$endMarker`r`n</div>`r`n`r`n<footer>")

# Actualiza contadores visibles existentes sin tocar el resto del diseno.
$html = [regex]::Replace($html, '<div class="val">\d+</div><div class="lbl">Skills activas</div>', "<div class=""val"">$($skills.Count)</div><div class=""lbl"">Skills activas</div>", 1)
$html = [regex]::Replace($html, '(\d+) skills activas \+ \d+ extensiones', "$($skills.Count) skills proyecto + $($globalSkills.Count) globales + $extensionCount extensiones")
$html = [regex]::Replace($html, '<div class="badge">.*?</div>', "<div class=""badge"">Actualizado: $now</div>", 1)

$mojibakePattern = ([string][char]0x00C3) + "|" + ([string][char]0x00C2)
if ($html -match $mojibakePattern) {
    $badMatch = [regex]::Match($html, $mojibakePattern)
    $start = [Math]::Max(0, $badMatch.Index - 60)
    $length = [Math]::Min(140, $html.Length - $start)
    $snippet = $html.Substring($start, $length)
    throw "Se detecto texto con codificacion rota en el HTML generado cerca de: $snippet"
}

$html = [regex]::Replace($html, '(?m)[ \t]+\r?$', '')
Write-Utf8Text -Path $fullIndexPath -Value $html

$fullCatalogPath = Join-Path $RepoRoot $MarkdownCatalogPath
New-Item -ItemType Directory -Force -Path (Split-Path -Parent $fullCatalogPath) | Out-Null
$md = @()
$md += "# Skill Maestra - Catalogo vivo"
$md += ""
$md += "Fecha de actualizacion: $now"
$md += ""
$md += "## Estado"
$md += ""
$md += "- Skills del proyecto: $($skills.Count)"
$md += "- Skills globales: $($globalSkills.Count)"
$md += "- Skills visibles por Claude: $claudeSkillCount"
$md += "- Skills solo globales: $($globalOnlySkills.Count)"
$md += "- Avisos de frontmatter: $frontMatterIssueCount"
$md += "- Ruta global: ``$UserSkillRoot``"
$md += "- Ruta Claude: ``$ClaudeSkillRoot``"
$md += ""
$md += "## Skills del proyecto ($($skills.Count))"
$md += ""
foreach ($skill in ($skills | Sort-Object Category, Name)) {
    $md += "### $($skill.Name)"
    $md += "- Categoria: $($skill.Category)"
    $md += "- Ruta: ``" + $skill.Relative + "``"
    $md += "- Descripcion: $($skill.Description)"
    $md += ""
}
$md += "## Skills globales ($($globalSkills.Count))"
$md += ""
foreach ($skill in ($globalSkills | Sort-Object Category, Name)) {
    $md += "### $($skill.Name)"
    $md += "- Categoria: $($skill.Category)"
    $md += "- Ruta: ``" + $skill.Relative + "``"
    $md += "- Origen: $((Get-SkillPackage -Name $skill.Name -Origin $skill.Origin -Path $skill.Relative).Label)"
    $md += "- Scope: $($skill.Scope)"
    if ($skill.Issues.Count -gt 0) {
        $md += "- Avisos: $($skill.Issues -join ', ')"
    }
    $md += "- Descripcion: $($skill.Description)"
    $md += ""
}
$md += "## Instrucciones dadas a la IA ($($instructionSections.Count))"
$md += ""
foreach ($section in ($instructionSections | Sort-Object File, Title)) {
    $md += "### $($section.Title)"
    $md += "- Archivo: ``" + $section.File + "``"
    $md += "- Resumen: $($section.Summary)"
    $md += ""
}
Write-Utf8Text -Path $fullCatalogPath -Value ($md -join "`r`n")

[pscustomobject]@{
    Skills              = $skills.Count
    CatalogSkills       = $catalogSkills.Count
    CatalogCards        = @($skillCards).Count
    HyperFramesGrouped  = $hyperframesSkills.Count
    MissingDescriptions = $missingDescriptions.Count
    GlobalSkills        = $globalSkills.Count
    ClaudeSkills        = $claudeSkillCount
    FrontMatterIssues   = $frontMatterIssueCount
    InstructionBlocks   = $instructionSections.Count
    Index               = $fullIndexPath
    MarkdownCatalog     = $fullCatalogPath
    Updated             = $now
}
