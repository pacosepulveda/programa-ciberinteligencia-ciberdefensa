# Nota de CTI para el expediente TV-INT-2026-11

**Identificador:** CTI-01
**Preparación del caso docente:** 2026-11-04
**Naturaleza:** resumen educativo. No sustituye a las fuentes oficiales.

## Fuente externa real

Advisory conjunto de CISA: **AA25-239A — Countering Chinese State-Sponsored Actors Compromise of Networks Worldwide to Feed Global Espionage System**.

- Fuente oficial: https://www.cisa.gov/news-events/cybersecurity-advisories/aa25-239a
- Documento: https://www.cisa.gov/sites/default/files/2025-08/CSA_COUNTERING_CHINA_STATE_ACTORS_COMPROMISE_OF_NETWORKS.pdf
- Ficha ATT&CK de Salt Typhoon (G1045): https://attack.mitre.org/groups/G1045/

El advisory pertenece a **2025**; que un usuario lo mencione en 2026 no lo convierte en una confirmación nueva de actividad contra TELVORA. MITRE agrega información de diversas fuentes y puede incluir técnicas que **no están descritas directamente** en el advisory elegido.

## Contexto que debe orientar la lectura

Estudia por qué son relevantes para operadores de telecomunicaciones las actividades de espionaje en dispositivos de red, relaciones de confianza y conexiones entre operadores. Investiga en el documento original los comportamientos observados, el grado de atribución expresado y las recomendaciones de mitigación.

Los nombres de seguimiento utilizados por distintos proveedores de seguridad pueden solaparse parcialmente y no deben tratarse como sinónimos exactos sin justificación.

## Condiciones del ejercicio

1. **No existe vínculo demostrado** entre la actividad documentada por CISA y TELVORA.
2. Los eventos del SOC y el inventario de este casebook son **simulados**.
3. Las direcciones 198.51.100.44 y 203.0.113.44 del expediente pertenecen a rangos reservados para documentación: **no son IOC reales**.
4. No ejecutes consultas o conexiones directas contra direcciones listadas como IOC en fuentes externas.
5. Si una web no responde, conserva la URL y fecha del error. No atribuyas a la fuente contenido que no hayas podido leer.

## Pregunta de relevancia

¿Qué controles de telemetría o detección tendría sentido verificar o mejorar en TELVORA **aun cuando no exista evidencia de compromiso**? ¿Qué dato distinto sería necesario para abrir una investigación de intrusión?
