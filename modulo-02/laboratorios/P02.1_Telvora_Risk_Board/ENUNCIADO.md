# P02.1 — Telvora Risk Board
## Del inventario técnico a una decisión de riesgo defendible

**Programa:** Programa Avanzado de Ciberinteligencia y Ciberdefensa  
**Empresa ficticia:** Telvora Communications (TELVORA)  
**Módulo:** M02 — Gobernanza, Gestión del Riesgo y Resiliencia

---

# 1. Escenario

Telvora Communications presta servicios digitales y de telecomunicaciones a clientes empresariales y particulares.

El comité de riesgos solicita revisar cinco escenarios antes de aprobar el presupuesto de seguridad del próximo ejercicio.

El problema es que las propuestas recibidas hasta ahora se limitan a frases como:

- “el phishing es crítico”;
- “hay riesgo de ransomware”;
- “el proveedor cloud es importante”;
- “debemos mejorar el firewall”.

El comité exige una evaluación que permita responder:

> **¿Qué escenario concreto nos preocupa, con qué activos se relaciona, cuánto podría costarnos y qué control merece financiación prioritaria?**

---

# 2. Inventario simplificado

## A01 — Portal de clientes

- servicio público;
- acceso web;
- autenticación mediante `IDP01`;
- depende de `DNS01`;
- consulta datos de `CRM01`;
- indisponibilidad visible inmediatamente para clientes.

## A02 — CRM01

- base de datos de clientes;
- contiene información comercial y datos personales;
- utilizada por atención al cliente y operaciones;
- copias de seguridad diarias.

## A03 — IDP01

- plataforma de identidad corporativa;
- autentica empleados y administradores;
- se utiliza para VPN, SaaS y aplicaciones internas;
- determinadas cuentas poseen privilegios elevados.

## A04 — DNS01

- infraestructura DNS autoritativa para servicios públicos;
- esencial para la resolución de los servicios externos de TELVORA.

## A05 — VPN01

- acceso remoto para personal técnico;
- autenticación federada mediante `IDP01`.

## A06 — BACKUP01

- repositorio de copias;
- copia diaria de CRM01;
- copia semanal de determinadas configuraciones;
- accesible mediante una cuenta de servicio dedicada.

## A07 — SUPPLIER01

- proveedor externo de soporte;
- dispone de una cuenta nominativa y acceso limitado por VPN a sistemas concretos.

---

# 3. Dependencias

Representa gráficamente estas dependencias:

```text
Portal de clientes
├── DNS01
├── IDP01
└── CRM01

VPN01
└── IDP01

Recuperación CRM01
└── BACKUP01

SUPPLIER01
└── VPN01
    └── IDP01
```

Después responde:

1. ¿Qué activo tiene mayor capacidad de producir impacto en cascada?
2. ¿Qué dependencia podría no ser evidente si solo mirásemos un inventario de servidores?
3. ¿Qué activo no tiene por qué ser el más valioso económicamente para ser crítico?

---

# 4. Dimensiones de impacto

Valora cada activo de 1 a 5 en las siguientes dimensiones:

- **C** — Confidencialidad
- **I** — Integridad
- **D** — Disponibilidad
- **A** — Autenticidad
- **T** — Trazabilidad

Escala:

| Valor | Interpretación |
|---:|---|
| 1 | Impacto menor |
| 2 | Bajo |
| 3 | Significativo |
| 4 | Alto |
| 5 | Muy alto/crítico |

Completa:

| Activo | C | I | D | A | T | Justificación principal |
|---|---:|---:|---:|---:|---:|---|
| Portal | | | | | | |
| CRM01 | | | | | | |
| IDP01 | | | | | | |
| DNS01 | | | | | | |
| VPN01 | | | | | | |
| BACKUP01 | | | | | | |
| SUPPLIER01 | | | | | | |

No se evalúa que tus valores coincidan exactamente con una solución modelo. Se evalúa la coherencia.

---

# 5. Escenarios de riesgo

Analiza:

## R1 — Compromiso de identidad privilegiada

Un administrador recibe un phishing dirigido. El atacante obtiene una sesión válida y accede a recursos internos utilizando credenciales legítimas.

## R2 — Explotación de VPN perimetral

Se publica una vulnerabilidad crítica que afecta a la versión desplegada en `VPN01`. Existen intentos de explotación en Internet antes de completarse el parcheado.

## R3 — Ransomware con afectación de CRM y copias

Un atacante obtiene acceso inicial, alcanza `CRM01` y logra afectar también al repositorio `BACKUP01`.

## R4 — Ataque DDoS contra DNS y portal

Un actor hacktivista intenta degradar la disponibilidad de los servicios públicos de TELVORA.

## R5 — Compromiso del proveedor

Las credenciales de `SUPPLIER01` son comprometidas y se utilizan para acceder mediante la relación de confianza existente.

---

# 6. Declaración formal del riesgo

Reescribe cada escenario utilizando:

```text
[Actor/fuente]
podría
[acción o evento]
sobre
[activo]
aprovechando
[condición]
provocando
[consecuencia].
```

Ejemplo de estructura:

> Un actor externo podría ... sobre ... aprovechando ... provocando ...

Evita expresiones como:

> “riesgo de phishing”

porque no describen de forma suficiente el escenario.

---

# 7. Evaluación cualitativa

Asigna a cada riesgo:

## Probabilidad

| Valor | Interpretación |
|---:|---|
| 1 | Rara |
| 2 | Poco probable |
| 3 | Posible |
| 4 | Probable |
| 5 | Muy probable |

## Impacto

| Valor | Interpretación |
|---:|---|
| 1 | Menor |
| 2 | Bajo |
| 3 | Significativo |
| 4 | Alto |
| 5 | Crítico |

Calcula:

```text
Nivel cualitativo = Probabilidad × Impacto
```

Completa:

| Riesgo | Prob. | Impacto | Resultado | Nivel de confianza | Justificación |
|---|---:|---:|---:|---|---|
| R1 | | | | | |
| R2 | | | | | |
| R3 | | | | | |
| R4 | | | | | |
| R5 | | | | | |

La confianza debe ser:

- Alta
- Media
- Baja

---

# 8. Cuantificación FAIR simplificada

El comité solicita profundizar en **R1 — Compromiso de identidad privilegiada**.

Dispones de estas estimaciones:

## Threat Event Frequency — TEF

Número anual de intentos relevantes capaces de llegar al usuario privilegiado:

```text
mínimo: 2
más probable: 4
máximo: 8
```

## Vulnerability

Probabilidad de que un intento relevante produzca un compromiso efectivo:

```text
mínimo: 25 %
más probable: 35 %
máximo: 45 %
```

## Primary Loss Magnitude

Pérdidas directas por incidente:

```text
mínimo: 150.000 €
más probable: 400.000 €
máximo: 900.000 €
```

## Secondary Loss Magnitude

Costes adicionales si se desencadenan consecuencias secundarias:

```text
mínimo: 0 €
más probable: 250.000 €
máximo: 1.200.000 €
```

Probabilidad de que exista pérdida secundaria:

```text
40 %
```

---

# 9. Estimación PERT

Para evitar utilizar siempre el punto medio, emplea:

```text
PERT = (mínimo + 4 × más_probable + máximo) / 6
```

Calcula:

1. TEF esperado.
2. Vulnerability esperada.
3. **Loss Event Frequency (LEF)**:

```text
LEF = TEF × Vulnerability
```

4. Primary Loss Magnitude esperada.
5. Secondary Loss Magnitude esperada.
6. Pérdida secundaria ponderada:

```text
Secondary expected = Secondary Loss × probabilidad secundaria
```

7. Pérdida total esperada por evento:

```text
Loss/Event = Primary Loss + Secondary expected
```

8. Pérdida anual esperada:

```text
Annualized Loss = LEF × Loss/Event
```

Redondea de forma razonable. No se busca precisión actuarial.

---

# 10. Decisión de tratamiento

Se propone implantar:

## Control C1 — MFA resistente al phishing + refuerzo de cuentas privilegiadas

Coste anual equivalente estimado:

```text
180.000 €
```

Después del control se estima que `Vulnerability` pasa a:

```text
mínimo: 8 %
más probable: 15 %
máximo: 25 %
```

Mantén iguales el resto de variables para simplificar.

Calcula:

1. nueva Vulnerability PERT;
2. nueva LEF;
3. nueva pérdida anual esperada;
4. reducción anual estimada del riesgo;
5. beneficio neto aproximado:

```text
Beneficio neto = reducción del riesgo − coste del control
```

6. ratio aproximado de retorno:

```text
ROI = beneficio neto / coste del control × 100
```

Finalmente decide:

- **mitigar**;
- **evitar**;
- **transferir**;
- **aceptar**;

y justifica por qué.

---

# 11. Riesgo residual

Responde:

1. ¿El control elimina R1?
2. ¿Qué riesgo permanece?
3. ¿Qué controles adicionales considerarías?
4. ¿Qué información pedirías para aumentar la confianza de la estimación?
5. ¿Qué cambiaría si el apetito de riesgo de TELVORA fuese muy bajo para cuentas privilegiadas?
