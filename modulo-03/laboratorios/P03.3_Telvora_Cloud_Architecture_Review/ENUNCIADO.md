# P03.3 — Telvora Cloud Architecture Review
## Revisión de postura cloud, IaC y policy-as-code

> **Antes de comenzar:** revisa el [entorno común del M03](../README.md).

---

# 1. Escenario

TELVORA está preparando una pequeña carga en AWS.

El equipo de plataforma entrega una plantilla Terraform antes de desplegarla. El objetivo es revisar la arquitectura **antes** de que exista infraestructura real y comprobar si cumple los guardrails aprobados.

Tu misión es responder:

> **¿Qué decisiones de arquitectura y configuración crean exposición innecesaria y cómo podemos convertir la política en controles verificables?**

La práctica trabaja:

- responsabilidad compartida;
- configuración cloud;
- Infrastructure as Code;
- policy-as-code;
- guardrails;
- DevSecOps;
- validación de arquitectura;
- riesgo residual.

No se desplegará ningún recurso cloud.

---

# 2. Máquina

Utiliza:

```text
KALI01
```

Necesitas únicamente:

- Python 3;
- Git o acceso a los archivos del repositorio;
- un editor de texto.

Comprueba:

```bash
python3 --version
```

---

# 3. Archivos de la práctica

El directorio contiene:

```text
main.tf
TELVORA_GUARDRAILS.md
iac_guardrails.py
```

- `main.tf`: arquitectura IaC que debes revisar.
- `TELVORA_GUARDRAILS.md`: política mínima aprobada.
- `iac_guardrails.py`: verificador local de policy-as-code para el laboratorio.

Trabaja sobre una copia para conservar el estado inicial:

```bash
cp main.tf main-inicial.tf
```

---

# 4. Fase 1 — Revisión manual antes de automatizar

Lee `main.tf` sin ejecutar todavía el checker.

Identifica al menos cuatro decisiones que revisarías.

Completa:

| Hallazgo | Activo | Qué puede ocurrir | Principio afectado | Prioridad |
|---|---|---|---|---|
| | | | | |
| | | | | |
| | | | | |
| | | | | |

Principios posibles:

- mínimo privilegio;
- deny by default;
- cifrado;
- trazabilidad;
- reducción de superficie;
- defensa en profundidad.

No confundas una configuración llamativa con una vulnerabilidad explotable demostrada.

---

# 5. Fase 2 — Política de arquitectura

Lee:

```text
TELVORA_GUARDRAILS.md
```

Los controles definidos son:

```text
G001  SSH administrativo no expuesto a Internet
G002  S3 Public Access Block habilitado
G003  Volúmenes EBS cifrados
G004  Retención explícita de logs >= 90 días
```

Para cada guardrail explica:

1. qué riesgo intenta reducir;
2. qué recurso afecta;
3. si es preventivo, detectivo o ambos;
4. qué riesgo puede seguir existiendo aunque el check pase.

---

# 6. Fase 3 — Primera evaluación automática

Ejecuta:

```bash
python3 iac_guardrails.py main.tf
```

Registra el resultado:

| Guardrail | PASS / FAIL | Evidencia en `main.tf` | Riesgo asociado |
|---|---|---|---|
| G001 | | | |
| G002 | | | |
| G003 | | | |
| G004 | | | |

Compara la salida automática con tu revisión manual.

Responde:

- ¿detectó el checker todo lo que habías identificado?
- ¿detectaste tú algún problema que no esté expresado como guardrail?
- ¿por qué ambas cosas pueden ocurrir?

---

# 7. Fase 4 — Remediación

Modifica `main.tf` para cumplir la política aprobada.

## R1 — Administración

SSH administrativo no debe estar expuesto a todo Internet.

Para el escenario del laboratorio, la red administrativa autorizada es:

```text
10.40.0.0/24
```

## R2 — Almacenamiento

Las cuatro protecciones de S3 Public Access Block deben quedar habilitadas.

## R3 — Protección de datos

El volumen EBS debe declarar cifrado explícito.

## R4 — Logging

El log group debe definir una retención de al menos:

```text
90 días
```

No añadas cambios que no puedas justificar.

---

# 8. Fase 5 — Segunda evaluación

Vuelve a ejecutar:

```bash
python3 iac_guardrails.py main.tf
```

Compara:

```text
ANTES
vs.
DESPUÉS
```

Registra:

| Métrica | Inicial | Final |
|---|---:|---:|
| Guardrails PASS | | |
| Guardrails FAIL | | |

Una ejecución con todos los checks en `PASS` demuestra **conformidad con estas cuatro reglas**, no demuestra que toda la arquitectura sea segura.

---

# 9. Fase 6 — Del check al pipeline

Supón que esta validación se ejecuta automáticamente antes de aceptar un cambio IaC.

Diseña una política de pipeline para responder:

1. ¿qué guardrails deberían bloquear siempre el cambio?
2. ¿permitirías excepciones?
3. ¿quién podría aprobarlas?
4. ¿qué debería registrar una excepción?
5. ¿cuándo debería caducar o revisarse?

Representa el flujo:

```text
Cambio IaC
   ↓
Validación automática
   ↓
PASS ─────────────→ revisión / merge
   │
   └─ FAIL → bloqueo o excepción gobernada
```

---

# 10. Revisión arquitectónica

Responde:

1. ¿Quién es responsable de que un Security Group no exponga SSH: AWS o TELVORA?
2. ¿Quién protege físicamente el hardware?
3. ¿Por qué IaC facilita revisar arquitectura antes del despliegue?
4. ¿Qué diferencia existe entre una política escrita y policy-as-code?
5. ¿Un `PASS` en G001 demuestra que el acceso administrativo es seguro?
6. ¿Qué controles de identidad no puede comprobar este fichero?
7. ¿Qué aporta una retención explícita si nadie consume los logs?
8. ¿Por qué un guardrail puede ser técnicamente correcto y operacionalmente insuficiente?
9. ¿Qué riesgo introduce una excepción permanente a un guardrail?
10. ¿Qué evidencia conservarías para una revisión de arquitectura posterior?

---

# 11. Traslado multicloud

Para cada problema identifica el equivalente conceptual en Azure y GCP.

| Problema | AWS | Azure | GCP |
|---|---|---|---|
| Administración demasiado expuesta | Security Group | | |
| Almacenamiento público | S3 | | |
| Disco sin cifrado adecuado | EBS | | |
| Logs sin política de retención | CloudWatch Logs | | |

No se pide memorizar todos los nombres comerciales.

Se evalúa comprender el **patrón de seguridad**.

---

# 12. Architecture Review final

Prepara un **Architecture Review Brief** con:

## Hallazgos prioritarios

Máximo cinco.

## Riesgo

Qué puede ocurrir y sobre qué activo.

## Guardrail relacionado

G001–G004 o `NO CUBIERTO`.

## Remediación

Cambio concreto.

## Evidencia

Resultado manual y/o del checker.

## Responsabilidad

Proveedor / TELVORA / compartida.

## Riesgo residual

Qué no queda resuelto después de que el check pase.

## Decisión de pipeline

Bloquear / permitir / permitir con excepción gobernada.
