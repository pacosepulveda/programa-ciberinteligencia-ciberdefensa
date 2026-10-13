# M04 — Laboratorios

## Entorno

Los laboratorios reutilizan exclusivamente las máquinas previstas en el **Telvora Cyber Range**. No es necesario encender todas simultáneamente.

| Práctica | Máquinas principales | Infraestructura adicional | Objetivo |
|---|---|---|---|
| P04.1 | KALI01 o LINUX01 | — | PKI, X.509, SAN, cadena de confianza, diagnóstico TLS y certificados para P04.3 |
| P04.2 | AD01 o paquete de evidencias | — | privilegios directos/indirectos, cuentas obsoletas, service accounts y standing privilege |
| Micro-lab 4.C | KALI01 | — | secretos en árbol Git e historial, impacto, rotación/revocación y prevención |
| P04.3 | KALI01 + LINUX01 | FW01 | MQTT inseguro, captura, TLS/mTLS, autenticación, ACL y validación de flujos |

## Direccionamiento de referencia

```text
FW01 RED   10.20.0.1
FW01 DMZ   10.30.0.1

KALI01     10.20.0.10
LINUX01    10.30.0.20
AD01       10.40.0.10
```

Adapta las direcciones únicamente si el instructor indica que tu entorno utiliza otras.

## Dependencia entre P04.1 y P04.3

P04.1 genera una CA y cuatro identidades de laboratorio:

```text
portal.telvora.test
mqtt.telvora.test
sensor01
analyst01
```

Los tres últimos artefactos se reutilizan en P04.3:

```text
mqtt.telvora.test → certificado de servidor del broker
sensor01          → cliente autorizado a publicar telemetría
analyst01         → cliente autorizado a leer telemetría
```

No publiques claves privadas en Git.

## Red durante P04.3

`KALI01` está en TELVORA-RED y `LINUX01` en TELVORA-DMZ. Por tanto, `FW01` debe estar encendido.

La práctica utiliza:

```text
Fase 1: TCP/1883 permitido temporalmente
Fase 2: TCP/8883 permitido
Final:  TCP/1883 cerrado/no permitido
```

## Principios

- Data security no equivale a cifrado.
- Cifrar no equivale a autenticar.
- Autenticar no equivale a autorizar.
- Un certificado correctamente firmado no es automáticamente confiable para cualquier cliente o identidad.
- La clave privada de una CA compromete la confianza de los certificados emitidos por ella.
- El privilegio permanente aumenta exposición.
- Eliminar un secreto de la última versión de un repositorio no revoca la credencial ni elimina necesariamente su historial.
- TLS protege el canal, pero no corrige ACL, lógica de aplicación ni compromiso de identidades legítimas.
- Una arquitectura se valida con pruebas positivas, negativas y evidencia reproducible.
