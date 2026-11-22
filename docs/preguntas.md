# La guía de preguntas: cuando el que sabe no eres tú

En un proyecto grande, lo que te frena no es el código. Es que hay decisiones que solo puede tomar el cliente, y tú no estás con él. Mientras tanto construyes sobre suposiciones, y cada suposición mal puesta se paga después.

El patrón: **una sola fuente de preguntas, viva, que crece con el proyecto.**

## El problema que resuelve

Sin esto, las preguntas se dispersan: una en un chat, otra en un correo, otra en la cabeza de alguien. Pasa siempre lo mismo:

- preguntas lo mismo dos veces, y el cliente lo nota;
- una respuesta llega por audio de WhatsApp, nadie la escribe, y se pierde;
- te sientas con el cliente media hora y sales sin lo que más te bloqueaba, porque no tenías la lista priorizada;
- un agente nuevo entra al proyecto y vuelve a preguntar lo ya respondido.

## Cómo funciona

**Un archivo estructurado es la fuente única.** JSON o similar, versionado con el proyecto. Cada pregunta lleva:

```
id            referencia corta y estable, para citarla en una reunión
pregunta      redactada para quien la va a responder, no para ti
para_quien    la persona concreta
prioridad     qué está bloqueando ahora mismo
estado        pendiente | respondida
respuesta     textual, y la fecha
bloquea       qué no se puede construir hasta que llegue
```

**La guía que lee el humano se genera, no se escribe.** Un script toma ese archivo y produce el documento que le pasas al cliente: ordenado por prioridad, en su lenguaje, sin ids internos si estorban. Nunca editas el documento a mano, porque entonces vuelves a tener dos fuentes.

**La regla que lo sostiene:** si un agente tiene una pregunta para una persona, va ahí. No a un chat, no a un archivo suelto, no a un `TODO` en el código. Y cuando llega una respuesta, por audio, por mensaje o en una reunión, se registra ahí **antes** de usarla.

## Lo que gana el trabajo

Llegas a una reunión con las tres preguntas que de verdad te bloquean, no con quince. El cliente responde rápido porque ve que avanza. Y una respuesta, una vez registrada, es verdad del proyecto: cualquier agente la lee y nadie la vuelve a preguntar.

Un número real de un proyecto en curso: 33 respondidas, 99 pendientes. Eso es visible de un vistazo, y dice más del estado del proyecto que cualquier informe.

## El cierre del círculo

Una respuesta no termina en el archivo de preguntas. Si cambia cómo funciona algo, se escribe también en el brief del proyecto, porque es ahí donde el agente que construye va a mirar.

Es la misma regla que gobierna todo el sistema: **lo que se descubre en una sesión no se queda en la sesión.** Las conversaciones se borran. La carpeta de markdown no.

Lo mismo aplica a lo que descubres tú sin preguntarle a nadie: que una tabla no se usa, que el cliente ajusta el inventario de una forma distinta a la documentada, que un documento viejo está equivocado. Al cerrar la sesión, eso va a la nota que corresponde o a la bitácora del brief, con fecha. Si no, dentro de un mes nadie sabe cuál de las dos versiones es la verdadera.
