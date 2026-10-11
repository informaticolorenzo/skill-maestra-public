# Troubleshooting - Code App

## E1: Node.js por debajo de v22
**Sintoma**: comandos `npx power-apps` fallan o se comportan de forma inestable.
**Solucion**:
1. Actualizar Node.js a v22+.
2. Reinstalar dependencias con `npm install`.

---

## E2: Build falla por imports no usados (TS6133)
**Sintoma**: `npm run build` marca errores por imports/variables no utilizados.
**Solucion**:
1. Eliminar imports no usados.
2. Repetir build hasta quedar en verde.

---

## E3: Se intenta usar fetch/axios con conector disponible
**Sintoma**: runtime inconsistente o incumplimiento del patron del plugin.
**Solucion**:
1. Aplicar regla connector-first.
2. Usar skills `/add-*` para generar servicios.
3. Consumir servicios de `src/generated/services`.

---

## E4: `npx power-apps push` falla por falta de build limpio
**Sintoma**: deploy rechazado o app rota tras despliegue.
**Solucion**:
1. Ejecutar `npm run build` antes de `push`.
2. Corregir errores TypeScript.
3. Reintentar despliegue.

---

## E5: Falta de contexto entre sesiones
**Sintoma**: se repiten pasos o se pierde estado de trabajo.
**Solucion**:
1. Revisar `memory-bank.md` al inicio.
2. Actualizarlo tras cada fase importante.
