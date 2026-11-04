# Módulo 6 — Misiones autónomas de ciberinteligencia

Tres misiones técnicas individuales que utilizan TELVORA Communications como escenario de entrenamiento. El trabajo se centra en **investigar, automatizar, comprobar y correlacionar información**. Los resultados técnicos son los entregables principales.

## Misiones

| Misión | Objetivo | Recursos principales |
|---|---|---|
| [MA06.A — External Intelligence Watch](MA06-A_External_Intelligence_Watch.md) | Monitorizar y detectar cambios en superficie pública mediante OSINT pasivo | [Colector, comparador, grafo, datos y comprobador](ma06-a/) |
| [MA06.B — Digital Evidence Investigation](MA06-B_Digital_Evidence_Investigation.md) | Investigar imágenes y publicaciones, geolocalizar y verificar su cronología | [Pistas, API de Wikimedia, plantillas y comprobador](ma06-b/) |
| [MA06.C — Threat Intelligence to Detection](MA06-C_Threat_Intelligence_to_Detection.md) | Correlacionar eventos de SOC, desarrollar detecciones y mapear MITRE ATT&CK | [Eventos JSONL, inventarios, detector, Sigma y comprobador](ma06-c/) |

## Requisitos técnicos

- Python 3 y un editor de texto; navegador y conexión a Internet para las fases de investigación en fuentes públicas.
- Las herramientas obligatorias utilizan la biblioteca estándar de Python.
- Los datos ficticios están identificados como tales y no representan infraestructuras o incidentes reales.
- El trabajo puede realizarse sin mantener máquinas del curso encendidas y sin adquirir suscripciones.

## Entregas

Cada misión solicita archivos técnicos verificables (JSON/JSONL, CSV, DOT, GeoJSON, reglas Sigma o scripts), más conclusiones breves y justificadas. Se incluyen plantillas y ayudas en sus carpetas respectivas.

## Alcance

La investigación LIVE se limita a objetivos autorizados y consultas pasivas. Las evidencias de TELVORA son simuladas; los documentos oficiales de CISA y MITRE son referencias públicas independientes y no atribuyen ningún ataque a TELVORA. No se permite contactar con personas ajenas, escanear terceros ni interactuar con IOC maliciosos.
