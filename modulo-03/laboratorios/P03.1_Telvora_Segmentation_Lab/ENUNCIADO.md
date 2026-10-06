# P03.1 — Telvora Segmentation Lab
## Segmentación, mínimo privilegio y validación de política

> **Antes de comenzar:** revisa el [entorno común, topología y perfil de memoria del M03](../README.md#3-entorno-de-laboratorio).

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

# 3. Estado inicial esperado

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

No continúes si la configuración IP no corresponde a la zona DMZ.

---

# 4. Acceso a FW01

Desde el navegador del host físico accede a la interfaz de administración de pfSense en CORP.

Registra:

- versión;
- interfaces;
- direcciones;
- rutas directamente conectadas.

No publiques credenciales en los entregables.

---

# 5. Crea aliases

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

# 6. Política de RED

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

# 7. Validación desde KALI01

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
curl -I http://10.30.0.20/
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

Comprueba un destino autorizado de la zona CORP, por ejemplo la interfaz del firewall:

```bash
nc -vz -w 3 10.40.0.1 443
```

Debe quedar bloqueado desde RED.

---

# 8. Evidencia de firewall

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

# 9. Fase CORP/DMZ

En equipos con 8 GB:

1. apaga `KALI01`;
2. arranca `LABSERV01`.

Comprueba:

```text
LABSERV01 = 10.40.0.30
LINUX01   = 10.30.0.20
```

Configura las reglas necesarias para:

```text
CORP → DMZ TCP/22     PERMITIDO
CORP → DMZ TCP/80     PERMITIDO
DMZ  → CORP           BLOQUEADO por defecto
```

---

# 10. Validación desde CORP

Desde `LABSERV01`:

```bash
curl -I http://10.30.0.20/
```

y:

```bash
nc -vz -w 3 10.30.0.20 22
```

Ambos deben poder alcanzar el servicio correspondiente.

---

# 11. Validación DMZ → CORP

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

# 12. Matriz de validación

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

# 13. Análisis de arquitectura

Responde:

1. ¿Qué aporta la DMZ si el servidor sigue teniendo vulnerabilidades?
2. ¿Qué riesgo existiría si CORP tuviese `allow any any` hacia DMZ?
3. ¿Segmentación equivale a Zero Trust?
4. ¿Por qué la ubicación de las reglas importa en un firewall stateful?
5. ¿Qué cambio realizarías si el servidor DMZ necesitase consultar una base de datos en CORP?
6. ¿Permitirías toda CORP o únicamente una identidad/workload/origen concreto?
7. ¿Cómo trasladarías este modelo a cloud?
