# M03 — Arquitecturas de Ciberseguridad
## Laboratorios del módulo

**Programa:** Programa Avanzado de Ciberinteligencia y Ciberdefensa  
**Empresa ficticia:** Telvora Communications (TELVORA)  
**Entorno:** Telvora Cyber Range  
**Dominio de laboratorio:** `telvora.test`

En este módulo el objetivo es pasar del análisis de riesgo a la **implementación y validación de una arquitectura defensiva**.

## Laboratorios y archivos de partida

### P03.1 — Telvora Segmentation Lab

- [Enunciado](P03.1_Telvora_Segmentation_Lab/ENUNCIADO.md)
- [Matriz de validación T01–T06](P03.1_Telvora_Segmentation_Lab/MATRIZ_VALIDACION.csv)

### P03.2 — Telvora Network Detection Lab

- [Enunciado](P03.2_Telvora_Network_Detection_Lab/ENUNCIADO.md)
- [Regla Suricata de partida](P03.2_Telvora_Network_Detection_Lab/telvora_m03.rules)

### P03.3 — Telvora Cloud Architecture Review

- [Enunciado](P03.3_Telvora_Cloud_Architecture_Review/ENUNCIADO.md)
- [Terraform inicial bajo revisión](P03.3_Telvora_Cloud_Architecture_Review/main.tf)

La secuencia práctica es:

```text
necesidad de negocio
      ↓
zonas de seguridad
      ↓
política de comunicaciones
      ↓
reglas de firewall
      ↓
validación técnica
      ↓
telemetría IDS
      ↓
detección
      ↓
revisión de postura cloud
```

## Entorno de laboratorio

### Máquinas

| Máquina | RAM habitual | Uso |
|---|---:|---|
| `FW01` | 1 GB / 2 GB con Suricata | pfSense CE, routing, firewall e IDS |
| `KALI01` | 1.5 GB | validación desde zona RED |
| `LINUX01` | 1 GB | servicio situado en DMZ |
| `LABSERV01` | 1–2 GB | estación técnica en CORP y análisis IaC |

No es necesario mantener las cuatro encendidas simultáneamente.

## Topología

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
                           |
                     host físico / gestión
```

El equipo físico puede tener una interfaz en la red virtual CORP para acceder a la GUI de `FW01`.

Las redes deben ser **virtuales y aisladas**. No deben corresponder a redes corporativas o domésticas reales.

## Plan de direccionamiento

| Zona | Red | Gateway |
|---|---|---|
| RED | `10.20.0.0/24` | `10.20.0.1` |
| DMZ | `10.30.0.0/24` | `10.30.0.1` |
| CORP | `10.40.0.0/24` | `10.40.0.1` |

Hosts:

```text
KALI01      10.20.0.10
LINUX01     10.30.0.20
LABSERV01   10.40.0.30
```

La dirección del host físico en CORP puede variar.

## Perfil de 8 GB

### P03.1 — Fase RED

```text
FW01       1 GB
KALI01   1.5 GB
LINUX01    1 GB
----------------
Total    3.5 GB
```

Después se apaga `KALI01`.

### P03.1 — Fase CORP/DMZ

```text
FW01       1 GB
LINUX01    1 GB
LABSERV01  1 GB
----------------
Total      3 GB
```

### P03.2 — Suricata

`FW01` puede ampliarse temporalmente a 2 GB. No es necesario mantener todas las máquinas encendidas durante la configuración y análisis.

### P03.3

Solo:

```text
LABSERV01  2 GB
```

En un equipo de 16 GB pueden mantenerse más sistemas simultáneamente.

## Entregables del M03

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

- `main.tf` inicial;
- resultado Checkov inicial;
- `main.tf` corregido;
- resultado Checkov final;
- matriz multicloud;
- Architecture Review.

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
