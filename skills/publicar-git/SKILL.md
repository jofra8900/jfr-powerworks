---
name: publicar-git
description: Usar siempre cuando haya cambios probados y listos para subir a GitHub o cuando el usuario pida publicar/pushear. El agente nunca ejecuta git push; prepara el commit limpio sin Co-Authored-By y entrega al humano el comando exacto en PowerShell.
---

# Publicar en GitHub (control humano)

El agente **no** ejecuta `git push` ni crea PRs por su cuenta (`attribution` vacía y `Bash(git push*)` denegado en `settings.json`).

## Pasos obligatorios antes de publicar

1. **Verificar higiene:**
   - Ejecutar `git -C "<repo>" status --short` y `git -C "<repo>" diff --stat`.
   - Confirmar que **no** hay secretos, `.env*`, credenciales ni (en repos públicos) rutas personales o nombres de clientes.
   - Confirmar que pasaron las pruebas y checks del proyecto.
2. **Preparar el commit limpio (si el usuario pidió commitear):**
   - Usar `git add -- <archivos exactos>` (evitar `git add -A` cuando haya artefactos temporales).
   - Escribir mensaje claro sin trailers `Co-Authored-By`.
3. **Detenerse antes de `push` y entregar el comando exacto:**
   - Mostrar qué archivos entran en el commit (`git log -n 1 --stat`).
   - Entregar **un único bloque de PowerShell listo para copiar y pegar**:

```powershell
git -C "<RUTA_DEL_REPO>" pull --rebase --autostash; git -C "<RUTA_DEL_REPO>" push
```

*(Si se enmendó un commit local recién creado en un repo personal para corregir mensaje/autoría, indicar `--force-with-lease`.)*
