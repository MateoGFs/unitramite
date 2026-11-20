# Evaluación del asistente

Pruebas realizadas en noviembre de 2026 con los 7 trámites verificados. Se pueden repetir con los comandos de la sección "Pruebas y evaluación" del README.

## Método

- **Preguntas de prueba:** cada trámite trae sus preguntas con respuesta conocida.
- **Preguntas ajenas:** 5 lejanas (capital de Francia, una receta...) y 5 cercanas a la universidad pero no cubiertas (becas, cambio de carrera, horario de la biblioteca...). El asistente debe rechazarlas.
- **Preguntas reales:** 6 escritas por compañeros que no conocían el contenido de los trámites, con lenguaje informal y errores de ortografía, más 8 casos difíciles.
- **Conversaciones:** preguntas de seguimiento ("¿y cuánto cuesta?"), cambio de tema y preguntas fuera de alcance.
- **Lectura manual:** además de contar aciertos, se leyó cada respuesta para comprobar que no afirmara nada ausente de los trámites.

## Resultados

| Prueba | Qué mide | Resultado |
|---|---|---|
| Recuperación | El trámite correcto sale en primer lugar | 32 de 37 (35 de 37 entre los dos primeros) |
| Respuestas de punta a punta | Responde con respaldo las preguntas de trámites y rechaza las ajenas | 47 de 48; la restante (sede de Tumaco) responde "sin información", lo cual es aceptable |
| Preguntas reales | Lenguaje informal y casos difíciles | 14 de 14 con el trámite correcto y sin errores; sin afirmaciones fuera de los trámites |
| Conversaciones | Preguntas de seguimiento y cambio de tema | 5 de 5 verificables correctas; la de Tumaco se revisó a mano |
| Intenciones de cada trámite | Cada pregunta que el trámite promete tiene respuesta | 40 de 41; la restante se eliminó |

**Calibración del umbral:** las preguntas de trámites obtuvieron similitudes de 0,635 a 0,81 (la mayoría sobre 0,70). Las lejanas llegaron a 0,57 y las cercanas a 0,66. Se eligió 0,60: descarta lo evidentemente ajeno sin perder preguntas legítimas, y las cercanas las rechaza la IA al leer el contenido.

## Problemas encontrados y corregidos

1. **Condiciones no mencionadas:** a un estudiante de octavo semestre que preguntaba por reservar cupo por servicio militar, la primera versión le daba los pasos sin condiciones, pero según el trámite ese motivo aplica a primer semestre o año. Se agregaron reglas al prompt y ahora indica la condición y recomienda confirmar con la dependencia.
2. **Situaciones particulares:** a "¿puedo pedirlo si estudio en Tumaco?" respondía "Sí" sin respaldo. Ahora dice que la información no especifica diferencias por sede.
3. **Preguntas sugeridas sin respuesta:** una pregunta que la propia app sugería (beneficios de un título técnico) no tenía respuesta en el trámite. Se creó una revisión automática de las intenciones y las sugerencias ahora son las preguntas de prueba comprobadas.
4. **Saturación del servicio de IA:** durante las pruebas hubo errores 503 y 504 de Gemini. Se agregaron reintentos, modelos de respaldo y un límite de tiempo; en las últimas corridas todas las preguntas se respondieron.
5. **Pérdida de contexto:** si fallaba la reformulación, las preguntas de seguimiento no se entendían. Ahora se une con la pregunta anterior como plan B.
6. **Enlaces con texto equivocado:** una respuesta enlazó "OCARA" a un formulario de recibos. Se ajustó el prompt; no se midió de forma sistemática.

## Límites de esta evaluación

- Son pocas preguntas (unas 100 en total) y las escribimos nosotros, así que los resultados son orientativos y no una medición estadística.
- Las respuestas de la IA pueden variar entre ejecuciones.
- La información de los trámites puede cambiar: conviene volver a verificarla.