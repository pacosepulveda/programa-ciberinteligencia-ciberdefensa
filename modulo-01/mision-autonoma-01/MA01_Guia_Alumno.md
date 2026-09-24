# MA01 — Telvora Casebook 01: Shadow Exposure
## Misión autónoma

**Programa:** Programa Avanzado de Ciberinteligencia y Ciberdefensa  
**Empresa:** Telvora Communications  
**Módulo de partida:** M01 — Fundamentos de Ciberseguridad, Ciberinteligencia y Ciberdefensa  
**Modalidad:** individual  
**Entorno:** Telvora Cyber Range  
**Segmento autorizado:** `10.20.0.0/24`

---

# 1. Situación

El inventario de Telvora describe un pequeño entorno de laboratorio usado para validar servicios internos antes de incorporarlos a otros segmentos.

La responsable de seguridad ha detectado una discrepancia entre la documentación disponible y algunas observaciones técnicas recientes. No hay evidencia de compromiso y no se solicita una prueba de penetración.

El objetivo es responder a una pregunta más concreta:

> **¿La superficie de exposición real del entorno coincide con la que Telvora cree tener documentada?**

La misión combina descubrimiento técnico, análisis de evidencias y ciberinteligencia. No consiste en encontrar “el mayor número posible de problemas”.

---

# 2. Objetivos

Al finalizar la investigación debes ser capaz de:

- reconstruir el entorno a partir de información incompleta;
- descubrir los hosts activos sin recibir una lista de IPs completa;
- caracterizar `LINUX01` y el controlador de dominio de `TELVORA.LAB`;
- diferenciar **servicio expuesto**, **debilidad**, **vulnerabilidad** y **riesgo**;
- comparar inventario documental con evidencia técnica;
- correlacionar resultados de red, logs, captura y documentación;
- separar hechos, inferencias e hipótesis;
- construir una cronología defendible;
- valorar el riesgo de una exposición no documentada;
- identificar intelligence gaps y preguntas prioritarias;
- proponer medidas proporcionadas;
- redactar un Executive Security & Intelligence Brief.

---

# 3. Reglas de alcance

Está permitido:

- consultar configuración local de `KALI01`;
- descubrir hosts en `10.20.0.0/24`;
- realizar escaneo TCP y detección de servicios sobre los hosts del cyber range;
- usar `curl`, consultas DNS y herramientas de observación;
- analizar los ficheros proporcionados;
- consultar localmente la configuración de las VMs propias cuando sea necesario para validar una hipótesis.

No está permitido:

- escanear redes ajenas a `10.20.0.0/24`;
- realizar fuerza bruta o ataques de contraseña;
- explotar vulnerabilidades;
- obtener persistencia;
- modificar configuraciones para “crear” un hallazgo;
- detener servicios de forma deliberada;
- asumir que un puerto abierto equivale a una vulnerabilidad.

> **El objetivo es obtener evidencia y reducir incertidumbre, no explotar sistemas.**

---

# 4. Entorno

Se utilizan:

- `KALI01` — estación de análisis;
- `LINUX01` — Ubuntu Server con servicios web y administración remota;
- `AD01` — Ubuntu Server con Samba Active Directory Domain Controller;
- dominio: `TELVORA.LAB`.

Datos conocidos de partida:

- `KALI01` pertenece al segmento `10.20.0.0/24`;
- `LINUX01` existe en ese segmento;
- hay un servicio de directorio para `TELVORA.LAB`;
- el inventario corporativo puede estar incompleto.

No se entrega la IP de `AD01`. Debe deducirse mediante evidencia técnica.

Si el equipo físico tiene memoria limitada, mantén `KALI01` activa y trabaja secuencialmente con `LINUX01` y `AD01`.

---

# 5. Material de caso

Antes de comenzar revisa:

```text
casebook/
├── architecture.png
├── inventory.csv
├── observaciones-corporativas.md
├── timeline.csv
├── nginx-access.log
├── auth.log
├── capture.pcap
├── change-request.txt
├── threat-advisory.txt
└── mensaje-responsable-seguridad.txt
```

No presupongas que todos los documentos son completos ni que una observación informal es un hecho confirmado.

---

# 6. Fase 1 — Reconstrucción inicial

Examina:

- `architecture.png`;
- `inventory.csv`;
- `observaciones-corporativas.md`;
- `change-request.txt`.

Crea una tabla con tres columnas:

| Elemento | Lo que Telvora cree saber | Qué falta por confirmar |
|---|---|---|
| LINUX01 | | |
| AD01 | | |
| Servicios | | |
| Accesos administrativos | | |
| Dependencias | | |

Identifica al menos **tres intelligence gaps** antes de ejecutar ninguna herramienta.

---

# 7. Fase 2 — Descubrimiento técnico

Desde `KALI01`:

1. identifica tu interfaz y rutas;
2. determina el segmento directamente conectado;
3. descubre los hosts activos de `10.20.0.0/24`;
4. registra los comandos utilizados;
5. conserva las salidas relevantes como evidencia.

Ejemplos de herramientas válidas:

```bash
ip -br addr
ip route
ip neigh
nmap -sn 10.20.0.0/24
```

No des por identificado un host únicamente porque responda a ICMP.

---

# 8. Fase 3 — Caracterización de LINUX01

Localiza `LINUX01` y caracteriza su superficie visible.

Realiza primero un escaneo de puertos y después identifica servicios únicamente sobre los puertos encontrados.

Puedes utilizar, entre otros:

```bash
nmap -sT <IP>
nmap -sV -p <puertos> <IP>
curl -i http://<IP>/
```

Compara lo observado con `inventory.csv`.

Debes poder responder:

1. ¿Qué servicios aparecen realmente accesibles?
2. ¿Coinciden con el inventario?
3. ¿Existe exposición no reflejada documentalmente?
4. ¿Qué puedes afirmar con certeza?
5. ¿Qué **no** puedes afirmar todavía?

### Punto crítico

Si descubres un servicio que no aparece en inventario, la conclusión correcta no es automáticamente:

> “El servidor es vulnerable.”

Una formulación profesional sería:

> “Se ha confirmado una exposición no reflejada en el inventario. Debe validarse su necesidad, ownership, restricciones de acceso y configuración antes de valorar el riesgo residual.”

---

# 9. Fase 4 — Identificación de AD01

No se proporciona su IP.

Debes justificar la atribución utilizando las características observadas. Busca evidencia consistente con un controlador de dominio Samba AD, por ejemplo servicios asociados a:

- DNS;
- Kerberos;
- LDAP;
- SMB.

No es necesario realizar autenticación ofensiva.

Registra:

| Evidencia | Observación | Interpretación | Confianza |
|---|---|---|---|
| | | | |

La conclusión debe explicar **por qué** atribuyes ese host a `AD01` y no limitarse a anotar una IP.

---

# 10. Fase 5 — Correlación con el Casebook

Analiza:

- `nginx-access.log`;
- `auth.log`;
- `capture.pcap`;
- `timeline.csv`;
- `change-request.txt`;
- `threat-advisory.txt`.

Puedes usar Wireshark o `tshark` para la captura si están disponibles.

Ejemplos:

```bash
tshark -r casebook/capture.pcap
tshark -r casebook/capture.pcap -Y "tcp.port == 22"
tshark -r casebook/capture.pcap -Y "http"
```

Responde:

1. ¿Qué hechos están respaldados por más de una fuente?
2. ¿Qué evidencia confirma la exposición web?
3. ¿Qué evidencia confirma la existencia de administración remota?
4. ¿La solicitud de cambio documenta ambos servicios?
5. ¿Existe evidencia de explotación o compromiso?
6. ¿Qué explicación alternativa sería razonable?

---

# 11. Fase 6 — Hechos, inferencias e hipótesis

Completa al menos:

- 8 hechos;
- 5 inferencias;
- 3 hipótesis.

Utiliza esta estructura:

| Tipo | Afirmación | Evidencia | Confianza | Qué la refutaría |
|---|---|---|---|---|
| H / I / P | | | | |

Ejemplos de la distinción:

**Hecho**

> TCP/22 responde en LINUX01 y la detección de servicio identifica OpenSSH.

**Inferencia**

> LINUX01 dispone de un camino de administración remota accesible desde el segmento.

**Hipótesis**

> El servicio SSH podría haberse mantenido tras el aprovisionamiento aunque ya no fuese necesario.

La hipótesis necesita verificación.

---

# 12. Fase 7 — Cronología

Construye una cronología única utilizando las evidencias proporcionadas y tus propias observaciones.

Incluye al menos:

- cambio documentado;
- actividad web;
- actividad de autenticación;
- observaciones técnicas;
- momento de tu validación.

Marca cada evento como:

- confirmado;
- inferido;
- pendiente de confirmar.

---

# 13. Fase 8 — Threat assessment

Utiliza `threat-advisory.txt` como **información de contexto**, no como prueba de que Telvora esté siendo atacada.

Evalúa:

### Activo
¿Qué activo o capacidad se ve afectada?

### Exposición
¿Qué servicio o camino está accesible y desde dónde?

### Amenaza plausible
¿Qué tipo de actor o acción podría beneficiarse de esa exposición?

### Condiciones necesarias
¿Qué tendría que ser cierto para que el escenario produzca impacto?

### Impacto
¿Qué consecuencias serían relevantes?

### Controles existentes
¿Qué controles conoces realmente y cuáles solo supones?

### Confianza
Alta / Media / Baja.

---

# 14. Fase 9 — Hipótesis alternativas

Debes mantener al menos dos explicaciones hasta disponer de evidencia suficiente.

Por ejemplo:

**H1 — Exposición administrativa necesaria y autorizada**

SSH es necesario para operación y existe una justificación que no quedó reflejada en el inventario exportado.

**H2 — Exposición residual de aprovisionamiento**

SSH se habilitó durante el despliegue y quedó accesible aunque el servicio ya no fuese necesario.

No selecciones una hipótesis solo porque parezca más “interesante”. Indica qué evidencia necesitarías para discriminar entre ambas.

---

# 15. Fase 10 — Decisión y mitigación

Propón una decisión proporcionada.

No es obligatorio recomendar cerrar SSH. La acción depende de su necesidad real.

Ejemplos de alternativas a valorar:

- confirmar el owner y la necesidad del servicio;
- actualizar el inventario;
- limitar el origen de administración;
- ubicar la administración en una red específica;
- aplicar autenticación reforzada;
- revisar privilegios;
- mejorar logging;
- establecer revisión y fecha de expiración de excepciones;
- deshabilitar el servicio si no existe necesidad operacional.

Para cada acción prioritaria indica:

| Acción | Riesgo que reduce | Owner propuesto | Evidencia de cierre |
|---|---|---|---|
| | | | |

---

# 16. Fase 11 — Intelligence gaps y PIR

Formula entre **2 y 3 preguntas prioritarias de inteligencia (PIR)** que realmente puedan cambiar una decisión.

Ejemplos de categorías:

- necesidad operacional del acceso;
- población autorizada;
- origen permitido;
- controles de autenticación;
- exposición histórica;
- intentos anómalos;
- cambios no documentados.

Evita preguntas genéricas que no alteren ninguna decisión.

---

# 17. Entregables

## 17.1. Casebook

Utiliza `plantillas/MA01_Casebook.md` como base.

Debe contener:

- reconstrucción del entorno;
- inventario observado;
- evidencias;
- discrepancias;
- hechos / inferencias / hipótesis;
- cronología;
- threat assessment;
- hipótesis alternativas;
- intelligence gaps;
- PIR;
- acciones propuestas;
- validaciones.

## 17.2. Executive Security & Intelligence Brief

Máximo **una página**.

Debe contener:

### Situación
Qué se ha investigado y por qué.

### Hallazgos confirmados
Solo aquello respaldado por evidencia.

### Evaluación
Qué significa para Telvora.

### Confianza e incertidumbre
Qué sabemos y qué falta por confirmar.

### Riesgos prioritarios
No una lista de puertos: escenarios.

### Acciones inmediatas
Entre 3 y 5, ordenadas.

### PIR / Intelligence gaps
Las preguntas que pueden cambiar la decisión.

---

# 18. Criterios de calidad

Una investigación sólida:

- conserva evidencia reproducible;
- no confunde exposición con vulnerabilidad;
- no presenta hipótesis como hechos;
- explica por qué atribuye cada host;
- correlaciona varias fuentes;
- incluye alternativas;
- declara incertidumbre;
- propone acciones proporcionales;
- convierte datos técnicos en una decisión.

---

# 19. Pregunta final

La misión termina respondiendo:

> **¿Qué sabe Telvora ahora que no sabía al comenzar, qué riesgo merece atención y qué evidencia adicional cambiaría la decisión?**
