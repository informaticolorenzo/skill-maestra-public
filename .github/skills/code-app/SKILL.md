---
name: code-app
description: "Crea, extiende y despliega Power Apps Code Apps siguiendo el estandar del plugin oficial code-apps: connector-first, planning policy, memory-bank y build/deploy con npx power-apps. WHEN: Code App, Code Apps, code app, create-code-app, add datasource, add connector, dataverse code app, deploy code app, power-apps push."
argument-hint: "Objetivo (crear/actualizar/desplegar), entorno, fuentes de datos necesarias, alcance funcional"
---

# Code App

## Triggers, Keywords y Alias
- Trigger exacto principal: Code App.
- Trigger alternativo: Code Apps.
- Keywords de discovery: create-code-app, add-datasource, add-connector, deploy code app, power-apps push.
- Alias conversacionales: crear Code App, actualizar Code App, desplegar Code App, plugin code-apps.

## Cuando usar esta skill
- Cuando el usuario quiere crear una Power Apps Code App nueva.
- Cuando el usuario quiere ampliar una Code App existente con nuevas capacidades.
- Cuando hay que conectar datos (Dataverse, SharePoint, Teams, Excel, OneDrive, Office 365, Azure DevOps).
- Cuando hay que compilar y desplegar cambios de forma controlada.

## Plugin oficial de referencia
- Plugin: `code-apps` del repositorio `microsoft/power-platform-skills`.
- Principios obligatorios heredados:
  - `connector-first`: no usar `fetch/axios` si existe conector.
  - usar `npx power-apps` como CLI principal.
  - validar build antes de desplegar.
  - plan previo para cambios grandes o multifichero.
  - revisar/actualizar `memory-bank.md` en el proyecto.

---

## Resultado esperado
- Proyecto scaffolded o actualizado sin deuda tecnica evitable.
- Fuentes de datos agregadas via skills/flujo especializado.
- Build en verde (`npm run build`) antes de despliegue.
- Despliegue ejecutado con trazabilidad (`npx power-apps push`).
- Resumen final con estado, riesgos y proximos pasos.

## Gate visual DESIGN.md (obligatorio cuando hay UI nueva o revisada)
Antes de tocar componentes, layouts o estilos, esta skill debe:
- buscar un `DESIGN.md` existente en el proyecto;
- usarlo como contrato visual si existe;
- si no existe, capturar discovery visual minimo antes de generar interfaz;
- recomendar la skill `design-md` cuando el cambio visual sea amplio o fundacional.

No cerrar cambios de UI con una solucion visual generica si la app ya tiene marca, patrones o sistema de componentes.

## Gate de arquitectura y escalado
Antes de implementar, revisar:
- `../shared/references/decision-matrix-modern-apps.md`
- `../shared/references/json-contract-standard.md`

Reglas obligatorias:
- Si el requisito puede resolverse con logica ligera y delegable, evitar sobre-ingenieria.
- Si existe procesamiento pesado, volumen alto o reglas sensibles, desacoplar en backend.
- Si se integra con APIs o skills, usar contrato JSON estandar con requestId y errores estructurados.
- Documentar decision tecnica y alternativa de escalado en el cierre.

---

## Flujo estandar (por fases)

### Fase 0 - Clasificar el escenario
Determinar si la peticion es:
1. **Crear app nueva**.
2. **Actualizar app existente**.
3. **Solo desplegar**.

Aplicar el camino minimo necesario segun el escenario.

### Fase 1 - Verificar prerequisitos
Ejecutar al inicio:
```bash
node --version
npm --version
git --version
```
Reglas:
- Node.js recomendado: `v22+`.
- Si Node no cumple, detener y pedir actualizacion.
- Git opcional pero recomendado.

### Fase 2 - Discovery y memoria
1. Localizar raiz del proyecto.
2. Revisar si existe `memory-bank.md`.
3. Si existe, leer progreso, decisiones y recursos ya creados.
4. Si no existe y se va a trabajar en serio, crearlo tras la primera fase mayor.

### Fase 3 - Plan (obligatorio en cambios grandes)
Plan obligatorio cuando:
- hay cambios en multiples archivos,
- se agregan nuevas features/componentes,
- se agregan/alteran datasources/connectores,
- hay reestructuracion UI/estado.

Plan minimo:
- alcance funcional,
- skills a invocar,
- archivos principales impactados,
- contrato visual aplicable (`DESIGN.md` o discovery minimo),
- orden de implementacion,
- validaciones y criterio de salida.

Esperar aprobacion explicita del usuario antes de ejecutar cambios grandes.

### Fase 4 - Scaffold e inicializacion (si es app nueva)
Usar el patron oficial:
```bash
npx degit microsoft/PowerAppsCodeApps/templates/vite <carpeta> --force
cd <carpeta>
npm install
npx power-apps init -n "<app-name>" -e <environment-id>
```

### Fase 5 - Estrategia de datos (plugin-aware)
- Si el usuario no sabe que conector necesita, enrutar por objetivo de negocio.
- Priorizar skills especializadas de adicion de datos.

Mapa recomendado:
- Dataverse -> `/add-dataverse`
- SharePoint -> `/add-sharepoint`
- Excel -> `/add-excel`
- OneDrive -> `/add-onedrive`
- Teams -> `/add-teams`
- Office 365 -> `/add-office365`
- Azure DevOps -> `/add-azuredevops`
- Otro conector -> `/add-connector`
- Sin claridad inicial -> `/add-datasource` (router)

Reglas:
- usar servicios generados en `src/generated/` para acceso a datos,
- no mezclar servicios generados con accesos directos no soportados.

### Fase 6 - Implementacion
1. Aplicar cambios funcionales/visuales.
2. Mantener consistencia con arquitectura existente.
3. Evitar editar `src/generated/` salvo correccion justificada y controlada.
4. Si hay UI, respetar `DESIGN.md` o documentar explicitamente la ausencia de contrato visual.

### Fase 7 - Validacion tecnica obligatoria
Ejecutar:
```bash
npm run build
```
Corregir errores TypeScript antes de seguir.

### Fase 8 - Despliegue controlado
Solo con build en verde:
```bash
npx power-apps push
```
Registrar resultado y contexto del despliegue.

### Fase 9 - Cierre
Entregar resumen estructurado:
- escenario ejecutado,
- cambios realizados,
- conectores/datasources agregados,
- estado de build/despliegue,
- riesgos pendientes,
- siguiente accion recomendada.

---

## Guardrails especificos del plugin
- No proponer acceso HTTP directo para servicios con conector disponible.
- No saltarse `npm run build` antes de `push`.
- No desplegar automaticamente si el usuario pidio solo implementacion local.
- En cambios de arquitectura, aplicar fase de plan + aprobacion.
- En cambios visuales significativos, no avanzar sin discovery visual minimo o `DESIGN.md`.

---

## Progress Tracking

| Fase | activeForm | Descripcion |
|---|---|---|
| Clasificar escenario | Clasificando escenario | Definir si es crear, actualizar o solo desplegar |
| Verificar prerequisitos | Verificando prerequisitos | Validar Node/NPM/Git y viabilidad tecnica |
| Discovery y memoria | Relevando contexto | Leer proyecto y memory-bank para retomar sin duplicar |
| Planificar cambios | Planificando implementacion | Definir alcance y esperar aprobacion en cambios grandes |
| Scaffold/inicializar | Inicializando app | Crear app base e inicializar CLI (si aplica) |
| Integrar datos | Integrando fuentes de datos | Agregar datasource/conector con flujo oficial |
| Implementar | Implementando cambios | Aplicar cambios funcionales y de UI |
| Validar build | Validando build | Ejecutar build y corregir errores |
| Desplegar | Desplegando app | Ejecutar push con build limpio |
| Cerrar | Cerrando ejecucion | Reportar resultados, riesgos y proximos pasos |

---

## Checklist de cierre
- [ ] Escenario correctamente clasificado (crear/actualizar/desplegar)
- [ ] Prerequisitos validados
- [ ] Plan aprobado cuando el cambio lo requiere
- [ ] Datasources agregados con enfoque connector-first
- [ ] Build en verde (`npm run build`)
- [ ] Push ejecutado solo cuando procede
- [ ] Memory-bank actualizado con estado final
- [ ] Resumen final entregado al usuario

---

## Recursos recomendados
- Repositorio oficial: https://github.com/microsoft/power-platform-skills
- Plugin code-apps (arquitectura y skills): `plugins/code-apps/`
- Comando base de despliegue: `npx power-apps push`
- Troubleshooting local: [./references/troubleshooting.md](./references/troubleshooting.md)
