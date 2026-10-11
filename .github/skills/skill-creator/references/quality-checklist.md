# Checklist de Calidad de Skill

## Frontmatter
- `name` en kebab-case y coincide con carpeta.
- `description` especifica claramente cuando usar la skill.
- `description` incluye keywords reales de activacion.
- `argument-hint` presente cuando aporta contexto util.

## Contenido
- Explica cuando usar y cuando no usar.
- Define procedimiento por pasos.
- Incluye recursos enlazados con rutas relativas.
- Evita instrucciones ambiguas o contradictorias.

## Estructura
- Existe `SKILL.md`.
- Existen carpetas `references`, `assets`, `scripts` si aplican.
- No hay rutas absolutas incrustadas dentro de la skill.

## Discovery
- Hay terminos de negocio y terminos tecnicos en la descripcion.
- La skill puede invocarse por slash con nombre claro.
- El caso de uso principal aparece en primeras lineas.

## Cierre
- Se valida con un ejemplo real de solicitud.
- Se documentan limites y supuestos.
