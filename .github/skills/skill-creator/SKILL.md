---
name: skill-creator
description: "Crea nuevas skills reutilizables para VS Code/Copilot con SKILL.md valido, estructura estandar, checklist de discovery y scaffold de carpetas. Usar cuando pidas crear o mejorar una skill futura."
argument-hint: "Indica nombre de skill, objetivo, triggers y recursos requeridos"
---

# Skill Creator

## Cuando usar esta skill
- Cuando quieras crear una skill nueva desde cero.
- Cuando necesites corregir frontmatter o discovery de una skill existente.
- Cuando busques estandarizar assets, referencias y scripts.

## Resultado esperado
- Skill lista para uso con nombre valido y descripcion descubrible.
- Estructura de carpetas completa.
- Checklist de calidad superado antes de dar por cerrada la skill.

## Politica de Autonomia y Ejecucion

- No pedir datos ya disponibles en el workspace o en el indice de skills.
- Ejecutar la creacion/mejora completa de forma autonoma siempre que sea posible.
- Preguntar solo por decisiones de alcance (nueva vs mejora, proyecto vs global, versionado).
- Mantener compatibilidad con la estructura y convenciones existentes.

## Pregunta Inicial Obligatoria

Antes de crear o modificar una skill, preguntar:

1. La skill es nueva o es una mejora de una skill existente?
2. Se instalara solo en este proyecto, o tambien en repositorio global de skills?
3. Hay requisitos de versionado o compatibilidad con skills ya instaladas?

## Opciones Soportadas (1-5)

1. Crear skill nueva desde plantilla.
2. Mejorar skill existente (estructura, discovery y calidad).
3. Corregir frontmatter y metadatos de invocacion.
4. Crear scaffolding de assets/references/scripts.
5. Auditar y estandarizar varias skills del mismo workspace.

## Flujo Recomendado

1. Confirmar opcion y alcance (proyecto/global).
2. Verificar ruta raiz de skills y estructura minima.
3. Crear o actualizar `SKILL.md` con descripcion invocable.
4. Completar assets, referencias y scripts minimos.
5. Ejecutar checklist de calidad.
6. Actualizar indice/catalogo de skills del workspace.

## Procedimiento

### Paso 0 (obligatorio): Confirmar ruta local de skills
Antes de cualquier otra accion, preguntar al usuario donde quiere guardar las skills en local.
Usar la respuesta como `SKILLS_ROOT_PATH` para toda la sesion.
Si no indica una ruta distinta, proponer por defecto:
`{{SKILLS_ROOT_PATH}}` (raíz local donde están instaladas las skills)
Validar que la ruta existe y contiene `README.md` e `INDEX.md`.
No continuar si la validacion falla.

1. Definir objetivo y casos de uso de la nueva skill.
2. Elegir nombre en kebab-case y validar coincidencia carpeta/frontmatter.
3. Crear estructura base usando el script scaffold en `SKILLS_ROOT_PATH`.
4. Rellenar plantilla de `SKILL.md` con triggers concretos.
5. Crear referencias, assets y scripts minimos.
6. Ejecutar checklist de calidad.
7. Ajustar descripcion para mejorar discovery y regenerar el catálogo web con `Update-SkillMaestraWebIndex.ps1`.
8. Registrar lecciones operativas (anti-patrones + fix validado) en la skill afectada y en memoria repo para evitar reincidencia.

## Recursos
- [Checklist de calidad](./references/quality-checklist.md)
- [Plantilla base SKILL](./assets/SKILL.template.md)
- [Script scaffold](./scripts/new-skill-scaffold.ps1)
