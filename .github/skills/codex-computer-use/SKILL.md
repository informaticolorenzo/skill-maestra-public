---
name: codex-computer-use
description: "Diagnostica, configura y usa Codex Computer Use / Uso del ordenador en Windows o macOS. Usar cuando el usuario quiera manejar aplicaciones de escritorio desde Codex, abrir apps con @Computer, permitir apps, revisar permisos, comprobar computer-use/config.toml o explicar limites de seguridad."
argument-hint: "Indica app objetivo, sistema operativo, si quieres solo diagnostico o uso real, y si hay permisos ya concedidos"
---

# Codex Computer Use

## Cuando usar esta skill
- Cuando el usuario quiera que Codex maneje el ordenador o aplicaciones de escritorio.
- Cuando pida activar, instalar, diagnosticar o configurar Computer Use / Uso del ordenador.
- Cuando mencione `@Computer`, `@Chrome`, navegador externo, app de Windows, app de macOS, permisos de apps o `computer-use`.
- Cuando una tarea dependa de una interfaz grafica que no se puede resolver bien con shell, archivos, MCP, conectores o navegador integrado.

## Cuando no usarla
- Para automatizar terminales o el propio Codex.
- Para tareas que se resuelven mejor con CLI, API, MCP, conectores o archivos locales.
- Para abrir una web local de desarrollo si el navegador integrado de Codex basta.
- Para introducir secretos, pagos, credenciales o ajustes sensibles sin presencia y aprobacion del usuario.

## Resultado esperado
- Decidir si Computer Use es la herramienta correcta.
- Guiar al usuario para instalar o habilitar el complemento si no esta disponible.
- Revisar de forma no destructiva la configuracion local de Computer Use.
- Pedir una autorizacion de app concreta cuando toque usar una aplicacion visual.
- Mantener el alcance estrecho: una app o flujo objetivo por vez.

## Procedimiento

1. Identificar la superficie adecuada:
   - Usar navegador integrado para webs locales o testing web dentro de Codex.
   - Usar Chrome extension o browser dedicado cuando el flujo sea web con sesion del usuario.
   - Usar Computer Use solo si hace falta ver, hacer clic o escribir en una app de escritorio.
2. Si la pregunta es de producto o disponibilidad actual, verificar documentacion oficial de OpenAI antes de afirmar limites, precios, permisos o plataformas.
3. En Windows:
   - Recordar que Computer Use actua en el escritorio activo y en primer plano.
   - Pedir que la app objetivo este visible y que el equipo permanezca desbloqueado.
   - Explicar que Codex puede mover puntero, escribir y cambiar ventanas mientras trabaja.
4. En macOS:
   - Confirmar permisos de Grabacion de pantalla y Accesibilidad para Codex.
   - Para uso bloqueado, seguir solo el flujo oficial documentado por OpenAI.
5. Diagnosticar configuracion local:
   - Ejecutar `./scripts/check-computer-use.ps1` desde esta skill cuando se necesite inspeccion no destructiva.
   - Revisar si existe `$CODEX_HOME/computer-use/config.toml`.
   - Si solo existe `config.json`, tratarlo como indicador de instalacion parcial, anterior o de UI; no editarlo salvo peticion explicita.
6. Para usar una app:
   - Pedir una accion concreta, por ejemplo: `@Computer abre Chrome y verifica el login`.
   - No ejecutar flujos destructivos ni acciones sensibles sin aprobacion paso a paso.
   - Si existe una integracion estructurada para la app, preferirla antes que Computer Use.
7. Cerrar con el estado:
   - Disponible y listo para usar.
   - Instalado pero falta autorizar app.
   - No instalado/no expuesto en esta sesion.
   - Bloqueado por politica, permisos o app no visible.

## Validaciones minimas

1. Confirmar sistema operativo y superficie de Codex actual.
2. Confirmar si las herramientas de Computer Use estan disponibles en la sesion.
3. Confirmar que la app objetivo no es terminal ni Codex.
4. Confirmar que el usuario entiende que en Windows se usa el primer plano.
5. Si se modifica una allowlist/denylist local, mostrar antes y despues.

## Recursos
- [Workflow operativo](./references/workflow.md)
- [Diagnostico local](./scripts/check-computer-use.ps1)
