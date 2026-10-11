# Instrucciones para instalar la Skill `agent-customization`

## Instalación manual en VS Code

---

## Paso 1: Extraer el ZIP

1. Descarga el archivo `agent-customization.zip`
2. Extrae el contenido en tu carpeta de skills de VS Code:

   **Windows (PowerShell):**
   ```powershell
   $destination = "$env:APPDATA\Code\User\prompts"
   Expand-Archive -Path "C:\ruta\a\agent-customization.zip" -DestinationPath $destination -Force
   ```

   **O manualmente:**
   - Clic derecho en el ZIP → "Extraer todo"
   - Guardar en: `C:\Users\<tu-usuario>\AppData\Roaming\Code\User\prompts\`

---

## Paso 2: Reiniciar VS Code

1. Cierra VS Code completamente
2. Vuelve a abrir VS Code

---

## Paso 3: Verificar que se cargó

1. Abre VS Code
2. Abre Copilot Chat (`Ctrl+Shift+I`)
3. En la paleta de comandos, busca "Copilot: Show Agent Skills"
4. Debería aparecer `agent-customization` en la lista

---

## ¿Qué hace esta skill?

Esta skill está diseñada para:
- Crear, actualizar, revisar, fijar o debuguear archivos de personalización de agentes
- Configurar archivos `.instructions.md`, `.prompt.md`, `.agent.md`, `SKILL.md`
- Definir patrones `applyTo` y restricciones de herramientas
- Crear modos de agentes especializados
- Empaquetar conocimiento de dominio

---

## Contacto

Si tienes problemas con la instalación, abre una incidencia en el repositorio.

---

**Última actualización:** 27 de abril de 2026
