# P02.1 — Telvora Risk Board
## Solución

**Programa:** Programa Avanzado de Ciberinteligencia y Ciberdefensa  
**Empresa ficticia:** Telvora Communications (TELVORA)  
**Módulo:** M02 — Gobernanza, Gestión del Riesgo y Resiliencia  
**Práctica:** P02.1 — Telvora Risk Board

---

# 1. Mapa de dependencias

Una representación coherente de las dependencias descritas en el escenario es:

```text
                    ┌─────────┐
                    │ DNS01   │
                    └────┬────┘
                         │
                         ▼
                    ┌─────────┐
                    │ PORTAL  │
                    └──┬───┬──┘
                       │   │
                  ┌────┘   └────┐
                  ▼             ▼
              ┌────────┐    ┌────────┐
              │ IDP01  │    │ CRM01  │
              └──┬───┬─┘    └───┬────┘
                 │   │           │
                 │   │           ▼
                 │   │       ┌──────────┐
                 │   │       │ BACKUP01 │
                 │   │       └──────────┘
                 │   ▼
                 │ ┌────────┐
                 └►│ VPN01  │◄──── SUPPLIER01
                   └────────┘
```

El sentido de las flechas debe interpretarse de forma coherente. En este esquema se representan relaciones de dependencia funcional entre servicios y componentes.

## 1.1. Activo con mayor impacto en cascada

Una respuesta especialmente defendible es:

```text
IDP01
```

La identidad corporativa soporta varias capacidades transversales:

- autenticación del portal;
- acceso VPN;
- acceso a aplicaciones internas y SaaS;
- autenticación de administradores;
- acceso privilegiado a distintos sistemas.

Por tanto, una degradación o compromiso de IDP01 puede generar efectos en cascada sobre varios servicios aparentemente independientes.

También existen argumentos razonables para considerar especialmente críticos:

- **DNS01**, por su impacto inmediato sobre los servicios públicos;
- **CRM01**, por su dependencia directa con atención al cliente, facturación y tratamiento de datos.

La idea fundamental es que la criticidad debe evaluarse a partir de las dependencias y del impacto sobre el servicio, no únicamente del valor económico del componente.

## 1.2. Dependencias no evidentes

Algunas relaciones que pueden pasar desapercibidas en un inventario plano son:

- el acceso de SUPPLIER01 depende realmente de VPN01 e IDP01;
- la recuperación de CRM01 depende de BACKUP01;
- el portal, aunque sea un servicio web público, depende de identidad, DNS y CRM;
- una caída de IDP01 puede afectar simultáneamente a administración, VPN y aplicaciones.

## 1.3. Activo crítico sin ser necesariamente el más caro

Un buen ejemplo es:

```text
DNS01
```

Su coste de infraestructura puede ser relativamente reducido, pero un fallo de disponibilidad o de integridad puede hacer inaccesibles servicios públicos de TELVORA.

> **Criticidad no equivale a precio de compra.**

---

# 2. Valoración C/I/D/A/T

Una valoración de referencia puede ser:

| Activo | C | I | D | A | T | Justificación principal |
|---|---:|---:|---:|---:|---:|---|
| Portal | 3 | 4 | 5 | 4 | 3 | Servicio público y transaccional |
| CRM01 | 5 | 5 | 4 | 4 | 5 | Datos personales y comerciales |
| IDP01 | 5 | 5 | 5 | 5 | 5 | Identidad, autenticación y privilegios |
| DNS01 | 2 | 5 | 5 | 5 | 4 | Integridad, autenticidad y disponibilidad |
| VPN01 | 4 | 5 | 4 | 5 | 5 | Punto de entrada remoto |
| BACKUP01 | 5 | 5 | 5 | 4 | 5 | Recuperación, integridad y disponibilidad |
| SUPPLIER01 | 3 | 4 | 3 | 5 | 5 | Relación de confianza con un tercero |

Estas puntuaciones no deben sumarse automáticamente para obtener un único “valor del activo”. Las dimensiones permiten razonar sobre qué propiedades son especialmente relevantes para cada componente.

Por ejemplo:

- en **CRM01**, confidencialidad e integridad son fundamentales por los datos tratados;
- en **DNS01**, integridad, autenticidad y disponibilidad son más relevantes que la confidencialidad;
- en **IDP01**, todas las dimensiones tienen una importancia elevada debido a su función transversal.

---

# 3. Declaraciones formales de riesgo

## R1 — Compromiso de identidad privilegiada

> Un actor externo podría comprometer una sesión o identidad administrativa sobre IDP01 mediante phishing dirigido y uso de credenciales legítimas, provocando acceso no autorizado, abuso de privilegios y posible compromiso de sistemas dependientes.

## R2 — Explotación de VPN perimetral

> Un actor externo podría explotar una vulnerabilidad crítica en VPN01 durante la ventana entre divulgación y mitigación, obteniendo acceso inicial a recursos internos.

## R3 — Ransomware con afectación de CRM y copias

> Un actor con presencia interna podría cifrar CRM01 y afectar BACKUP01 aprovechando credenciales o conectividad excesiva entre producción y copia, provocando pérdida de disponibilidad y dificultando la recuperación.

## R4 — Ataque DDoS contra DNS y portal

> Un actor hacktivista podría saturar DNS01 y/o el portal público mediante tráfico distribuido, provocando degradación o indisponibilidad de los servicios públicos.

## R5 — Compromiso del proveedor

> Un actor que haya comprometido al proveedor podría utilizar la cuenta y la relación de confianza de SUPPLIER01 para acceder a recursos de TELVORA mediante VPN01, provocando acceso no autorizado y posible movimiento posterior.

Estas formulaciones incluyen:

```text
actor / fuente
        ↓
acción o evento
        ↓
activo afectado
        ↓
condición aprovechada
        ↓
consecuencia
```

Por eso contienen mucha más información útil para decidir que expresiones aisladas como “riesgo de phishing”, “ransomware” o “vulnerabilidad crítica”.

---

# 4. Evaluación cualitativa

Una evaluación de referencia es:

| Riesgo | Probabilidad | Impacto | Resultado | Confianza |
|---|---:|---:|---:|---|
| R1 | 4 | 5 | 20 | Alta |
| R2 | 3 | 5 | 15 | Media |
| R3 | 4 | 5 | 20 | Alta |
| R4 | 4 | 4 | 16 | Media-Alta |
| R5 | 3 | 5 | 15 | Media |

## 4.1. Interpretación

### R1 — Compromiso de identidad privilegiada

La probabilidad se considera alta porque las identidades privilegiadas son objetivos de gran valor y el phishing dirigido es un vector plausible.

El impacto es crítico porque una identidad administrativa puede facilitar acceso a múltiples sistemas y producir un efecto en cascada.

### R2 — Explotación de VPN perimetral

La probabilidad se sitúa en un nivel medio-alto debido a la exposición a Internet y a la existencia de intentos de explotación antes de completar el parcheado.

El impacto es crítico porque VPN01 representa una vía de acceso al entorno interno.

### R3 — Ransomware con afectación de CRM y backups

La combinación de pérdida de producción y degradación de la capacidad de recuperación justifica un impacto crítico.

La probabilidad se considera alta en el escenario planteado debido a que el atacante ha conseguido acceso inicial y existe una ruta posible hacia BACKUP01.

### R4 — DDoS contra DNS y portal

La probabilidad es alta por tratarse de servicios públicos expuestos.

El impacto es elevado por la pérdida de disponibilidad y visibilidad externa, aunque no implica necesariamente compromiso de información.

### R5 — Compromiso del proveedor

La probabilidad se considera media porque requiere un compromiso previo del tercero.

El impacto potencial es crítico debido a la relación de confianza y al acceso remoto permitido.

## 4.2. Por qué R1 y R3 no son equivalentes aunque ambos den 20

La puntuación:

```text
Probabilidad × Impacto
```

comprime información.

R1 y R3 tienen:

- mecanismos diferentes;
- activos afectados diferentes;
- controles diferentes;
- pérdidas potenciales diferentes;
- incertidumbres diferentes.

Por tanto:

```text
20 ≠ descripción completa del riesgo
```

La matriz sirve para ordenar y discutir, pero no sustituye el escenario.

---

# 5. Cuantificación FAIR simplificada de R1

El escenario R1 utiliza las siguientes estimaciones.

## 5.1. Threat Event Frequency — TEF

```text
mínimo:        2
más probable:  4
máximo:        8
```

Se utiliza:

```text
PERT = (mínimo + 4 × más_probable + máximo) / 6
```

Por tanto:

```text
TEF = (2 + 4×4 + 8) / 6
    = 26 / 6
    ≈ 4,33
```

### Resultado

```text
TEF ≈ 4,33 eventos relevantes/año
```

---

# 6. Vulnerability

Datos:

```text
mínimo:        25 %
más probable:  35 %
máximo:        45 %
```

Cálculo:

```text
Vulnerability = (0,25 + 4×0,35 + 0,45) / 6
              = 2,10 / 6
              = 0,35
```

### Resultado

```text
Vulnerability = 35 %
```

En esta simplificación de FAIR, `Vulnerability` no significa una CVE. Expresa la probabilidad de que un evento relevante de amenaza llegue a producir una pérdida dadas las condiciones existentes.

---

# 7. Loss Event Frequency — LEF

```text
LEF = TEF × Vulnerability
```

```text
LEF = 4,3333 × 0,35
    ≈ 1,5167
```

### Resultado

```text
LEF ≈ 1,52 eventos de pérdida/año
```

Esto no significa que vayan a producirse exactamente 1,52 incidentes. Es un valor esperado utilizado para razonar y comparar escenarios.

---

# 8. Primary Loss Magnitude

Datos:

```text
mínimo:        150.000 €
más probable:  400.000 €
máximo:        900.000 €
```

Cálculo:

```text
PLM = (150.000 + 4×400.000 + 900.000) / 6
    = 2.650.000 / 6
    ≈ 441.666,67 €
```

### Resultado

```text
Primary Loss Magnitude ≈ 441.666,67 €
```

---

# 9. Secondary Loss Magnitude

Datos:

```text
mínimo:              0 €
más probable:  250.000 €
máximo:      1.200.000 €
```

Cálculo PERT:

```text
SLM = (0 + 4×250.000 + 1.200.000) / 6
    = 2.200.000 / 6
    ≈ 366.666,67 €
```

La probabilidad de pérdida secundaria es:

```text
40 %
```

Por tanto:

```text
Secondary expected
= 366.666,67 × 0,40
≈ 146.666,67 €
```

---

# 10. Pérdida total esperada por evento

```text
Loss/Event
= Primary Loss + Secondary expected
```

```text
Loss/Event
= 441.666,67
+ 146.666,67
≈ 588.333,34 €
```

---

# 11. Pérdida anual esperada

```text
Annualized Loss = LEF × Loss/Event
```

Utilizando los valores anteriores:

```text
Annualized Loss
≈ 1,5167 × 588.333,34
≈ 892.472 €/año
```

Por redondeo, el resultado puede expresarse aproximadamente como:

```text
0,89 M€/año
```

La interpretación correcta no es:

> TELVORA perderá 892.472 € el próximo año.

La interpretación adecuada es:

> Bajo las hipótesis utilizadas, el escenario presenta una pérdida anual esperada cercana a 0,89 M€, útil para comparar alternativas de tratamiento y apoyar una decisión.

La cuantificación hace explícitas las hipótesis y la incertidumbre; no elimina esa incertidumbre.

---

# 12. Evaluación del control C1

Se propone:

> **MFA resistente al phishing + refuerzo de cuentas privilegiadas**

Coste anual equivalente:

```text
180.000 €
```

Después del control, la estimación de `Vulnerability` pasa a:

```text
mínimo:         8 %
más probable:  15 %
máximo:        25 %
```

## 12.1. Nueva Vulnerability PERT

```text
(0,08 + 4×0,15 + 0,25) / 6
= 0,93 / 6
= 0,155
```

### Resultado

```text
Vulnerability = 15,5 %
```

---

# 13. Nueva Loss Event Frequency

Se mantiene:

```text
TEF ≈ 4,33
```

Por tanto:

```text
Nueva LEF
= 4,3333 × 0,155
≈ 0,6717
```

---

# 14. Nueva pérdida anual esperada

Se mantiene, para simplificar:

```text
Loss/Event ≈ 588.333 €
```

Entonces:

```text
Nueva Annualized Loss
≈ 0,6717 × 588.333
≈ 395.153 €/año
```

---

# 15. Reducción anual estimada del riesgo

```text
892.472
− 395.153
≈ 497.319 €/año
```

### Resultado

```text
Reducción estimada del riesgo ≈ 497.319 €/año
```

---

# 16. Beneficio neto aproximado

Coste anual del control:

```text
180.000 €
```

Cálculo:

```text
Beneficio neto
= reducción del riesgo − coste del control
```

```text
Beneficio neto
= 497.319 − 180.000
≈ 317.319 €/año
```

---

# 17. ROI aproximado

```text
ROI
= beneficio neto / coste del control × 100
```

```text
ROI
= 317.319 / 180.000 × 100
≈ 176,3 %
```

Este porcentaje debe interpretarse como una aproximación basada en las hipótesis del escenario.

No significa que el ROI, por sí solo, determine la decisión. También deben considerarse:

- calidad y confianza de las estimaciones;
- restricciones técnicas;
- capacidad operativa;
- otros riesgos que compiten por presupuesto;
- apetito y tolerancia al riesgo;
- posibles efectos no incluidos en el modelo.

---

# 18. Decisión de tratamiento

La decisión más defendible con los datos proporcionados es:

```text
MITIGAR
```

## Justificación

El escenario presenta:

- una pérdida anual esperada elevada;
- un activo transversal relacionado con identidad privilegiada;
- impacto potencial sobre múltiples sistemas;
- una reducción importante de la frecuencia de pérdida mediante C1;
- una reducción anual estimada del riesgo superior al coste anual equivalente del control.

El control también se alinea con un apetito de riesgo muy bajo frente al acceso privilegiado no autorizado.

La decisión no se fundamenta únicamente en el ROI. El valor principal es reducir la probabilidad de compromiso de una capacidad transversal especialmente crítica.

---

# 19. Riesgo residual

C1 reduce el riesgo, pero no lo elimina.

Después de implantar MFA resistente al phishing y reforzar las cuentas privilegiadas todavía pueden existir escenarios como:

- robo o secuestro de sesiones;
- compromiso del endpoint administrativo;
- errores de autorización;
- abuso interno;
- compromiso del proceso de recuperación de cuenta;
- vectores alternativos que permitan evitar el control;
- privilegios excesivos una vez obtenida una cuenta válida;
- mecanismos de autenticación o aplicaciones que queden fuera de cobertura.

Por tanto:

```text
control implantado
        ≠
riesgo eliminado
```

El riesgo que permanece es el **riesgo residual**.

---

# 20. Controles adicionales

Entre los controles que podrían complementar C1 se encuentran:

- Privileged Access Management (PAM);
- privilegios just-in-time (JIT);
- reducción permanente de privilegios;
- estaciones administrativas dedicadas;
- Conditional Access;
- monitorización específica de identidades privilegiadas;
- protección de sesiones;
- detección de anomalías;
- segmentación;
- hardening del proceso de recuperación de cuentas.

La selección dependerá del escenario, de la arquitectura y del coste de cada tratamiento.

---

# 21. Información necesaria para aumentar la confianza

La estimación podría mejorar disponiendo de datos como:

- número real de administradores;
- frecuencia histórica de phishing dirigido;
- incidentes de identidad registrados;
- tecnología MFA actualmente desplegada;
- cobertura real del control;
- tasa histórica de interacción con campañas de phishing;
- cobertura EDR;
- costes reales de respuesta a incidentes;
- impacto de incidentes anteriores;
- tiempos de recuperación;
- exposición regulatoria;
- pólizas y cobertura de ciberseguro.

La incertidumbre no implica que el análisis carezca de utilidad.

```text
incertidumbre ≠ ignorancia
```

La confianza puede aumentar mediante mejores datos y evidencia.

---

# 22. Efecto de un apetito de riesgo muy bajo

Si TELVORA establece un apetito muy bajo para el compromiso de cuentas privilegiadas, una pérdida residual cercana a:

```text
395.153 €/año
```

podría seguir siendo incompatible con el nivel de riesgo deseado.

En ese caso, C1 no sería necesariamente el final del tratamiento.

Sería necesario considerar controles adicionales y definir tolerancias operativas concretas, por ejemplo:

- ausencia de cuentas privilegiadas compartidas;
- MFA resistente al phishing para el 100 % del acceso privilegiado externo;
- cuentas de terceros con owner y fecha de expiración;
- privilegios permanentes reducidos al mínimo;
- excepciones documentadas, temporales y formalmente aceptadas.

La pregunta de gobierno deja de ser únicamente:

> “¿Es rentable C1?”

y pasa a ser:

> “¿El riesgo residual resultante está dentro del apetito y de las tolerancias aprobadas por TELVORA?”

---

# 23. Resumen de la decisión

```text
Escenario prioritario
R1 — Compromiso de identidad privilegiada

Pérdida anual esperada inicial
≈ 0,89 M€/año

Tratamiento
C1 — MFA resistente al phishing + refuerzo de cuentas privilegiadas

Coste anual equivalente
180.000 €

Pérdida anual esperada después de C1
≈ 395.153 €/año

Reducción estimada del riesgo
≈ 497.319 €/año

Beneficio neto aproximado
≈ 317.319 €/año

ROI aproximado
≈ 176,3 %

Decisión
MITIGAR

Riesgo residual
Permanece y debe ser aceptado o tratado adicionalmente según el apetito de riesgo.
```

---

# 24. Conclusiones

La práctica muestra que una decisión de riesgo defendible necesita conectar varias capas:

```text
activos y dependencias
        ↓
escenario concreto
        ↓
probabilidad e impacto
        ↓
incertidumbre
        ↓
cuantificación
        ↓
controles
        ↓
coste del tratamiento
        ↓
riesgo residual
        ↓
decisión
```

Las ideas principales son:

- una amenaza no es todavía un escenario de riesgo;
- una puntuación de una matriz no describe por completo un riesgo;
- la criticidad depende de los servicios y dependencias que soporta el activo;
- cuantificar riesgo no elimina la incertidumbre, pero permite hacerla explícita;
- un control debe evaluarse por el riesgo que reduce, no simplemente por existir;
- el riesgo residual permanece después del tratamiento;
- la decisión final depende también del apetito de riesgo y de la autoridad del propietario del riesgo.
