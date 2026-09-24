# M01 — Fundamentos de Ciberseguridad, Ciberinteligencia y Ciberdefensa
## Enunciado de laboratorio

**Programa:** Programa Avanzado de Ciberinteligencia y Ciberdefensa  
**Módulo:** M01  
**Prácticas incluidas:** P01.1 y P01.2  
**Versión:** 1.0 — septiembre de 2026

---

# 1. Objetivos prácticos del módulo

Al finalizar estas prácticas, el alumno deberá ser capaz de:

- reconocer los elementos fundamentales de un entorno técnico antes de realizar cualquier análisis de seguridad;
- distinguir host, interfaz, red, servicio, puerto, activo y superficie de exposición;
- identificar servicios visibles sin realizar explotación;
- registrar observaciones técnicas separando **hechos**, **inferencias** e **hipótesis**;
- relacionar activos y servicios con amenazas plausibles;
- utilizar un informe de threat landscape como fuente de ciberinteligencia;
- transformar datos generales sobre amenazas en una priorización aplicable a una organización;
- justificar decisiones indicando evidencia, impacto, probabilidad y nivel de confianza;
- diferenciar ciberseguridad, ciberinteligencia y ciberdefensa dentro de un mismo escenario.

---

# 2. Entorno de laboratorio

## 2.1 Máquinas utilizadas

Este módulo utiliza:

| Máquina | Sistema | RAM orientativa | Uso |
|---|---|---:|---|
| `KALI01` | Kali Linux | 1.5 GB | Estación de análisis y descubrimiento |
| `LINUX01` | Ubuntu Server | 1 GB | Servidor Linux de laboratorio |
| `MEMBER01` | Windows Server 2025 Core | 2 GB | Sistema Windows de laboratorio |

Las tres máquinas pertenecen exclusivamente al cyber range del curso.

> **Regla de alcance:** no se debe escanear ninguna red, sistema o dirección que no pertenezca al entorno aislado proporcionado para el laboratorio.

## 2.2 Ejecución con 8 GB y 16 GB de RAM

### Equipo físico con 8 GB

La práctica se realiza por fases:

**Fase A**

- `KALI01`
- `LINUX01`

Al terminar la Fase A se apaga `LINUX01`.

**Fase B**

- `KALI01`
- `MEMBER01`

La RAM simultánea de las VMs permanece aproximadamente entre 2.5 y 3.5 GB.

### Equipo físico con 16 GB o más

Se pueden mantener encendidas simultáneamente:

- `KALI01`
- `LINUX01`
- `MEMBER01`

El procedimiento y los resultados esperados son los mismos en ambos perfiles.

---

# P01.1 — Telvora Cyber Range Discovery
## Reconocimiento técnico, servicios y superficie de exposición

### 1. Escenario

Acabas de incorporarte al equipo de ciberseguridad de **Telvora Communications (TELVORA)**, una operadora ficticia utilizada durante el programa.

Se te entrega acceso a un pequeño segmento aislado de laboratorio del que no existe documentación fiable. Antes de analizar riesgos, vulnerabilidades o amenazas, el equipo necesita responder a una pregunta más básica:

> **¿Qué tenemos realmente delante?**

Tu trabajo consiste en obtener una primera imagen técnica del entorno sin explotar vulnerabilidades ni modificar los sistemas.

No debes partir de una lista de IPs suministrada por el instructor. La práctica comienza obteniendo información del propio entorno.

---

## 2. Objetivos

Debes ser capaz de:

1. identificar la configuración de red de tu estación de análisis;
2. determinar la red o redes directamente alcanzables;
3. identificar los hosts activos del laboratorio;
4. asociar cada host con la función más probable;
5. identificar los principales puertos y servicios visibles;
6. distinguir lo que **sabes** de lo que únicamente **infieres**;
7. representar la superficie inicial de exposición;
8. elaborar una breve priorización de revisión posterior.

---

## 3. Restricciones

Durante esta práctica está permitido:

- consultar la configuración local;
- utilizar `ping` cuando proceda;
- consultar tablas ARP/neighbour;
- realizar descubrimiento de hosts;
- realizar escaneo TCP de puertos;
- realizar identificación básica de servicios y versiones;
- consultar banners;
- consultar la configuración local de las propias VMs.

Durante esta práctica **no** está permitido:

- explotar vulnerabilidades;
- realizar ataques de contraseña;
- utilizar Metasploit para explotación;
- modificar configuraciones del sistema objetivo;
- detener servicios;
- realizar acciones de persistencia;
- escanear direcciones ajenas al cyber range.

El propósito es **descubrimiento y análisis**, no explotación.

---

## 4. Fase 1 — Conoce tu estación

Desde `KALI01`, determina:

- hostname;
- dirección o direcciones IP;
- máscara/prefijo;
- interfaz utilizada;
- gateway, si existe;
- servidores DNS configurados;
- tabla de rutas;
- vecinos conocidos.

Registra los comandos utilizados y los datos obtenidos.

### Entregable parcial

Completa:

| Dato | Resultado |
|---|---|
| Hostname | |
| Interfaz principal | |
| IPv4 | |
| Prefijo | |
| Gateway | |
| DNS | |
| Red directamente conectada | |

---

## 5. Fase 2 — Descubrimiento de LINUX01

Arranca `LINUX01`.

Desde su consola local, averigua únicamente su dirección IP para comprobar posteriormente tus resultados de descubrimiento. No utilices todavía esa información desde Kali para saltarte el proceso.

Desde `KALI01`:

1. identifica qué hosts responden en la red del laboratorio;
2. compara el resultado con las entradas de la tabla de vecinos;
3. identifica cuál podría corresponder a `LINUX01`;
4. realiza un escaneo TCP inicial;
5. realiza después identificación de servicios únicamente sobre los puertos detectados.

No realices un escaneo indiscriminado de Internet ni de otras redes del equipo anfitrión.

### Entregable parcial

| Campo | Resultado |
|---|---|
| IP atribuida a LINUX01 | |
| Evidencia utilizada para atribuirla | |
| Puertos TCP visibles | |
| Servicios inferidos | |
| Versiones identificadas, si procede | |
| Nivel de confianza | Alto / Medio / Bajo |

---

## 6. Fase 3 — De puerto a servicio

Para cada puerto relevante detectado en `LINUX01`, registra:

| Puerto | Estado | Servicio | Evidencia | Riesgo potencial a revisar |
|---:|---|---|---|---|
| | | | | |
| | | | | |
| | | | | |

No debes afirmar que existe una vulnerabilidad únicamente porque un puerto esté abierto.

Ejemplo de razonamiento válido:

> “El puerto TCP X está accesible y la identificación de servicio devuelve Y. Esto demuestra exposición del servicio Y. No demuestra por sí mismo que el servicio sea vulnerable.”

---

## 7. Fase 4 — Validación desde el propio servidor

En `LINUX01`, identifica:

- procesos escuchando en red;
- puertos asociados;
- servicios iniciados;
- direcciones en las que escucha cada servicio.

Compara la visión **externa** obtenida desde Kali con la visión **interna** del servidor.

Responde:

1. ¿Todos los sockets en escucha son necesariamente visibles desde Kali?
2. ¿Qué diferencia existe entre escuchar en `127.0.0.1` y escuchar en `0.0.0.0`?
3. ¿Por qué un servicio activo puede no aparecer en un escaneo remoto?

---

## 8. Fase 5 — Descubrimiento de MEMBER01

### Perfil de 8 GB

1. guarda tus resultados;
2. apaga `LINUX01`;
3. arranca `MEMBER01`;
4. mantén `KALI01` encendida.

### Perfil de 16 GB

Puedes mantener las tres VMs encendidas.

Repite para `MEMBER01` el proceso de:

- identificación del host;
- descubrimiento de puertos TCP;
- identificación básica de servicios;
- interpretación del propósito probable del sistema.

No realices autenticación ofensiva ni explotación.

Completa:

| Campo | Resultado |
|---|---|
| IP atribuida a MEMBER01 | |
| Puertos TCP visibles | |
| Servicios inferidos | |
| Función probable del host | |
| Evidencias | |
| Nivel de confianza | Alto / Medio / Bajo |

---

## 9. Fase 6 — Hecho, inferencia o hipótesis

Clasifica cada afirmación que hayas producido durante la práctica como:

- **H — Hecho:** observado directamente.
- **I — Inferencia:** conclusión razonable sustentada por uno o más hechos.
- **P — Hipótesis:** posibilidad que requiere verificación adicional.

Debes incluir al menos:

- cinco hechos;
- tres inferencias;
- dos hipótesis.

Ejemplo:

| Tipo | Afirmación | Evidencia |
|---|---|---|
| H | El host responde en TCP/22 | Resultado del escaneo |
| I | Probablemente ofrece administración SSH | Identificación de servicio |
| P | Podría existir riesgo por credenciales débiles | No evaluado todavía |

---

## 10. Fase 7 — Superficie de exposición

Construye un esquema sencillo como el siguiente, adaptado a tus resultados:

```text
KALI01
   |
   +---- Host A
   |       +-- servicio 1
   |       +-- servicio 2
   |
   +---- Host B
           +-- servicio 3
           +-- servicio 4
```

Para cada host responde:

1. ¿Qué activos o capacidades parece ofrecer?
2. ¿Qué servicios aumentan su superficie de exposición?
3. ¿Qué información adicional pedirías antes de realizar una evaluación de seguridad?
4. ¿Cuál revisarías primero y por qué?

---

## 11. Resultado final de P01.1

Entrega un **Discovery Brief** de una página como máximo con:

### Alcance
Red y sistemas analizados.

### Activos observados
Hosts y función estimada.

### Exposición
Servicios principales visibles.

### Incertidumbre
Qué afirmaciones requieren todavía confirmación.

### Prioridad
Tres aspectos que recomendarías revisar en una fase posterior.

No debes incluir ninguna afirmación de vulnerabilidad que no haya sido demostrada.

---

# P01.2 — Threat Landscape Challenge
## De información pública a inteligencia accionable

### 1. Escenario

TELVORA presta servicios de telecomunicaciones y servicios digitales a organizaciones y usuarios de varios países europeos.

El comité de seguridad solicita al equipo una actualización breve:

> “Tenemos decenas de amenazas posibles. ¿Cuáles debemos vigilar primero durante los próximos meses y por qué?”

No se espera una repetición del informe de ENISA. Debes transformar información general del panorama de amenazas en una **priorización específica para TELVORA**.

---

## 2. Fuente principal

Utiliza como referencia:

**ENISA Threat Landscape 2025**  
European Union Agency for Cybersecurity (ENISA)  
Publicación: 1 de octubre de 2025  
Periodo analizado: 1 de julio de 2024 a 30 de junio de 2025

Página oficial:

https://www.enisa.europa.eu/publications/enisa-threat-landscape-2025

Datos que puedes considerar, verificándolos en la fuente:

- DDoS representa una parte muy elevada de los incidentes analizados;
- ransomware continúa destacando por impacto;
- phishing aparece como principal vía de acceso inicial;
- explotación de vulnerabilidades figura también entre los accesos iniciales relevantes;
- las dependencias y cadenas de suministro incrementan el impacto potencial;
- digital infrastructure and services se encuentra entre los sectores relevantes;
- dentro de ese grupo, telecomunicaciones presenta una exposición significativa.

No debes convertir automáticamente “frecuente” en “más importante”: frecuencia e impacto no son la misma variable.

---

## 3. Perfil simplificado de TELVORA

TELVORA dispone de:

- portales públicos de clientes;
- infraestructura DNS y servicios de conectividad;
- aplicaciones internas;
- correo corporativo;
- usuarios con acceso remoto;
- proveedores tecnológicos;
- plataformas cloud;
- información de clientes;
- servicios cuya indisponibilidad puede afectar a miles de usuarios.

El ejercicio no pretende reproducir una operadora real concreta.

---

## 4. Escenarios a priorizar

Analiza estos cinco escenarios:

### T1 — DDoS sobre servicios públicos

Una campaña hacktivista dirige tráfico masivo contra portales y servicios públicos de TELVORA durante un contexto de tensión geopolítica.

### T2 — Ransomware con exfiltración

Un actor criminal consigue acceso a la red corporativa, extrae información y despliega ransomware en parte del entorno.

### T3 — Phishing dirigido a personal con privilegios

Usuarios con acceso administrativo reciben una campaña de phishing diseñada para obtener credenciales o sesiones.

### T4 — Explotación de un servicio perimetral vulnerable

Un servicio accesible desde Internet presenta una vulnerabilidad conocida que puede ser aprovechada antes de completarse el ciclo de parcheado.

### T5 — Compromiso de proveedor

Un proveedor con acceso autorizado o integración tecnológica es comprometido y se utiliza esa relación de confianza como vía hacia TELVORA.

---

## 5. Modelo de análisis

Para cada escenario valora de 1 a 5:

### Probabilidad
1 = muy baja  
5 = muy alta

### Impacto
1 = menor  
5 = crítico

### Exposición
1 = TELVORA tiene poca exposición  
5 = exposición directa o amplia

Calcula:

```text
Prioridad inicial = Probabilidad × Impacto × Exposición
```

La cifra no sustituye al juicio analítico. Sirve para hacer explícito tu razonamiento.

Añade además:

### Confianza
- Alta
- Media
- Baja

La confianza no mide gravedad. Mide cuánto confías en tu evaluación a partir de la evidencia disponible.

---

## 6. Matriz de trabajo

| Amenaza | Prob. | Impacto | Exposición | Puntuación | Confianza | Evidencia principal |
|---|---:|---:|---:|---:|---|---|
| T1 DDoS | | | | | | |
| T2 Ransomware | | | | | | |
| T3 Phishing | | | | | | |
| T4 Explotación | | | | | | |
| T5 Proveedor | | | | | | |

Ordena después las cinco amenazas según la prioridad que propondrías a TELVORA.

No existe obligación de obtener exactamente el mismo orden que otros equipos. La evaluación se basa principalmente en la **calidad de la justificación**.

---

## 7. De amenaza a activo y vector

Completa:

| Amenaza | Activos principales afectados | Vector o condición inicial | Consecuencia más relevante |
|---|---|---|---|
| T1 | | | |
| T2 | | | |
| T3 | | | |
| T4 | | | |
| T5 | | | |

---

## 8. Del dato a la inteligencia

Selecciona una de las cinco amenazas y escribe:

### Dato
Un dato concreto procedente de ENISA.

### Información
Qué significa ese dato en su contexto.

### Inteligencia
Qué implica específicamente para TELVORA.

### Decisión
Qué decisión o prioridad puede adoptar un responsable a partir de esa inteligencia.

Ejemplo de estructura:

```text
DATO
...

INFORMACIÓN
...

INTELIGENCIA
...

DECISIÓN
...
```

---

## 9. Ciberseguridad, ciberinteligencia y ciberdefensa

Para el escenario seleccionado, indica una actividad que correspondería principalmente a:

### Ciberseguridad
Medida preventiva, protectora o de reducción de riesgo.

### Ciberinteligencia
Obtención y análisis de información para reducir incertidumbre.

### Ciberdefensa
Capacidad organizada de detección, respuesta, contención y recuperación ante actividad hostil.

Explica por qué las tres disciplinas se complementan.

---

## 10. Threat Brief final

Prepara un briefing de máximo **una página** dirigido al responsable de seguridad de TELVORA.

Debe contener:

1. **Situación:** qué está cambiando o qué destaca.
2. **Top 3 amenazas:** las tres prioridades propuestas.
3. **Por qué TELVORA está expuesta.**
4. **Indicadores a vigilar:** no IOCs concretos, sino señales relevantes.
5. **Acciones prioritarias:** tres acciones razonables.
6. **Confianza:** nivel de confianza global y principales incertidumbres.

El documento debe distinguir claramente:

- evidencia;
- interpretación;
- recomendación.

---

# 3. Entregables del módulo

Al finalizar M01 deben existir:

## P01.1

- tabla de configuración de KALI01;
- resultados de descubrimiento de LINUX01;
- resultados de descubrimiento de MEMBER01;
- tabla hecho / inferencia / hipótesis;
- esquema de superficie de exposición;
- Discovery Brief.

## P01.2

- matriz de priorización de cinco amenazas;
- relación amenaza-activo-vector-consecuencia;
- ejercicio dato → información → inteligencia → decisión;
- distinción ciberseguridad / ciberinteligencia / ciberdefensa;
- Threat Brief.

---

# 4. Principios importantes

- Un puerto abierto no equivale a una vulnerabilidad.
- Una herramienta no sustituye al razonamiento.
- Un dato no es automáticamente inteligencia.
- Frecuencia no equivale a impacto.
- Una valoración sin nivel de confianza oculta incertidumbre.
- El objetivo del análisis es apoyar una decisión.

---

# 5. Fuentes recomendadas

- ENISA Threat Landscape 2025  
  https://www.enisa.europa.eu/publications/enisa-threat-landscape-2025

- ENISA Cybersecurity Threat Landscape Methodology  
  https://www.enisa.europa.eu/publications/enisa-cybersecurity-threat-landscape-methodology

- MITRE ATT&CK  
  https://attack.mitre.org/

---
