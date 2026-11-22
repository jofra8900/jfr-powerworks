# Skills: cuáles valen la pena y cuánto cuestan

Una skill es una carpeta con un `SKILL.md`: instrucciones que tu agente va a obedecer cuando la descripción coincida con lo que estás haciendo. Bien elegidas, evitan que un modelo barato invente. Mal elegidas, te llenan el contexto y te dan instrucciones que no pediste.

## El presupuesto de contexto

Cada skill instalada mete su **descripción** en todas las sesiones, la uses o no. Solo el cuerpo se carga bajo demanda.

Medido en mi configuración:

| | Tokens por sesión |
|---|---|
| 19 skills activas, solo descripciones | ~2.100 |
| Índice de memoria del agente | ~1.000 |
| Un plugin de video con 20 skills | ~2.000 más |

Son unos 5.000 tokens antes de escribir una palabra. No es catastrófico, pero crece sin que lo notes: cada plugin que instalas suma, y nadie te lo cobra de forma visible.

Por eso `scripts/skills_toggle.ps1`: mueve la carpeta entre `skills/` y `skills-bajo-demanda/`. No borra nada, y se prende solo cuando hace falta.

```powershell
.\skills_toggle.ps1 -Nombre differential-review -Accion on
```

## Antes de instalar una de terceros

Lee el `SKILL.md` **entero**, y sus archivos de apoyo. Es texto que tu agente va a obedecer con tus permisos. Descarta si:

- descarga algo y lo ejecuta, o manda datos a un servidor que no controlas;
- te dice que la prefieras **por encima de tus propias reglas** o de otras herramientas;
- viene en un paquete de cientos de skills generadas en masa;
- trae disparadores de cosas que no usas, que solo sirven para que se active de más.

Si una skill trae un archivo de reglas fijado por hash, verifica el hash. Es la señal de que quien la hizo pensó en esto.

**Ninguna skill pasa por encima de tu `AGENTS.md`.** Es normal que una skill oficial sugiera un atajo cómodo que tus reglas prohíben, por ejemplo iterar directo contra la base en vez de pasar por migraciones. Gana tu contrato.

## Qué instalar, en orden de rendimiento

**1. Las oficiales del fabricante de lo que ya usas.** Es donde un modelo barato más se equivoca: reglas de seguridad de tu base de datos, patrones de tu framework, trampas de configuración. Una skill oficial las trae escritas, y el ejecutor barato las sigue en vez de improvisar.

Instálalas también en la carpeta de skills de tus **ejecutores**, no solo en la del agente principal. Ahí es donde hacen efecto.

**2. Proceso, no tecnología.** Lo que ordena el trabajo rinde más que lo que sabe de una herramienta concreta:

- escribir un plan antes de tocar código;
- depuración sistemática, para no parchear síntomas;
- revisión de código, y revisión de seguridad de un diff antes de publicar algo delicado;
- hacer el cambio más pequeño que resuelve el problema completo.

**3. Las tuyas, para lo que repites.** Si una tarea la haces más de tres veces igual, conviértela en skill: el procedimiento, las rutas, las trampas conocidas. Son las que más ahorran, porque evitan que expliques lo mismo cada vez.

**Bajo demanda, no activas:** revisiones de seguridad, generación de video o presentaciones, y todo lo estacional.

## Lo que no instalo

- **Bibliotecas de cientos de skills.** Suelen ser generadas en masa y llenan el contexto. Si de 800 te sirven dos, copia esas dos.
- **Skills de dominios que no tocas.** Blockchain, bioinformática, nubes que no usas.
- **Las que duplican algo que ya tienes.** Si tu agente ya maneja documentos de oficina, una skill de terceros para lo mismo solo añade ruido.
- **Catálogos de enlaces.** No son skills: son lecturas. No ocupan contexto porque no se instalan.
