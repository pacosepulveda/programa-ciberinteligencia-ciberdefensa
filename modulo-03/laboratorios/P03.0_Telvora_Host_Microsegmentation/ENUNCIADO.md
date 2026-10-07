# P03.0 — Telvora Host Microsegmentation & Evidence Lab
## Microsegmentación, management plane, default deny y validación

> **Antes de comenzar:** revisa el [entorno común del M03](../README.md).

---

# 1. Escenario

`LINUX01` aloja un servicio web interno utilizado por personal de TELVORA.

Durante una revisión de arquitectura se detecta que el mismo segmento desde el que se consume el servicio también puede alcanzar el servicio de administración SSH del servidor.

La decisión de arquitectura es:

- el servicio HTTP debe seguir siendo accesible desde la red de usuarios del laboratorio;
- el servicio SSH no debe ser alcanzable desde ese segmento;
- el plano de gestión debe quedar separado de los flujos de usuario;
- los intentos bloqueados deben dejar evidencia;
- la política debe validarse mediante pruebas positivas y negativas.

En el laboratorio, la consola local de `LINUX01` representa un canal de administración fuera de banda.

---

# 2. Máquinas

Utiliza únicamente:

```text
KALI01
LINUX01
```

Direcciones de referencia:

```text
KALI01   10.20.0.10
LINUX01  10.20.0.20
```

Verifica las direcciones reales antes de comenzar:

```bash
ip -br address
ip route
```

Si tu entorno utiliza direcciones distintas, adapta los comandos y la política.

---

# 3. Política que debes implementar

La política aprobada es:

| ID | Origen | Destino | Servicio | Decisión |
|---|---|---|---|---|
| POL-H01 | red de usuarios del laboratorio | `LINUX01` | HTTP TCP/80 | ALLOW |
| POL-H02 | red de usuarios del laboratorio | `LINUX01` | SSH TCP/22 | DENY |
| POL-H03 | cualquier otro tráfico entrante no justificado | `LINUX01` | cualquiera | DENY por defecto |
| POL-H04 | tráfico saliente necesario desde `LINUX01` | exterior | cualquiera | ALLOW |
| POL-H05 | denegaciones relevantes | `LINUX01` | — | LOG |

La práctica no consiste en cerrar puertos indiscriminadamente. Debes convertir una **intención de arquitectura** en una política técnica verificable.

---

# 4. Fase 1 — Línea base

En `LINUX01`, registra primero qué servicios están escuchando:

```bash
sudo ss -lntp
```

Comprueba el estado del firewall local:

```bash
sudo ufw status verbose
```

Desde `KALI01`, valida HTTP:

```bash
curl -I --connect-timeout 3 http://10.20.0.20/
```

Valida SSH sin autenticarte ni realizar ataques de contraseña:

```bash
nc -vz -w 3 10.20.0.20 22
```

También puedes utilizar el script [`validate_flows.sh`](validate_flows.sh):

```bash
chmod +x validate_flows.sh
./validate_flows.sh 10.20.0.20
```

Registra el estado inicial en [`MATRIZ_VALIDACION.csv`](MATRIZ_VALIDACION.csv).

---

# 5. Fase 2 — Diseña las reglas

Utiliza el firewall local de Ubuntu mediante `ufw`.

Antes de modificarlo, documenta:

```bash
sudo ufw status numbered
sudo ufw show added
```

Debes traducir POL-H01 a POL-H05 a reglas concretas.

Referencia de sintaxis:

```bash
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow from <RED_ORIGEN> to any port <PUERTO> proto tcp
sudo ufw deny from <RED_ORIGEN> to any port <PUERTO> proto tcp
sudo ufw logging medium
sudo ufw enable
```

No copies valores sin relacionarlos con la política.

Antes de habilitar el firewall, comprueba que sigues teniendo acceso a la consola de `LINUX01`.

---

# 6. Fase 3 — Revisión de política

Una vez creadas las reglas, registra:

```bash
sudo ufw status numbered
sudo ufw status verbose
```

Completa:

| Regla | Origen | Destino/puerto | Acción | Política asociada | Justificación |
|---|---|---|---|---|---|
| | | | | | |
| | | | | | |

Responde antes de ejecutar las pruebas:

1. ¿Qué flujo debe seguir funcionando?
2. ¿Qué flujo debe dejar de funcionar?
3. ¿Por qué existe una política por defecto además de reglas explícitas?
4. ¿Qué representa la consola local dentro del diseño del management plane?

---

# 7. Fase 4 — Validación positiva y negativa

Desde `KALI01`, vuelve a ejecutar:

```bash
./validate_flows.sh 10.20.0.20
```

O realiza manualmente:

```bash
curl -I --connect-timeout 3 http://10.20.0.20/
nc -vz -w 3 10.20.0.20 22
```

La validación debe incluir:

- una **prueba positiva**: un flujo que debe funcionar;
- una **prueba negativa**: un flujo que debe fallar.

Completa la matriz con el resultado observado y la evidencia obtenida.

---

# 8. Fase 5 — Telemetría

En `LINUX01`, genera de nuevo un intento SSH desde `KALI01` y busca evidencia del bloqueo.

Puedes revisar el journal del kernel:

```bash
sudo journalctl -k --since "10 minutes ago" | grep -i UFW
```

Según la configuración de la distribución, también puede existir información en otros logs del sistema.

Registra, si está disponible:

| Campo | Valor |
|---|---|
| Timestamp | |
| Acción | |
| IP origen | |
| IP destino | |
| Puerto destino | |
| Interfaz | |

Explica por qué **bloquear sin poder observar** reduce la capacidad de validar y operar la arquitectura.

---

# 9. Análisis arquitectónico

Responde:

1. ¿Esto es segmentación de red tradicional o microsegmentación en host?
2. ¿Qué ventaja aporta aplicar el control directamente en el workload?
3. ¿Qué limitación tiene confiar únicamente en una dirección IP como criterio de confianza?
4. ¿Qué ocurre con esta política si el propio `LINUX01` es comprometido con privilegios de administrador?
5. ¿Por qué separar el management plane reduce superficie de ataque?
6. ¿Qué aporta `default deny` frente a permitir todo y bloquear excepciones?
7. ¿Por qué demostrar que HTTP funciona es tan importante como demostrar que SSH falla?
8. ¿Qué cambiaría si esta política tuviera que aplicarse a cientos de servidores?

---

# 10. Cierre y restauración

Cuando hayas terminado de recoger evidencias, deja constancia del estado final:

```bash
sudo ufw status verbose
```

Si el instructor indica que el laboratorio debe volver a su estado previo, desactiva el firewall:

```bash
sudo ufw disable
```

No elimines evidencias hasta haber completado el entregable.

---

# 11. Entregable

Entrega un **Architecture Validation Brief** con:

- política POL-H01 a POL-H05;
- reglas implementadas;
- estado antes y después;
- prueba positiva HTTP;
- prueba negativa SSH;
- evidencia de logging;
- análisis de management plane;
- al menos dos limitaciones de la solución;
- conclusión: qué has demostrado y qué no has demostrado.
