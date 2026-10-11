# PRD - model-driven-apps

Fecha: 2026-06-22
Version: 1.0
Estado: Vigente

## 1. Objetivo
Guiar la creacion y despliegue de paginas generativas para model-driven apps con estandar tecnico consistente.

## 2. Problema
Sin flujo estandar, las paginas genpage presentan deuda tecnica, errores de despliegue o UX inconsistente.

## 3. Alcance
- Generacion de pagina .tsx en archivo unico.
- Integracion con schema Dataverse cuando aplica.
- Despliegue y verificacion con PAC CLI.

## 4. Requisitos funcionales
- RF1: Verificar prerequisitos y entorno PAC.
- RF2: Capturar requisitos funcionales y visuales.
- RF3: Generar codigo compatible con stack definido.
- RF4: Subir pagina con comando oficial.
- RF5: Validar resultado funcional y de UI.

## 5. Requisitos no funcionales
- RNF1: Coherencia visual con DESIGN.md.
- RNF2: Mantenibilidad del codigo generado.
- RNF3: Trazabilidad de despliegue.

## 6. KPI
- Exito de despliegue en primer intento.
- Tiempo medio de generacion a publicacion.
- Defectos funcionales post-subida.

## 7. Criterio de aceptacion
La skill se acepta cuando la pagina queda desplegada y usable en la app model-driven objetivo.
