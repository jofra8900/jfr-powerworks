# Los ajustes: subir y bajar el freno

Nada de esto es sagrado. Un sistema que te traba lo terminas esquivando, y un sistema que esquivas no te protege de nada. Estos son los números que puedes mover, dónde se mueven y qué ganas o pierdes con cada uno.

Todos viven en texto plano: tu `AGENTS.md`, los archivos de skill, o la cabecera de un script. Se cambian editándolos.

## Cuándo se delega

**Por defecto:** si toca más de 2 archivos o es trabajo mecánico, se delega. Lo pequeño o delicado lo hace el agente principal.

Súbelo si el ejecutor barato te está devolviendo trabajo que hay que rehacer. Bájalo si te quedas sin cuota del caro a media tarde. El número no importa tanto como tenerlo escrito: sin un umbral, el agente decide distinto cada día.

## Cuándo se corta la sesión

**Por defecto:** aviso de cerrar el tema al 60 % del contexto, relevo al 85 %.

Una sesión larga no solo cuesta más: razona peor, porque arrastra cosas que ya no importan. Si cambias de tema, no esperes el porcentaje; corta.

## Cuánto piensa el modelo

**Por defecto:** esfuerzo medio. Alto solo para cambios en producción, un bug que resistió dos intentos, o el diseño de algo nuevo.

Dejarlo siempre en alto es la fuga de tokens más silenciosa que existe, porque no se ve en ningún lado: pagas razonamiento extra en cada respuesta rutinaria.

## Qué se pregunta antes de hacer

Aquí es donde más se nota el freno, y donde más conviene afinar.

**No se pregunta:** leer, navegar, buscar, y escribir todo lo que quieras en una copia borrable.

**No se pregunta, pero se avisa después:** escribir en producción cuando la tarea lo pidió explícitamente, y solo registros nuevos marcados como prueba.

**Se pregunta siempre:** borrar, cambios masivos, enviar algo que sale hacia afuera —un correo, un documento a un cliente, un pago—, y cualquier cosa que consuma un número correlativo.

Esa última lista es la que yo no bajaría. No es por trámite: son las acciones donde equivocarse no se arregla con `git revert`.

El resto, aflójalo sin culpa. Si te está preguntando por cosas que siempre apruebas, el umbral está mal puesto.

## Las credenciales

**La regla:** la contraseña nunca va escrita dentro de un comando.

Esta es la que más parece burocracia y menos lo es. Un comando con la clave dentro queda en el log que escribe el monitor, y ese log lo leen los modelos baratos a los que delegas. Tu clave de administrador terminaría en un archivo de texto y enviada a un modelo gratuito.

**Y no tiene por qué trabarte.** Hay dos salidas sin fricción:

- un baúl de credenciales: guardas la clave una vez por entrada estándar y después el agente entra con un comando que no la contiene;
- o abres el navegador en modo visible, entras tú, y el agente sigue trabajando en esa misma sesión.

Si una regla de seguridad te está frenando, casi siempre es que falta la herramienta, no que sobre la regla.

## Qué puede ir a modelos que entrenan con tus datos

**Por defecto:** nada sensible. Clientes, sueldos, datos personales de terceros.

Esta depende de tu riesgo real, y conviene escribirla en vez de decidirla cada vez. Un ejemplo de excepción razonable, escrita en el contrato: la IA que va dentro de un producto puede usar modelos gratuitos mientras no exista presupuesto para los de pago, siempre que la capa de modelo quede intercambiable para migrar sin reescribir.

Lo importante no es dónde pongas la línea. Es que esté escrita, con fecha y motivo, para que ningún agente la interprete a su manera ni te la discuta cada vez.

## El equilibrio

Todo esto es la misma tensión: más contexto y más verificación dan mejor calidad y cuestan más. La respuesta no es un número fijo, es **poner el gasto donde cambia el resultado**.

Pensar mucho antes de tocar producción, sí. Pensar mucho para renombrar una variable, no.

## Autoría limpia y control de `git push`

Por defecto, algunos CLI de agentes agregan `Co-Authored-By: ...` en cada commit o ejecutan `git push` directo si tienen permisos. En repositorios públicos y de clientes conviene separar la preparación (del agente) de la publicación (tuya):

1. En `settings.json` de Claude Code:
   - `"attribution": { "commit": "", "pr": "" }` quita las firmas automáticas de IA en commits y PRs (`includeCoAuthoredBy` quedó deprecado).
   - `"permissions": { "deny": ["Bash(git push*)", "Bash(git -C * push*)", "Bash(gh pr create*)", "Bash(gh pr merge*)"] }` impide técnicamente que el agente publique al remoto sin bloquear `commit`, `diff` o `status`.
2. Con `skills/publicar-git/SKILL.md`, cuando el trabajo está probado, el agente deja el commit preparado y te entrega el bloque exacto para revisar y ejecutar en tu terminal.
3. Si conectas un modelo de respaldo con API `/anthropic` directa (como DeepSeek) y el planificador pesado tiene riesgo de quedarse colgado en razonamiento largo, fija `API_TIMEOUT_MS` (p. ej. `180000` ms) para cortar antes del tope de 10 min y pasar el plan a otro proveedor de respaldo.
