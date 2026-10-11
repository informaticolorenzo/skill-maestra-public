# Instrucciones del proyecto Skill Maestra

Estas instrucciones las leen los agentes (Copilot, Claude, Codex) al trabajar en este repositorio. Sirven de ejemplo: adáptalas a tu equipo.

## Regla de arranque

- Antes de empezar una tarea, leer la skill del dominio en `.github/skills/<nombre>/SKILL.md` y seguirla.
- Si la tarea toca un dominio con skill disponible, cargarla antes de buscar, editar o ejecutar nada.

## Modo de trabajo

- Ejecutar de forma autónoma todo lo que se pueda y pedir datos solo cuando no haya forma de automatizarlo.
- Ante un cambio con riesgo (datos, configuración, despliegues), actuar de la forma más conservadora posible y preferir una prueba reversible antes del cambio definitivo.

## Verificación

- Tras cualquier cambio, comprobar el resultado real (archivo generado, página renderizada, salida del script) antes de darlo por terminado.
- Que un comando devuelva éxito no basta: verificar que el cambio está presente.

## Seguridad

- Nunca subir secretos ni configuración local (`.env`, `local.settings.json`, tokens).
- No desplegar ni publicar en producción sin confirmación explícita.

## Mejora continua de skills

- Cuando se descubra un error, una limitación o un camino más rápido, corregir el `SKILL.md` correspondiente en la misma intervención para que no se repita.
