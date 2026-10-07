# M03 — Arquitecturas de Ciberseguridad
## Laboratorios del módulo

**Programa:** Programa Avanzado de Ciberinteligencia y Ciberdefensa  
**Empresa ficticia:** Telvora Communications (TELVORA)  
**Entorno:** Telvora Cyber Range  
**Dominio de laboratorio:** `telvora.test`

En este módulo el objetivo es pasar del análisis de riesgo a la **implementación y validación de una arquitectura defensiva**.

## Laboratorios y archivos de partida

### P03.0 — Telvora Host Microsegmentation & Evidence Lab

- [Enunciado](P03.0_Telvora_Host_Microsegmentation/ENUNCIADO.md)
- [Script de validación de flujos](P03.0_Telvora_Host_Microsegmentation/validate_flows.sh)
- [Matriz de validación](P03.0_Telvora_Host_Microsegmentation/MATRIZ_VALIDACION.csv)

### P03.1 — Telvora Segmentation Lab

- [Enunciado](P03.1_Telvora_Segmentation_Lab/ENUNCIADO.md)
- [Matriz de validación T01–T06](P03.1_Telvora_Segmentation_Lab/MATRIZ_VALIDACION.csv)

### P03.2 — Telvora Network Detection Lab

- [Enunciado](P03.2_Telvora_Network_Detection_Lab/ENUNCIADO.md)
- [Regla Suricata de partida](P03.2_Telvora_Network_Detection_Lab/telvora_m03.rules)

### P03.3 — Telvora Cloud Architecture Review

- [Enunciado](P03.3_Telvora_Cloud_Architecture_Review/ENUNCIADO.md)
- [Terraform inicial bajo revisión](P03.3_Telvora_Cloud_Architecture_Review/main.tf)
- [Guardrails de arquitectura](P03.3_Telvora_Cloud_Architecture_Review/TELVORA_GUARDRAILS.md)
- [Checker policy-as-code](P03.3_Telvora_Cloud_Architecture_Review/iac_guardrails.py)

## Relación con los bloques del módulo

| Laboratorio | Conceptos principales |
|---|---|
| P03.0 | microsegmentación · management plane · default deny · telemetría · validación positiva/negativa |
| P03.1 | segmentación por intención · firewall stateful · mínimo privilegio · evidencia de flujos |
| P03.2 | IDS/IPS · ubicación de sensores · alertas · correlación · tuning |
| P03.3 | responsabilidad compartida · IaC · policy-as-code · guardrails · DevSecOps · riesgo residual |

La secuencia conceptual es:

```text
intención de seguridad
      ↓
política explícita
      ↓
enforcement
      ↓
telemetría
      ↓
validación
      ↓
evidencia
      ↓
riesgo residual
```

## Entorno de laboratorio

### Máquinas

| Máquina | RAM habitual | Uso |
|---|---:|---|
| `KALI01` | 1.5 GB | estación de validación, análisis y revisión IaC |
| `LINUX01` | 1 GB | servidor Linux y workload protegido |
| `FW01` | 1 GB / 2 GB con Suricata | pfSense CE, routing, firewall e IDS |
| `LABSERV01` | 1–2 GB | estación técnica en CORP |

No es necesario mantener todas las máquinas encendidas simultáneamente.

## Perfiles por práctica

### P03.0

```text
KALI01
LINUX01
```

Red de referencia:

```text
10.20.0.0/24
KALI01   10.20.0.10
LINUX01  10.20.0.20
```

### P03.1 y P03.2

Utilizan la topología segmentada del Telvora Cyber Range:

```text
                    TELVORA CYBER RANGE

              RED
            10.20.0.0/24
                  |
           KALI01 .10
                  |
              10.20.0.1
              +---------+
              |         |
              |  FW01   |
              | pfSense |
              |         |
              +---------+
         10.30.0.1     10.40.0.1
             |              |
             |              |
          DMZ |              | CORP
   10.30.0.0/24              10.40.0.0/24
             |              |
        LINUX01 .20      LABSERV01 .30
```

Plan de direccionamiento:

| Zona | Red | Gateway |
|---|---|---|
| RED | `10.20.0.0/24` | `10.20.0.1` |
| DMZ | `10.30.0.0/24` | `10.30.0.1` |
| CORP | `10.40.0.0/24` | `10.40.0.1` |

### P03.3

```text
KALI01
```

No requiere desplegar recursos cloud. La revisión se realiza sobre IaC y guardrails locales.

## Entregables del M03

### P03.0

- política de comunicaciones;
- reglas de microsegmentación;
- matriz antes/después;
- prueba positiva;
- prueba negativa;
- evidencia de logging;
- Architecture Validation Brief.

### P03.1

- tabla de aliases;
- reglas aplicadas;
- matriz de validación T01–T06;
- evidencias de firewall;
- respuestas de arquitectura.

### P03.2

- configuración básica Suricata;
- regla local 1000001;
- segunda regla propia;
- evidencias de alertas;
- correlación firewall/IDS;
- Detection Brief.

### P03.3

- revisión manual inicial;
- resultado de guardrails inicial;
- `main.tf` corregido;
- resultado final;
- análisis de policy-as-code y pipeline;
- Architecture Review Brief.

## Principios del módulo

- Una arquitectura no está validada hasta probar sus flujos.
- `Allow` y `alert` no son conceptos contradictorios.
- Segmentación reduce alcance; no elimina vulnerabilidades.
- Una DMZ no convierte un servidor en seguro.
- Zero Trust no significa “poner más firewalls”.
- El proveedor cloud no configura por ti todos los controles del cliente.
- IaC permite revisar seguridad antes del despliegue.
- Compliance no equivale a seguridad.
- Un check automático es evidencia, no una decisión.
