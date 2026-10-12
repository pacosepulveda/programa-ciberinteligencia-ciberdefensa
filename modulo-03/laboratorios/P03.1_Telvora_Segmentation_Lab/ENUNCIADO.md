# P03.1 — Telvora Segmentation Lab
## Segmentación, mínimo privilegio y validación de política

> **Antes de comenzar:** revisa el [entorno común y la topología del M03](../README.md#entorno-de-laboratorio).

---

# 1. Escenario

TELVORA está separando servicios públicos de la red corporativa.

Se han definido tres zonas:

### RED

Zona no confiable utilizada para representar tráfico procedente de una red externa.

### DMZ

Zona destinada a servicios que deben ser accesibles desde RED.

### CORP

Zona corporativa desde la que pueden realizarse determinadas tareas administrativas.

Tu misión es convertir esta intención arquitectónica en una **política verificable**.

---

# 2. Requisitos de seguridad

La política aprobada es:

### POL-01

Desde RED solo debe permitirse acceso HTTP al servidor público de DMZ.

### POL-02

Desde RED no debe permitirse administración SSH del servidor DMZ.

### POL-03

Desde RED no debe poderse acceder a la zona CORP.

### POL-04

Desde CORP debe permitirse HTTP y SSH hacia `LINUX01`.

### POL-05

Desde DMZ no debe poder iniciarse tráfico arbitrario hacia CORP.

### POL-06

Las denegaciones relevantes deben dejar evidencia en el firewall.

### POL-07

Las reglas deben aplicar mínimo privilegio y ser comprensibles para otro administrador.

---

# 3. Preparación de la topología

Antes de comenzar, P03.0A debe haber finalizado con UFW desactivado en `LINUX01`:

```bash
sudo ufw status
```

Debe mostrar:

```text
Status: inactive
```

La topología para esta práctica es:

```text
RED         10.20.0.0/24
DMZ         10.30.0.0/24
CORP        10.40.0.0/24

KALI01      10.20.0.10
FW01 RED    10.20.0.254
FW01 DMZ    10.30.0.1
FW01 CORP   10.40.0.1
LINUX01     10.30.0.20
LABSERV01   10.40.0.30
```

## 3.1 Mover LINUX01 a DMZ

Siguiendo las indicaciones del instructor, conecta la interfaz de laboratorio de `LINUX01` a la red DMZ correspondiente a tu hipervisor y configura:

```text
IP       10.30.0.20/24
Gateway  10.30.0.1
```

Los nombres de las redes por hipervisor están documentados en el README del módulo.

Comprueba:

```bash
ip -br address
ip route
```

No continúes si LINUX01 no está en `10.30.0.20/24`.

## 3.2 Preparar KALI01 para alcanzar DMZ y CORP

KALI01 permanece en RED con `10.20.0.10`.

La interfaz RED de FW01 es:

```text
10.20.0.254
```

Añade rutas temporales para que el tráfico hacia las otras zonas pase por FW01:

```bash
sudo ip route replace 10.30.0.0/24 via 10.20.0.254
sudo ip route replace 10.40.0.0/24 via 10.20.0.254
```

Comprueba:

```bash
ip route get 10.30.0.20
ip route get 10.40.0.1
```

Ambos destinos deben utilizar `10.20.0.254` como siguiente salto.

> `10.20.0.1` puede seguir existiendo como gateway/NAT de la red de M01/M02. No es una interfaz de FW01.

---

# 4. Estado inicial esperado

`LINUX01` debe ofrecer:

```text
TCP/22   SSH
TCP/80   HTTP
```

Comprueba desde su propia consola:

```bash
sudo ss -lntp
```

Verifica también:

```bash
ip -br address
ip route
```

---

# 5. Acceso a FW01

Desde el navegador de `KALI01` accede a:

```text
https://10.20.0.254
```

No es necesario conectar el host físico a CORP.

Registra:

- versión;
- interfaces;
- direcciones;
- rutas directamente conectadas.

No publiques credenciales en los entregables.

---

# 6. Crea aliases

Crea aliases que hagan las reglas legibles.

Como mínimo:

```text
DMZ_WEB
10.30.0.20
```

```text
DMZ_WEB_PORTS
80
```

```text
DMZ_ADMIN_PORTS
22
```

Opcionalmente puedes definir:

```text
CORP_NET
10.40.0.0/24
```

```text
DMZ_NET
10.30.0.0/24
```

---

# 7. Política de RED

Implementa las reglas necesarias para que:

```text
RED → LINUX01:80      PERMITIDO
RED → LINUX01:22      BLOQUEADO
RED → CORP            BLOQUEADO
```

Utiliza reglas explícitas y activa logging en los bloqueos que quieras demostrar.

Documenta:

| Orden | Acción | Origen | Destino | Puerto | Log | Justificación |
|---:|---|---|---|---|---|---|
| | | | | | | |

---

# 8. Validación desde KALI01

Arranca:

- `FW01`
- `KALI01`
- `LINUX01`

Comprueba configuración:

```bash
ip -br a
ip route
```

## Prueba HTTP

```bash
curl -I --connect-timeout 3 http://10.30.0.20/
```

Debe existir conectividad si POL-01 está correctamente aplicada.

## Prueba SSH

No realices ataques de contraseña.

Comprueba únicamente conectividad:

```bash
nc -vz -w 3 10.30.0.20 22
```

o:

```bash
nmap -Pn -p22 10.30.0.20
```

El tráfico debe ser bloqueado por la política.

## Prueba hacia CORP

Comprueba la interfaz CORP del firewall:

```bash
nc -vz -w 3 10.40.0.1 443
```

Debe quedar bloqueado desde RED.

---

# 9. Evidencia de firewall

En pfSense localiza los logs correspondientes a:

- HTTP permitido;
- intento SSH bloqueado;
- intento RED → CORP bloqueado.

Para cada uno registra:

| Hora | Interfaz | Acción | Origen | Destino | Puerto | Política relacionada |
|---|---|---|---|---|---:|---|

Responde:

1. ¿En qué interfaz debe existir la regla para tráfico iniciado desde RED?
2. ¿Por qué no hace falta una segunda regla para permitir el tráfico de respuesta HTTP?
3. ¿Qué papel desempeña el seguimiento de estado?

---

# 10. Fase CORP/DMZ

En equipos con 8 GB:

1. apaga `KALI01`;
2. arranca `LABSERV01`.

Comprueba:

```text
LABSERV01 = 10.40.0.30
LINUX01   = 10.30.0.20
```

En LABSERV01 verifica que las rutas hacia RED y DMZ utilizan FW01:

```bash
ip route get 10.30.0.20
ip route get 10.20.0.254
```

Configura las reglas necesarias para:

```text
CORP → DMZ TCP/22     PERMITIDO
CORP → DMZ TCP/80     PERMITIDO
DMZ  → CORP           BLOQUEADO por defecto
```

---

# 11. Validación desde CORP

Desde `LABSERV01`:

```bash
curl -I --connect-timeout 3 http://10.30.0.20/
```

y:

```bash
nc -vz -w 3 10.30.0.20 22
```

Ambos deben poder alcanzar el servicio correspondiente.

---

# 12. Validación DMZ → CORP

Desde `LINUX01` intenta establecer una conexión hacia un puerto de prueba de `LABSERV01`.

No es necesario disponer de un servicio vulnerable ni realizar explotación.

Puedes levantar temporalmente un listener legítimo en LABSERV01:

```bash
nc -lv 8080
```

Desde LINUX01:

```bash
nc -vz -w 3 10.40.0.30 8080
```

El firewall debe impedir la conexión.

Finaliza el listener después de la prueba.

---

# 13. Matriz de validación

Completa:

| ID | Flujo | Esperado | Observado | Evidencia | Resultado |
|---|---|---|---|---|---|
| T01 | RED → DMZ HTTP | Allow | | | |
| T02 | RED → DMZ SSH | Deny | | | |
| T03 | RED → CORP HTTPS | Deny | | | |
| T04 | CORP → DMZ HTTP | Allow | | | |
| T05 | CORP → DMZ SSH | Allow | | | |
| T06 | DMZ → CORP TCP/8080 | Deny | | | |

La práctica no se considera terminada porque “las reglas están creadas”.

Se considera terminada cuando la matriz se ha **validado**.

---

# 14. Análisis de arquitectura

Responde:

1. ¿Qué aporta la DMZ si el servidor sigue teniendo vulnerabilidades?
2. ¿Qué riesgo existiría si CORP tuviese `allow any any` hacia DMZ?
3. ¿Segmentación equivale a Zero Trust?
4. ¿Por qué la ubicación de las reglas importa en un firewall stateful?
5. ¿Qué cambio realizarías si el servidor DMZ necesitase consultar una base de datos en CORP?
6. ¿Permitirías toda CORP o únicamente una identidad/workload/origen concreto?
7. ¿Cómo trasladarías este modelo a cloud?
