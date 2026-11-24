# La torre: un PC viejo haciendo de servidor

**Esta capa es opcional.** El sistema del README —planear caro, ejecutar barato, la bóveda, el control de contexto— funciona entero en un portátil, sin servidor y sin Docker. Si estás empezando, sáltate este documento y vuelve cuando algo necesite correr sin ti.

Lo que gana quien sí tiene una máquina encendida: modelos gratuitos encadenados con reserva, transcripción de voz en local, y un agente que trabaja a las 7 de la mañana aunque tú estés durmiendo. Lo que pierde quien no la tiene: nada del flujo de trabajo; solo esas tres comodidades, y las dos primeras se reemplazan pagando.

Esta capa se montó después, cuando quedó claro que varias cosas tenían que correr aunque el portátil estuviera apagado.

La decisión de fondo: **en vez de alquilar un VPS, se usa un PC de escritorio que ya estaba en casa.** Encendido todo el día, con Docker, y alcanzable desde el celular y desde la otra máquina por una VPN privada. Cuesta la luz.

Lo que se gana sobre un VPS alquilado: no hay mensualidad, hay disco de sobra, y hay GPU para lo que la necesite. Lo que se pierde: depende de tu conexión y de que no se corte la luz, así que no sirve para nada que un cliente tenga que ver en vivo. Para eso están los servicios de alojamiento de siempre.

## Qué corre ahí

| Pieza | Para qué |
|---|---|
| **Enrutador de modelos** | Una sola puerta para todos los proveedores. Ver abajo. |
| **Transcripción de voz** | Audios a texto, en local. Ver abajo. |
| **Agente 24/7** | La parte que no necesita que tú estés. En construcción. |
| **Panel propio** | Tablero de pendientes, recordatorios y accesos, abierto desde el celular. |
| **Editor en el navegador** | Entrar al código desde cualquier máquina. |
| **Memoria conversacional** | Servicio aparte, autoalojado, para el agente 24/7. |
| **Herramientas sueltas** | Utilidades de PDF, un navegador sin interfaz para automatizar. |

Todo en contenedores con reinicio automático, un script de arranque, un vigilante que revisa cada pocos minutos y levanta lo que se cayó, y respaldo de volúmenes. Un corte de luz no debería requerir que hagas nada.

## El enrutador: muchos proveedores, una sola puerta

Los modelos gratuitos de la nube sirven de verdad, pero se agotan. Cada proveedor tiene su cuota diaria, y cuando la alcanzas devuelve un error y te quedas sin nada a mitad de una tarea.

La solución es un enrutador que expone **una sola dirección compatible con OpenAI** y detrás tiene una cadena ordenada de proveedores. Si el primero devuelve cuota agotada, pasa al segundo, y así. Para quien lo llama, siempre hay modelo.

Encima de la cadena van perfiles por tipo de trabajo: uno rápido, uno para programar, uno que ve imágenes. El que llama pide el perfil, no el modelo. El día que cambies de proveedor, cambias la cadena en un sitio y nadie más se entera.

Una advertencia que cuesta aprender: **no pongas modelos de razonamiento al principio de una cadena automática.** Gastan la respuesta entera pensando y devuelven vacío.

Hay un detalle que vale la pena anotar si haces lo mismo: algunos proveedores de pago exigen cabeceras propias además de la clave, y un cliente genérico compatible con OpenAI no las manda. Si recibes un error 400 con todo bien configurado, es por ahí.

Y otra lección de uso diario: **no metas un proxy o daemon en `127.0.0.1` delante del arnés principal cuando el proveedor de respaldo ya expone un endpoint compatible directo** (como `/anthropic`). Un daemon local caído o un puerto muerto (`127.0.0.1:3456` → `Connection refused`) deja paralizadas incluso las verificaciones de permisos y rompe sesiones interactivas; es más simple conmutar variables de entorno en un wrapper de proceso al arrancar.

## Transcripción: el cliente manda audios, no texto

Un cliente real no te escribe especificaciones. Te manda notas de voz de tres minutos por WhatsApp, y ahí dentro va la decisión que estabas esperando.

Un servicio de transcripción en local, en su contenedor, convierte esos audios a texto. A partir de ahí el texto entra al sistema como cualquier otra cosa: se registra la respuesta en el archivo de preguntas, y lo que cambia cómo funciona algo se escribe en la nota del proyecto.

Que sea local importa por dos razones: no mandas la voz de tus clientes a un servicio de terceros, y no pagas por minuto.

Un detalle que ahorra confusiones: los nombres propios salen mal. Antes de dar por buena una transcripción, cruza los nombres con los que ya existen en tus notas.

## El agente 24/7

La parte en construcción, y la más barata de todas: corre con modelos gratuitos a través del enrutador. Hace lo que no necesita que tú estés delante: el resumen de la mañana, recordatorios, guardar notas que mandas desde el celular.

El plan de modelos, en orden de preferencia: primero los gratuitos que ya están en la cadena, después la clave del ejecutor de pago que ya se usa para programar —sirve como API compatible con OpenAI—, y más adelante, si hace falta, una API barata por uso.

Dos cosas que aprendimos a la mala:

**No lo pongas a trabajar con la misma cuota que usas para programar.** Un agente encendido todo el día se come el tope mensual que necesitabas para el trabajo de verdad.

**Separa los perfiles por privacidad, no por confianza.** Lo que no lleva datos sensibles puede ir a modelos que entrenan con lo que reciben; lo personal y lo de clientes, no. Y eso se resuelve con dos perfiles distintos en el enrutador, no con recordárselo al agente cada vez.

## Si no tienes una torre

Casi todo esto tiene reemplazo, y ninguno es imprescindible:

| En la torre | Sin torre |
|---|---|
| Modelos gratuitos encadenados | El plan del ejecutor que ya pagas. Es lo que hace el sistema igual. |
| Transcripción de voz en local | Un servicio de transcripción por minuto, o la función de notas de voz del propio asistente. |
| Agente 24/7 | No hay reemplazo barato, y tampoco es el primer problema que tienes que resolver. |
| Panel y editor remoto | Tu máquina, sin más. |

**El orden que recomiendo:** primero el flujo del README, que no necesita nada de esto y es donde está casi todo el beneficio. Monta la torre solo cuando te encuentres diciendo "esto tendría que haber corrido anoche".

Y si vas a montarla, empieza por lo aburrido: que arranque sola tras un corte de luz y que algo la vigile. Un servidor que hay que levantar a mano es peor que no tenerlo, porque confías en él y no está.
