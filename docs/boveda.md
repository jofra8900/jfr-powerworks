# La bóveda: dónde vive el contexto

Esta es la pieza que hace que lo demás funcione. Sin ella, cada sesión de agente empieza de cero y te toca volver a explicar el proyecto.

La bóveda es **una carpeta de archivos markdown, versionada con git, que se abre con Obsidian**. Nada más. No hay servidor, ni base de datos vectorial, ni servicio que mantener.

## Por qué markdown y git, y no un sistema de memoria

Probé el camino contrario antes de quedarme con este. Las razones, en orden de peso:

1. **Los agentes leen markdown nativamente.** Cualquier CLI, de cualquier proveedor, abre un `.md` sin integración, sin API y sin clave. El día que cambies de herramienta, tu contexto sigue ahí.
2. **Git ya es el historial.** Quién cambió qué y cuándo, con posibilidad de volver atrás. Un sistema de memoria que resume y deduce te da una versión del pasado que no puedes auditar.
3. **Tú también la lees.** Obsidian te da buscador, enlaces y grafo. Una base vectorial no te deja leer tus propias notas un domingo.
4. **Cuesta cero y no se cae.** No hay contenedor que vigilar ni embeddings que regenerar.

Lo que pierdes: búsqueda semántica. En la práctica, `grep` sobre una bóveda bien nombrada resuelve casi todo, y para lo que no, un subagente barato busca y resume.

**La regla que importa:** una sola fuente por dato. Si un hecho vive a la vez en la bóveda y en la memoria del agente, el día que cambie vas a tener dos versiones y ninguna marcada como falsa. Elige la bóveda.

## Estructura

```
Boveda/
  AGENTS.md              El contrato. Primer archivo que lee cualquier agente.
  CLAUDE.md              Apunta a AGENTS.md, para los CLI que buscan ese nombre.
  00_Meta/
    Pendientes.md        El tablero. Fuente única de qué falta y con qué prioridad.
    <guías del sistema>  Quién hace qué, qué skill usar, infraestructura.
  01_Proyectos/
    <proyecto>/
      BRIEF_*.md         Objetivo, entregables, rutas, reglas, orden y Bitácora.
  02_Credenciales/       Ignorada por git. Solo nombres en notas: [secreto: NOMBRE].
```

## Las dos convenciones que hacen el trabajo

**`Pendientes.md` es el tablero.** Prioridades visibles y cada tarea enlazando a su brief. Cuando le dices a un agente "continuemos", lee ese archivo y sabe dónde está parado. Sin él, le cuentas el estado cada vez.

**Cada brief tiene una `Bitácora`.** Al cerrar una sesión, el agente escribe qué hizo, qué falta y dónde quedaron los archivos. Eso es lo que lee la sesión siguiente. Es la diferencia entre retomar en dos minutos o en veinte.

## El relevo

Una sesión larga se encarece y se vuelve torpe. Cuando el contexto pasa de cierto punto, no se sigue: se cierra.

El agente escribe el estado en la bitácora del brief, y la sesión nueva arranca leyendo `AGENTS.md` → `Pendientes.md` → el brief. La bóveda es el cable entre las dos.

El mod `linea-ahorro` de este repo avisa cuándo toca: muestra el porcentaje de contexto usado y la cuota consumida en la línea de estado.

## Montarla

```bash
mkdir mi-boveda && cd mi-boveda
git init
# AGENTS.md en la raíz, 00_Meta/Pendientes.md, 01_Proyectos/, 02_Credenciales/
echo "02_Credenciales/" > .gitignore
```

Abre la carpeta con Obsidian. Para sincronizar entre máquinas, el plugin Obsidian Git hace commit y push solo cada cierto tiempo.

Un aviso que cuesta caro aprender: **el repositorio es privado**, y aun así los secretos no entran. Cualquier agente o plugin que lea la bóveda lee también el historial de git, y de ahí una clave ya no se borra.
