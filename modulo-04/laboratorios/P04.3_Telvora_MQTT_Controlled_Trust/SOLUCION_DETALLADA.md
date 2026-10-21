# P04.3 — MQTT: Cleartext → Controlled Trust
## Solución detallada paso a paso

> Esta guía parte de las máquinas apagadas y de la topología TELVORA ya construida en M03.
> Se asume que P04.1 ya generó la CA y los certificados `mqtt.telvora.test`, `sensor01` y `analyst01`.

---

# 1. Objetivo

El laboratorio demuestra tres ideas distintas:

1. **MQTT sin TLS expone contenido y tópicos en claro.**
2. **TLS/mTLS protege el canal y autentica identidades.**
3. **La autenticación no sustituye a la autorización: seguimos necesitando ACL.**

La evolución será:

```text
MQTT/1883
sin TLS
sin identidad fuerte
sin ACL útil
        ↓
MQTTS/8883
TLS + certificado servidor
mTLS + certificados cliente
ACL por identidad
1883 cerrado
```

---

# 2. Topología

Usaremos:

```text
TELVORA-RED                         TELVORA-DMZ
10.20.0.0/24                        10.30.0.0/24

KALI01                               LINUX01
10.20.0.10                           10.30.0.20
   │                                     ▲
   │              FW01                   │
   └────────────── routing ──────────────┘
```

Interfaces de FW01:

```text
FW01 RED = 10.20.0.254
FW01 DMZ = 10.30.0.1
```

Importante:

```text
10.20.0.1
```

puede seguir siendo el gateway/NAT heredado de M01/M02, pero no es una interfaz de FW01.

---

# 3. Encender las máquinas

Arrancamos:

```text
FW01
LINUX01
KALI01
```

No necesitamos AD01 ni LABSERV01.

---

# 4. Comprobar la red antes de tocar MQTT

## En LINUX01

```bash
ip -br a
ip route
```

Esperamos:

```text
10.30.0.20/24
default via 10.30.0.1
```

## En KALI01

```bash
ip -br a
ip route get 10.30.0.20
```

Debe aparecer:

```text
via 10.20.0.254
```

Si no aparece:

```bash
sudo ip route replace 10.30.0.0/24 via 10.20.0.254
```

---

# 5. Redes virtuales según hipervisor

## VMware Workstation

```text
KALI01   → VMnet1
LINUX01  → VMnet2
FW01 RED → VMnet1
FW01 DMZ → VMnet2
```

## VirtualBox

```text
KALI01   → TELVORA-M01
LINUX01  → TELVORA-DMZ
FW01 RED → TELVORA-M01
FW01 DMZ → TELVORA-DMZ
```

## KVM/libvirt

```text
KALI01   → telvora-lab
LINUX01  → telvora-dmz
FW01 RED → telvora-lab
FW01 DMZ → telvora-dmz
```

---

# 6. Comprobar Mosquitto

En LINUX01:

```bash
mosquitto -h | head
mosquitto_pub --help | head
systemctl status mosquitto
```

La práctica utiliza:

```text
broker      → LINUX01
publisher   → KALI01
subscriber  → KALI01
```

---

# 7. Preparar certificados

En LINUX01 deben estar:

```text
/etc/mosquitto/certs/telvora-root-ca.crt
/etc/mosquitto/certs/mqtt.crt
/etc/mosquitto/certs/mqtt.key
```

En KALI01:

```text
~/m04/certs/telvora-root-ca.crt
~/m04/certs/sensor01.crt
~/m04/certs/sensor01.key
~/m04/certs/analyst01.crt
~/m04/certs/analyst01.key
```

Protegemos las claves:

```bash
chmod 600 ~/m04/certs/*.key
```

En LINUX01:

```bash
sudo chown mosquitto:mosquitto /etc/mosquitto/certs/mqtt.key
sudo chmod 600 /etc/mosquitto/certs/mqtt.key
sudo chmod 644 /etc/mosquitto/certs/*.crt
```

---

# 8. Fase 1 — MQTT inseguro

Creamos en LINUX01:

```bash
sudo tee /etc/mosquitto/conf.d/telvora.conf >/dev/null <<'EOF'
listener 1883 0.0.0.0
allow_anonymous true
persistence false
EOF
```

Reiniciamos:

```bash
sudo systemctl restart mosquitto
sudo systemctl status mosquitto --no-pager
sudo ss -lntp | grep 1883
```

Esperamos un listener en `0.0.0.0:1883`.

---

# 9. Permitir temporalmente 1883 en FW01

Desde KALI01 accedemos a:

```text
https://10.20.0.254
```

En:

```text
Firewall → Rules → RED
```

creamos:

```text
Action       Pass
Protocol     TCP
Source       10.20.0.10
Destination  10.30.0.20
Port         1883
Log          Sí
Description  P04.3 TEMP - MQTT insecure
```

La regla debe quedar antes de bloqueos generales RED → DMZ.

---

# 10. Validar conectividad

Desde KALI01:

```bash
nc -vz -w 3 10.30.0.20 1883
```

Debe conectar.

---

# 11. Probar MQTT en claro

Terminal 1:

```bash
mosquitto_sub -h 10.30.0.20 -p 1883 -t 'telvora/site01/#' -v
```

Terminal 2:

```bash
mosquitto_pub -h 10.30.0.20 -p 1883 -t 'telvora/site01/sensor/temperature' -m '23.7'
mosquitto_pub -h 10.30.0.20 -p 1883 -t 'telvora/site01/sensor/power' -m '412W'
mosquitto_pub -h 10.30.0.20 -p 1883 -t 'telvora/site01/control/restart' -m 'restart-request'
```

El subscriber recibe los tres mensajes.

---

# 12. Capturar tráfico en claro

Identificamos la interfaz:

```bash
ip -br a
```

Suponiendo `eth0`:

```bash
sudo tcpdump -i eth0 -nn -s0 -w ~/m04-mqtt-plaintext.pcap host 10.30.0.20 and port 1883
```

Generamos tráfico y detenemos con `Ctrl+C`.

Abrimos:

```bash
wireshark ~/m04-mqtt-plaintext.pcap
```

Filtro:

```text
mqtt
```

También puede usarse:

```text
Follow → TCP Stream
```

En esta fase son observables directamente los tópicos y payloads MQTT.

---

# 13. Crear ACL para la fase segura

En LINUX01:

```bash
sudo tee /etc/mosquitto/telvora.acl >/dev/null <<'EOF'
user sensor01
topic write telvora/site01/sensor/#

user analyst01
topic read telvora/site01/#
EOF
```

La política queda así:

```text
sensor01  → solo publica en sensor/#
analyst01 → solo lee site01/#
```

---

# 14. Configurar TLS/mTLS

Sustituimos la configuración:

```bash
sudo tee /etc/mosquitto/conf.d/telvora.conf >/dev/null <<'EOF'
listener 8883 0.0.0.0

cafile /etc/mosquitto/certs/telvora-root-ca.crt
certfile /etc/mosquitto/certs/mqtt.crt
keyfile /etc/mosquitto/certs/mqtt.key

tls_version tlsv1.2
require_certificate true
use_identity_as_username true
allow_anonymous false
acl_file /etc/mosquitto/telvora.acl
persistence false
EOF
```

En Mosquitto actual, `tls_version tlsv1.2` establece la versión mínima. TLS 1.3 puede negociarse si cliente y servidor lo soportan.

Reiniciamos:

```bash
sudo systemctl restart mosquitto
sudo systemctl status mosquitto --no-pager
```

Si falla:

```bash
sudo journalctl -u mosquitto -n 50 --no-pager
```

---

# 15. Comprobar listeners

```bash
sudo ss -lntp | grep -E '1883|8883'
```

Esperamos:

```text
8883 LISTEN
1883 no aparece
```

---

# 16. Modificar FW01

Deshabilitamos o eliminamos la regla temporal de 1883.

Creamos:

```text
Action       Pass
Protocol     TCP
Source       10.20.0.10
Destination  10.30.0.20
Port         8883
Log          Sí
Description  P04.3 - MQTTS
```

Aplicamos cambios.

---

# 17. Validar el plano de red

Desde KALI01:

```bash
nc -vz -w 3 10.30.0.20 8883
```

Debe funcionar.

Después:

```bash
nc -vz -w 3 10.30.0.20 1883
```

Debe fallar.

---

# 18. Prueba negativa — cliente sin certificado

```bash
mosquitto_sub \
  -h 10.30.0.20 \
  -p 8883 \
  --cafile ~/m04/certs/telvora-root-ca.crt \
  -t 'telvora/site01/#'
```

Debe fallar porque `require_certificate true` exige certificado cliente.

---

# 19. Resolver el hostname del broker

En KALI01:

```bash
echo '10.30.0.20 mqtt.telvora.test' | sudo tee -a /etc/hosts
getent hosts mqtt.telvora.test
```

---

# 20. Conectar analyst01

```bash
mosquitto_sub \
  -h mqtt.telvora.test \
  -p 8883 \
  --cafile ~/m04/certs/telvora-root-ca.crt \
  --cert ~/m04/certs/analyst01.crt \
  --key ~/m04/certs/analyst01.key \
  -t 'telvora/site01/#' \
  -v
```

Debe conectar.

---

# 21. Publicar como sensor01

```bash
mosquitto_pub \
  -h mqtt.telvora.test \
  -p 8883 \
  --cafile ~/m04/certs/telvora-root-ca.crt \
  --cert ~/m04/certs/sensor01.crt \
  --key ~/m04/certs/sensor01.key \
  -t 'telvora/site01/sensor/temperature' \
  -m '22.8'
```

Debe funcionar y `analyst01` debe ver el mensaje.

---

# 22. Prueba negativa — sensor01 intenta publicar control

```bash
mosquitto_pub \
  -h mqtt.telvora.test \
  -p 8883 \
  --cafile ~/m04/certs/telvora-root-ca.crt \
  --cert ~/m04/certs/sensor01.crt \
  --key ~/m04/certs/sensor01.key \
  -t 'telvora/site01/control/restart' \
  -m 'restart-request' \
  -d
```

La autenticación TLS puede ser correcta, pero la operación debe ser rechazada por la ACL.

Concepto:

```text
AuthN correcta ≠ AuthZ ilimitada
```

---

# 23. Revisar logs del broker

En LINUX01:

```bash
sudo journalctl -u mosquitto -n 100 --no-pager
```

Buscamos conexiones, errores TLS, identidades y denegaciones por ACL.

---

# 24. Captura TLS

En KALI01:

```bash
sudo tcpdump -i eth0 -nn -s0 -w ~/m04-mqtt-tls.pcap host 10.30.0.20 and port 8883
```

Generamos tráfico y detenemos con `Ctrl+C`.

Comparamos:

```text
m04-mqtt-plaintext.pcap
m04-mqtt-tls.pcap
```

Con TLS siguen siendo visibles metadatos como IPs, puertos, tamaños y tiempos, pero el topic y payload MQTT dejan de ser directamente observables.

---

# 25. Verificar TLS negociado

```bash
openssl s_client \
  -connect mqtt.telvora.test:8883 \
  -CAfile ~/m04/certs/telvora-root-ca.crt \
  -cert ~/m04/certs/sensor01.crt \
  -key ~/m04/certs/sensor01.key
```

Registramos la versión negociada, por ejemplo TLS 1.3 o TLS 1.2 según el software disponible.

---

# 26. Matriz final

| Test | Expected | Resultado esperado |
|---|---|---|
| listener 1883 | CLOSED | PASS |
| FW01 hacia 1883 | DENY / no necesario | PASS |
| FW01 hacia 8883 | ALLOW | PASS |
| client sin certificado | DENY | PASS |
| analyst01 subscribe | ALLOW | PASS |
| sensor01 publish telemetry | ALLOW | PASS |
| sensor01 publish control | DENY | PASS |
| passive capture payload | NOT VISIBLE | PASS |

---

# 27. Relación entre certificado, identidad y ACL

```text
Telvora Root CA
      ↓
firma sensor01.crt
      ↓
CN=sensor01
      ↓
mTLS valida identidad
      ↓
Mosquitto usa CN como username
      ↓
ACL aplica:
user sensor01
      ↓
solo sensor/#
```

Tenemos tres controles distintos:

```text
TLS  → protege el canal
mTLS → autentica cliente
ACL  → autoriza acciones
```

---

# 28. Debrief resuelto

## ¿Qué ha solucionado TLS?

Confidencialidad e integridad en tránsito y autenticación del servidor.

## ¿Qué no ha solucionado TLS?

No corrige ACL, permisos excesivos, endpoints comprometidos, malware, robo de claves privadas ni errores de aplicación.

## ¿Qué aporta mTLS?

El broker también valida criptográficamente al cliente.

## ¿Por qué sigue siendo necesaria la ACL?

Porque autenticar responde “quién eres”; autorizar responde “qué puedes hacer”.

## ¿Qué ocurre si roban `sensor01.key`?

La identidad puede ser suplantada mientras el certificado siga siendo aceptado. Hay que revocar/reemitir, investigar uso y sustituir el material.

## ¿Qué pierde un sensor de red con TLS?

Visibilidad directa del payload y topics MQTT, aunque conserva metadata de red/TLS.

## ¿Qué logs debe producir el broker?

Conexiones, desconexiones, errores TLS, identidades, fallos de certificado, denegaciones ACL, cambios administrativos y eventos relevantes.

## ¿Cómo rotar miles de certificados?

Mediante lifecycle automatizado: enrolment, emisión, distribución, renovación, revocación y baja.

## ¿Por qué cerrar 1883 también en firewall?

Defensa en profundidad: evita que una futura mala configuración de Mosquitto vuelva a exponer MQTT inseguro.

---

# 29. Riesgos residuales

- robo de claves privadas;
- compromiso de un cliente legítimo;
- disponibilidad/DoS;
- problemas de lifecycle y revocación;
- errores de autorización futura.

---

# 30. Estado final

```text
KALI01 10.20.0.10
        │
        │ TCP/8883
        ▼
FW01 RED 10.20.0.254
FW01 DMZ 10.30.0.1
        │
        ▼
LINUX01 10.30.0.20
Mosquitto 8883
TLS/mTLS
ACL

TCP/1883 CLOSED / DENY
```

La conclusión fundamental es:

> **Cifrar no es autenticar. Autenticar no es autorizar. Y ninguna de esas capas elimina la necesidad de segmentación, monitorización y gobierno del ciclo de vida.**
