---
name: power-bi-modeling-mcp-server
description: "Instala, configura y usa la extension oficial Power BI Modeling MCP Server de Microsoft para exponer capacidades de modelado semantico de Power BI a GitHub Copilot en VS Code. Usar cuando necesites conectarte a Power BI Desktop, Fabric o proyectos PBIP/TMDL, listar y modificar tablas, columnas, medidas, relaciones, particiones, roles o ejecutar consultas DAX mediante MCP. Cubre instalacion de la extension, verificacion del servidor, conexion al modelo, operaciones de modelado y trazas basicas."
argument-hint: "Indica: origen del modelo (Power BI Desktop, Fabric o carpeta PBIP/TMDL), accion deseada (conectar, listar, crear medida, editar tabla, revisar relaciones, ejecutar DAX) y, si aplica, nombre de la conexion o del modelo"
---

# Power BI Modeling MCP Server

## Objetivo

Esta skill sirve para trabajar con modelos semanticos de Power BI desde VS Code Copilot usando la extension oficial **Power BI Modeling MCP Server** de Microsoft.

Permite que el agente use capacidades MCP para:
- conectar con Power BI Desktop, Fabric o proyectos PBIP/TMDL;
- inspeccionar tablas, columnas, medidas, relaciones, jerarquias y particiones;
- crear o modificar objetos del modelo;
- ejecutar consultas DAX;
- capturar trazas para diagnostico y validacion.

---

## Cuando usar esta skill

Usa esta skill cuando necesites:
- explorar un modelo semantico de Power BI con lenguaje natural;
- crear o actualizar medidas, columnas calculadas, tablas o relaciones;
- revisar el esquema del modelo antes de tocarlo;
- conectarte a un PBIX abierto en Power BI Desktop;
- conectarte a un modelo publicado en Fabric;
- trabajar sobre un proyecto PBIP/TMDL versionado en Git;
- ejecutar DAX de validacion o revisar dependencias del modelo.

No la uses para:
- construir informes visuales o maquetar paginas de reporte;
- publicar cambios funcionales sin validar antes el modelo;
- sustituir control de versiones del proyecto PBIP/TMDL.

---

## Resultado esperado

Al terminar, deberias tener:
- la extension oficial instalada y habilitada en VS Code;
- el servidor MCP de modelado visible para Copilot Chat en modo Agente;
- una conexion activa al modelo correcto;
- cambios de modelado ejecutados y validados sobre el objeto adecuado.

---

## Prerrequisitos

| Requisito | Verificacion |
|---|---|
| VS Code | `code --version` |
| GitHub Copilot + Copilot Chat | Panel de extensiones |
| Extension Power BI Modeling MCP Server | Buscar `Power BI Modeling MCP Server` en extensiones |
| Power BI Desktop, Fabric o proyecto PBIP/TMDL | Tener uno de los tres orígenes disponible |

Notas:
- En la imagen de referencia, la extension es la oficial de **Microsoft**.
- El identificador visible en la UI empieza por `analysis-services.`.
- Si ya aparece el boton `Deshabilitar`, la extension ya esta instalada.

---

## Fase 1 - Instalar la extension

### Opcion A - Desde VS Code

1. Abrir extensiones en VS Code.
2. Buscar `Power BI Modeling MCP Server`.
3. Verificar que el publicador sea **Microsoft**.
4. Instalar o, si ya esta instalada, dejarla habilitada.

### Opcion B - Desde terminal

Si conoces el identificador exacto de la extension en tu entorno, puedes instalarla con:

```powershell
code --install-extension <ID-DE-LA-EXTENSION>
```

Si ya la tienes instalada, no hace falta reinstalarla.

---

## Fase 2 - Activar y verificar el servidor MCP

1. Recarga VS Code: `Ctrl+Shift+P` -> `Developer: Reload Window`
2. Abre Copilot Chat en modo **Agente**.
3. Prueba una instruccion simple como:

```text
Lista las conexiones disponibles para Power BI Modeling MCP.
```

O bien:

```text
Conectate al ultimo modelo usado y lista las tablas.
```

Si el agente responde con operaciones de conexion o listado de objetos del modelo, el servidor MCP esta operativo.

---

## Fase 3 - Elegir origen del modelo

### A. Power BI Desktop

Usar cuando tienes un `.pbix` abierto localmente y quieres modificar el modelo en caliente.

Prompt recomendado:

```text
Conectate a la instancia local de Power BI Desktop y lista los modelos semanticos disponibles.
```

### B. Fabric / XMLA endpoint

Usar cuando el modelo esta publicado en un workspace de Fabric o servicio Power BI.

Prompt recomendado:

```text
Conectate al modelo semantico de Fabric indicando workspace y nombre del modelo.
```

### C. Proyecto PBIP / TMDL

Usar cuando el modelo esta en archivos versionados dentro de un repositorio.

Prompt recomendado:

```text
Conectate a la carpeta del proyecto PBIP/TMDL y revisa la definicion del modelo.
```

---

## Fase 4 - Flujos de trabajo recomendados

### 1. Inspeccion inicial

Antes de editar nada, pedir:

```text
Conectate al modelo y resume tablas, medidas, relaciones y roles.
```

### 2. Cambio pequeño y verificable

Ejemplos:

```text
Crea una medida Total Ventas = SUM(FactVentas[Importe]) y valida que compile.
```

```text
Revisa las relaciones activas de DimFecha y explica posibles conflictos.
```

```text
Lista las columnas de la tabla Cliente y detecta nombres inconsistentes.
```

### 3. Validacion posterior

Despues de cada cambio, pedir:

```text
Ejecuta una comprobacion del modelo y resume cualquier error o advertencia.
```

Si procede:

```text
Ejecuta una consulta DAX de validacion sobre la nueva medida.
```

---

## Operaciones tipicas que la skill cubre

- Gestion de conexiones a Power BI Desktop, Fabric y carpeta local.
- Listado y lectura de tablas, columnas, medidas, relaciones y roles.
- Creacion o actualizacion de medidas.
- Revisión de relaciones activas e inactivas.
- Ejecucion de consultas DAX.
- Captura de trazas del motor para diagnostico.
- Exportacion de definiciones TMDL cuando aplique.

---

## Prompts utiles

### Conexion

```text
Lista las conexiones activas del servidor Power BI Modeling MCP.
```

```text
Conectate al ultimo modelo usado y ponle un nombre de conexion claro.
```

### Exploracion

```text
Resume el modelo: tablas, medidas, relaciones y roles de seguridad.
```

```text
Lista solo las medidas de la tabla Ventas.
```

### Modelado

```text
Crea una medida Margen Neto y explica donde la has guardado.
```

```text
Añade una relacion entre DimFecha[Fecha] y FactVentas[FechaVenta] si no existe y valida el resultado.
```

### Diagnostico

```text
Inicia una traza del modelo, ejecuta una consulta DAX simple y resume los eventos relevantes.
```

```text
Detecta objetos duplicados, nombres ambiguos o relaciones potencialmente problematicas.
```

---

## Errores comunes

| Sintoma | Causa probable | Accion recomendada |
|---|---|---|
| Copilot no ve herramientas de Power BI | Extension no instalada o ventana no recargada | Instalar extension oficial y recargar VS Code |
| No encuentra modelos locales | No hay Power BI Desktop abierto | Abrir el PBIX antes de conectar |
| Falla conexion a Fabric | Workspace, tenant o modelo incorrectos | Revisar nombre exacto del workspace y del modelo |
| El agente modifica el modelo equivocado | Conexion ambigua o mal nombrada | Renombrar la conexion y confirmar el destino antes de editar |
| El cambio existe pero no esta validado | No se ejecutaron comprobaciones despues del cambio | Ejecutar validacion del modelo y una consulta DAX minima |

---

## Flujo operativo recomendado

1. Verificar que la extension oficial esta instalada.
2. Recargar VS Code.
3. Abrir Copilot Chat en modo Agente.
4. Conectar solo al modelo que vas a tocar.
5. Pedir un resumen del modelo antes de modificar.
6. Hacer cambios pequeños y acotados.
7. Validar despues de cada cambio.
8. Si trabajas con PBIP/TMDL, revisar diff antes de confirmar.

---

## Buenas practicas

- Nombrar las conexiones para evitar tocar el modelo equivocado.
- Empezar por cambios pequeños: una medida, una relacion, una tabla.
- Validar inmediatamente despues de cada edicion.
- Si el modelo esta en PBIP/TMDL, usar Git para revisar el diff antes de seguir.
- No mezclar cambios de modelado con cambios visuales del informe en el mismo paso.

---

## Ejemplos de uso rapido

### Crear una medida

```text
Conectate al modelo local de Power BI Desktop, crea la medida Total Coste = SUM(FactCostes[Importe]) en la tabla FactCostes y valida el resultado.
```

### Revisar relaciones

```text
Conectate al modelo y lista las relaciones de la tabla Calendario indicando cuales estan activas.
```

### Trabajar con PBIP/TMDL

```text
Abre la definicion del modelo desde la carpeta PBIP/TMDL, detecta medidas mal agrupadas y propón una reorganizacion minima.
```

---

## Nota de integracion global

Esta skill esta pensada para instalarse en **Skill Maestra** y sincronizarse con:
- `shared/scripts/sync-global-skills.ps1` hacia el directorio global de prompts/skills;
- la configuracion global de GitHub Copilot en VS Code, para poder invocarla desde cualquier workspace.

---

## Prompt reutilizable - Contexto de negocio progresivo (Power BI)

Usa este bloque cuando quieras construir contexto de negocio antes de modelar en Power BI:

```text
# Resumen - Enfoque de Prompt Progresivo (Contexto Negocio Power BI)

## Objetivo

Construir un documento de contexto de negocio para un workspace de Power BI mediante un enfoque de vibe coding, basado en:
- Iteracion progresiva
- Inputs reales de negocio
- Alineamiento entre negocio y modelo analitico

## Enfoque de trabajo

El documento se construye en capas sucesivas de contexto, evitando crear un modelo cerrado desde el inicio.

### 1. Inicio - Definicion base del negocio

Se establece:
- Actividad de la empresa (fabricacion + venta)
- Alcance (global)
- Canales de venta (Retail vs Online)

Objetivo: entender el marco general del negocio.

### 2. Identificacion de la dinamica operativa

Se incorporan elementos clave del proceso:
- El albaran como unidad base de venta
- Granularidad del analisis (cabecera vs linea)
- Metricas disponibles: ventas, coste, margen

Objetivo: definir la base del modelo de datos.

### 3. Introduccion de logica economica (clave)

Se anade la estrategia de margen:
- Canal Retail:
	- Bicicletas -> bajo margen
	- Complementos -> alto margen
- Canal Online:
	- Bicicletas -> alto margen
	- Complementos -> bajo margen

Objetivo: pasar de un modelo de ventas a un modelo de rentabilidad real.

### 4. Incorporacion de contexto real de negocio

Se integra informacion cualitativa (ej. entrevistas con cliente):
- El mix de ventas es intencional
- Existen incentivos comerciales
- El canal retail busca recurrencia
- El canal online busca rentabilidad directa
- Las campanas pueden distorsionar el margen
- No todos los albaranes son comparables

Objetivo: evitar interpretaciones incorrectas del dato.

### 5. Definicion del principio analitico clave

El objetivo NO es maximizar ingresos.
El objetivo SI es optimizar el margen segun canal y contexto.

Esto condiciona todo el modelo analitico.

## Resultado del enfoque

El documento generado:
- No es solo descriptivo: es interpretativo
- No es solo tecnico: esta anclado en negocio
- No es estatico: esta preparado para evolucionar

## Impacto en Power BI

Este enfoque permite:
- Disenar un modelo basado en albaran (fact table), canal, producto y contexto (campanas, mix)
- Evitar errores tipicos:
	- Analizar ventas sin contexto
	- Comparar canales incorrectamente
	- Evaluar mal el rendimiento comercial

## Claves del enfoque (para equipo)

- Empezar por contexto, no por tablas
- Introducir logica de negocio antes que modelo
- Validar siempre:
	- Que mide realmente este dato
	- Que comportamiento hay detras
- Iterar -> enriquecer -> refinar

## Conclusion

El prompt progresivo permite construir modelos de Power BI que:
- Reflejan el funcionamiento real del negocio
- Incorporan estrategia comercial
- Evitan conclusiones erroneas
- Sirven como base para decisiones de gestion
```
