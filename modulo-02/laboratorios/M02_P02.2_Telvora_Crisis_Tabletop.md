# P02.2 — Telvora Crisis Tabletop
## Decisiones de ciberdefensa bajo incertidumbre

## 1. Objetivo

En esta práctica trabajarás como miembro del equipo de crisis de **Telvora Communications**.

El objetivo no es adivinar una respuesta única, sino **tomar decisiones defendibles con la información disponible en cada momento**, dejando constancia de:

- qué decides;
- qué evidencia sustenta la decisión;
- qué hipótesis manejas;
- qué riesgo tiene actuar;
- qué riesgo tiene no actuar;
- quién debe asumir o ejecutar la decisión;
- qué información necesitas a continuación.

La práctica se desarrolla mediante una aplicación web interactiva que irá mostrando nuevas **actualizaciones de situación** de forma progresiva.

---

## 2. Escenario inicial

**Martes, 09:00.**

El SOC de Telvora comunica:

- múltiples autenticaciones anómalas asociadas a una cuenta administrativa;
- varios endpoints presentan ejecución de PowerShell no habitual;
- un servidor de ficheros ha comenzado a generar un número anormal de escrituras;
- el EDR ha bloqueado un binario en dos equipos;
- todavía no existe evidencia suficiente para confirmar ransomware.

El Director de Operaciones pregunta:

> **¿Tenemos un incidente? ¿Debemos aislar sistemas?**

A partir de este momento deberás trabajar únicamente con la información que la aplicación vaya liberando.

---

## 3. Forma de trabajo

La práctica se realiza de forma **individual**.

En cada etapa recibirás una actualización de situación. Antes de acceder a la siguiente tendrás que registrar tu decisión en el **Decision Log**.

La aplicación no mostrará toda la narrativa de una vez. El instructor irá liberando nuevas actualizaciones durante la sesión.

No puedes utilizar información de fases futuras para justificar una decisión anterior.

---

## 4. Decision Log

En cada etapa debes completar:

```text
DECISIÓN
EVIDENCIA DISPONIBLE
HIPÓTESIS
RIESGO DE ACTUAR
RIESGO DE NO ACTUAR
RESPONSABLE
SIGUIENTE INFORMACIÓN NECESARIA
```

### DECISIÓN

Indica qué harías en ese momento.

Evita respuestas vagas como:

> "seguir investigando"

si no explicas qué acciones concretas se realizan mientras continúa la investigación.

### EVIDENCIA DISPONIBLE

Incluye únicamente hechos conocidos en ese momento.

Distingue entre:

- evidencia confirmada;
- indicios;
- hipótesis.

### HIPÓTESIS

Explica qué crees que puede estar ocurriendo sin presentar una hipótesis como si ya fuera un hecho demostrado.

### RIESGO DE ACTUAR

Describe qué impacto puede causar la propia medida:

- indisponibilidad;
- pérdida de productividad;
- interrupción de servicios;
- pérdida de evidencia;
- impacto sobre clientes;
- otros efectos relevantes.

### RIESGO DE NO ACTUAR

Describe qué puede ocurrir si retrasas o descartas la acción.

### RESPONSABLE

Indica qué rol debe:

- tomar la decisión;
- coordinarla;
- ejecutarla;
- o aceptar sus consecuencias.

No asumas que todas las decisiones corresponden al SOC o al CISO.

### SIGUIENTE INFORMACIÓN NECESARIA

Indica qué información concreta pedirías para reducir incertidumbre y mejorar la siguiente decisión.

---

## 5. Regla principal

> **Trabaja únicamente con la información disponible en la etapa actual.**

En una crisis real las decisiones se toman antes de conocer el desenlace.

Por este motivo, cuando pulses **Confirmar y bloquear decisión**, la respuesta quedará registrada y ya no podrá modificarse después de recibir nueva información.

---

## 6. Criterios para una buena decisión

No se busca necesariamente "la respuesta más técnica".

Una decisión de calidad debe ser:

- **defendible**, porque puede explicarse con la evidencia disponible;
- **proporcional**, porque la respuesta guarda relación con el riesgo observado;
- **trazable**, porque queda documentada;
- **consciente de la incertidumbre**, diferenciando hechos e hipótesis;
- **responsable**, indicando quién tiene autoridad para decidir o ejecutar;
- **revisable**, identificando qué nueva información podría hacer cambiar la decisión.

Puede existir más de una decisión válida si está correctamente justificada.

---

## 7. Aspectos que tendrás que considerar durante la práctica

A medida que evolucione la situación tendrás que razonar sobre cuestiones como:

- clasificación y escalado de un incidente;
- contención proporcional;
- compromiso de identidades privilegiadas;
- movimiento lateral;
- protección de copias de seguridad;
- continuidad de negocio;
- RTO y RPO;
- preservación de evidencias;
- comunicación interna y externa;
- participación de funciones técnicas, de negocio y de gobierno;
- posible impacto regulatorio;
- recuperación de servicios;
- riesgo residual.

La aplicación proporcionará los datos necesarios cuando corresponda. No es necesario anticipar acontecimientos futuros.

---

## 8. After Action Review

Al finalizar las actualizaciones de situación se habilitará un **After Action Review (AAR)**.

En ese momento sí podrás utilizar toda la información conocida durante el ejercicio.

Tendrás que preparar:

### Línea temporal

Reconstruye al menos diez hitos relevantes del incidente.

### Decisiones acertadas

Identifica tres decisiones que mantendrías y explica por qué fueron adecuadas con la información disponible en ese momento.

### Decisiones discutibles

Identifica dos decisiones que revisarías.

No basta con indicar que fueron "incorrectas": explica qué información, criterio o alternativa habría permitido decidir mejor.

### Información que faltó

Identifica al menos tres datos que habrían permitido reducir incertidumbre durante la respuesta.

### Controles preventivos

Propón al menos cinco controles que podrían reducir la probabilidad o el impacto de un incidente similar.

### Controles de detección

Propón al menos cinco capacidades de detección que habrían permitido descubrir antes la actividad o mejorar el conocimiento del alcance.

### Mejoras de continuidad

Propón al menos tres mejoras relacionadas con recuperación, backup, RTO, RPO o continuidad.

### Riesgo residual

Explica qué riesgo seguiría existiendo incluso después de implantar las mejoras propuestas.

---

## 9. Entregable

El entregable de la práctica queda registrado directamente en la aplicación y está formado por:

- las decisiones tomadas en cada actualización de situación;
- el Decision Log asociado a cada decisión;
- el After Action Review final.

No es necesario entregar un documento adicional salvo que el instructor lo indique.

---

## 10. Acceso a la aplicación

Las instrucciones de acceso están disponibles en:

[M02_P02.2_Acceso_Tabletop.md](M02_P02.2_Acceso_Tabletop.md)

Aplicación:

**https://tabletop.cloudsecurityinpractice.com**

El código de edición será facilitado por el instructor al comenzar la práctica.

---

## 11. Principios que debes conservar durante todo el ejercicio

- Una alerta no es una conclusión.
- Una hipótesis no es un hecho confirmado.
- No actuar también es una decisión y también tiene riesgo.
- Contener no significa necesariamente apagar todos los sistemas.
- La disponibilidad no es el único objetivo: también importan integridad, confidencialidad y evidencia.
- Un backup no garantiza recuperación si no puede restaurarse.
- RTO y RPO deben relacionarse con capacidades reales.
- Las decisiones técnicas pueden requerir aceptación o autorización de negocio.
- Una crisis debe gestionarse con la información disponible en ese momento, no con la que conoceremos después.
