# Workflow operativo de Computer Use

## Decision rapida

Usa Computer Use si la tarea necesita una interfaz visual de escritorio:

- Probar una app Windows/macOS.
- Reproducir un bug que solo aparece en UI.
- Cambiar ajustes navegando por menus.
- Usar una fuente de datos sin API, MCP, conector o CLI.
- Ejecutar un flujo entre varias aplicaciones.

No lo uses si hay una via estructurada:

- Shell o scripts locales.
- APIs oficiales.
- MCP o conectores.
- Browser integrado para web local.
- Chrome extension cuando el objetivo sea usar el perfil real de Chrome.

## Activacion en Codex

1. Abrir Configuracion de Codex.
2. Entrar en Uso del ordenador / Computer Use.
3. Instalar el complemento.
4. Iniciar una tarea mencionando `@Computer` o una app concreta como `@Chrome`.
5. Aprobar la app cuando Codex lo solicite.

## Windows

- Computer Use funciona en el escritorio activo.
- La app objetivo debe estar visible o accesible en la sesion desbloqueada.
- Codex puede mover el puntero, escribir y tomar el primer plano.
- Para tareas largas, mantener el equipo despierto y conectado.
- Si el usuario quiere seguir usando el equipo, recomendar otro navegador, otro dispositivo o una maquina virtual.

## macOS

- Requiere permisos de Grabacion de pantalla y Accesibilidad para Codex.
- El uso bloqueado es especifico de macOS y debe activarse desde configuracion.
- Si Codex no ve o no controla la app, revisar permisos del sistema.

## Configuracion local

La documentacion actual menciona:

```toml
[apps]
allowed = ["mspaint.exe"]
denied = ["calc.exe"]
```

Puntos importantes:

- Las apps denegadas tienen prioridad sobre las permitidas.
- El archivo vive bajo `$CODEX_HOME/computer-use/config.toml` cuando la version actual lo usa.
- Algunas instalaciones pueden tener otros archivos como `config.json`; no asumir que equivalen a la allowlist.
- No editar listas persistentes sin una peticion clara del usuario.

Estado inicial recomendado en este workspace:

```toml
[apps]
allowed = []
denied = []
```

Con listas vacias, Computer Use pedira permiso cuando necesite usar una app no registrada. Es mas seguro que permitir aplicaciones automaticamente antes de saber el flujo concreto.

## Seguridad

- Mantener cerradas apps con informacion sensible si no son necesarias.
- Evitar credenciales, pagos y ajustes de seguridad salvo presencia del usuario.
- Cancelar si Codex interactua con la ventana equivocada.
- Revisar permisos antes de elegir "Permitir siempre".
- No automatizar terminales ni Codex.

## Troubleshooting: no se pudo cargar el complemento

Sintoma:

- Al aceptar instalar `computer-use@openai-bundled`, Codex muestra un aviso como `No se pudo cargar este complemento en este momento`.
- `request_plugin_install` devuelve `completed: false` o `user_confirmed: false`.
- La cache local de plugins tiene `openai-bundled/browser` y `openai-bundled/chrome`, pero no `openai-bundled/computer-use`.

Comprobaciones:

1. Confirmar que existe `$CODEX_HOME/computer-use/config.toml`.
2. Revisar si `computer-use` aparece como herramienta disponible en la sesion actual.
3. Revisar si existe una carpeta local de plugin en `$CODEX_HOME/plugins/cache/openai-bundled/computer-use`.
4. Si no existe, el problema no es la allowlist local de apps: es carga/instalacion del complemento.

Acciones recomendadas:

1. Recargar la ventana de VS Code/Codex.
2. Actualizar la extension ChatGPT/Codex si hay update pendiente.
3. Volver a intentar instalar Computer Use sin marcar `No volver a mostrar`.
4. Si sigue fallando, cerrar y abrir una sesion/hilo nuevo de Codex.
5. Si aun falla, reportarlo como fallo de carga del plugin `computer-use@openai-bundled` e incluir que la cache local no contiene `openai-bundled/computer-use`.

## Prompts utiles

```text
@Computer abre Chrome y verifica que la pagina de checkout carga correctamente.
```

```text
Usa Computer Use para abrir la aplicacion, reproducir el bug de onboarding y dime que ves antes de tocar codigo.
```

```text
Abre @Chrome con Computer Use, entra en la web local y prueba el boton de guardar.
```
