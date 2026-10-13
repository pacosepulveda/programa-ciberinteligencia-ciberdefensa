# P04.3 — MQTT: Cleartext → Controlled Trust
## De tráfico IoT en claro a TLS/mTLS y autorización por tópico

**Duración:** 50–65 minutos  
**Máquinas de trabajo:** `KALI01` + `LINUX01`  
**Infraestructura de red:** `FW01`

## 1. Escenario

TELVORA recibe un prototipo IoT cuyo broker MQTT expone inicialmente:

```text
TCP/1883
sin TLS
acceso insuficientemente restringido
```

El argumento del equipo es: “está en una red interna”. Debes demostrar qué información queda expuesta y transformar el servicio en un diseño con canal cifrado, identidad de cliente y autorización por tópico.

P04.3 reutiliza la CA y los certificados emitidos en **P04.1**.

## 2. Topología

```text
TELVORA-RED                         TELVORA-DMZ
10.20.0.0/24                        10.30.0.0/24

KALI01                               LINUX01
10.20.0.10                           10.30.0.20
   │                                     ▲
   │              FW01                   │
   └────────────── routing ──────────────┘
```

`FW01` forma parte de la infraestructura del laboratorio porque RED y DMZ son redes separadas. No es una máquina de trabajo principal, pero debe estar encendida y enrutar el tráfico autorizado entre ambas zonas.

### Flujos necesarios

| Fase | Origen | Destino | Servicio | Estado esperado |
|---|---|---|---|---|
| 1 | KALI01 | LINUX01 | MQTT TCP/1883 | ALLOW temporal |
| 2 | KALI01 | LINUX01 | MQTTS TCP/8883 | ALLOW |
| 2 | KALI01 | LINUX01 | MQTT TCP/1883 | DENY/CLOSED |

No abras otros servicios únicamente para completar esta práctica.

## 3. Prerrequisitos criptográficos

Antes de comenzar comprueba que dispones del material generado en P04.1.

### En `LINUX01`

```text
/etc/mosquitto/certs/telvora-root-ca.crt
/etc/mosquitto/certs/mqtt.crt
/etc/mosquitto/certs/mqtt.key
```

### En `KALI01`

```text
~/m04/certs/telvora-root-ca.crt
~/m04/certs/sensor01.crt
~/m04/certs/sensor01.key
~/m04/certs/analyst01.crt
~/m04/certs/analyst01.key
```

Protege las claves privadas:

```bash
chmod 600 ~/m04/certs/*.key
```

Si el material se generó en otra máquina del Cyber Range, utiliza el mecanismo de transferencia indicado por el instructor. **No publiques private keys en Git.**

## 4. Fase 1 — estado inseguro

En `LINUX01`, revisa [`mosquitto/telvora-insecure.conf`](mosquitto/telvora-insecure.conf), instálalo en el directorio indicado por el instructor y reinicia Mosquitto.

Comprueba el listener:

```bash
sudo ss -lntp | grep 1883
```

Confirma que `FW01` permite temporalmente `KALI01 → LINUX01 TCP/1883`.

Desde `KALI01`, suscríbete a:

```text
telvora/site01/#
```

y publica mensajes en:

```text
telvora/site01/sensor/temperature
telvora/site01/sensor/power
telvora/site01/control/restart
```

No ejecutes ninguna acción real de reinicio: los mensajes son únicamente datos ficticios de laboratorio.

## 5. Captura en claro

Captura tráfico:

```bash
sudo tcpdump -i <INTERFAZ> -nn -s0 -w m04-mqtt-plaintext.pcap host 10.30.0.20 and port 1883
```

En Wireshark utiliza, cuando sea útil:

```text
mqtt
Follow → TCP Stream
```

Registra:

| Evidencia | Visible? | Riesgo |
|---|---|---|
| broker IP | | |
| username (si existe) | | |
| password (si existe) | | |
| topic | | |
| payload | | |
| control topic | | |

## 6. Fase 2 — controlled trust

El diseño final debe incorporar:

- TLS en TCP/8883;
- certificado de servidor `mqtt.telvora.test`;
- autenticación mediante certificado cliente;
- `allow_anonymous false`;
- identidad del certificado utilizada como usuario;
- ACL de mínimo privilegio;
- listener inseguro 1883 deshabilitado;
- regla de red que permita 8883 y deje de necesitar 1883.

Utiliza las plantillas:

- [`mosquitto/telvora-secure.template.conf`](mosquitto/telvora-secure.template.conf)
- [`mosquitto/telvora.acl.template`](mosquitto/telvora.acl.template)

Adapta las rutas a tu entorno y valida la sintaxis/configuración antes de considerar finalizada la fase.

## 7. Política de autorización

La identidad `sensor01` debe poder publicar únicamente en:

```text
telvora/site01/sensor/#
```

La identidad `analyst01` debe poder leer:

```text
telvora/site01/#
```

`sensor01` no debe poder publicar en:

```text
telvora/site01/control/#
```

La autenticación correcta del certificado **no implica** autorización para cualquier tópico.

## 8. Validación

Demuestra:

| Test | Expected | Actual | Evidence |
|---|---|---|---|
| listener 1883 | CLOSED | | |
| FW01 hacia 1883 | DENY / no necesario | | |
| FW01 hacia 8883 | ALLOW | | |
| client sin certificado | DENY | | |
| analyst01 subscribe | ALLOW | | |
| sensor01 publish telemetry | ALLOW | | |
| sensor01 publish control | DENY | | |
| passive capture payload | NOT VISIBLE | | |

Incluye al menos una **prueba positiva** y dos **pruebas negativas** en la evidencia final.

## 9. Segunda captura

```bash
sudo tcpdump -i <INTERFAZ> -nn -s0 -w m04-mqtt-tls.pcap host 10.30.0.20 and port 8883
```

Genera tráfico MQTT TLS y compara:

```text
m04-mqtt-plaintext.pcap
m04-mqtt-tls.pcap
```

No basta con afirmar que “ahora está cifrado”. Explica qué metadatos siguen siendo visibles y qué contenido deja de ser directamente observable.

## 10. Debrief

1. ¿Qué ha solucionado TLS?
2. ¿Qué no ha solucionado TLS?
3. ¿Qué aporta mTLS frente a TLS solo de servidor?
4. ¿Por qué sigue siendo necesaria la ACL después de autenticar al cliente?
5. ¿Qué ocurre si la clave privada legítima de `sensor01` es robada?
6. ¿Qué telemetría pierde un sensor de red cuando el payload queda cifrado?
7. ¿Qué logs debe producir el broker?
8. ¿Cómo rotarías certificados/credenciales en miles de dispositivos?
9. ¿Qué aporta cerrar 1883 también en el plano de red aunque Mosquitto ya no escuche en ese puerto?
10. ¿Dónde añadirías controles adicionales de red, endpoint o aplicación?

## Entregable

`mqtt-security-review.md` con:

- evidencia fase 1;
- cambios aplicados;
- evidencia de las reglas de flujo necesarias;
- evidencia fase 2;
- tabla de validación;
- comparación de PCAP;
- relación entre certificado, identidad MQTT y ACL;
- al menos tres riesgos residuales.
