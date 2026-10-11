# Cómo contribuir a Skill Maestra

Gracias por querer aportar. Este proyecto se mantiene en el tiempo libre, así que las propuestas pequeñas y claras se atienden antes.

## Qué puedes aportar

- **Una skill nueva** en `.github/skills/<nombre-kebab>/SKILL.md`, con frontmatter `name` y `description`, y su fila en `_archivos_por_categoria/web/data/skill-descriptions.es.tsv`.
- **Un truco** en `_archivos_por_categoria/web/html/trucos.html`: copia una `<article class="truco">` de su categoría. La insignia "Recomendado" solo va en lo que de verdad recomiendas por experiencia.
- **Correcciones** del catálogo, de la web o de los scripts.

## Antes de abrir la pull request

1. Crea una rama desde `main`.
2. Si tocas skills, regenera el catálogo:
   ```powershell
   pwsh -File _archivos_por_categoria\scripts\ps1\Update-SkillMaestraWebIndex.ps1
   ```
   No edites a mano lo que hay entre `<!-- AUTO-INDEX-SKILL-MAESTRA:START -->` y `:END` en `index.html`, ni `web/md/catalogo-skills.md`.
3. Abre la web con Live Preview y comprueba que la página sigue cargando sin errores en la consola.
4. Comprueba que no subes nada personal: rutas con tu usuario, correos, claves, identificadores de tenant o de entorno. El `.gitignore` ya bloquea `.env`, `settings.json`, `mcp.json` y `.vsix`.

## Estilo

- Texto de cara al usuario en español, en lenguaje llano; los identificadores técnicos se dejan tal cual.
- Las skills de terceros conservan su licencia en un `LICENSE.txt` dentro de su carpeta. No incluyas skills cuya licencia no permita redistribuirlas.
- Commits cortos y descriptivos, en español o inglés.

## Issues

Usa las plantillas de issue para informar de un fallo o proponer una skill. Para problemas de seguridad, sigue [SECURITY.md](SECURITY.md) en vez de abrir un issue público.
