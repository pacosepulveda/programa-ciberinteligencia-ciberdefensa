# Mission 03 — Architecture Defence Pack

## Contexto

TELVORA debe aprobar la arquitectura antes de ampliar el entorno con nuevos servicios y dependencias cloud.

La dirección técnica no quiere recibir únicamente un diagrama. Necesita un paquete breve que permita responder a estas preguntas:

- ¿qué zonas y trust boundaries existen?;
- ¿qué comunicaciones están permitidas y cuáles deben estar prohibidas?;
- ¿qué decisiones de arquitectura se han tomado y por qué?;
- ¿qué controles aplican cada decisión?;
- ¿qué telemetría permite validar el diseño?;
- ¿qué riesgos residuales siguen abiertos?;
- ¿cómo se demuestra que la arquitectura funciona como se afirma?

Tu misión es preparar ese **Architecture Defence Pack** reutilizando la evidencia obtenida en P03.1, P03.2 y P03.3.

---

## 1. Arquitectura base

Parte del Telvora Cyber Range:

```text
RED        10.20.0.0/24
DMZ        10.30.0.0/24
CORP       10.40.0.0/24

KALI01      10.20.0.10
FW01        10.20.0.1 / 10.30.0.1 / 10.40.0.1
LINUX01     10.30.0.20
LABSERV01   10.40.0.30
```

Añade al modelo una pequeña carga cloud representada por los recursos revisados en P03.3. No es necesario desplegarla.

---

## 2. Diagrama y trust boundaries

Crea un diagrama sencillo que muestre como mínimo:

- RED;
- DMZ;
- CORP;
- FW01;
- LINUX01;
- LABSERV01;
- la carga cloud revisada en P03.3;
- los principales trust boundaries;
- los puntos donde existe enforcement o telemetría.

El diagrama puede realizarse con la herramienta que prefieras o mediante un esquema claro en Markdown.

No se evalúa la calidad artística. Se evalúa que el modelo permita razonar sobre confianza, flujos y controles.

---

## 3. Matriz de flujos

Utiliza `MATRIZ_FLUJOS.csv` como punto de partida.

Documenta **al menos diez flujos relevantes**. Deben existir como mínimo tres flujos explícitamente prohibidos.

Para cada flujo indica:

- origen;
- destino;
- servicio/puerto;
- decisión `ALLOW` o `DENY`;
- justificación;
- control de enforcement;
- telemetría o evidencia esperada.

Incluye obligatoriamente los seis flujos validados en P03.1.

---

## 4. Architecture Decision Records

Documenta **tres decisiones de arquitectura** utilizando `ADR_TEMPLATE.md`.

Cada ADR debe incluir:

- decisión y estado;
- contexto;
- escenarios de riesgo que pretende tratar;
- supuestos;
- opciones consideradas;
- justificación y trade-offs;
- controles necesarios;
- telemetría;
- riesgos residuales;
- método de validación;
- trigger o fecha de revisión.

Las decisiones deben estar relacionadas con la arquitectura trabajada en el módulo. Ejemplos válidos:

- exposición de servicios en DMZ;
- administración desde CORP;
- acceso de terceros;
- ubicación de sensores;
- restricciones de acceso cloud;
- logging y retención.

No copies estos ejemplos como respuesta automática: selecciona tres decisiones que puedas defender con evidencia.

---

## 5. Attack path

Describe un posible camino de ataque desde una zona de menor confianza hacia un activo de mayor valor.

Debes identificar:

1. punto de entrada;
2. salto o dependencia intermedia;
3. trust boundary atravesado;
4. control que debería impedir o detectar el avance;
5. evidencia que demostraría el funcionamiento del control.

No es necesario explotar sistemas ni desarrollar malware.

---

## 6. Controles y telemetría

Construye una tabla que relacione arquitectura, controles y evidencia:

| Riesgo o decisión | Control | Dónde actúa | Telemetría | Evidencia de validación |
|---|---|---|---|---|
| | | | | |

Debes incluir, cuando corresponda:

- firewalling stateful;
- segmentación;
- IDS/Suricata;
- logging;
- configuración cloud/IaC;
- policy-as-code o revisión automática.

---

## 7. Riesgo residual

Identifica **tres riesgos residuales** que sigan existiendo incluso después de aplicar los controles.

Para cada uno explica:

- activo afectado;
- escenario de riesgo;
- controles existentes;
- por qué el riesgo no desaparece completamente;
- qué evento obligaría a revisar la decisión.

---

## 8. Validación

La arquitectura no se considera defendida porque el diagrama parezca correcto.

Define cómo demostrarías que funciona.

Incluye como mínimo:

- resultados de T01–T06 de P03.1;
- una alerta controlada de P03.2;
- correlación firewall/IDS;
- resultado inicial y posterior a la remediación de P03.3;
- una prueba negativa que demuestre un flujo prohibido;
- una prueba positiva que demuestre un flujo permitido.

Si alguna evidencia no está disponible, indica exactamente qué prueba ejecutarías para obtenerla.

---

## 9. Entregable

Entrega un único **Architecture Defence Pack** siguiendo `ARCHITECTURE_DEFENCE_PACK_TEMPLATE.md` y adjunta, cuando proceda, las evidencias generadas en los laboratorios.

El paquete debe permitir que otra persona comprenda y defienda la arquitectura sin depender de explicaciones orales adicionales.
