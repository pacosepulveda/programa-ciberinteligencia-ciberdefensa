# Mission 04 — Data & Identity Security Review

**Duración estimada:** 60–90 minutos  
**Entregable:** máximo 3 páginas

## Contexto

El Architecture Board de TELVORA solicita revisar un nuevo servicio:

```text
Customer Operations Data Gateway (CODG)
```

CODG:

- recibe datos de clientes;
- almacena información operacional;
- expone un API;
- utiliza una service account;
- se conecta a un broker MQTT;
- integra una aplicación de proveedor;
- utiliza TLS;
- mantiene al menos un secreto estático;
- tiene logging parcial.

No se pide desplegar CODG. Debes revisar los artefactos incluidos y producir una decisión defendible basada en evidencia.

## Artefactos

- [`CODG_ARCHITECTURE.md`](CODG_ARCHITECTURE.md)
- [`artifacts/data-inventory.csv`](artifacts/data-inventory.csv)
- [`artifacts/identity-review.csv`](artifacts/identity-review.csv)
- [`artifacts/tls-summary.txt`](artifacts/tls-summary.txt)
- [`artifacts/secrets-review.txt`](artifacts/secrets-review.txt)
- [`artifacts/mqtt-config-review.conf`](artifacts/mqtt-config-review.conf)

## 1. Data classification

Clasifica al menos tres conjuntos de datos:

| Data | Classification | CIA priority | Retention concern | Main threat |
|---|---|---|---|---|
| | | | | |

## 2. Top 5 risk scenarios

Utiliza el formato:

```text
Threat actor/event
exploits
weakness
on
asset/data
causing
business/security impact
```

## 3. Identity findings

Mínimo tres findings. Distingue autenticación, autorización, privilegio permanente, identidad de workload y acceso de terceros.

## 4. Crypto/key/certificate findings

Mínimo dos. No consideres “usa TLS” como evidencia suficiente por sí sola.

## 5. Secret-management findings

Mínimo dos. Incluye lifecycle y respuesta si un secreto ya estuvo expuesto.

## 6. MQTT/IoT findings

Mínimo dos. Distingue confidencialidad del canal, identidad del dispositivo y autorización por topic.

## 7. Cinco controles priorizados

Para cada control:

```text
Risk reduced:
Control:
Owner:
Validation evidence:
Residual risk:
```

## 8. Autoevaluación

Antes de entregar, comprueba que no has:

- confundido cifrado con control de acceso;
- confundido AuthN con AuthZ;
- supuesto que MFA elimina token theft;
- recomendado secretos estáticos cuando podría utilizarse identidad de workload;
- ignorado rotation/revocation;
- propuesto un control sin evidencia de validación;
- omitido riesgo residual.

Utiliza [`REPORT_TEMPLATE.md`](REPORT_TEMPLATE.md) si deseas una estructura de entrega.
