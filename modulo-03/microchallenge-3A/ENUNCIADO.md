# Microchallenge 3.A — Architecture under pressure

## Objetivo

Analizar decisiones de arquitectura que pueden parecer razonables bajo presión operativa y detectar sus **trade-offs, trust assumptions y gaps de control**.

No se busca encontrar una única respuesta correcta. Se evalúa la capacidad de identificar qué riesgo introduce cada decisión, qué supuesto de confianza contiene y qué control o evidencia faltaría para aceptarla.

---

## Escenario

TELVORA está cerrando el diseño de una nueva arquitectura. El equipo de operaciones necesita mantener agilidad, pero varias decisiones se han tomado con poco tiempo para revisarlas.

Analiza las cinco decisiones siguientes.

### Decisión 1 — Administración desde CORP

> Para simplificar la operación, cualquier equipo de la red CORP podrá administrar por SSH los servidores de la DMZ.

### Decisión 2 — Acceso de proveedor

> Un proveedor externo necesita soporte urgente. Se propone darle conectividad VPN directa a CORP mientras dure la intervención.

### Decisión 3 — Sensor en un único punto

> Suricata se desplegará únicamente en el perímetro porque todo el tráfico importante termina pasando por allí.

### Decisión 4 — Exposición temporal en cloud

> Para acelerar una intervención, se abrirá SSH desde `0.0.0.0/0` hacia una instancia cloud y se cerrará cuando termine el trabajo.

### Decisión 5 — Logging centralizado

> Todos los sistemas enviarán logs a un repositorio central. Con ello se considera resuelta la necesidad de trazabilidad.

---

## Tarea

Para cada decisión completa la tabla:

| Decisión | Beneficio buscado | Trust assumption | Riesgo / gap | Control compensatorio o cambio | Evidencia necesaria |
|---|---|---|---|---|---|
| 1 | | | | | |
| 2 | | | | | |
| 3 | | | | | |
| 4 | | | | | |
| 5 | | | | | |

Después selecciona **una** de las cinco decisiones y redacta una alternativa que mantenga el objetivo operativo reduciendo el riesgo.

---

## Preguntas de cierre

1. ¿Qué decisiones dependen demasiado de la ubicación de red como señal de confianza?
2. ¿En cuáles aparece un problema de mínimo privilegio?
3. ¿Qué decisión puede fallar aunque el control técnico esté correctamente configurado?
4. ¿Dónde necesitarías telemetría para demostrar que el diseño funciona como se espera?
5. ¿Qué decisión documentarías mediante un ADR y qué trigger definirías para revisarla?

---

## Entregable

Un único documento con:

- la tabla completada;
- la alternativa propuesta para una de las decisiones;
- las respuestas breves a las cinco preguntas de cierre.
