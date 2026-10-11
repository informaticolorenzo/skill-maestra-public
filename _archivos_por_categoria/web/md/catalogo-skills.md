# Skill Maestra - Catalogo vivo

Fecha de actualizacion: 2026-10-11 11:22:30

## Estado

- Skills del proyecto: 14
- Skills globales: 0
- Skills visibles por Claude: 0
- Skills solo globales: 0
- Avisos de frontmatter: 0
- Ruta global: `C:\Users\usuario\.agents\skills`
- Ruta Claude: `C:\Users\usuario\.claude\skills`

## Skills del proyecto (14)

### gh-address-comments
- Categoria: Código, pruebas y seguridad
- Ruta: `.github/skills/gh-address-comments/SKILL.md`
- Descripcion: Help address review/issue comments on the open GitHub PR for the current branch using gh CLI; verify gh auth first and prompt the user to authenticate if not logged in.

### gh-fix-ci
- Categoria: Código, pruebas y seguridad
- Ruta: `.github/skills/gh-fix-ci/SKILL.md`
- Descripcion: Use when a user asks to debug or fix failing GitHub PR checks that run in GitHub Actions; use `gh` to inspect checks and logs, summarize failure context, draft a fix plan, and implement only after explicit approval. Treat external providers (for example Buildkite) as out of scope and report only the details URL.

### security-best-practices
- Categoria: Código, pruebas y seguridad
- Ruta: `.github/skills/security-best-practices/SKILL.md`
- Descripcion: Perform language and framework specific security best-practice reviews and suggest improvements. Trigger only when the user explicitly requests security best practices guidance, a security review/report, or secure-by-default coding help. Trigger only for supported languages (python, javascript/typescript, go). Do not trigger for general...

### security-threat-model
- Categoria: Código, pruebas y seguridad
- Ruta: `.github/skills/security-threat-model/SKILL.md`
- Descripcion: Repository-grounded threat modeling that enumerates trust boundaries, assets, attacker capabilities, abuse paths, and mitigations, and writes a concise Markdown threat model. Trigger only when the user explicitly asks to threat model a codebase or path, enumerate threats/abuse paths, or perform AppSec threat modeling. Do not trigger for...

### webapp-testing
- Categoria: Código, pruebas y seguridad
- Ruta: `.github/skills/webapp-testing/SKILL.md`
- Descripcion: Toolkit for interacting with and testing local web applications using Playwright. Supports verifying frontend functionality, debugging UI behavior, capturing browser screenshots, and viewing browser logs.

### design-md
- Categoria: Documentos y diseño
- Ruta: `.github/skills/design-md/SKILL.md`
- Descripcion: Define y valida un archivo DESIGN.md para guiar a agentes de IA en la generacion de interfaces coherentes con tu sistema visual: colores, tipografia, spacing, componentes, reglas visuales y estilo UI. Usar cuando pidas crear, revisar, mejorar o lintar un DESIGN.md para UI.

### frontend-design
- Categoria: Documentos y diseño
- Ruta: `.github/skills/frontend-design/SKILL.md`
- Descripcion: Guidance for distinctive, intentional visual design when building new UI or reshaping an existing one. Helps with aesthetic direction, typography, and making choices that don't read as templated defaults.

### agent-customization
- Categoria: Organizar el trabajo de la IA
- Ruta: `.github/skills/agent-customization/SKILL.md`
- Descripcion: Crea, actualiza, revisa, arregla o debuggea archivos de personalización de agentes (.instructions.md, .prompt.md, .agent.md, SKILL.md, copilot-instructions.md, AGENTS.md). Usa cuando necesites guardar preferencias de código, diagnosticar por qué instrucciones no se invocan, configurar patrones applyTo, definir restricciones de herramient...

### codex-computer-use
- Categoria: Organizar el trabajo de la IA
- Ruta: `.github/skills/codex-computer-use/SKILL.md`
- Descripcion: Diagnostica, configura y usa Codex Computer Use / Uso del ordenador en Windows o macOS. Usar cuando el usuario quiera manejar aplicaciones de escritorio desde Codex, abrir apps con @Computer, permitir apps, revisar permisos, comprobar computer-use/config.toml o explicar limites de seguridad.

### find-skills
- Categoria: Organizar el trabajo de la IA
- Ruta: `.github/skills/find-skills/SKILL.md`
- Descripcion: Descubre skills existentes del repo o del ecosistema abierto cuando el usuario pregunte si hay una skill para algo, quiera ampliar capacidades, buscar workflows reutilizables, instalar skills de terceros o evaluar si conviene crear una nueva skill local. Cubre: skills.sh, npx skills find, npx skills add, comparación entre skill local y e...

### skill-creator
- Categoria: Organizar el trabajo de la IA
- Ruta: `.github/skills/skill-creator/SKILL.md`
- Descripcion: Crea nuevas skills reutilizables para VS Code/Copilot con SKILL.md valido, estructura estandar, checklist de discovery y scaffold de carpetas. Usar cuando pidas crear o mejorar una skill futura.

### code-app
- Categoria: Power Platform
- Ruta: `.github/skills/code-app/SKILL.md`
- Descripcion: Crea, extiende y despliega Power Apps Code Apps siguiendo el estandar del plugin oficial code-apps: connector-first, planning policy, memory-bank y build/deploy con npx power-apps. WHEN: Code App, Code Apps, code app, create-code-app, add datasource, add connector, dataverse code app, deploy code app, power-apps push.

### model-driven-apps
- Categoria: Power Platform
- Ruta: `.github/skills/model-driven-apps/SKILL.md`
- Descripcion: Crea, actualiza y despliega paginas generativas (genpage/genux) para aplicaciones model-driven siguiendo el estandar del plugin oficial model-apps: prerequisitos PAC CLI, plan confirmado, generacion de schema, codigo React 17 + TypeScript + Fluent UI V9, despliegue y verificacion. WHEN: Model Driven Apps, Model-Driven Apps, model driven...

### power-bi-modeling-mcp-server
- Categoria: Power Platform
- Ruta: `.github/skills/power-bi-modeling-mcp-server/SKILL.md`
- Descripcion: Instala, configura y usa la extension oficial Power BI Modeling MCP Server de Microsoft para exponer capacidades de modelado semantico de Power BI a GitHub Copilot en VS Code. Usar cuando necesites conectarte a Power BI Desktop, Fabric o proyectos PBIP/TMDL, listar y modificar tablas, columnas, medidas, relaciones, particiones, roles o e...

## Skills globales (0)

## Instrucciones dadas a la IA (5)

### Mejora continua de skills
- Archivo: `.github/copilot-instructions.md`
- Resumen: - Cuando se descubra un error, una limitación o un camino más rápido, corregir el `SKILL.md` correspondiente en la misma intervención para que no se repita.

### Modo de trabajo
- Archivo: `.github/copilot-instructions.md`
- Resumen: - Ejecutar de forma autónoma todo lo que se pueda y pedir datos solo cuando no haya forma de automatizarlo. - Ante un cambio con riesgo (datos, configuración, despliegues), actuar de la forma más conservadora posible y preferir una prueba reversible antes del...

### Regla de arranque
- Archivo: `.github/copilot-instructions.md`
- Resumen: - Antes de empezar una tarea, leer la skill del dominio en `.github/skills/<nombre>/SKILL.md` y seguirla. - Si la tarea toca un dominio con skill disponible, cargarla antes de buscar, editar o ejecutar nada.

### Seguridad
- Archivo: `.github/copilot-instructions.md`
- Resumen: - Nunca subir secretos ni configuración local (`.env`, `local.settings.json`, tokens). - No desplegar ni publicar en producción sin confirmación explícita.

### Verificación
- Archivo: `.github/copilot-instructions.md`
- Resumen: - Tras cualquier cambio, comprobar el resultado real (archivo generado, página renderizada, salida del script) antes de darlo por terminado. - Que un comando devuelva éxito no basta: verificar que el cambio está presente.
