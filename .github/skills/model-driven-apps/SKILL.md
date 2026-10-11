---
name: model-driven-apps
description: "Crea, actualiza y despliega paginas generativas (genpage/genux) para aplicaciones model-driven siguiendo el estandar del plugin oficial model-apps: prerequisitos PAC CLI, plan confirmado, generacion de schema, codigo React 17 + TypeScript + Fluent UI V9, despliegue y verificacion. WHEN: Model Driven Apps, Model-Driven Apps, model driven app, genpage, generative page, genux, pac model genpage upload."
argument-hint: "Tipo de pagina, app objetivo, entidades Dataverse o mock data, requisitos funcionales"
---

# Model Driven Apps

## Triggers, Keywords y Alias
- Trigger exacto principal: Model Driven Apps.
- Trigger alternativo: Model-Driven Apps.
- Keywords de discovery: genpage, genux, model driven app, pac model genpage upload.
- Alias conversacionales: crear Model Driven Apps, actualizar Model Driven Apps, desplegar Model Driven Apps, plugin model-apps.

## Cuando usar esta skill
- Cuando el usuario quiere crear una pagina generativa nueva en una app model-driven.
- Cuando el usuario quiere editar una pagina generativa existente.
- Cuando hay que desplegar una pagina `.tsx` via PAC CLI.

## Plugin oficial de referencia
- Plugin: `model-apps` del repositorio `microsoft/power-platform-skills`.
- Skill base oficial: `/genpage`.
- Enfoque oficial: ciclo completo en una sesion (requisitos -> codigo -> despliegue -> verificacion).

---

## Resultado esperado
- Pagina generativa en formato single-file `.tsx`.
- Codigo consistente con React 17 + TypeScript + Fluent UI V9.
- Despliegue completado con `pac model genpage upload`.
- Verificacion estructural/visual realizada (si aplica Playwright).
- Resumen final con evidencias y siguientes iteraciones.

## Gate visual DESIGN.md (obligatorio)
Esta skill genera paginas visuales. Antes de construir o rehacer una pagina debe:
- buscar un `DESIGN.md` existente;
- usarlo como contrato visual para layout, color, tipografia, spacing y componentes;
- si no existe, capturar discovery visual minimo antes de codificar;
- recomendar la skill `design-md` si el sistema visual aun no esta definido.

No generar una pagina Fluent UI correcta en lo tecnico pero visualmente generica si la app tiene identidad o patrones previos.

## Gate de arquitectura y limites
Antes de codificar, revisar:
- `../shared/references/decision-matrix-modern-apps.md`
- `../shared/references/json-contract-standard.md`

Criterios de escalado:
- Si la pagina concentra logica pesada o no delegable, mover procesamiento a backend.
- Si hay integraciones criticas, aplicar contrato JSON estandar y trazabilidad minima.
- Si la experiencia requerida excede controles nativos, evaluar PCF o capa complementaria.

---

## Estándar técnico obligatorio
- React 17 + TypeScript.
- Fluent UI V9 como libreria de componentes principal.
- Arquitectura de archivo unico para la pagina (`export default GeneratedComponent`).
- Si hay Dataverse: usar `RuntimeTypes` y `props.dataApi` (sin adivinar columnas).
- No introducir librerias externas innecesarias.
- No omitir accesibilidad basica (labels, jerarquia semantica, teclado).

---

## Flujo estandar (por fases)

### Fase 1 - Validar prerequisitos
Ejecutar:
```powershell
node --version
pac help
```
Reglas:
- `pac` debe estar disponible.
- Version recomendada de PAC CLI: `>= 2.3.1`.
- Si falla, detener y corregir entorno antes de continuar.

### Fase 2 - Autenticacion y entorno
1. Confirmar sesion activa de PAC.
2. Confirmar entorno objetivo.
3. Confirmar app model-driven objetivo (app-id o nombre).

### Fase 3 - Requisitos interactivos
Capturar:
- crear pagina nueva o editar existente,
- descripcion funcional de la pagina,
- origen de datos (Dataverse o mock data),
- requisitos de UX (filtros, ordenacion, formularios, dashboard, etc.).
- `DESIGN.md` o referencia visual aplicable.

### Fase 4 - Plan y confirmacion
Presentar un plan claro antes de codificar:
- tipo de pagina,
- datos a usar,
- componentes Fluent principales,
- estrategia de layout responsivo,
- contrato visual aplicable,
- alcance de despliegue.

Esperar aprobacion explicita del usuario.

### Fase 5 - Generar schema (solo Dataverse)
Si la pagina usa Dataverse:
1. generar tipos/esquema con PAC,
2. validar columnas reales contra metadata,
3. usar esos tipos en el codigo final.

Si es mock data, esta fase se marca N/A.

### Fase 6 - Generar codigo
Construir `.tsx` completo con:
- imports correctos,
- componente principal exportado por defecto,
- logica y estado tipados,
- UI Fluent coherente,
- UI alineada con `DESIGN.md` o discovery visual minimo,
- sin placeholders vacios.

### Fase 7 - Despliegue
Antes de subir:
- pedir confirmacion de publicacion.

Subir con PAC usando flags requeridos por el flujo oficial (`--app-id`, `--code-file`, `--prompt`, `--agent-message`, y los adicionales que correspondan al escenario).

### Fase 8 - Verificacion en navegador
Si hay verificacion browser disponible:
1. abrir pagina desplegada,
2. validar estructura esperada (grid/form/cards/wizard),
3. validar interacciones seguras (sin mutaciones destructivas de datos reales),
4. capturar screenshot final.

Si falla, corregir y repetir despliegue/verificacion.

### Fase 9 - Cierre
Entregar resumen con:
- app y pagina objetivo,
- tipo de datos usado,
- estado de despliegue,
- evidencia visual (si existe),
- limitaciones o pendientes,
- propuesta de siguiente iteracion.

---

## Guardrails especificos del plugin
- No asumir `app-id` por defecto: confirmar siempre con el usuario.
- No desplegar sin confirmacion explicita.
- No validar funcionalidades destructivas en navegador (create/update/delete sobre datos reales) salvo que el usuario lo pida de forma expresa y controlada.
- En modo edicion de pagina existente, descargar contexto primero antes de regenerar codigo.

---

## Progress Tracking

| Fase | activeForm | Descripcion |
|---|---|---|
| Validar prerequisitos | Verificando prerequisitos | Comprobar Node y PAC CLI |
| Confirmar entorno | Confirmando entorno | Asegurar autenticacion y app objetivo |
| Recoger requisitos | Relevando requisitos | Definir tipo de pagina, datos y UX |
| Planificar | Planificando pagina | Presentar plan y obtener aprobacion |
| Generar schema | Generando schema | Crear tipos Runtime para Dataverse (si aplica) |
| Generar codigo | Generando codigo | Construir `.tsx` completo y tipado |
| Desplegar | Desplegando pagina | Subir pagina con PAC CLI |
| Verificar | Verificando en navegador | Validar estructura, interaccion y captura final |
| Cerrar | Cerrando ejecucion | Resumir resultados y siguientes pasos |

---

## Checklist de cierre
- [ ] Prerequisitos tecnicos validados
- [ ] App objetivo confirmada explicitamente
- [ ] Plan aprobado por el usuario
- [ ] Tipos/schema generados cuando hay Dataverse
- [ ] Codigo `.tsx` completo y consistente con estandar
- [ ] Despliegue PAC ejecutado con confirmacion previa
- [ ] Verificacion browser realizada o justificada como N/A
- [ ] Resumen final entregado con riesgos y siguientes pasos

---

## Recursos recomendados
- Repositorio oficial: https://github.com/microsoft/power-platform-skills
- Plugin model-apps (AGENTS, README y skill `/genpage`): `plugins/model-apps/`
- PAC CLI model-driven docs: https://learn.microsoft.com/power-platform/developer/cli/reference/model
- Troubleshooting local: [./references/troubleshooting.md](./references/troubleshooting.md)
