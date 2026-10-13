# Módulo 4 — Ciberseguridad del Dato y Tecnologías Disruptivas

## Material del alumno

### Presentación

- [Carpeta de presentación](presentacion/)

> PDF previsto: `M4_Ciberseguridad_del_Dato.pdf`.

### Microchallenges

- [4.A — «Está cifrado, ¿está protegido?»](microchallenge-4A/ENUNCIADO.md)
- [4.B — OAuth/OIDC Security Review](microchallenge-4B/ENUNCIADO.md)

### Laboratorios

- [Entorno y visión general](laboratorios/README.md)
- [P04.1 — PKI & TLS Trust Investigation](laboratorios/P04.1_Telvora_PKI_TLS_Trust_Investigation/ENUNCIADO.md)
- [P04.2 — IAM Privilege & Identity Audit](laboratorios/P04.2_Telvora_IAM_Privilege_Identity_Audit/ENUNCIADO.md)
- [Micro-lab 4.C — Secret Exposure Drill](laboratorios/P04.C_Telvora_Secret_Exposure_Drill/ENUNCIADO.md)
- [P04.3 — MQTT: Cleartext → Controlled Trust](laboratorios/P04.3_Telvora_MQTT_Controlled_Trust/ENUNCIADO.md)

### Misión de consolidación

- [Mission 04 — Data & Identity Security Review](mission-04/ENUNCIADO.md)
- [Arquitectura CODG](mission-04/CODG_ARCHITECTURE.md)
- [Plantilla de informe](mission-04/REPORT_TEMPLATE.md)

## Recorrido práctico

```text
Microchallenge 4.A
      ↓
P04.1 · PKI + X.509 + confianza TLS
      │    └─ emite mqtt.telvora.test + sensor01 + analyst01
      ↓
Microchallenge 4.B
      ↓
P04.2 · identidad + privilegio efectivo + standing privilege
      ↓
Micro-lab 4.C · secretos + rotación/revocación + Git history
      ↓
P04.3 · MQTT en claro → TLS/mTLS + ACL
      │    └─ reutiliza certificados de P04.1
      ↓
Mission 04 · Data & Identity Security Review
```

P04.3 utiliza `KALI01` y `LINUX01` como máquinas de trabajo y `FW01` como infraestructura de routing/enforcement entre TELVORA-RED y TELVORA-DMZ. No requiere máquinas adicionales a las previstas en el Telvora Cyber Range.

El objetivo transversal es distinguir **cifrado, autenticación, autorización, confianza, gestión de claves/secretos y evidencia de validación**. Cada control debe relacionarse con un riesgo concreto y con el riesgo residual que permanece después de aplicarlo.
