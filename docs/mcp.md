# Darle ojos a la base sin darle las llaves

Un agente que no puede consultar la base te hace leerle los datos a mano. Uno con acceso total puede borrar producción por error. El punto medio es un MCP local que **consulta** y que guarda la credencial fuera de la configuración.

## MCP no es el enrutador

Son dos cosas distintas y se confunden seguido:

- **El enrutador de modelos** (`claude-code-router` y similares) decide *qué modelo* responde. No aporta herramientas.
- **El MCP** le da *herramientas* al agente: leer una tabla, abrir un archivo, manejar un navegador. Lo lanza el cliente (Claude Code, Codex, el que sea), no el enrutador.

Por eso configurar el enrutador no arregla un MCP que falla. Son tuberías separadas.

## El patrón: lanzador que lee tu archivo de secretos

La configuración del cliente no debe contener claves. Un lanzador de 20 líneas lee el archivo de secretos y arranca el servidor:

```js
// start-mcp.mjs — sin claves dentro
import { spawn } from 'node:child_process';
import { readFileSync } from 'node:fs';

const env = Object.fromEntries(
  readFileSync('C:/ruta/a/secrets.env', 'utf8')
    .split(/\r?\n/)
    .filter((l) => /^[A-Za-z_][A-Za-z0-9_]*=/.test(l))
    .map((l) => { const i = l.indexOf('='); return [l.slice(0, i), l.slice(i + 1).trim()]; }),
);

spawn(process.execPath, ['C:/ruta/al/servidor.js', '--apiUrl', env.API_URL, '--apiKey', env.API_KEY], {
  stdio: 'inherit', // el MCP habla por stdin/stdout
});
```

Se registra una sola vez:

```bash
claude mcp add nombre --scope user -- node C:/ruta/start-mcp.mjs
```

La clave vive en un solo sitio, fuera de git y fuera de la configuración del cliente. Si rotas la credencial, no tocas la config.

## Caso Supabase: el paquete que ya no se mantiene

El servidor local de Supabase para PostgREST (`@supabase/mcp-server-postgrest`) está deprecado y, instalado con `npx`, falla con:

```
Cannot find package '@modelcontextprotocol/server'
```

No es tu configuración: le falta una dependencia que `npx` no resuelve. La salida es instalarlo en una carpeta propia, junto con la dependencia, y apuntar el lanzador ahí:

```bash
mkdir mcp-supabase && cd mcp-supabase
npm init -y
npm install @supabase/mcp-server-postgrest @modelcontextprotocol/server
```

```js
// dentro del lanzador
['node_modules/@supabase/mcp-server-postgrest/dist/stdio.js',
 '--apiUrl', `${env.SUPABASE_URL}/rest/v1`,
 '--apiKey', env.SUPABASE_SERVICE_ROLE_KEY,
 '--schema', 'public']
```

Comprobación sin abrir el cliente: mándale un `initialize` por stdin y debe responder un JSON con `serverInfo`.

```bash
printf '%s\n' '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2024-11-05","capabilities":{},"clientInfo":{"name":"test","version":"1"}}}' \
  | node start-mcp.mjs
```

## La advertencia que importa

Con la **service role key**, el MCP ignora RLS: ve y modifica todo. Es la única forma práctica de consultar tablas protegidas sin una sesión de usuario, pero convierte al agente en superusuario.

Reglas mínimas:

- Ese MCP se usa para **leer**. Las mutaciones van por RPC o por una persona, no por el agente.
- Si la base es de un cliente, el MCP no se configura en su máquina sin su permiso.
- Si necesitas escritura real, crea un rol de Postgres con permisos mínimos y una credencial propia; no uses service role para todo.
- La clave anónima no sirve para esto: sin sesión, RLS devuelve cero filas.

## Alternativa alojada

Supabase ofrece un MCP alojado con OAuth (`https://mcp.supabase.com/mcp`). Es la vía preferida cuando el cliente soporta MCP remoto y puedes autenticarte con tu cuenta: no hay clave que guardar y los permisos son los de tu usuario. El MCP local con service role queda para cuando el cliente solo habla stdio o no hay OAuth disponible.
