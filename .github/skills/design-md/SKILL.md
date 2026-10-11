---
name: design-md
description: "Define y valida un archivo DESIGN.md para guiar a agentes de IA en la generacion de interfaces coherentes con tu sistema visual: colores, tipografia, spacing, componentes, reglas visuales y estilo UI. Usar cuando pidas crear, revisar, mejorar o lintar un DESIGN.md para UI."
argument-hint: "Indica producto o marca, estilo visual, plataforma objetivo, y si quieres crear, revisar, lintar, comparar o exportar un DESIGN.md"
---

# Design.md

## Cuando usar esta skill
- Cuando quieras describir un sistema visual para que una IA genere interfaces con un estilo consistente.
- Cuando necesites crear un archivo DESIGN.md desde cero para una marca, producto o pantalla.
- Cuando quieras revisar, corregir o endurecer un DESIGN.md existente antes de usarlo con agentes.
- Cuando necesites convertir el sistema visual a tokens reutilizables o comparar versiones.

## Cuando no usar esta skill
- Cuando solo necesites una maqueta puntual sin necesidad de reglas visuales persistentes.
- Cuando el objetivo sea documentar logica de negocio o flujos no visuales.
- Cuando no haya una identidad visual minima que capturar en tokens y reglas.

## Resultado esperado
- Archivo DESIGN.md con frontmatter YAML y secciones Markdown alineadas con la especificacion publica de Google.
- Tokens reutilizables para colores, tipografias, espaciado, redondeos y componentes.
- Reglas visuales claras para que otro agente o herramienta mantenga el mismo estilo.
- Validacion basica con CLI para detectar referencias rotas, contraste deficiente o problemas de estructura.

## Politica de Autonomia y Ejecucion

- No pedir informacion que ya exista en archivos del workspace.
- Ejecutar de forma autonoma todo lo posible: crear, revisar, lintar y comparar.
- Preguntar solo cuando falte una decision funcional (marca, plataforma objetivo o alcance).
- Mantener cambios centrados en el sistema visual; no tocar logica de negocio.

## Pregunta Inicial Obligatoria

Antes de crear o modificar DESIGN.md, preguntar:

1. Quieres crear desde cero, revisar, comparar o lintar un DESIGN.md existente?
2. Cual es la referencia visual principal (marca/producto/sistema actual)?
3. La salida final debe priorizar web, mobile o ambos?

## Opciones Soportadas (1-5)

1. Crear DESIGN.md nuevo desde briefing.
2. Revisar y mejorar DESIGN.md existente.
3. Lint y correccion estructural.
4. Comparar dos versiones y detectar regresiones visuales.
5. Exportar tokens a formatos reutilizables (Tailwind/DTCG).

## Flujo Recomendado

1. Confirmar opcion de trabajo y plataforma objetivo.
2. Capturar identidad visual y restricciones.
3. Traducir a tokens y reglas en frontmatter.
4. Completar secciones Markdown en orden recomendado.
5. Validar con lint y corregir findings relevantes.
6. Entregar cambios con resumen de decisiones visuales.

## Procedimiento
1. Identificar la identidad visual que se quiere capturar: tono, referencias, restricciones, producto y plataforma.
2. Traducir esa identidad a tokens concretos en el frontmatter: `colors`, `typography`, `rounded`, `spacing`, `components`.
3. Redactar el cuerpo del DESIGN.md con secciones `##` en el orden recomendado por la especificacion.
4. Validar el archivo con `npx @google/design.md lint DESIGN.md` y corregir findings relevantes.
5. Si hay una version previa, comparar con `diff` para detectar regresiones visuales o de tokens.
6. Si hace falta interoperabilidad, exportar a Tailwind o DTCG para reutilizar el sistema en otras herramientas.

## Reglas practicas
- El frontmatter es la fuente normativa de tokens; la prosa explica como aplicarlos.
- Usa nombres de tokens semanticos y estables, no nombres ligados a una sola pantalla.
- Define al menos un color `primary` si trabajas la paleta.
- Usa referencias entre tokens cuando la relacion sea estable, por ejemplo `{colors.primary}`.
- Modela variantes de componentes como claves separadas: `button-primary`, `button-primary-hover`, `button-primary-active`.
- Si faltan secciones opcionales, la skill debe decirlo, no inventar complejidad innecesaria.

## Instalacion
- Ruta de la skill en este workspace: `design-md/`
- Instalacion en workspace de VS Code: copiar la carpeta `design-md` dentro de `%APPDATA%/Code/User/prompts/` o dentro del repositorio compartido de skills que use el equipo.
- Limitacion: VS Code no instala skills de forma global como extensiones; hay que copiarlas al directorio de prompts/skills que use el usuario o el workspace.
- Verificacion: reiniciar VS Code, abrir Copilot Chat y comprobar que `/design-md` aparece entre las skills disponibles.

## Recursos
- [Workflow operativo](./references/workflow.md)
- [Plantilla base DESIGN.md](./assets/DESIGN.template.md)
- [Script helper para lint/diff/export](./scripts/design-md-tools.ps1)
