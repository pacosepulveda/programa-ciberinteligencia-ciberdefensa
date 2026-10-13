# CODG — Architecture Snapshot

```text
                    Internet / Partner
                           |
                     HTTPS / OAuth
                           |
                    +---------------+
                    |  CODG API     |
                    |  DMZ workload |
                    +---------------+
                      |      |     \
                      |      |      \
                  PostgreSQL |       MQTT
                  customer DB|       8883
                      |      |         \
                      |      |          +---------------+
                      |      |          | MQTT Broker   |
                      |      |          | IoT telemetry |
                      |      |          +---------------+
                      |      |
                      |   Secrets backend
                      |      |
                      +------+

       Identity provider / privileged administration
                           |
                     admin + service identities
```

## Trust boundaries a revisar

- Internet/partner → CODG API
- CODG workload → customer database
- CODG workload → secrets backend
- CODG workload → MQTT broker
- privileged administration → CODG

## Preguntas

1. ¿Qué datos atraviesan cada boundary?
2. ¿Qué identidad se utiliza?
3. ¿Qué controla autorización?
4. ¿Qué clave/secreto/certificado participa?
5. ¿Qué evidencia queda disponible para detectar abuso?
