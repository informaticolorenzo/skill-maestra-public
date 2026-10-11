# PRD - code-app

Fecha: 2026-06-22
Version: 1.0
Estado: Vigente

## 1. Objetivo
Definir como crear, ampliar y desplegar Power Apps Code Apps con flujo connector-first y calidad de entrega.

## 2. Problema
Las code apps se degradan cuando se improvisa arquitectura, se omite plan o se despliega sin validacion.

## 3. Alcance
- Scaffold, configuracion y build.
- Integracion de datasources y conectores.
- Despliegue controlado con CLI oficial.

## 4. Requisitos funcionales
- RF1: Clasificar escenario (crear, actualizar, desplegar).
- RF2: Exigir plan para cambios grandes.
- RF3: Priorizar conectores sobre llamadas ad-hoc.
- RF4: Ejecutar build antes de push.
- RF5: Registrar decisiones de arquitectura.

## 5. Requisitos no funcionales
- RNF1: Mantenibilidad del codigo.
- RNF2: Coherencia visual con DESIGN.md si aplica.
- RNF3: Trazabilidad de despliegues.

## 6. KPI
- Exito de build en primera pasada.
- Tiempo medio de entrega por feature.
- Incidencias post-despliegue.

## 7. Criterio de aceptacion
Se acepta cuando la app compila, despliega y cumple el alcance funcional acordado.
