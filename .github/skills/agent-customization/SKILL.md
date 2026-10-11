---
name: agent-customization
description: "Crea, actualiza, revisa, arregla o debuggea archivos de personalización de agentes (.instructions.md, .prompt.md, .agent.md, SKILL.md, copilot-instructions.md, AGENTS.md). Usa cuando necesites guardar preferencias de código, diagnosticar por qué instrucciones no se invocan, configurar patrones applyTo, definir restricciones de herramientas, crear workflows customizados, empaquetar knowledge, o arreglar sintaxis YAML frontmatter."
argument-hint: "Indica: tipo de customización (.instructions.md, .prompt.md, .agent.md, SKILL.md), ámbito (workspace o user), patrones applyTo, restricciones de herramientas"
---

# Agent Customization

## Decision Flow

| Primitive | When to Use |
|-----------|-------------|
| agent instructions | Always-on, applies everywhere in the project |
| File Instructions | Explicit via `applyTo` patterns, or on-demand via `description` |
| MCP | Integrates external systems, APIs, or data |
| Hooks | Deterministic shell commands at agent lifecycle points (block tools, auto-format, inject context) |
| Custom Agents | Subagents for context isolation, or multi-stage workflows with tool restrictions |
| Prompts | Single focused task with parameterized inputs |
| Skills | On-demand workflow with bundled assets (scripts/templates) |

## Quick Reference

Consult the reference docs for templates, domain examples, advanced frontmatter options, asset organization, anti-patterns, and creation checklists. If the references are not enough, load the official documentation links for each primitive.

| Type | File | Location | Reference |
|------|------|----------|-----------|
| agent instructions | `copilot-instructions.md`, `AGENTS.md` | `.github/` or root | [Link](./references/agent-instructions.md) |
| File Instructions | `*.instructions.md` | `.github/instructions/` | [Link](./references/instructions.md) |
| Prompts | `*.prompt.md` | `.github/prompts/` | [Link](./references/prompts.md) |
| Hooks | `*.json` | `.github/hooks/` | [Link](./references/hooks.md) |
| Custom Agents | `*.agent.md` | `.github/agents/` | [Link](./references/agents.md) |
| Skills | `SKILL.md` | `.github/skills/<name>/`, `.agents/skills/<name>/`, `.claude/skills/<name>/` | [Link](./references/skills.md) |

**User-level**: `{{VSCODE_USER_PROMPTS_FOLDER}}/` (*.prompt.md, *.instructions.md, *.agent.md; not skills)
Customizations roam with user's settings sync

## Politica de Autonomia y Ejecucion

- Resolver de forma autonoma la creacion o reparacion de customizaciones cuando el objetivo este claro.
- No pedir rutas o archivos si pueden inferirse del tipo de primitive y del workspace.
- Pedir confirmacion solo para decisiones de ambito (workspace vs user) o cambios potencialmente disruptivos.
- Validar siempre frontmatter y discovery metadata tras cada cambio.

## Pregunta Inicial Obligatoria

Antes de crear cualquier archivo, preguntar:

1. Quieres customizacion de workspace o de perfil de usuario?
2. Necesitas efecto global (always-on) o bajo demanda?
3. Se busca crear, corregir, depurar o migrar customizacion existente?


## Opciones Soportadas (1-6)

1. Crear instrucciones globales del proyecto.
2. Crear file instructions por patrones `applyTo`.
3. Crear prompts o agentes custom para tareas especificas.
4. Crear o mejorar skills reutilizables con assets.
5. Depurar por que una customizacion no se invoca.
6. Corregir frontmatter YAML y discovery metadata.

## Flujo Recomendado

1. Confirmar alcance (workspace/user) y objetivo (always-on/on-demand).
2. Elegir el primitive correcto (instructions, prompt, agent, skill, hook, MCP).
3. Crear o editar archivo en ruta correcta.
4. Validar YAML frontmatter y descripcion de invocacion.
5. Verificar comportamiento esperado en una prueba minima.
6. Documentar cambios y riesgos de contexto/performance.

## Creation Process

If you need to explore or validate patterns in the codebase, use a read-only subagent. If the ask-questions tool is available, use it to interview the user and clarify requirements.

Follow these steps when creating any customization file.

### 1. Determine Scope

Ask the user where they want the customization:
- **Workspace**: For project-specific, team-shared customizations → `.github/` folder
- **User profile**: For personal, cross-workspace customizations → `{{VSCODE_USER_PROMPTS_FOLDER}}/`

### 2. Choose the Right Primitive

Use the Decision Flow above to select the appropriate file type based on the user's need.

### 3. Create the File

Create the file directly at the appropriate path:
- Use the location tables in each reference file
- Include required frontmatter as needed
- Add the body content following the templates

### 4. Validate

After creating:
- Confirm the file is in the correct location
- Verify frontmatter syntax (YAML between `---` markers)
- Check that `description` is present and meaningful

## Edge Cases

**Instructions vs Skill?** Does this apply to *most* work, or *specific* tasks? Most → Instructions. Specific → Skill.

**Skill vs Prompt?** Both appear as slash commands in chat (type `/`). Multi-step workflow with bundled assets → Skill. Single focused task with inputs → Prompt.

**Skill vs Custom Agent?** Same capabilities for all steps → Skill. Need context isolation (subagent returns single output) or different tool restrictions per stage → Custom Agent.

**Hooks vs Instructions?** Instructions *guide* agent behavior (non-deterministic). Hooks *enforce* behavior via shell commands at lifecycle events like `PreToolUse` or `PostToolUse` — they can block operations, require approval, or run formatters deterministically. See [hooks reference](./references/hooks.md).

## Common Pitfalls

**Description is the discovery surface.** The `description` field is how the agent decides whether to load a skill, instruction, or agent. If trigger phrases aren't IN the description, the agent won't find it. Use the "Use when..." pattern with specific keywords.

**YAML frontmatter silent failures.** Unescaped colons in values, tabs instead of spaces, `name` that doesn't match folder name — all cause silent failures with no error message. Always quote descriptions that contain colons: `description: "Use when: doing X"`.

**`applyTo: "**"` burns context.** This means "always included for every file request" — it loads the instruction into the context window on every interaction, even when irrelevant. Use specific globs (`**/*.py`, `src/api/**`) unless the instruction truly applies to all files.
