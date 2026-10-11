---
name: find-skills
description: "Descubre skills existentes del repo o del ecosistema abierto cuando el usuario pregunte si hay una skill para algo, quiera ampliar capacidades, buscar workflows reutilizables, instalar skills de terceros o evaluar si conviene crear una nueva skill local. Cubre: skills.sh, npx skills find, npx skills add, comparación entre skill local y externa, criterios de calidad, instalación global o por proyecto."
argument-hint: "Indica dominio o tarea, si buscas skill local o externa, y si quieres solo recomendación, instalación o creación de skill nueva"
---

# Find Skills

## Cuando usar esta skill
- Cuando el usuario pregunte si existe una skill para una tarea concreta.
- Cuando quiera ampliar capacidades del agente con skills externas.
- Cuando convenga decidir entre reutilizar una skill local, instalar una skill externa o crear una nueva.
- Cuando haga falta auditar una skill de un repositorio externo y extraer buenas prácticas.
- Cuando el usuario pida buscar workflows, plantillas o conocimiento reutilizable en el ecosistema abierto.

## Objetivo
- Localizar primero si el workspace ya tiene una skill adecuada.
- Si no existe, buscar skills externas relevantes y filtrar por calidad.
- Recomendar el camino correcto: reutilizar, adaptar, instalar o crear una skill nueva.

## Politica de decision

1. Comprobar primero skills locales del repo.
2. Si no cubren bien el caso, revisar skills externas del ecosistema abierto.
3. No incorporar una skill externa completa sin revisar su calidad, encaje y mantenimiento.
4. Si la aportación útil es parcial, extraer buenas prácticas y adaptarlas a una skill local.
5. Si la necesidad es recurrente y específica de tu entorno, priorizar skill nueva local sobre dependencia externa.

## Cuando instalar global vs local

- Instalar global si la capacidad es transversal y te servirá en muchos repositorios.
- Instalar local si la skill depende de convenciones, rutas o tooling específicos de este proyecto.
- Crear skill nueva local si el conocimiento es propio de Power Platform o de este workspace.
- Si una skill externa necesita mucha adaptación para encajar aquí, no instalarla tal cual: extraer lo útil y convertirlo en skill local.

## Criterios de calidad obligatorios

- Priorizar fuentes reputadas: `microsoft`, `vercel-labs`, `anthropics` u organizaciones conocidas.
- Revisar si la skill realmente añade conocimiento o solo explica comandos genéricos.
- Confirmar que la `description` sirve para discovery real y contiene disparadores concretos.
- Descartar skills que no indiquen claramente cuándo usarse.
- No recomendar instalación ciega basada solo en nombre o coincidencia superficial.

## Flujo recomendado

1. Identificar dominio, tarea y alcance.
2. Revisar índice y skills locales del workspace.
3. Si falta cobertura, inspeccionar skill externa o buscar en `skills.sh`.
4. Comparar valor real aportado:
   - conocimiento nuevo,
   - workflow reusable,
   - estructura o discovery mejores,
   - scripts o referencias aprovechables.
5. Decidir una de estas salidas:
   - reutilizar skill local existente,
   - mejorar skill local con buenas prácticas externas,
   - crear skill nueva local,
   - recomendar instalación externa.
6. Si se crea o mejora skill local, regenerar el catálogo web (`Update-SkillMaestraWebIndex.ps1`) y, cuando aplique, actualizar `README.md`.

## Comandos útiles del ecosistema abierto

```bash
npx skills find <query>
npx skills add <owner/repo>
npx skills add <owner/repo> --skill <nombre>
npx skills add <owner/repo> --list
npx skills init <nombre>
```

## Ejemplos reales de búsqueda

- Buscar skill para revisar PRs: `npx skills find pr review`
- Buscar skill para React o Next.js: `npx skills find react nextjs`
- Buscar skill para Azure o despliegues: `npx skills find azure deployment`
- Buscar skill para Power Platform o Dataverse: `npx skills find power platform dataverse`
- Buscar skill para documentación o changelogs: `npx skills find changelog docs`

## Ejemplos de decisión en este workspace

- Si el usuario pide una capacidad que ya cubre una skill local del repositorio, reutilizarla antes de buscar fuera.
- Si pide una capacidad genérica nueva, como descubrir skills del ecosistema, evaluar primero skills abiertas y luego decidir si conviene una skill local.
- Si una skill externa solo aporta comandos genéricos y no workflow reusable, no incorporarla como dependencia local.

## Reglas de incorporacion a Skill Maestra

- Si una skill externa aporta una capacidad nueva y reusable, crear carpeta local en kebab-case.
- Si solo aporta una buena práctica, incorporarla a la skill existente afectada y documentarla en memoria repo.
- Mantener la documentación en español y ajustada al flujo operativo real del workspace.

## Resultado esperado
- Decisión clara entre reutilizar, adaptar, instalar o crear.
- Skill local creada o mejorada si aporta valor persistente.
- Índice del repositorio actualizado.
- Justificación breve de qué se aprovechó y qué no.