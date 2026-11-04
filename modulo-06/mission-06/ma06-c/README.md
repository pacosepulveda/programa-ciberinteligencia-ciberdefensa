# MA06.C — Entorno técnico

El caso se desarrolla con datos **ficticios y autocontenidos**. No se necesita acceso a un SIEM, a equipos de TELVORA ni a IOC.

## Inicio rápido

~~~bash
python3 starter/hunt.py --events data/events.jsonl --changes data/changes.csv --out resultados/alerts.json
python3 checks/check.py --events data/events.jsonl --changes data/changes.csv --alerts resultados/alerts.json
~~~

**El detector es un starter y no contiene la correlación completa.** Primero devuelve cero alertas; el alumno debe completar detect_sessions y ejecutar de nuevo. El error del checker durante la primera ejecución es esperado.

### Herramientas incluidas

- starter/parse_events.py: parsing JSONL, fechas UTC, agrupación por sesión y verificación de cambios aprobados.
- starter/hunt.py: CLI y extracción de gaps; contiene un TODO funcional para hunting.
- data/: eventos sintéticos e inventarios.
- checks/demo_events.jsonl: dataset pequeño con secuencia ordenada y secuencia desordenada para autocomprobación.
- checks/check.py: verifica relaciones, IDs, ventanas, aprobaciones y gaps de las alertas suministradas.
- templates/router_logging_change.yml: Sigma atómica de eventos; **no** implementa correlación temporal.
- templates/attack-layer.json: capa vacía para ATT&CK Navigator.
- templates/cti-behaviours.json: plantilla de comportamientos y procedencia.

Los resultados personales se almacenan en resultados/ local. No publiques información ajena al ejercicio. Las direcciones IP utilizadas pertenecen a rangos reservados para documentación.
