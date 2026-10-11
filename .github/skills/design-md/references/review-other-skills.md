# Revision de otras skills con criterios DESIGN.md

## Objetivo
Usar DESIGN.md como contrato visual para revisar skills que crean, modifican o condicionan interfaces, HTML, pantallas, dashboards o cualquier salida UI.

## Cuando aplicar esta revision
- La skill genera frontend, mockups, HTML, pantallas Power Apps, dashboards o componentes visuales.
- La skill puede producir una UI generica si no recibe una referencia visual explicita.
- El usuario quiere endurecer la coherencia visual del repositorio de skills.

## Cuando no aplicar esta revision
- La skill solo trata backend, autenticacion, despliegue, datos o procesos no visuales.
- La salida final no incluye decisiones de interfaz.

## Criterios de revision

### 1. Discovery visual minimo
La skill debe capturar o inferir:
- marca, producto o referencia visual principal;
- plataforma objetivo: web, mobile, dashboard, intranet, canvas app;
- restricciones: accesibilidad, paleta cerrada, tema claro/oscuro, design system existente.

### 2. Fuente de verdad visual
La skill debe:
- reutilizar un DESIGN.md existente cuando exista;
- o declarar explicitamente que falta y proponer uno minimo;
- o justificar por que el resultado no necesita contrato visual.

### 3. Tokens y reglas
Para skills visuales, revisar si el prompt o workflow obliga a aterrizar al menos:
- colores;
- tipografia;
- spacing/layout;
- componentes clave;
- anti-patrones visuales o limites de estilo.

### 4. Componentes y superficies
La skill debe concretar que componentes o zonas visuales gobierna:
- hero, cards, formularios, tablas, modales, navegacion, KPIs, layouts, pantallas.

### 5. Antidoto contra UI generica
Marcar como finding si la skill:
- deja la UI sin direccion visual;
- cae en plantillas intercambiables;
- no diferencia entre desktop y mobile cuando importa;
- no obliga a respetar patrones visuales existentes.

### 6. Validacion de salida
La skill debe incluir al menos una comprobacion de coherencia visual:
- revision contra DESIGN.md;
- checklist de componentes/tokens;
- preview, diff o validacion del artefacto generado.

## Formato de hallazgos recomendado
- Estado: OK, Atencion o Falta.
- Evidencia: archivo o seccion donde se observa.
- Impacto: riesgo de incoherencia visual o salida generica.
- Ajuste propuesto: cambio minimo en discovery, workflow o instrucciones.

## Checklist rapido
- La skill identifica la referencia visual?
- La skill cita o busca DESIGN.md?
- La skill fuerza tokens o reglas visuales?
- La skill define componentes o superficies?
- La skill evita UI generica?
- La skill valida el resultado visual?

## Cierre esperado
Una auditoria completa de otra skill debe terminar con:
- hallazgos priorizados;
- cambios propuestos o aplicados;
- nota explicita de si la skill queda alineada, parcialmente alineada o no alineada con DESIGN.md.