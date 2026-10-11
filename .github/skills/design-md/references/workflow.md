# Workflow de la Skill design-md

## Objetivo
Usar la especificacion abierta DESIGN.md de Google para describir un sistema visual que otro agente pueda seguir de forma consistente al generar UI.

## Flujo recomendado
1. Recoger contexto visual minimo.
2. Elegir nombre y alcance del sistema.
3. Definir tokens base.
4. Redactar secciones narrativas.
5. Validar con lint.
6. Comparar o exportar si hace falta.

## 1. Discovery minimo
Antes de escribir el archivo, identificar:
- Marca o producto.
- Tono visual: sobrio, editorial, corporativo, ludico, premium, tecnico.
- Plataforma: web, app movil, dashboard, landing, panel interno.
- Componentes clave: botones, cards, tablas, formularios, modales, navegacion.
- Restricciones: accesibilidad, tema claro/oscuro, paleta cerrada, tipografias obligatorias.

## 2. Frontmatter YAML
La skill debe priorizar el frontmatter porque es la parte que mejor consumen los agentes.

Campos mas utiles:
- `version`
- `name`
- `description`
- `colors`
- `typography`
- `rounded`
- `spacing`
- `components`

## 3. Cuerpo Markdown
Las secciones presentes deben ir en el orden canonico:
1. `## Overview`
2. `## Colors`
3. `## Typography`
4. `## Layout`
5. `## Elevation & Depth`
6. `## Shapes`
7. `## Components`
8. `## Do's and Don'ts`

Tambien son validos algunos alias documentados por la especificacion, como `Brand & Style` para overview o `Layout & Spacing` para layout.

## 4. Validacion recomendada
### Lint
```powershell
npx @google/design.md lint DESIGN.md
```

### Diff entre versiones
```powershell
npx @google/design.md diff DESIGN.md DESIGN-v2.md
```

### Export a Tailwind
```powershell
npx @google/design.md export --format tailwind DESIGN.md > tailwind.theme.json
```

### Export a DTCG
```powershell
npx @google/design.md export --format dtcg DESIGN.md > tokens.json
```

### Ver especificacion desde CLI
```powershell
npx @google/design.md spec
```

## 5. Findings habituales
- `broken-ref`: una referencia como `{colors.primary}` no existe.
- `missing-primary`: hay colores pero no existe `primary`.
- `contrast-ratio`: contraste insuficiente entre `backgroundColor` y `textColor`.
- `missing-typography`: hay paleta definida pero no tokens tipograficos.
- `section-order`: las secciones estan fuera del orden recomendado.

## 6. Criterio practico para esta skill
- Si el usuario no tiene un sistema visual, empezar por una version minima y coherente, no por un documento enorme.
- Si el usuario ya tiene identidad visual, reflejarla y no reinventarla.
- Si hay HTML/CSS existente, usar DESIGN.md como contrato visual, no como sustituto del codigo.
- Si el objetivo es que otra IA disene una UI, dejar claros los no negociables: colores, tipografias, espaciado, radios y componentes principales.

## 7. Verificacion de instalacion
1. Copiar `design-md/` al directorio de prompts/skills del usuario o del workspace.
2. Reiniciar VS Code.
3. Abrir Copilot Chat.
4. Confirmar que `/design-md` aparece y que responde a peticiones como:
   - `crea un DESIGN.md para una intranet corporativa`
   - `revisa este DESIGN.md y corrige referencias rotas`
   - `exporta estos tokens a tailwind`
