# P04.1 — PKI & TLS Trust Investigation
## Solución detallada paso a paso

> Esta guía parte de un escenario en el que las máquinas están apagadas. El objetivo es construir una PKI de laboratorio mínima, comprender cómo se establece la confianza X.509/TLS, provocar fallos controlados y dejar preparado el material criptográfico que se reutilizará en P04.3.

---

# 1. Qué vamos a construir y por qué

TELVORA necesita una PKI interna de laboratorio para dos propósitos:

1. estudiar cómo un cliente decide si confía o no en un certificado TLS;
2. generar identidades criptográficas para el broker y los clientes MQTT que se utilizarán después en P04.3.

La jerarquía será:

```text
Telvora Training Root CA
│
├── portal.telvora.test       serverAuth
├── mqtt.telvora.test         serverAuth
├── sensor01                  clientAuth
└── analyst01                 clientAuth
```

La CA raíz es la entidad de confianza del laboratorio. Firma los certificados de los servicios y clientes.

La idea central que debemos demostrar es:

```text
firma criptográfica válida
≠
certificado confiable y apropiado para cualquier uso
```

Para confiar en un certificado no basta con que esté firmado. También debemos comprobar quién lo emitió, si confiamos en esa CA, si está vigente, si su identidad coincide con el servicio que esperamos y si su uso permitido es compatible.

---

# 2. Máquinas necesarias

Para P04.1 podemos trabajar únicamente con una máquina Linux que disponga de OpenSSL.

Usaremos preferentemente:

```text
KALI01
```

También sería posible hacerlo en `LINUX01`, pero utilizar KALI01 simplifica la práctica y evita modificar todavía el servidor que reutilizaremos en P04.3.

## 2.1 Arrancar la máquina

Arranca únicamente:

```text
KALI01
```

No necesitamos arrancar todavía:

```text
FW01
LINUX01
LABSERV01
```

La práctica puede realizarse localmente y no necesita Internet.

---

# 3. Iniciar sesión y comprobar OpenSSL

Abre una terminal en KALI01.

Comprueba que OpenSSL está instalado:

```bash
openssl version
```

Deberíamos obtener una salida equivalente a:

```text
OpenSSL 3.x.x ...
```

No es importante que el número exacto sea idéntico al del instructor. Lo importante es disponer de una versión moderna de OpenSSL.

¿Por qué empezamos comprobando la versión?

Porque las herramientas criptográficas evolucionan. Algoritmos, opciones de línea de comandos, valores por defecto y validaciones pueden cambiar entre versiones. Registrar la versión forma parte de una evidencia reproducible.

---

# 4. Obtener los archivos del laboratorio

Necesitamos disponer del repositorio del curso en KALI01.

Si ya existe, entra en él y actualízalo siguiendo el procedimiento habitual del curso.

Si todavía no está disponible, utiliza el mecanismo que haya indicado el instructor para obtener el repositorio.

La carpeta que necesitaremos es:

```text
modulo-04/laboratorios/P04.1_Telvora_PKI_TLS_Trust_Investigation/
```

Dentro deben existir, entre otros, estos ficheros de extensiones:

```text
openssl/server-san.ext
openssl/mqtt-server.ext
openssl/client-auth.ext
```

Estos archivos evitan que el objetivo del laboratorio se convierta en memorizar sintaxis avanzada de OpenSSL. El aprendizaje está en entender SAN, EKU, cadena de confianza y diagnóstico TLS.

---

# 5. Crear el directorio de trabajo

No trabajaremos directamente dentro del repositorio.

Creamos una carpeta separada:

```bash
mkdir -p ~/labs/m04/pki/{ca,portal,mqtt,clients,evidence}
cd ~/labs/m04/pki
```

Comprueba la estructura:

```bash
find . -maxdepth 2 -type d | sort
```

Deberíamos tener:

```text
.
./ca
./clients
./evidence
./mqtt
./portal
```

¿Por qué separamos los artefactos?

Porque en una PKI real diferentes materiales tienen diferentes niveles de sensibilidad. Un certificado público puede distribuirse; una clave privada no.

---

# 6. Copiar los ficheros de extensiones

Desde la carpeta del laboratorio del repositorio copia el directorio `openssl` al directorio de trabajo.

Por ejemplo, si el repositorio está en `~/programa-ciberinteligencia-ciberdefensa`:

```bash
cp -r ~/programa-ciberinteligencia-ciberdefensa/modulo-04/laboratorios/P04.1_Telvora_PKI_TLS_Trust_Investigation/openssl ~/labs/m04/pki/
```

Comprueba:

```bash
find openssl -maxdepth 1 -type f -print
```

Debemos ver:

```text
openssl/server-san.ext
openssl/mqtt-server.ext
openssl/client-auth.ext
```

Si tu repositorio está en otra ubicación, adapta únicamente la ruta de origen.

---

# 7. Crear la CA raíz de TELVORA

## 7.1 Generar la clave privada de la CA

Ejecuta:

```bash
openssl genrsa -out ca/telvora-root-ca.key 3072
```

La clave privada de la CA es el activo más sensible de esta práctica.

Protegemos sus permisos:

```bash
chmod 600 ca/telvora-root-ca.key
```

Comprueba:

```bash
ls -l ca/telvora-root-ca.key
```

Esperamos algo parecido a:

```text
-rw------- ... ca/telvora-root-ca.key
```

`600` significa que el propietario puede leer y escribir el fichero, pero otros usuarios no tienen acceso.

### ¿Por qué importa tanto esta clave?

Porque cualquiera que posea la clave privada de la CA podría generar certificados que parecieran haber sido emitidos por nuestra autoridad de confianza.

Comprometer una clave de servidor afecta principalmente a ese servidor.

Comprometer la clave de una CA puede afectar a **toda la confianza que depende de ella**.

---

# 8. Crear el certificado raíz

Ahora utilizaremos esa clave privada para crear un certificado raíz autofirmado.

Ejecuta:

```bash
openssl req -x509 -new -sha256 \
  -key ca/telvora-root-ca.key \
  -days 3650 \
  -out ca/telvora-root-ca.crt \
  -subj "/O=Telvora Communications/CN=Telvora Training Root CA"
```

Aquí ocurre algo importante:

- la clave privada permanece secreta;
- el certificado raíz contiene la clave pública y la identidad de la CA;
- el certificado sí puede distribuirse a los sistemas que deban confiar en esta CA.

Inspecciona el certificado:

```bash
openssl x509 -in ca/telvora-root-ca.crt -noout -subject -issuer -dates
```

Esperamos conceptualmente:

```text
subject=O = Telvora Communications, CN = Telvora Training Root CA
issuer=O = Telvora Communications, CN = Telvora Training Root CA
```

Que `subject` e `issuer` coincidan es normal en una raíz autofirmada.

Comprueba también:

```bash
ls -l ca/
```

Deberíamos tener al menos:

```text
telvora-root-ca.crt
telvora-root-ca.key
```

---

# 9. Analizar qué puede compartirse

La tabla correcta es conceptualmente:

| Elemento | Ruta | ¿Debe compartirse? | Riesgo si se compromete |
|---|---|---|---|
| Clave privada CA | `ca/telvora-root-ca.key` | No | Permite emitir certificados falsos confiables para esta PKI |
| Certificado CA | `ca/telvora-root-ca.crt` | Sí | Es material público necesario para verificar certificados |

El certificado raíz **no es un secreto**.

La seguridad depende de proteger su clave privada.

---

# 10. Crear la identidad de `portal.telvora.test`

Vamos a emitir el primer certificado de servidor.

## 10.1 Crear la clave privada

```bash
openssl genrsa -out portal/portal.key 2048
chmod 600 portal/portal.key
```

Comprueba:

```bash
ls -l portal/portal.key
```

---

# 11. Crear una CSR

CSR significa **Certificate Signing Request**.

Contiene la identidad solicitada y la clave pública que queremos certificar, pero no la clave privada.

Ejecuta:

```bash
openssl req -new \
  -key portal/portal.key \
  -out portal/portal.csr \
  -subj "/O=Telvora Communications/CN=portal.telvora.test"
```

Comprueba el contenido:

```bash
openssl req -in portal/portal.csr -noout -subject -text | head -30
```

La CSR todavía **no es un certificado confiable**.

Es simplemente una solicitud que deberá ser firmada por la CA.

---

# 12. Revisar el fichero de extensiones del servidor

Antes de emitir el certificado, observa:

```bash
cat openssl/server-san.ext
```

Debes localizar al menos una configuración equivalente a:

```text
subjectAltName = DNS:portal.telvora.test
```

También debería existir un propósito de uso compatible con servidor TLS, normalmente:

```text
extendedKeyUsage = serverAuth
```

## ¿Por qué usamos SAN?

Los clientes modernos comprueban la identidad del servidor frente al **Subject Alternative Name**.

El hecho de que el `CN` diga `portal.telvora.test` no debe considerarse por sí solo suficiente para validar un servidor moderno.

---

# 13. Firmar el certificado del portal

Ejecuta:

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

Ahora sí tenemos un certificado firmado por nuestra CA.

Comprueba:

```bash
openssl x509 -in portal/portal.crt -noout -subject -issuer -serial -dates
```

El `subject` debe identificar al portal y el `issuer` debe ser:

```text
Telvora Training Root CA
```

---

# 14. Inspeccionar SAN y Extended Key Usage

Ejecuta:

```bash
openssl x509 -in portal/portal.crt -noout -text
```

Busca:

```text
X509v3 Subject Alternative Name
```

Debe aparecer:

```text
DNS:portal.telvora.test
```

Busca también:

```text
X509v3 Extended Key Usage
```

Debe ser compatible con autenticación de servidor, por ejemplo:

```text
TLS Web Server Authentication
```

Esto demuestra una idea importante:

> un certificado tiene una identidad y también puede tener restricciones sobre para qué puede utilizarse.

---

# 15. Guardar evidencia del certificado

Genera un fichero de evidencia:

```bash
openssl x509 -in portal/portal.crt -noout -text > evidence/certificate-analysis.txt
```

Comprueba:

```bash
less evidence/certificate-analysis.txt
```

Debemos ser capaces de localizar:

- Subject;
- Issuer;
- Serial Number;
- Not Before / Not After;
- Public Key Algorithm;
- Signature Algorithm;
- SAN;
- Extended Key Usage.

---

# 16. Primera prueba de confianza: sin proporcionar la CA

Ejecuta:

```bash
openssl verify portal/portal.crt
```

Es probable que obtengas un error equivalente a:

```text
unable to get local issuer certificate
```

o:

```text
unable to get issuer certificate
```

Esto **no significa necesariamente que la firma sea incorrecta**.

Significa que OpenSSL no encuentra en su trust store habitual una CA en la que confíe y que permita construir la cadena.

---

# 17. Segunda prueba: proporcionar explícitamente la CA

Ejecuta:

```bash
openssl verify -CAfile ca/telvora-root-ca.crt portal/portal.crt
```

Esperamos:

```text
portal/portal.crt: OK
```

La diferencia entre ambas pruebas es esencial.

El certificado es el mismo.

Lo que cambia es el **trust store del verificador**.

Esto demuestra:

```text
certificado firmado correctamente
+
CA confiable para este cliente
=
validación de cadena correcta
```

---

# 18. Levantar un servidor TLS temporal

Abrimos un segundo terminal.

En el primero:

```bash
cd ~/labs/m04/pki
```

Levanta un servidor TLS:

```bash
openssl s_server \
  -accept 8443 \
  -cert portal/portal.crt \
  -key portal/portal.key \
  -www
```

Deja esa terminal abierta.

El servidor escucha ahora en:

```text
127.0.0.1:8443
```

y presenta el certificado de:

```text
portal.telvora.test
```

No estamos creando una aplicación web real. `s_server` nos permite estudiar el establecimiento TLS sin introducir software adicional.

---

# 19. Conectarnos sin confiar en la CA

En otra terminal:

```bash
cd ~/labs/m04/pki
```

Ejecuta:

```bash
openssl s_client \
  -connect 127.0.0.1:8443 \
  -servername portal.telvora.test \
  </dev/null
```

Observa la salida.

Localiza:

```text
Protocol
Cipher
Certificate chain
Verify return code
```

La conexión TLS puede llegar a negociarse aunque la verificación del certificado no sea satisfactoria.

Ese matiz es importante: **cifrado de canal y confianza de identidad son conceptos relacionados pero distintos**.

---

# 20. Conectarnos confiando explícitamente en TELVORA

Ejecuta:

```bash
openssl s_client \
  -connect 127.0.0.1:8443 \
  -servername portal.telvora.test \
  -CAfile ca/telvora-root-ca.crt \
  -verify_hostname portal.telvora.test \
  </dev/null
```

Ahora esperamos una verificación satisfactoria.

Busca al final:

```text
Verify return code: 0 (ok)
```

Aquí estamos comprobando simultáneamente:

1. que la firma encadena hasta la CA indicada;
2. que confiamos en esa CA;
3. que el certificado presentado es válido para `portal.telvora.test`.

---

# 21. Guardar la evidencia TLS

Ejecuta:

```bash
openssl s_client \
  -connect 127.0.0.1:8443 \
  -servername portal.telvora.test \
  -CAfile ca/telvora-root-ca.crt \
  -verify_hostname portal.telvora.test \
  </dev/null \
  > evidence/tls-validation.txt 2>&1
```

Comprueba:

```bash
less evidence/tls-validation.txt
```

---

# 22. Caso de diagnóstico 1 — CA no confiable

Ejecuta de nuevo sin `-CAfile`:

```bash
openssl s_client \
  -connect 127.0.0.1:8443 \
  -servername portal.telvora.test \
  </dev/null
```

## Interpretación

El servidor presenta un certificado firmado por Telvora Training Root CA.

Sin embargo, ese certificado raíz no forma parte automáticamente del trust store del sistema.

Por tanto:

```text
CRYPTOGRAPHIC SIGNATURE VALID?: Sí, si se verifica contra la CA correcta.
ROOT/ISSUER TRUSTED?: No para este cliente en esta prueba.
LIKELY ROOT CAUSE: la CA de laboratorio no está en el trust store utilizado.
```

La solución no es volver a emitir el certificado.

La solución es establecer correctamente la confianza del cliente cuando esa CA deba ser confiable.

---

# 23. Caso de diagnóstico 2 — hostname mismatch

Ejecuta:

```bash
openssl s_client \
  -connect 127.0.0.1:8443 \
  -servername wrong.telvora.test \
  -CAfile ca/telvora-root-ca.crt \
  -verify_hostname wrong.telvora.test \
  </dev/null
```

El certificado puede seguir estando perfectamente firmado por una CA confiable.

Pero su SAN contiene:

```text
portal.telvora.test
```

no:

```text
wrong.telvora.test
```

## Interpretación

```text
CRYPTOGRAPHIC SIGNATURE VALID?: Sí.
ROOT/ISSUER TRUSTED?: Sí.
EXPECTED IDENTITY: wrong.telvora.test
PRESENTED IDENTITY: portal.telvora.test
LIKELY ROOT CAUSE: hostname mismatch.
```

Esta es una de las demostraciones más importantes del laboratorio:

> un certificado puede ser criptográficamente correcto y aun así no ser válido para el servicio al que creemos estar conectándonos.

---

# 24. Caso de diagnóstico 3 — trust store correcto

Repite la prueba correcta:

```bash
openssl s_client \
  -connect 127.0.0.1:8443 \
  -servername portal.telvora.test \
  -CAfile ca/telvora-root-ca.crt \
  -verify_hostname portal.telvora.test \
  </dev/null
```

Esperamos:

```text
Verify return code: 0 (ok)
```

Esto sirve como **prueba positiva** frente a las anteriores pruebas negativas.

---

# 25. Qué otros fallos podríamos diagnosticar

El laboratorio también plantea otros escenarios:

- certificado expirado;
- cadena incompleta;
- incompatibilidad de versión o cipher;
- mTLS requerido sin certificado cliente.

No es necesario forzar artificialmente todos ellos si no disponemos del artefacto correspondiente.

Lo importante es saber razonar el diagnóstico.

## Certificado expirado

La firma puede ser correcta, el SAN puede coincidir y la CA puede ser confiable, pero el periodo:

```text
Not Before
Not After
```

no incluye la fecha actual.

## Cadena incompleta

Si hubiera una CA intermedia:

```text
Root CA
  ↓
Intermediate CA
  ↓
Server certificate
```

el servidor debería presentar la cadena necesaria para que el cliente pueda construir el camino hasta una raíz confiable.

## mTLS sin certificado cliente

En TLS normal autenticamos principalmente al servidor.

En mTLS el servidor exige además que el cliente presente un certificado aceptable.

Si no lo hace, el establecimiento TLS puede fallar aunque el certificado del servidor sea correcto.

---

# 26. Detener el servidor TLS temporal

Vuelve al terminal donde está `openssl s_server` y pulsa:

```text
Ctrl+C
```

---

# 27. Preparar la identidad del broker MQTT

El siguiente objetivo es generar material que reutilizaremos en P04.3.

El broker estará en `LINUX01`, cuya IP en la DMZ será:

```text
10.30.0.20
```

Su identidad lógica será:

```text
mqtt.telvora.test
```

El certificado debe ser válido tanto para el nombre DNS como para esa IP.

---

# 28. Revisar las extensiones MQTT

Ejecuta:

```bash
cat openssl/mqtt-server.ext
```

Debemos comprobar que contempla:

```text
DNS:mqtt.telvora.test
IP:10.30.0.20
```

además de un Extended Key Usage compatible con:

```text
serverAuth
```

---

# 29. Crear la clave del broker

```bash
openssl genrsa -out mqtt/mqtt.key 2048
chmod 600 mqtt/mqtt.key
```

---

# 30. Crear la CSR del broker

```bash
openssl req -new \
  -key mqtt/mqtt.key \
  -out mqtt/mqtt.csr \
  -subj "/O=Telvora Communications/CN=mqtt.telvora.test"
```

---

# 31. Firmar el certificado del broker

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

Comprueba:

```bash
openssl x509 -in mqtt/mqtt.crt -noout -subject -issuer -ext subjectAltName -ext extendedKeyUsage
```

Debemos identificar:

```text
CN=mqtt.telvora.test
DNS:mqtt.telvora.test
IP Address:10.30.0.20
TLS Web Server Authentication
```

---

# 32. Crear el certificado cliente `sensor01`

Primero revisa:

```bash
cat openssl/client-auth.ext
```

Debe establecer un uso compatible con:

```text
clientAuth
```

Genera la clave:

```bash
openssl genrsa -out clients/sensor01.key 2048
chmod 600 clients/sensor01.key
```

Genera la CSR:

```bash
openssl req -new \
  -key clients/sensor01.key \
  -out clients/sensor01.csr \
  -subj "/O=Telvora Communications/CN=sensor01"
```

Firma el certificado:

```bash
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

Comprueba:

```bash
openssl x509 -in clients/sensor01.crt -noout -subject -issuer -ext extendedKeyUsage
```

Debe identificar:

```text
CN=sensor01
```

y un uso equivalente a:

```text
TLS Web Client Authentication
```

---

# 33. Crear el certificado cliente `analyst01`

Genera la clave:

```bash
openssl genrsa -out clients/analyst01.key 2048
chmod 600 clients/analyst01.key
```

Genera la CSR:

```bash
openssl req -new \
  -key clients/analyst01.key \
  -out clients/analyst01.csr \
  -subj "/O=Telvora Communications/CN=analyst01"
```

Firma:

```bash
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

Comprueba:

```bash
openssl x509 -in clients/analyst01.crt -noout -subject -issuer -ext extendedKeyUsage
```

Debe aparecer:

```text
CN=analyst01
```

con propósito de cliente TLS.

---

# 34. Validar los tres certificados MQTT

Ejecuta:

```bash
openssl verify -CAfile ca/telvora-root-ca.crt mqtt/mqtt.crt
openssl verify -CAfile ca/telvora-root-ca.crt clients/sensor01.crt
openssl verify -CAfile ca/telvora-root-ca.crt clients/analyst01.crt
```

Esperamos:

```text
mqtt/mqtt.crt: OK
clients/sensor01.crt: OK
clients/analyst01.crt: OK
```

Guarda la evidencia:

```bash
{
  openssl verify -CAfile ca/telvora-root-ca.crt mqtt/mqtt.crt
  openssl verify -CAfile ca/telvora-root-ca.crt clients/sensor01.crt
  openssl verify -CAfile ca/telvora-root-ca.crt clients/analyst01.crt
} > evidence/mqtt-certificates-validation.txt 2>&1
```

---

# 35. Verificar que cada certificado corresponde a su clave privada

Un certificado contiene una clave pública.

La clave pública derivada de la private key debe ser la misma.

## Broker MQTT

```bash
openssl pkey -in mqtt/mqtt.key -pubout -outform pem | sha256sum
openssl x509 -in mqtt/mqtt.crt -pubkey -noout | sha256sum
```

Los dos hashes deben coincidir.

## sensor01

```bash
openssl pkey -in clients/sensor01.key -pubout -outform pem | sha256sum
openssl x509 -in clients/sensor01.crt -pubkey -noout | sha256sum
```

## analyst01

```bash
openssl pkey -in clients/analyst01.key -pubout -outform pem | sha256sum
openssl x509 -in clients/analyst01.crt -pubkey -noout | sha256sum
```

Si los hashes de una pareja no coinciden, esa clave privada no corresponde a ese certificado.

---

# 36. Revisar permisos de las claves

Ejecuta:

```bash
find ca portal mqtt clients -name '*.key' -exec ls -l {} \;
```

Las claves deberían mostrar permisos equivalentes a:

```text
-rw-------
```

Si alguna no los tiene:

```bash
chmod 600 ruta/a/la/clave.key
```

---

# 37. Preparar el material para P04.3

Cuando lleguemos a P04.3 necesitaremos distribuir diferentes artefactos.

## En LINUX01, que actuará como broker

Necesitaremos:

```text
telvora-root-ca.crt
mqtt.crt
mqtt.key
```

## En KALI01, para los clientes MQTT

Necesitaremos:

```text
telvora-root-ca.crt
sensor01.crt
sensor01.key
analyst01.crt
analyst01.key
```

No realizaremos todavía la transferencia si vamos a hacer otros ejercicios antes.

Conserva el directorio:

```text
~/labs/m04/pki
```

No elimines el material al terminar P04.1.

---

# 38. No subir claves privadas a Git

Nunca debemos ejecutar algo como:

```bash
git add ca/telvora-root-ca.key
```

ni subir:

```text
*.key
```

al repositorio.

Una private key no debe convertirse en un artefacto distribuido por Git simplemente porque sea cómodo.

Este punto conecta directamente con la gestión de secretos que se estudia en el módulo.

---

# 39. Respuestas del debrief

## 39.1 ¿Qué demuestra que la firma del certificado sea válida?

Demuestra que el certificado fue firmado con la clave privada correspondiente al emisor indicado y que el contenido firmado no ha sido modificado desde entonces.

No demuestra por sí sola que debamos confiar en el emisor.

---

## 39.2 ¿Qué papel cumple SAN?

SAN expresa las identidades para las que el certificado es válido.

Para un servidor puede incluir, por ejemplo:

```text
DNS:portal.telvora.test
DNS:mqtt.telvora.test
IP:10.30.0.20
```

El cliente compara la identidad esperada con los SAN del certificado.

---

## 39.3 ¿Por qué el CN no debe ser el único mecanismo moderno de verificación de identidad?

Porque la verificación moderna de nombres de servidor se basa en `Subject Alternative Name`.

Un `CN` correcto sin un SAN adecuado no debe considerarse suficiente para validar un servicio TLS moderno.

---

## 39.4 ¿Qué diferencia hay entre certificado válido y certificado confiable?

Un certificado puede ser estructural y criptográficamente válido, pero el cliente puede no confiar en su emisor.

Para que la confianza sea satisfactoria necesitamos además construir una cadena hasta una raíz aceptada por el cliente y validar otras propiedades como vigencia, identidad y uso.

---

## 39.5 ¿Por qué `serverAuth` y `clientAuth` representan propósitos distintos?

Porque Extended Key Usage limita el propósito para el que se espera utilizar un certificado.

`serverAuth` está destinado a autenticación del servidor.

`clientAuth` está destinado a autenticación del cliente.

No debemos considerar todos los certificados intercambiables simplemente porque estén firmados por la misma CA.

---

## 39.6 ¿Qué riesgo introduce el compromiso de la private key de la CA?

Un atacante podría emitir certificados fraudulentos que pareciesen legítimos dentro de esa PKI.

El problema afectaría potencialmente a todas las identidades que dependan de esa raíz de confianza.

En una PKI real esto puede obligar a revocar o retirar la confianza de la CA comprometida y reconstruir la jerarquía.

---

## 39.7 ¿Qué haríamos si se roba la clave privada de `sensor01`?

Deberíamos dejar de confiar en esa identidad comprometida, revocar su certificado según el mecanismo de la PKI, generar una nueva clave y emitir un nuevo certificado.

También deberíamos investigar dónde y cómo se produjo el compromiso.

Rotar únicamente el certificado sin resolver la causa no sería suficiente.

---

## 39.8 ¿Cómo gestionaríamos expiración y revocación?

Mantendríamos inventario de certificados, propietarios y fechas de expiración, con renovación antes de caducar.

Para compromiso o baja utilizaríamos mecanismos de revocación acordes con la PKI, por ejemplo CRL u OCSP cuando correspondan.

Además, la revocación tiene limitaciones operativas: disponibilidad del servicio, caching, políticas de soft-fail y latencia.

---

## 39.9 ¿Qué eventos enviaríamos al SIEM?

Como mínimo serían relevantes:

- certificados próximos a expirar;
- certificados expirados utilizados;
- errores repetidos de validación TLS;
- fallos de mTLS;
- certificados revocados utilizados;
- cambios de trust store;
- emisión o renovación anómala de certificados;
- acceso a material de claves;
- errores por hostname mismatch cuando sean inesperados;
- versiones o parámetros TLS no autorizados.

No registraríamos el contenido de las claves privadas.

---

# 40. Qué protege TLS y qué no protege

TLS puede proporcionar:

```text
confidencialidad en tránsito
integridad en tránsito
autenticación del servidor
opcionalmente autenticación del cliente mediante mTLS
```

Pero TLS no garantiza que:

```text
la aplicación sea segura
el servidor no esté comprometido
la autorización sea correcta
los datos estén protegidos antes o después del canal
un usuario autenticado tenga permisos adecuados
```

Esta distinción será especialmente importante en P04.3.

Podremos tener MQTT protegido mediante TLS y aun así tener una ACL incorrecta que permita a un dispositivo publicar en topics que no debería controlar.

---

# 41. Evidencias finales

Comprueba que disponemos de:

```bash
find ~/labs/m04/pki -maxdepth 2 -type f | sort
```

Debemos conservar, entre otros:

```text
ca/telvora-root-ca.crt
ca/telvora-root-ca.key
portal/portal.crt
portal/portal.key
mqtt/mqtt.crt
mqtt/mqtt.key
clients/sensor01.crt
clients/sensor01.key
clients/analyst01.crt
clients/analyst01.key
evidence/certificate-analysis.txt
evidence/tls-validation.txt
evidence/mqtt-certificates-validation.txt
```

---

# 42. Estado final de la práctica

La práctica está correctamente completada cuando podemos demostrar:

```text
✓ hemos creado una CA raíz de laboratorio
✓ hemos protegido su clave privada
✓ hemos emitido un certificado de servidor con SAN
✓ sabemos distinguir firma válida de confianza del cliente
✓ hemos validado correctamente una cadena
✓ hemos provocado y diagnosticado fallos de confianza e identidad
✓ hemos comprobado un hostname mismatch
✓ hemos generado identidades serverAuth y clientAuth
✓ hemos verificado que certificados y private keys corresponden
✓ hemos generado el material necesario para P04.3
```

La conclusión principal es:

> X.509 y TLS no crean confianza por sí solos. La confianza aparece cuando una identidad, una cadena criptográfica, una raíz aceptada, un propósito permitido y un contexto esperado encajan correctamente.

Y la segunda conclusión, que reutilizaremos en P04.3, es:

> TLS protege el canal. No sustituye a la autorización ni corrige una ACL incorrecta.
