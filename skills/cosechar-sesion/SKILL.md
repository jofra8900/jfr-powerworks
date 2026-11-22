---
name: cosechar-sesion
description: Decidir qué de esta sesión debe quedarse en el sistema y escribirlo donde corresponde, para que no se pierda al cerrar el chat. Usar al terminar una sesión con resultado, cuando JFR diga "cosecha", "guarda lo aprendido", "que no se pierda", "esto hay que anotarlo"; cuando se descubra que una nota estaba equivocada; cuando se tome una decisión que ya no se debe volver a discutir; o cuando un procedimiento se haya repetido por tercera vez. No es lo mismo que relevo-sesion: el relevo pasa el contexto a una sesión nueva, esto deja el conocimiento en la bóveda para siempre.
---

# Cosechar la sesión

Las conversaciones se borran. La bóveda no. Si algo que se aprendió hoy solo vive en este chat, dentro de un mes nadie sabrá que existió, y lo peor: la nota vieja y equivocada seguirá ahí, y alguien la va a creer.

## 1. Listar lo que pasó

Antes de clasificar, escribir la lista cruda. Sin filtrar todavía:

- **Decisiones** que tomó JFR y que ya no se deben volver a discutir.
- **Descubrimientos:** cómo funciona algo de verdad, en contra de lo que decía la documentación.
- **Correcciones:** algo que se hizo mal y cómo se debe hacer.
- **Construido:** qué se creó o cambió, y dónde quedó.
- **Fallos:** qué se intentó y no funcionó, y por qué. Esto vale tanto como lo que sí funcionó.
- **Preguntas** que quedaron abiertas para una persona.

## 2. Decidir dónde va cada cosa

| Qué es | Dónde va |
|---|---|
| Un hecho de un proyecto que puede cambiar | La nota del proyecto o la **bitácora** de su brief, **con fecha** |
| Estado de hoy: qué se hizo, qué falta, dónde quedó | Bitácora del brief + `Pendientes.md` |
| Cómo trabajar con JFR: una preferencia, una corrección suya | Memoria (`feedback`), con el **porqué** |
| Una trampa técnica que evita romper algo | Memoria (`feedback`) si aplica a todo; a la nota del proyecto si es de uno solo |
| Una regla que nunca se debe romper | `AGENTS.md` |
| Un procedimiento hecho ya tres veces igual | Una **skill** nueva |
| Algo mecánico que se repite | Un **script** |
| Una pregunta para una persona | El archivo único de preguntas |
| Una herramienta o servicio nuevo | El catálogo de repos y servicios |
| Una clave o acceso | Solo el archivo de secretos, nunca una nota |

**Lo que no entra:** lo que ya está escrito, lo que solo sirvió para esta conversación, y lo que se puede volver a averiguar en diez segundos. Escribir de más tiene costo: todo lo que se guarda, alguien lo va a leer después.

## 3. Buscar la contradicción antes de escribir

Antes de agregar un hecho, buscar si la bóveda ya dice algo sobre eso. Tres casos:

- **No dice nada:** se escribe.
- **Dice lo mismo:** no se escribe. Un dato, una sola casa.
- **Dice lo contrario:** esto es lo más valioso de todo el ejercicio. Se corrige la nota vieja, se marca con fecha qué cambió y por qué, y si el documento entero quedó obsoleto, se dice en su encabezado. **No dejar las dos versiones vivas.**

Si no se puede saber cuál es la verdad, se pregunta a JFR. No se adivina.

## 4. Escribir y cerrar

1. Hacer los cambios, cada hecho en un solo lugar.
2. `git pull --rebase` antes del commit, porque puede haber otra sesión trabajando.
3. Commit y push de la bóveda.
4. Informar a JFR en pocas líneas: qué se guardó, **en qué archivo**, qué se corrigió por estar equivocado, y qué se decidió no guardar y por qué.

Ese último punto importa: deja que JFR rescate algo que se iba a descartar.

## Señales de que hay que cosechar ya, sin esperar al final

- "ahora que lo pienso, en realidad funciona así";
- un documento y la realidad no coinciden;
- se tomó una decisión después de discutirla un rato;
- algo falló dos veces por el mismo motivo;
- apareció un número o una medición que costó conseguir.
