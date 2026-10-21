# P04.1 — PKI & TLS Trust Investigation
## Certificados, SAN, cadena de confianza, diagnóstico TLS y material de identidad para MQTT

**Máquina de trabajo:** `KALI01` o `LINUX01`  
**Internet:** no requerido

## 1. Escenario

TELVORA necesita una PKI interna mínima para dos necesidades del laboratorio:

1. investigar confianza e identidad TLS con un servicio web ficticio;
2. emitir las identidades criptográficas que se reutilizarán en **P04.3** para proteger MQTT mediante mTLS.

La jerarquía de laboratorio será:

```text
Telvora Training Root CA
│
├── portal.telvora.test       serverAuth · diagnóstico TLS
├── mqtt.telvora.test         serverAuth · broker MQTT
├── sensor01                  clientAuth · publicador MQTT
└── analyst01                 clientAuth · suscriptor MQTT
```

> Todas las claves y certificados son exclusivamente de laboratorio. No reutilices esta CA ni sus claves fuera del Telvora Cyber Range.

El objetivo no es desplegar una PKI corporativa completa. Debes comprender qué valida X.509, qué aporta TLS, cómo se establece confianza y por qué una firma criptográfica correcta no implica por sí sola que un certificado sea apropiado para una identidad o servicio concreto.

## 2. Directorio de trabajo

Crea la estructura de trabajo y comprueba la versión de OpenSSL:

```bash
mkdir -p ~/labs/m04/pki/{ca,portal,mqtt,clients,evidence}
cd ~/labs/m04/pki
openssl version
```

Registra la versión de OpenSSL utilizada.

## 3. CA de laboratorio

Crea una clave privada RSA de 3072 bits para la CA:

```bash
openssl genrsa -out ca/telvora-root-ca.key 3072
chmod 600 ca/telvora-root-ca.key
```

Genera un certificado raíz autofirmado con:

```text
CN=Telvora Training Root CA
O=Telvora Communications
```

Puedes utilizar:

```bash
openssl req -x509 -new -sha256 \
  -key ca/telvora-root-ca.key \
  -days 3650 \
  -out ca/telvora-root-ca.crt \
  -subj "/O=Telvora Communications/CN=Telvora Training Root CA"
```

Comprueba el material generado:

```bash
openssl x509 -in ca/telvora-root-ca.crt -noout -subject -issuer -dates
ls -l ca/
```

Documenta:

| Elemento | Ruta | Permisos | ¿Debe compartirse? | Riesgo si se compromete |
|---|---|---|---|---|
| CA private key | | | | |
| CA certificate | | | | |

Responde:

1. ¿Por qué el certificado raíz puede distribuirse y la clave privada no?
2. ¿Qué podría hacer un atacante que obtuviese la clave privada de la CA?
3. ¿Por qué la protección de la CA condiciona la confianza de todos los certificados emitidos por ella?

## 4. Certificado de `portal.telvora.test`

Crea para `portal.telvora.test`:

- private key;
- CSR;
- certificado firmado por la CA;
- SAN `DNS:portal.telvora.test`;
- Extended Key Usage adecuado para servidor.

Genera la clave privada y la CSR:

```bash
openssl genrsa -out portal/portal.key 2048
chmod 600 portal/portal.key

openssl req -new \
  -key portal/portal.key \
  -out portal/portal.csr \
  -subj "/O=Telvora Communications/CN=portal.telvora.test"
```

Utiliza [`openssl/server-san.ext`](openssl/server-san.ext) como fichero de extensiones para emitir el certificado:

```bash
openssl x509 -req \
  -in portal/portal.csr \
  -CA ca/telvora-root-ca.crt \
  -CAkey ca/telvora-root-ca.key \
  -CAcreateserial \
  -days 365 \
  -sha256 \
  -extfile openssl/server-san.ext \
  -out portal/portal.crt
```

Inspecciona el certificado:

```bash
openssl x509 -in portal/portal.crt -noout -text
```

Registra en `evidence/certificate-analysis.txt`:

- subject;
- issuer;
- serial;
- validity;
- SAN;
- algoritmo de clave pública;
- algoritmo de firma;
- Key Usage / Extended Key Usage.

## 5. Cadena y trust store

Compara:

```bash
openssl verify portal/portal.crt
```

con:

```bash
openssl verify -CAfile ca/telvora-root-ca.crt portal/portal.crt
```

Explica por qué los resultados pueden diferir.

Debes distinguir entre:

```text
certificado correctamente firmado
```

 y:

```text
certificado confiable para un cliente concreto
```

## 6. Servicio TLS temporal

Abre un primer terminal en el directorio de trabajo y levanta un servicio TLS temporal:

```bash
cd ~/labs/m04/pki
openssl s_server \
  -accept 8443 \
  -cert portal/portal.crt \
  -key portal/portal.key \
  -www
```

En un segundo terminal conéctate primero sin indicar la CA:

```bash
openssl s_client \
  -connect 127.0.0.1:8443 \
  -servername portal.telvora.test \
  </dev/null
```

Después repite la prueba indicando expresamente la CA de confianza:

```bash
openssl s_client \
  -connect 127.0.0.1:8443 \
  -servername portal.telvora.test \
  -CAfile ca/telvora-root-ca.crt \
  -verify_hostname portal.telvora.test \
  </dev/null
```

Obtén evidencia de:

- protocolo negociado;
- cipher suite;
- certificado presentado;
- cadena;
- resultado de verificación.

Guarda la salida relevante en:

```text
evidence/tls-validation.txt
```

## 7. Diagnóstico de confianza e identidad

Provoca y documenta **al menos tres** de los siguientes casos:

1. CA no confiable;
2. hostname mismatch;
3. trust store equivocado;
4. certificado expirado o fuera de vigencia — puede analizarse con un artefacto proporcionado o de forma razonada;
5. cadena incompleta — análisis razonado si trabajas únicamente con una CA raíz;
6. incompatibilidad de versión/cipher;
7. mTLS exigido sin certificado cliente.

Para los casos ejecutables directamente en este entorno puedes utilizar como referencia:

### CA no confiable

```bash
openssl s_client \
  -connect 127.0.0.1:8443 \
  -servername portal.telvora.test \
  </dev/null
```

### Hostname mismatch

```bash
openssl s_client \
  -connect 127.0.0.1:8443 \
  -servername wrong.telvora.test \
  -CAfile ca/telvora-root-ca.crt \
  -verify_hostname wrong.telvora.test \
  </dev/null
```

### Trust store correcto

```bash
openssl s_client \
  -connect 127.0.0.1:8443 \
  -servername portal.telvora.test \
  -CAfile ca/telvora-root-ca.crt \
  -verify_hostname portal.telvora.test \
  </dev/null
```

No basta con copiar el mensaje de error: interpreta qué propiedad de confianza ha fallado.

Para cada caso utiliza:

```text
CASE:
OBSERVED SYMPTOM:
CRYPTOGRAPHIC SIGNATURE VALID?:
EXPECTED IDENTITY:
PRESENTED IDENTITY:
ROOT/ISSUER TRUSTED?:
LIKELY ROOT CAUSE:
HOW TO VALIDATE THE FIX:
```

## 8. Material criptográfico para P04.3

La misma CA emitirá ahora las identidades que utilizará el laboratorio MQTT.

### 8.1 Broker `mqtt.telvora.test`

Crea la clave y la CSR:

```bash
openssl genrsa -out mqtt/mqtt.key 2048
chmod 600 mqtt/mqtt.key

openssl req -new \
  -key mqtt/mqtt.key \
  -out mqtt/mqtt.csr \
  -subj "/O=Telvora Communications/CN=mqtt.telvora.test"
```

Emite el certificado utilizando [`openssl/mqtt-server.ext`](openssl/mqtt-server.ext):

```bash
openssl x509 -req \
  -in mqtt/mqtt.csr \
  -CA ca/telvora-root-ca.crt \
  -CAkey ca/telvora-root-ca.key \
  -CAcreateserial \
  -days 365 \
  -sha256 \
  -extfile openssl/mqtt-server.ext \
  -out mqtt/mqtt.crt
```

El certificado debe tener:

```text
CN=mqtt.telvora.test
SAN=DNS:mqtt.telvora.test,IP:10.30.0.20
Extended Key Usage=serverAuth
```

### 8.2 Cliente `sensor01`

Crea:

```bash
openssl genrsa -out clients/sensor01.key 2048
chmod 600 clients/sensor01.key

openssl req -new \
  -key clients/sensor01.key \
  -out clients/sensor01.csr \
  -subj "/O=Telvora Communications/CN=sensor01"

openssl x509 -req \
  -in clients/sensor01.csr \
  -CA ca/telvora-root-ca.crt \
  -CAkey ca/telvora-root-ca.key \
  -CAcreateserial \
  -days 365 \
  -sha256 \
  -extfile openssl/client-auth.ext \
  -out clients/sensor01.crt
```

El certificado debe identificar exactamente:

```text
CN=sensor01
Extended Key Usage=clientAuth
```

### 8.3 Cliente `analyst01`

Crea:

```bash
openssl genrsa -out clients/analyst01.key 2048
chmod 600 clients/analyst01.key

openssl req -new \
  -key clients/analyst01.key \
  -out clients/analyst01.csr \
  -subj "/O=Telvora Communications/CN=analyst01"

openssl x509 -req \
  -in clients/analyst01.csr \
  -CA ca/telvora-root-ca.crt \
  -CAkey ca/telvora-root-ca.key \
  -CAcreateserial \
  -days 365 \
  -sha256 \
  -extfile openssl/client-auth.ext \
  -out clients/analyst01.crt
```

El certificado debe identificar exactamente:

```text
CN=analyst01
Extended Key Usage=clientAuth
```

> Los CN `sensor01` y `analyst01` son intencionados: P04.3 utilizará la identidad del certificado como identidad MQTT para aplicar ACL diferentes.

## 9. Validación del material MQTT

Valida explícitamente los tres certificados contra la CA del laboratorio:

```bash
openssl verify -CAfile ca/telvora-root-ca.crt mqtt/mqtt.crt
openssl verify -CAfile ca/telvora-root-ca.crt clients/sensor01.crt
openssl verify -CAfile ca/telvora-root-ca.crt clients/analyst01.crt
```

Debes obtener evidencia equivalente a:

```text
mqtt/mqtt.crt: OK
clients/sensor01.crt: OK
clients/analyst01.crt: OK
```

Comprueba también que cada private key corresponde a su certificado comparando la clave pública derivada de ambos artefactos. Por ejemplo, para `mqtt`:

```bash
openssl pkey -in mqtt/mqtt.key -pubout -outform pem | sha256sum
openssl x509 -in mqtt/mqtt.crt -pubkey -noout | sha256sum
```

Los dos hashes deben coincidir. Repite la comprobación para `sensor01` y `analyst01`.

Documenta:

| Certificado | Uso esperado | Identidad | Verificación CA | Private key protegida |
|---|---|---|---|---|
| `mqtt.crt` | serverAuth | `mqtt.telvora.test` | | |
| `sensor01.crt` | clientAuth | `sensor01` | | |
| `analyst01.crt` | clientAuth | `analyst01` | | |

## 10. Preparación para P04.3

No subas claves privadas al repositorio Git.

Conserva el material generado. En P04.3 deberán estar disponibles:

### En `LINUX01` — broker

```text
telvora-root-ca.crt
mqtt.crt
mqtt.key
```

### En `KALI01` — clientes

```text
telvora-root-ca.crt
sensor01.crt
sensor01.key
analyst01.crt
analyst01.key
```

Utiliza el mecanismo de transferencia indicado por el instructor para el Telvora Cyber Range. Después de la copia, protege las claves privadas con permisos restrictivos.

## 11. Debrief

Responde:

1. ¿Qué demuestra que la firma del certificado sea válida?
2. ¿Qué papel cumple SAN?
3. ¿Por qué el CN no debe ser el único mecanismo moderno de verificación de identidad de servidor?
4. ¿Qué diferencia hay entre certificado válido y certificado confiable para un cliente concreto?
5. ¿Por qué `serverAuth` y `clientAuth` representan propósitos distintos?
6. ¿Qué riesgo introduce el compromiso de la private key de la CA?
7. ¿Qué harías si se roba la clave privada de `sensor01`?
8. ¿Cómo gestionarías expiración y revocación?
9. ¿Qué eventos relacionados con certificados o TLS enviarías al SIEM?

## Entregable

```text
lab41/
├── certificate-analysis.txt
├── tls-validation.txt
├── mqtt-certificates-validation.txt
└── conclusions.md
```

`conclusions.md` debe indicar qué protege X.509/TLS, qué no protege y al menos tres riesgos operativos de gestión de claves y certificados.
