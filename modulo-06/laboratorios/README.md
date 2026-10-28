# Laboratorios del Módulo 6

Los laboratorios del Módulo 6 siguen una progresión completa de ciberinteligencia:

```text
OPSEC del investigador
        ↓
OSINT técnico de superficie externa
        ↓
Verificación de contenido y geolocalización
        ↓
Análisis de CTI real
        ↓
Mapeo ATT&CK basado en evidencia
```

## P06.0 — Investigator OPSEC Exposure Assessment

Objetivos:

- identificar qué expone el propio investigador;
- revisar IP, DNS, browser fingerprinting y WebRTC;
- aplicar compartimentación mediante perfiles separados;
- diferenciar anonimización, reducción de exposición y errores operacionales.

[Ir al enunciado](P06.0_Investigator_OPSEC_Exposure_Assessment/ENUNCIADO.md)

## P06.1 — External Surface Intelligence

Objetivos:

- investigar pasivamente `cloudsecurityinpractice.com`;
- trabajar con DNS, Certificate Transparency, TLS, RDAP y Shodan InternetDB;
- utilizar theHarvester y Recon-ng como apoyo a la colección;
- diferenciar descubrimiento, propiedad, exposición observada y vulnerabilidad;
- clasificar hechos, inferencias, assessments e incógnitas.

[Ir al enunciado](P06.1_External_Surface_Intelligence/ENUNCIADO.md)

## P06.2 — Multimedia Verification & Geolocation

Objetivos:

- preservar e inspeccionar una imagen pública;
- analizar EXIF y pistas visuales;
- validar ubicación y cronología;
- demostrar que contenido auténtico puede difundirse con contexto falso.

[Ir al enunciado](P06.2_Multimedia_Verification_Geolocation/ENUNCIADO.md)

## P06.3 — Real CTI Investigation: AA25-239A

Objetivos:

- trabajar con un advisory real de CISA;
- inspeccionar inteligencia estructurada STIX;
- extraer IOC y enriquecerlos mediante fuentes públicas;
- construir un Diamond Model basado únicamente en evidencia.

[Ir al enunciado](P06.3_Real_CTI_Investigation_AA25-239A/ENUNCIADO.md)

## P06.4 — MITRE ATT&CK Evidence Mapping

Objetivos:

- convertir evidencia del advisory en comportamientos observables;
- mapear técnicas ATT&CK con trazabilidad;
- relacionar técnicas con telemetría y oportunidades de detección;
- comparar el mapping propio con la ficha pública de Salt Typhoon en ATT&CK.

[Ir al enunciado](P06.4_MITRE_ATTACK_Evidence_Mapping/ENUNCIADO.md)

## Reglas comunes

- No instales herramientas adicionales para completar los laboratorios.
- No realices explotación ni escaneo activo contra sistemas de terceros.
- Prioriza colección pasiva y fuentes públicas.
- Un resultado de una herramienta no es una conclusión: conserva siempre fuente, timestamp y contexto.
- Si una fuente externa cambia o no responde, documenta la limitación y continúa con las demás fuentes.
