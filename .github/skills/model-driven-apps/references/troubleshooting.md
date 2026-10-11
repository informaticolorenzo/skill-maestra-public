# Troubleshooting - Model Driven Apps

## E1: PAC CLI no disponible o desactualizado
**Sintoma**: `pac help` falla o no soporta comandos `model genpage`.
**Solucion**:
1. Instalar o actualizar PAC CLI.
2. Verificar version >= 2.3.1.

---

## E2: Fallo de autenticacion PAC
**Sintoma**: comandos `pac model` no listan apps o entornos.
**Solucion**:
1. Reautenticar con PAC CLI.
2. Confirmar entorno activo antes de desplegar.

---

## E3: Error al generar schema/tipos
**Sintoma**: fallos en `generate-types` o columnas no reconocidas.
**Solucion**:
1. Verificar nombres logicos de entidades/campos.
2. Regenerar tipos y volver a compilar el codigo.

---

## E4: Upload de pagina falla
**Sintoma**: `pac model genpage upload` devuelve error de argumentos o app.
**Solucion**:
1. Confirmar `app-id` correcto con el usuario.
2. Revisar flags requeridos (`--app-id`, `--code-file`, `--prompt`, `--agent-message`).
3. Reintentar subida.

---

## E5: Verificacion browser inestable
**Sintoma**: referencias expiradas o pagina cerrada durante pruebas.
**Solucion**:
1. Refrescar snapshot antes de cada accion.
2. Reabrir navegador de verificacion si se cierra.
3. Evitar tests destructivos sobre datos reales.
