# P03.2 — Telvora Network Detection Lab
## Suricata, reglas de detección y análisis de alertas

> **Antes de comenzar:** revisa el [entorno común, topología y perfil de memoria del M03](../README.md#3-entorno-de-laboratorio).

---

# 1. Objetivo

En P03.1 el firewall responde a:

> **¿Debe permitirse este flujo?**

Ahora el IDS debe ayudar a responder:

> **¿Qué está ocurriendo dentro del tráfico permitido?**

No todo tráfico permitido es legítimo.

---

# 2. Preparación

Para esta práctica `FW01` incorpora el paquete Suricata.

La imagen del curso puede entregarlo preinstalado para que la práctica no dependa de repositorios externos.

Si el instructor indica lo contrario, se instalará desde el Package Manager de pfSense.

Asigna temporalmente a `FW01`:

```text
2 GB RAM
```

si el equipo lo permite.

---

# 3. Interfaz monitorizada

Selecciona la interfaz correspondiente a DMZ o la indicada por el instructor.

Define correctamente:

```text
HOME_NET
```

para que incluya la red que quieres proteger.

Ejemplo conceptual:

```text
10.30.0.0/24
```

No copies valores sin comprobar qué interfaz estás monitorizando.

---

# 4. Regla local controlada

Añade una regla de laboratorio que genere una alerta sin explotación.

Utiliza:

```text
alert http 10.40.0.0/24 any -> 10.30.0.0/24 any \
(msg:"TELVORA M03 suspicious lab URI"; \
flow:to_server,established; \
http.uri; content:"/telvora-lab-probe"; \
sid:1000001; rev:1;)
```

Si la interfaz o redes de tu entorno son distintas, adapta las direcciones.

La regla utiliza un identificador local (`sid`) reservado para el laboratorio.

---

# 5. Interpreta la regla

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

# 6. Generación de tráfico benigno

Desde CORP accede normalmente al servidor:

```text
http://10.30.0.20/
```

No debería activarse la regla personalizada.

Registra si existe otra alerta del ruleset general.

---

# 7. Generación del marcador de laboratorio

Desde un navegador o `curl` en CORP solicita:

```text
http://10.30.0.20/telvora-lab-probe
```

Ejemplo:

```bash
curl http://10.30.0.20/telvora-lab-probe
```

Aunque el servidor devuelva `404`, la petición HTTP debe atravesar el sensor y puede satisfacer la condición de detección.

---

# 8. Analiza la alerta

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

# 9. Correlación con firewall

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

# 10. Segunda regla

Diseña una regla que detecte intentos de acceso SSH hacia `LINUX01`.

No debe bloquear tráfico. Debe alertar.

Criterios:

```text
destino = 10.30.0.20
puerto = 22/TCP
evento = inicio de conexión
```

Utiliza un `sid` local diferente.

Documenta la regla y explica posibles falsos positivos.

---

# 11. Tuning

Supón que la segunda regla genera cientos de alertas porque un sistema de monitorización comprueba SSH cada minuto.

Propón al menos dos estrategias:

- limitar frecuencia;
- excluir un origen confiable;
- modificar el criterio de detección;
- utilizar contexto adicional.

Para cada estrategia explica el riesgo de suprimir demasiado.

---

# 12. IDS frente a IPS

Responde:

1. ¿Qué cambiaría si Suricata operase inline como IPS?
2. ¿Qué riesgo operacional introduce un falso positivo en modo IPS?
3. ¿Por qué puede ser razonable desplegar primero en IDS?
4. ¿Qué evidencia necesitarías antes de convertir una regla propia en bloqueo?

No es obligatorio activar IPS inline en esta práctica.

---

# 13. Entregable P03.2

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
