# TELVORA — Guardrails de arquitectura cloud

Estas reglas representan una política mínima de arquitectura para el escenario del laboratorio.

| ID | Guardrail | Criterio |
|---|---|---|
| G001 | Administración SSH no expuesta a Internet | No debe existir `0.0.0.0/0` para TCP/22 |
| G002 | S3 Public Access Block | Las cuatro protecciones deben estar habilitadas |
| G003 | Cifrado de volúmenes EBS | Todo `aws_ebs_volume` debe declarar `encrypted = true` |
| G004 | Retención explícita de logs | Todo `aws_cloudwatch_log_group` debe declarar al menos 90 días de retención |

## Principio

El objetivo no es considerar segura una arquitectura porque supere cuatro checks.

Los guardrails permiten convertir decisiones aprobadas en controles repetibles y verificables. Su resultado debe interpretarse junto con contexto, exposición, identidad, amenazas, controles compensatorios y riesgo residual.
