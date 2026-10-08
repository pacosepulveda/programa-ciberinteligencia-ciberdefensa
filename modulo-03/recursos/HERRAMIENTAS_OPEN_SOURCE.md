# Módulo 3 — Herramientas open source de seguridad

Este documento reúne herramientas open source relevantes para varias de las capas defensivas tratadas en el módulo: **SIEM, IDS/IPS, EDR/XDR, NGFW y WAF**.

> **Nota:** que una herramienta sea open source no implica que todos los servicios comerciales, reglas premium, soporte, SaaS o funcionalidades enterprise asociados a ella sean gratuitos. Conviene revisar siempre la licencia y el modelo de soporte antes de utilizarla en producción.

---

# 1. SIEM

Un **SIEM (Security Information and Event Management)** centraliza eventos y logs de múltiples fuentes, permite buscar y correlacionar actividad, generar alertas y mantener evidencia para investigación y cumplimiento.

## Wazuh

**Tipo:** SIEM + XDR  
**Web:** https://wazuh.com/  
**Documentación:** https://documentation.wazuh.com/

Wazuh es una plataforma de seguridad open source que combina capacidades de **SIEM y XDR**. Puede recibir y analizar eventos procedentes de endpoints, servidores, dispositivos de red, aplicaciones y entornos cloud.

Entre sus capacidades destacan:

- análisis y correlación de logs;
- agentes para endpoints;
- File Integrity Monitoring (FIM);
- detección de vulnerabilidades;
- evaluación de configuración y hardening;
- reglas de detección y alertas;
- threat hunting;
- active response;
- dashboards y búsqueda centralizada.

Es especialmente interesante para estudiar cómo la telemetría generada por controles distribuidos termina convertida en eventos y alertas utilizables por un SOC.

---

## OpenSearch Security Analytics

**Tipo:** SIEM / Security Analytics  
**Web:** https://opensearch.org/platform/security-analytics/  
**Documentación:** https://docs.opensearch.org/latest/security-analytics/

OpenSearch es una plataforma open source de búsqueda y análisis distribuido. Su componente **Security Analytics** añade funcionalidades específicamente orientadas a SIEM.

Permite:

- ingerir logs de hosts, dispositivos de red, aplicaciones y cloud;
- crear detectores;
- utilizar reglas Sigma;
- generar findings y alertas;
- correlacionar eventos procedentes de fuentes distintas;
- visualizar relaciones entre eventos;
- integrar threat intelligence.

Es una alternativa interesante cuando se quiere construir una plataforma de analítica de seguridad más modular y controlada por la propia organización.

---

# 2. IDS / IPS

Un **IDS (Intrusion Detection System)** inspecciona actividad para detectar patrones sospechosos y generar alertas. Un **IPS (Intrusion Prevention System)** puede además actuar inline y bloquear tráfico.

## Suricata

**Tipo:** IDS / IPS / Network Security Monitoring  
**Web:** https://suricata.io/  
**Documentación:** https://docs.suricata.io/

Suricata es un motor open source de detección y prevención de intrusiones mantenido por la Open Information Security Foundation (OISF).

Puede trabajar como:

- IDS pasivo;
- IPS inline;
- motor de inspección de protocolos;
- generador de telemetría de red;
- fuente de eventos para SIEM.

Soporta reglas de detección, inspección de protocolos de aplicación y salida estructurada mediante **EVE JSON**, lo que facilita su integración con otras plataformas de monitorización.

Es la herramienta utilizada como referencia en el laboratorio **P03.2**.

---

## Snort

**Tipo:** IDS / IPS  
**Web:** https://www.snort.org/  
**Documentación y descargas:** https://www.snort.org/downloads/

Snort es uno de los IDS/IPS open source más conocidos. Utiliza un lenguaje de reglas para describir actividad de red que debe detectarse.

Puede funcionar como:

- sniffer de paquetes;
- packet logger;
- IDS;
- IPS inline.

Es especialmente útil para comprender la detección basada en firmas y el ciclo de creación, ajuste y mantenimiento de reglas.

El motor y las reglas comunitarias son open source; existen además feeds de reglas comerciales mantenidos por Cisco Talos.

---

## Zeek

**Tipo:** Network Security Monitoring / Network Detection  
**Web:** https://zeek.org/  
**Documentación:** https://docs.zeek.org/

Zeek no es un IPS clásico. Es una plataforma open source de **monitorización y análisis de tráfico de red** orientada a proporcionar contexto de alto nivel.

En lugar de centrarse únicamente en firmas, genera registros estructurados sobre protocolos y conexiones, por ejemplo:

- conexiones;
- DNS;
- HTTP;
- TLS/SSL;
- certificados;
- ficheros;
- sesiones y metadatos de aplicación.

Es muy útil para threat hunting, investigación de incidentes y enriquecimiento de SIEM. Suricata y Zeek suelen utilizarse de forma complementaria: Suricata genera detecciones y Zeek aporta contexto de red muy detallado.

---

# 3. EDR / XDR

Un **EDR (Endpoint Detection and Response)** monitoriza endpoints para detectar comportamiento sospechoso, facilitar investigación y responder a incidentes. Un **XDR (Extended Detection and Response)** amplía la correlación a distintas fuentes y dominios de seguridad.

## Wazuh

**Tipo:** XDR + SIEM  
**Web:** https://wazuh.com/  
**Documentación:** https://documentation.wazuh.com/

Además de SIEM, Wazuh dispone de agentes instalables en endpoints y ofrece capacidades de detección y respuesta.

Puede recoger información como:

- cambios en ficheros;
- procesos y eventos del sistema;
- configuración del host;
- vulnerabilidades;
- logs de seguridad;
- indicadores de compromiso.

Permite además ejecutar determinadas respuestas activas ante eventos detectados.

Su interés arquitectónico está en conectar **telemetría del endpoint + detección central + respuesta** dentro de una misma plataforma.

---

## OpenEDR

**Tipo:** EDR  
**Web:** https://www.openedr.com/  
**Código:** https://github.com/ComodoSecurity/openedr

OpenEDR es un proyecto open source orientado a Endpoint Detection and Response.

Proporciona visibilidad de bajo nivel sobre actividad del endpoint, incluyendo procesos, sistema de ficheros, registro y actividad de red, con el objetivo de permitir:

- detección de comportamiento sospechoso;
- análisis de eventos;
- reconstrucción de actividad;
- root cause analysis;
- correlación con MITRE ATT&CK.

Es una referencia útil para estudiar cómo funciona internamente una arquitectura EDR. Como con cualquier proyecto de seguridad, antes de utilizarlo en producción deben evaluarse su madurez, mantenimiento, compatibilidad y advisories de seguridad vigentes.

---

## Velociraptor

**Tipo:** Endpoint monitoring / DFIR / Incident Response  
**Web y documentación:** https://docs.velociraptor.app/

Velociraptor es una plataforma open source orientada a **visibilidad del endpoint, Digital Forensics and Incident Response (DFIR) y threat hunting**.

Permite consultar y recopilar artefactos de endpoints a escala mediante su lenguaje **VQL (Velociraptor Query Language)**.

Entre sus usos habituales están:

- hunting remoto;
- adquisición de evidencia;
- análisis forense;
- búsqueda de indicadores;
- consultas distribuidas sobre endpoints;
- respuesta a incidentes.

No debe interpretarse necesariamente como un sustituto completo de un EDR comercial, pero cubre una parte muy importante de las capacidades de investigación, hunting y respuesta sobre endpoint.

---

# 4. NGFW

**NGFW (Next-Generation Firewall)** es una categoría amplia. Además del filtrado stateful tradicional, suele incluir funciones como VPN, IDS/IPS, control por aplicación, filtrado, inspección avanzada y servicios de seguridad adicionales.

En soluciones open source estas capacidades suelen construirse mediante una plataforma base y diferentes componentes o plugins.

## OPNsense

**Tipo:** Firewall / routing / VPN / IDS-IPS  
**Web:** https://opnsense.org/  
**Documentación:** https://docs.opnsense.org/

OPNsense es una plataforma open source basada en FreeBSD para firewalling y routing.

Incluye o puede integrar capacidades como:

- firewall stateful;
- segmentación por interfaces y VLAN;
- NAT;
- VPN;
- alta disponibilidad;
- traffic shaping;
- IDS/IPS;
- autenticación;
- APIs para automatización.

Es una opción adecuada para laboratorios de arquitectura defensiva y para escenarios en los que se quiere combinar segmentación, firewall e inspección de tráfico.

---

## pfSense Community Edition

**Tipo:** Firewall / router / VPN / IDS-IPS mediante paquetes  
**Web:** https://www.pfsense.org/  
**Documentación:** https://docs.netgate.com/pfsense/en/latest/

**pfSense Community Edition (CE)** es la edición open source del proyecto pfSense. No debe confundirse con **pfSense Plus**, que es un producto diferente.

pfSense CE permite trabajar con:

- reglas de firewall stateful;
- aliases;
- NAT;
- VLAN;
- VPN;
- routing;
- alta disponibilidad;
- logging y monitorización;
- paquetes adicionales como Suricata o Snort.

Es la plataforma elegida como referencia para el laboratorio **P03.1** y como base de red para **P03.2**.

---

## IPFire

**Tipo:** Firewall / routing / VPN / IDS-IPS  
**Web:** https://www.ipfire.org/  
**Documentación:** https://www.ipfire.org/docs

IPFire es una plataforma open source de firewall y seguridad basada en Linux.

Está diseñada alrededor de una arquitectura de zonas y ofrece:

- firewall stateful;
- NAT;
- segmentación;
- VPN;
- IDS/IPS;
- filtrado;
- logging;
- diferentes extensiones y add-ons.

Es especialmente útil para comprender arquitecturas basadas en zonas de diferente confianza y control explícito de comunicaciones entre ellas.

---

# 5. WAF

Un **WAF (Web Application Firewall)** analiza tráfico HTTP/HTTPS de capa 7 y aplica reglas específicas para proteger aplicaciones web y APIs.

Un WAF no sustituye al desarrollo seguro ni corrige vulnerabilidades en el código. Actúa como una capa adicional de defensa.

## OWASP ModSecurity

**Tipo:** WAF engine  
**Web:** https://owasp.org/projects/modsecurity  
**OWASP Core Rule Set:** https://coreruleset.org/

ModSecurity es uno de los motores WAF open source de referencia. Puede integrarse con servidores y proxies web para inspeccionar peticiones y respuestas HTTP.

Normalmente se utiliza junto con **OWASP Core Rule Set (CRS)**, que proporciona reglas genéricas para detectar categorías de ataques como:

- SQL Injection;
- Cross-Site Scripting;
- inyección de comandos;
- protocol violations;
- scanners y comportamiento anómalo.

Es una herramienta muy útil para demostrar la diferencia entre controles de red y controles específicos de aplicación.

---

## OWASP Coraza

**Tipo:** WAF engine  
**Web:** https://coraza.io/  
**Documentación:** https://www.coraza.io/docs/

Coraza es un WAF open source escrito en Go y compatible con reglas en sintaxis SecLang.

Puede utilizar **OWASP Core Rule Set** y está diseñado para integrarse en arquitecturas modernas y cloud-native mediante diferentes conectores.

Resulta especialmente interesante para escenarios con:

- reverse proxies;
- API gateways;
- Kubernetes;
- arquitecturas cloud-native;
- aplicaciones desarrolladas en Go.

---

## open-appsec

**Tipo:** WAF / API Security  
**Web:** https://www.openappsec.io/  
**Código:** https://github.com/openappsec

open-appsec es una plataforma WAF y API Security con componentes open source. Se diferencia de los WAF clásicos basados principalmente en firmas por incorporar modelos de machine learning para identificar tráfico malicioso.

Puede integrarse con tecnologías como:

- NGINX;
- Kubernetes Ingress;
- Kong;
- APISIX;
- Envoy;
- Istio.

Permite estudiar cómo evolucionan los WAF desde conjuntos de reglas tradicionales hacia mecanismos de detección basados también en comportamiento y contexto.

---

# 6. Cómo encajan estas herramientas en una arquitectura defensiva

Estas categorías no son intercambiables. Cada una controla u observa una parte diferente del sistema:

```text
Internet
   │
   ▼
NGFW ──────────────► segmentación, control de flujos, VPN, IPS
   │
   ▼
WAF ───────────────► HTTP/HTTPS, aplicaciones web y APIs
   │
   ▼
Aplicaciones / servidores
   │
   ├───────────────► EDR/XDR: telemetría y respuesta en endpoints
   │
   └───────────────► IDS/NDR: visibilidad y detección en red
                         │
                         ▼
                       SIEM
                         │
                         ▼
             correlación · investigación · alertas
```

La idea importante para el Módulo 3 es que una arquitectura sólida no se construye eligiendo un único producto. Se construye definiendo **qué riesgo queremos reducir, dónde debe actuar el control, qué telemetría produce y cómo vamos a validar que funciona**.

---

# 7. Selección rápida para laboratorio

| Categoría | Herramientas recomendadas para explorar primero |
|---|---|
| SIEM | Wazuh · OpenSearch Security Analytics |
| IDS/IPS | Suricata · Snort · Zeek |
| EDR/XDR | Wazuh · OpenEDR · Velociraptor |
| NGFW | OPNsense · pfSense CE · IPFire |
| WAF | OWASP ModSecurity + CRS · OWASP Coraza · open-appsec |

Para este curso, **pfSense CE + Suricata** permite trabajar directamente segmentación, enforcement y detección de red, mientras que **Wazuh** es una buena referencia para extender posteriormente el laboratorio hacia correlación centralizada y seguridad de endpoint.
