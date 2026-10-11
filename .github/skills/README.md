# Catálogo de skills

Cada carpeta contiene una skill: un `SKILL.md` con frontmatter (`name`, `description`) y, si hace falta, `references/`, `assets/` y `scripts/`. El `name` debe coincidir con el nombre de la carpeta.

## Skills propias de Skill Maestra

| Skill | Para qué sirve |
| --- | --- |
| `skill-creator` | Crear una skill nueva con estructura estándar (`scripts/new-skill-scaffold.ps1`). |
| `find-skills` | Buscar skills existentes en el ecosistema abierto antes de escribir una. |
| `agent-customization` | Escribir instrucciones, prompts y perfiles de agente para VS Code / Copilot. |
| `design-md` | Documentar el diseño de un proyecto en un `DESIGN.md` revisable. |
| `codex-computer-use` | Configurar y diagnosticar Codex Computer Use en Windows o macOS. |
| `code-app` | Desarrollar Power Apps Code Apps con arquitectura connector-first. |
| `model-driven-apps` | Crear y mantener aplicaciones basadas en modelo de Power Apps. |
| `power-bi-modeling-mcp-server` | Modelar Power BI a través de su servidor MCP. |

## Skills de terceros incluidas

Conservan su licencia original (`LICENSE.txt` en cada carpeta):

- `frontend-design`, `webapp-testing` (Anthropic)
- `gh-address-comments`, `gh-fix-ci` (GitHub)
- `security-best-practices`, `security-threat-model`

## Añadir una skill

1. `pwsh -File .github/skills/skill-creator/scripts/new-skill-scaffold.ps1 -SkillName mi-skill`
2. Añadir su fila en `_archivos_por_categoria/web/data/skill-descriptions.es.tsv` (nombre y descripción en lenguaje llano).
3. Regenerar el catálogo web: `pwsh -File _archivos_por_categoria/scripts/ps1/Update-SkillMaestraWebIndex.ps1`.
