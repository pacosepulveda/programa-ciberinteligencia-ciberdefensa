# P03.3 — Telvora Cloud Architecture Review
## Revisión de postura cloud mediante Infrastructure as Code

> **Antes de comenzar:** revisa el [entorno común y perfil de memoria del M03](../README.md#3-entorno-de-laboratorio).

---

# 1. Escenario

TELVORA está preparando una pequeña carga en AWS.

El equipo de plataforma entrega una plantilla Terraform antes de desplegarla.

Tu función no es desplegar recursos.

Tu misión es responder:

> **¿Qué decisiones de arquitectura y configuración crean exposición innecesaria antes de que lleguen a producción?**

La práctica utiliza análisis estático IaC para introducir:

- responsabilidad compartida;
- CIS Benchmarks;
- CSPM;
- policy as code;
- DevSecOps.

---

# 2. Máquina

Utiliza únicamente:

```text
LABSERV01
```

Debe disponer de:

- Python;
- Git;
- Checkov u otra herramienta indicada por el instructor.

Comprueba:

```bash
checkov --version
```

---

# 3. Crea el directorio

```bash
mkdir -p ~/m03-cloud-review
cd ~/m03-cloud-review
```

---

# 4. Configuración bajo revisión

Crea:

```text
main.tf
```

con:

```hcl
resource "aws_security_group" "admin" {
  name = "telvora-admin"

  ingress {
    description = "SSH administration"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_s3_bucket" "evidence" {
  bucket = "telvora-m03-evidence-demo"
}

resource "aws_s3_bucket_public_access_block" "evidence" {
  bucket = aws_s3_bucket.evidence.id

  block_public_acls       = false
  ignore_public_acls      = false
  block_public_policy     = false
  restrict_public_buckets = false
}

resource "aws_ebs_volume" "data" {
  availability_zone = "eu-west-1a"
  size              = 20
  encrypted         = false
}

resource "aws_cloudwatch_log_group" "app" {
  name = "/telvora/m03/app"
}
```

Este fichero es exclusivamente didáctico.

No se desplegará.

---

# 5. Primera revisión manual

Antes de ejecutar una herramienta, identifica al menos cuatro decisiones que revisarías.

Completa:

| Hallazgo | Activo | Riesgo | Principio afectado |
|---|---|---|---|
| | | | |
| | | | |
| | | | |
| | | | |

Principios posibles:

- mínimo privilegio;
- deny by default;
- cifrado;
- trazabilidad;
- reducción de superficie;
- defensa en profundidad.

---

# 6. Análisis automático

Ejecuta:

```bash
checkov -f main.tf --framework terraform
```

La salida concreta puede variar según la versión de Checkov.

Registra:

- checks superados;
- checks fallidos;
- recurso;
- descripción;
- identificador del check;
- línea afectada.

No asumas que cada fallo representa automáticamente el mismo nivel de riesgo para TELVORA.

---

# 7. Clasificación

Clasifica los hallazgos en:

```text
IDENTITY / ACCESS
NETWORK
DATA PROTECTION
LOGGING / DETECTION
RESILIENCE
```

Completa:

| Finding | Categoría | Riesgo | Prioridad | Justificación |
|---|---|---|---|---|
| | | | | |

---

# 8. Remediación

Modifica el fichero para:

### R1

No permitir SSH administrativo desde todo Internet.

Utiliza, para el laboratorio:

```text
10.40.0.0/24
```

como ejemplo de red administrativa autorizada.

### R2

Habilitar las cuatro protecciones de acceso público del bucket.

### R3

Habilitar cifrado del volumen EBS.

### R4

Definir una política explícita de retención de logs.

Selecciona un periodo razonable y justifícalo.

No existe un número universal válido para todas las organizaciones.

---

# 9. Segundo escaneo

Vuelve a ejecutar:

```bash
checkov -f main.tf --framework terraform
```

Compara:

```text
ANTES
vs.
DESPUÉS
```

No es obligatorio obtener cero findings.

Algunos controles requieren decisiones de arquitectura adicionales.

---

# 10. Revisión arquitectónica

Responde:

1. ¿Quién es responsable de que el Security Group no exponga SSH: AWS o TELVORA?
2. ¿Quién protege físicamente el hardware?
3. ¿El cifrado por defecto del proveedor elimina la necesidad de gobernanza de claves?
4. ¿Qué aporta IaC frente a configurar manualmente?
5. ¿Qué aporta policy-as-code al pipeline CI/CD?
6. ¿Un check superado demuestra que el sistema es seguro?
7. ¿Qué findings pueden estar relacionados con CIS Benchmarks?
8. ¿Qué controles no pueden comprobarse únicamente mirando este Terraform?

---

# 11. Traslado multicloud

Para cada problema identifica el equivalente conceptual en Azure y GCP.

| Problema | AWS | Azure | GCP |
|---|---|---|---|
| SSH demasiado expuesto | Security Group | | |
| Almacenamiento público | S3 | | |
| Disco sin cifrado adecuado | EBS | | |
| Logs sin política adecuada | CloudWatch | | |

No se pide memorizar nombres de todas las opciones de portal.

Se evalúa comprender el **patrón de seguridad**.

---

# 12. Relación con Zero Trust

Explica por qué sustituir:

```text
0.0.0.0/0 → TCP/22
```

por:

```text
10.40.0.0/24 → TCP/22
```

es una mejora, pero **no implementa por sí solo Zero Trust**.

Indica qué controles adicionales serían necesarios para aproximarse a un modelo Zero Trust:

- identidad;
- estado del dispositivo;
- autenticación fuerte;
- autorización contextual;
- mínimo privilegio;
- monitorización;
- reevaluación continua.

---

# 13. Architecture Review final

Entrega un documento de una página con:

## Hallazgos prioritarios

Máximo cinco.

## Riesgo

Qué puede ocurrir y sobre qué activo.

## Remediación

Cambio concreto.

## Evidencia

Resultado de Checkov o revisión manual.

## Responsabilidad

Proveedor / TELVORA / compartida.

## Riesgo residual

Qué no queda resuelto con la modificación.
