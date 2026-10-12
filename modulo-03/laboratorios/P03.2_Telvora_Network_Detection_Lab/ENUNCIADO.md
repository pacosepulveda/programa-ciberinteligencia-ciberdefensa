# P03.2 — Telvora Network Detection Lab
## Suricata, reglas de detección y análisis de alertas

> **Antes de comenzar:** revisa el [entorno común y la topología del M03](../README.md#entorno-de-laboratorio).

---

# 1. Objetivo

En P03.1 el firewall responde a:

> **¿Debe permitirse este flujo?**

Ahora el IDS debe ayudar a responder:

> **¿Qué está ocurriendo dentro del tráfico permitido?**

No todo tráfico permitido es legítimo.

---

# 2. Máquinas y estado de red

Esta práctica continúa sobre la topología segmentada de P03.1:

```text
FW01
LINUX01     10.30.0.20  DMZ
LABSERV01   10.40.0.30  CORP
```

FW01 mantiene:

```text
RED   10.20.0.254
DMZ   10.30.0.1
CORP  10.40.0.1
```

LINUX01 debe seguir en DMZ y LABSERV01 en CORP.

Desde LABSERV01 comprueba que el tráfico hacia DMZ utiliza FW01:

```bash
ip route get 10.30.0.20
```

El siguiente salto debe ser `10.40.0.1`.

---

# 3. Preparación de Suricata

FW01 incorpora **Suricata preinstalado**. No es necesario instalar el paquete desde Internet.

La configuración del sensor sí forma parte de la práctica.

FW01 dispone de:

```text
2 GB RAM
```

como configuración de referencia del laboratorio.

---

# 4. Interfaz monitorizada

Selecciona la interfaz correspondiente a DMZ o la indicada por el instructor.

Define correctamente:

```text
HOME_NET
```

para que incluya la red que quieres proteger.

Para la DMZ del laboratorio:

```text
10.30.0.0/24
```

No copies valores sin comprobar qué interfaz estás monitorizando.

---

# 5. Regla local controlada

Añade una regla de laboratorio que genere una alerta sin explotación.

Utiliza:

```text
alert http 10.40.0.0/24 any -> 10.30.0.0/24 any \
(msg:"TELVORA M03 suspicious lab URI"; \
flow:to_server,established; \
http.uri; content:"/telvora-lab-probe"; \
sid:1000001; rev:1;)
```

La regla representa tráfico iniciado desde CORP (`10.40.0.0/24`) hacia la DMZ (`10.30.0.0/24`).

La regla utiliza un identificador local (`sid`) reservado para el laboratorio.

---

# 6. Interpreta la regla

Explica:

- acción;
- protocolo;
- red origen;
- puerto origen;
- red destino;
- puerto destino;
- `flow`;
- buffer `http.uri`;
- `content`;
- `sid`;
- `rev`.

No continúes hasta entender qué condición dispara la detección.

---

# 7. Generación de tráfico benigno

Desde `LABSERV01` en CORP accede normalmente al servidor en DMZ:

```bash
curl -I --connect-timeout 3 http://10.30.0.20/
```

No debería activarse la regla personalizada `1000001`.

Registra si existe otra alerta del ruleset general.

---

# 8. Generación del marcador de laboratorio

Desde `LABSERV01` solicita:

```text
http://10.30.0.20/telvora-lab-probe
```

Ejemplo:

```bash
curl http://10.30.0.20/telvora-lab-probe
```

Aunque el servidor devuelva `404`, la petición HTTP debe atravesar FW01 y el sensor puede satisfacer la condición de detección.

---

# 9. Analiza la alerta

Localiza la alerta y registra:

| Campo | Valor |
|---|---|
| Timestamp | |
| SID | |
| Mensaje | |
| IP origen | |
| Puerto origen | |
| IP destino | |
| Puerto destino | |
| Protocolo | |
| Interfaz | |

Relaciona la alerta con la solicitud que acabas de generar.

---

# 10. Correlación con firewall

Busca en los logs de pfSense el mismo flujo.

Responde:

1. ¿El firewall permitió o bloqueó la conexión?
2. ¿Suricata alertó?
3. ¿Existe contradicción?

Explica por qué:

```text
ALLOW del firewall
```

y:

```text
ALERT del IDS
```

pueden ser correctos simultáneamente.

---

# 11. Segunda regla

Diseña una regla que detecte intentos de acceso SSH hacia `LINUX01`.

No debe bloquear tráfico. Debe alertar.

Criterios:

```text
destino = 10.30.0.20
puerto = 22/TCP
evento = inicio de conexión
```

Utiliza un `sid` local diferente.

Para probarla puedes generar una conexión autorizada desde LABSERV01/CORP, según la política creada en P03.1:

```bash
nc -vz -w 3 10.30.0.20 22
```

Documenta la regla y explica posibles falsos positivos.

---

# 12. Tuning

Supón que la segunda regla genera cientos de alertas porque un sistema de monitorización comprueba SSH cada minuto.

Propón al menos dos estrategias:

- limitar frecuencia;
- excluir un origen confiable;
- modificar el criterio de detección;
- utilizar contexto adicional.

Para cada estrategia explica el riesgo de suprimir demasiado.

---

# 13. IDS frente a IPS

Responde:

1. ¿Qué cambiaría si Suricata operase inline como IPS?
2. ¿Qué riesgo operacional introduce un falso positivo en modo IPS?
3. ¿Por qué puede ser razonable desplegar primero en IDS?
4. ¿Qué evidencia necesitarías antes de convertir una regla propia en bloqueo?

No es obligatorio activar IPS inline en esta práctica.

---

# 14. Entregable P03.2

Prepara un **Detection Brief** con:

- interfaz monitorizada;
- HOME_NET;
- regla 1000001;
- regla diseñada para SSH;
- dos alertas o pruebas realizadas;
- correlación con firewall;
- posible falso positivo;
- propuesta de tuning;
- decisión razonada IDS/IPS.
