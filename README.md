# jfr-powerworks

**Dos máquinas, cinco modelos, una regla: el caro no toca el teclado.**

El sistema de agentes con el que trabajo todos los días. No es una lista de enlaces ni una plantilla teórica: son los archivos que están corriendo ahora mismo en mi torre y en mi laptop.

---

## La regla

Un modelo caro razona bien y cuesta caro por token. Un modelo barato escribe código decente si le das un plan exacto.

Así que el caro **planea y revisa**. Los baratos **ejecutan**. El caro nunca escribe el diff completo; lee el que le trajeron.

| Quién | Motor | Para qué |
|---|---|---|
| Claude Code (Opus) | suscripción | Planear, decidir, revisar diffs, tocar producción |
| Claude (Sonnet) | la misma, vía `opusplan` | Ejecutar dentro de la sesión lo que Opus planeó |
| Subagente lector (Haiku) | la misma | Leer y buscar en decenas de archivos; devuelve solo el extracto |
| OpenCode Go | US$10/mes | El trabajo mecánico: refactors, CRUDs, tests, scripts |
| Antigravity (`agy`) | incluido en Google AI Pro | Segundo ejecutor y respaldo cuando el anterior se agota |

Costo real: **US$30 al mes**.

---

## El problema que esto resuelve

Los planes de agentes por suscripción tienen topes por ventana: 5 horas, semana, mes. Cuando se alcanza uno, el CLI **termina con código de salida 0** igual que si hubiera acabado bien. El agente que lo lanzó cree que la tarea está lista. No lo está: quedó a medias, y nadie se entera hasta que algo no compila.

Pasó aquí el 21 de noviembre, a mitad de una migración.

`scripts/monitor.ps1` lee la salida mientras corre, detecta el mensaje del tope, mata el proceso y escribe `LIMITE:` en el archivo de fin. El agente que esperaba lo lee, mira en git qué alcanzó a hacer, y relanza **solo lo que falta** con el siguiente modelo de la cadena.

La cadena baja sola: pago → gratis que no entrenan con tus datos → otro proveedor → el modelo caro, como último recurso y avisando.

---

## El otro problema: el contexto

Cada skill instalada mete su descripción en **todas** las sesiones, las use o no. Medido en mi configuración: 19 skills activas = ~2.100 tokens por sesión antes de escribir una palabra. Los plugins de video sumaban 20 skills más.

`scripts/skills_toggle.ps1` mueve una skill entre la carpeta activa y una apagada. No borra nada. Se prende cuando se necesita y se apaga al terminar.

```powershell
.\skills_toggle.ps1 -Nombre differential-review -Accion on
```

---

## Qué hay aquí

```
AGENTS.md                  El contrato. Lo lee cualquier agente que llegue sin contexto.
scripts/delegar.ps1        Lanza la tarea delegada. Elige el modelo solo, según disponibilidad.
scripts/monitor.ps1        Tablero en vivo: avance, archivos tocados, y el aviso de tope.
scripts/skills_toggle.ps1  Prender y apagar skills sin borrarlas.
agents/lector.md           Subagente barato de solo lectura.
mods/linea-ahorro/         Línea de estado: modelo, contexto, cuota y costo, con avisos.
```

---

## AGENTS.md: el contrato

Un agente nuevo no sabe nada de tu proyecto y no debería preguntártelo todo. `AGENTS.md` vive en la raíz y responde tres cosas: dónde está el tablero de tareas, qué reglas no se negocian, y a quién se le delega qué.

Las reglas que a mí me importan, y por qué cada una existe:

- **Los secretos solo en un archivo ignorado por git.** En notas y código va el nombre, nunca el valor.
- **Nada se borra de forma permanente sin mostrarlo antes.**
- **Producción se prueba primero** con la transacción revertida o en una copia, y se pide permiso para aplicar.
- **Nada sensible a modelos gratuitos.** Algunos entrenan con lo que les mandas.

Ninguna skill de terceros pasa por encima de esto. Una skill es texto que tu agente obedece: léela entera antes de instalarla.

---

## Lo que esto no es

- No es un framework. No hay nada que importar.
- No es una lista de enlaces a herramientas de otros.
- No promete autonomía. Un humano revisa el diff antes de publicar.
- No sirve tal cual: las rutas y las reglas son mías. Cópialas y cámbialas.

---

## Requisitos

Windows con PowerShell 5.1, git, y los CLI que uses como ejecutores. Los scripts no tienen dependencias.

---

MIT. Si te sirve algo de aquí, úsalo.
