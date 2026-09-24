# M02 — Gobernanza, Gestión del Riesgo y Resiliencia
## Enunciados de laboratorios para el alumno

**Programa:** Programa Avanzado de Ciberinteligencia y Ciberdefensa  
**Empresa ficticia:** Telvora Communications (TELVORA)  
**Entorno:** Telvora Cyber Range  
**Módulo:** M02  
**Prácticas:** P02.1, P02.2 y P02.3  
**Versión:** 1.0 — septiembre de 2026

---

# 1. Propósito del módulo

En este módulo el objetivo no es aprender a “rellenar una matriz de riesgos”.

El alumno debe practicar el ciclo completo:

```text
contexto
  ↓
activos y dependencias
  ↓
escenario de riesgo
  ↓
análisis
  ↓
cuantificación
  ↓
decisión de tratamiento
  ↓
continuidad
  ↓
crisis
  ↓
revisión
```

Las prácticas están diseñadas para que las decisiones puedan ser defendidas ante responsables técnicos y de negocio.

---

# 2. Objetivos prácticos

Al finalizar el módulo el alumno deberá ser capaz de:

- distinguir activo, proceso, amenaza, vulnerabilidad, impacto, control y riesgo;
- modelar dependencias entre servicios, información, aplicaciones, identidad e infraestructura;
- construir escenarios de riesgo concretos evitando formulaciones ambiguas;
- aplicar una aproximación cualitativa inspirada en MAGERIT;
- utilizar conceptos de Open FAIR para expresar riesgo en términos económicos;
- distinguir riesgo inherente, riesgo residual y apetito/tolerancia al riesgo;
- elaborar un Business Impact Analysis (BIA);
- definir MTPD, RTO y RPO coherentes;
- seleccionar estrategias de continuidad justificadas por impacto y coste;
- tomar decisiones durante una crisis con información incompleta;
- documentar decisiones, hipótesis y niveles de confianza;
- conectar gobierno, gestión de riesgos, continuidad y respuesta a incidentes.

---

# 3. Recursos necesarios

Este módulo **no requiere máquinas virtuales**.

Se necesita únicamente:

- editor de texto u hoja de cálculo;
- calculadora;
- acceso a las fuentes indicadas;
- los datos del escenario incluidos en este documento.

Por tanto, las prácticas son idénticas en equipos con 8 GB y 16 GB de RAM.

---

# 4. Referencias de trabajo

Las prácticas utilizan conceptos de:

- **MAGERIT v3**, metodología pública española de análisis y gestión de riesgos;
- **NIST Cybersecurity Framework 2.0**, especialmente la función GOVERN;
- **Open FAIR**, para razonamiento cuantitativo del riesgo;
- **Esquema Nacional de Seguridad (ENS)**, como referencia de gobierno y gestión basada en riesgo;
- principios de continuidad y análisis de impacto de negocio.

No se espera aplicar íntegramente ningún estándar. El objetivo es aprender a utilizar sus conceptos de forma coherente.

Fuentes:

- MAGERIT v3:  
  https://administracionelectronica.gob.es/ctt/magerit

- NIST Cybersecurity Framework 2.0:  
  https://www.nist.gov/cyberframework

- Open FAIR:  
  https://www.opengroup.org/open-fair

- Esquema Nacional de Seguridad — RD 311/2022:  
  https://www.boe.es/eli/es/rd/2022/05/03/311/con

---

# P02.1 — Telvora Risk Board
## Del inventario técnico a una decisión de riesgo defendible

---

## 1. Escenario

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

## 2. Inventario simplificado

### A01 — Portal de clientes

- servicio público;
- acceso web;
- autenticación mediante `IDP01`;
- depende de `DNS01`;
- consulta datos de `CRM01`;
- indisponibilidad visible inmediatamente para clientes.

### A02 — CRM01

- base de datos de clientes;
- contiene información comercial y datos personales;
- utilizada por atención al cliente y operaciones;
- copias de seguridad diarias.

### A03 — IDP01

- plataforma de identidad corporativa;
- autentica empleados y administradores;
- se utiliza para VPN, SaaS y aplicaciones internas;
- determinadas cuentas poseen privilegios elevados.

### A04 — DNS01

- infraestructura DNS autoritativa para servicios públicos;
- esencial para la resolución de los servicios externos de TELVORA.

### A05 — VPN01

- acceso remoto para personal técnico;
- autenticación federada mediante `IDP01`.

### A06 — BACKUP01

- repositorio de copias;
- copia diaria de CRM01;
- copia semanal de determinadas configuraciones;
- accesible mediante una cuenta de servicio dedicada.

### A07 — SUPPLIER01

- proveedor externo de soporte;
- dispone de una cuenta nominativa y acceso limitado por VPN a sistemas concretos.

---

## 3. Dependencias

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

## 4. Dimensiones de impacto

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

## 5. Escenarios de riesgo

Analiza:

### R1 — Compromiso de identidad privilegiada

Un administrador recibe un phishing dirigido. El atacante obtiene una sesión válida y accede a recursos internos utilizando credenciales legítimas.

### R2 — Explotación de VPN perimetral

Se publica una vulnerabilidad crítica que afecta a la versión desplegada en `VPN01`. Existen intentos de explotación en Internet antes de completarse el parcheado.

### R3 — Ransomware con afectación de CRM y copias

Un atacante obtiene acceso inicial, alcanza `CRM01` y logra afectar también al repositorio `BACKUP01`.

### R4 — Ataque DDoS contra DNS y portal

Un actor hacktivista intenta degradar la disponibilidad de los servicios públicos de TELVORA.

### R5 — Compromiso del proveedor

Las credenciales de `SUPPLIER01` son comprometidas y se utilizan para acceder mediante la relación de confianza existente.

---

## 6. Declaración formal del riesgo

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

## 7. Evaluación cualitativa

Asigna a cada riesgo:

### Probabilidad

| Valor | Interpretación |
|---:|---|
| 1 | Rara |
| 2 | Poco probable |
| 3 | Posible |
| 4 | Probable |
| 5 | Muy probable |

### Impacto

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

### Threat Event Frequency — TEF

Número anual de intentos relevantes capaces de llegar al usuario privilegiado:

```text
mínimo: 2
más probable: 4
máximo: 8
```

### Vulnerability

Probabilidad de que un intento relevante produzca un compromiso efectivo:

```text
mínimo: 25 %
más probable: 35 %
máximo: 45 %
```

### Primary Loss Magnitude

Pérdidas directas por incidente:

```text
mínimo: 150.000 €
más probable: 400.000 €
máximo: 900.000 €
```

### Secondary Loss Magnitude

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

## 9. Estimación PERT

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

---

# P02.2 — Continuity Under Pressure
## Business Impact Analysis y estrategia de recuperación

---

## 1. Escenario

El comité ejecutivo solicita revisar la continuidad de cuatro servicios.

La organización dispone de recursos limitados. No puede implementar active-active en todo.

Debes decidir:

> **¿Qué debe recuperarse primero, en cuánto tiempo y con qué nivel de pérdida de datos aceptable?**

---

# 2. Procesos y dependencias

## S1 — Autenticación corporativa

Depende de:

- `IDP01`;
- DNS interno;
- conectividad.

Si falla:

- administradores no pueden acceder a determinados sistemas;
- usuarios pueden perder acceso a SaaS;
- VPN puede verse afectada.

## S2 — Portal de clientes

Depende de:

- DNS;
- frontend;
- `IDP01`;
- `CRM01`.

## S3 — Atención al cliente

Depende de:

- CRM01;
- telefonía;
- identidad corporativa.

## S4 — Facturación

Depende de:

- CRM01;
- motor de facturación;
- almacenamiento;
- procesos batch.

---

# 3. Impacto temporal

Para cada servicio valora el impacto a:

- 1 hora;
- 4 horas;
- 8 horas;
- 24 horas;
- 72 horas.

Escala:

| Valor | Descripción |
|---:|---|
| 1 | Menor |
| 2 | Moderado |
| 3 | Significativo |
| 4 | Grave |
| 5 | Crítico |

Completa:

| Servicio | 1 h | 4 h | 8 h | 24 h | 72 h |
|---|---:|---:|---:|---:|---:|
| S1 Identidad | | | | | |
| S2 Portal | | | | | |
| S3 Atención cliente | | | | | |
| S4 Facturación | | | | | |

---

# 4. Definiciones

Para cada servicio establece:

### MTPD — Maximum Tolerable Period of Disruption

Tiempo máximo que la organización puede tolerar la interrupción antes de que el impacto sea inaceptable.

### RTO — Recovery Time Objective

Objetivo máximo de tiempo para recuperar el servicio.

Debe cumplirse normalmente:

```text
RTO < MTPD
```

### RPO — Recovery Point Objective

Máxima pérdida de datos temporal aceptable.

---

# 5. Define MTPD, RTO y RPO

Completa:

| Servicio | MTPD | RTO | RPO | Justificación |
|---|---|---|---|---|
| S1 Identidad | | | | |
| S2 Portal | | | | |
| S3 Atención | | | | |
| S4 Facturación | | | | |

Comprueba que tus valores no son contradictorios.

---

# 6. Estrategias disponibles

TELVORA puede financiar un máximo de **450.000 €** para las siguientes mejoras durante el próximo ejercicio.

### E1 — Identidad redundante

Coste:

```text
180.000 €
```

Efecto esperado:

- RTO de identidad: 1 hora;
- RPO: 15 minutos.

### E2 — Portal active-passive automatizado

Coste:

```text
140.000 €
```

Efecto:

- RTO portal: 2 horas;
- RPO: 30 minutos.

### E3 — Replicación CRM

Coste:

```text
220.000 €
```

Efecto:

- RTO CRM: 2 horas;
- RPO: 30 minutos.

### E4 — Backups inmutables + restauración probada

Coste:

```text
120.000 €
```

Efecto:

- reduce la probabilidad de pérdida simultánea de producción y backup;
- RTO de recuperación ante ransomware: 8 horas;
- RPO: 24 horas.

### E5 — Segundo proveedor DNS

Coste:

```text
90.000 €
```

Efecto:

- reduce dependencia de DNS;
- RTO ante fallo del proveedor principal: 30 minutos.

### E6 — Procedimiento manual de facturación diferida

Coste:

```text
35.000 €
```

Efecto:

- no recupera el sistema;
- permite operar de manera degradada durante un máximo de 72 horas.

---

# 7. Selección

Selecciona una combinación que no supere:

```text
450.000 €
```

Debes justificarla en función de:

- BIA;
- dependencias;
- riesgo;
- coste;
- efecto en RTO/RPO;
- riesgo residual.

No se evalúa únicamente “comprar el máximo”.

---

# 8. Prueba de coherencia

Responde:

1. ¿Una copia diaria puede cumplir un RPO de 30 minutos?
2. ¿Un RTO de 8 horas es válido si el MTPD es 4 horas?
3. ¿Un procedimiento manual puede ser una estrategia de continuidad válida?
4. ¿Redundancia equivale a backup?
5. ¿Alta disponibilidad sustituye a la recuperación ante ransomware?

---

# P02.3 — Telvora Crisis Tabletop
## Decisiones de ciberdefensa bajo incertidumbre

---

# 1. Escenario inicial

**Martes, 09:00.**

El SOC comunica:

- múltiples autenticaciones anómalas asociadas a una cuenta administrativa;
- varios endpoints presentan ejecución de PowerShell no habitual;
- un servidor de ficheros ha comenzado a generar un número anormal de escrituras;
- el EDR ha bloqueado un binario en dos equipos;
- todavía no existe evidencia suficiente para confirmar ransomware.

El Director de Operaciones pregunta:

> “¿Tenemos un incidente? ¿Debemos aislar sistemas?”

---

# 2. Reglas

Trabajarás como miembro del equipo de crisis.

En cada fase debes registrar:

```text
DECISIÓN
EVIDENCIA DISPONIBLE
HIPÓTESIS
RIESGO DE ACTUAR
RIESGO DE NO ACTUAR
RESPONSABLE
SIGUIENTE INFORMACIÓN NECESARIA
```

No puedes utilizar información de fases futuras.

---

# 3. Inject 1 — 09:15

Nueva información:

- la cuenta administrativa se autenticó desde una dirección IP no habitual;
- el usuario afirma no estar trabajando;
- existen conexiones SMB desde un endpoint hacia seis servidores;
- no hay aún ficheros cifrados confirmados.

Decide:

- ¿deshabilitar la cuenta?
- ¿aislar el endpoint?
- ¿bloquear SMB entre segmentos?
- ¿declarar incidente mayor?
- ¿informar al comité ejecutivo?

Justifica.

---

# 4. Inject 2 — 09:40

Nueva información:

- aparecen extensiones desconocidas en archivos de un servidor;
- el EDR detecta comportamiento compatible con cifrado masivo;
- `BACKUP01` ha recibido intentos fallidos de autenticación con una cuenta de servicio;
- atención al cliente funciona con normalidad;
- todavía no se conoce la extensión total.

Decide:

- alcance de aislamiento;
- tratamiento de backups;
- prioridad de continuidad;
- escalado;
- conservación de evidencias.

---

# 5. Inject 3 — 10:10

Nueva información:

- `CRM01` deja de responder;
- el último backup confirmado correctamente restaurable tiene 18 horas;
- la copia más reciente existe, pero no se ha validado;
- un periodista contacta con comunicación preguntando por “un posible ciberataque a TELVORA”;
- no existe confirmación de exfiltración.

Decide:

- si activar continuidad;
- qué RPO asumir inicialmente;
- qué mensaje interno emitir;
- qué puede decirse externamente;
- qué no puede afirmarse todavía;
- qué funciones deben participar.

---

# 6. Inject 4 — 11:00

Nueva información:

- análisis de proxy muestra transferencias de varios gigabytes hacia un servicio externo en las últimas 48 horas;
- parte del tráfico procede de un servidor con acceso a datos de clientes;
- aún no se ha determinado el contenido exacto;
- la actividad maliciosa parece haber comenzado dos días antes.

Decide:

- cómo cambia la clasificación;
- qué hipótesis aumentan o disminuyen;
- qué prioridades cambian;
- qué necesidades legales/regulatorias deben ser evaluadas;
- qué evidencia debe preservarse.

No debes realizar afirmaciones jurídicas concluyentes sin disponer de la información correspondiente.

---

# 7. Inject 5 — 13:00

Se confirma:

- compromiso de una cuenta privilegiada;
- movimiento lateral;
- cifrado parcial de CRM01;
- intentos de acceso a backups;
- probable exfiltración aún bajo investigación.

El equipo técnico puede:

### Opción A
Restaurar inmediatamente el backup de hace 18 horas.

### Opción B
Esperar aproximadamente cuatro horas para validar la copia más reciente, potencialmente reduciendo la pérdida de datos a unas dos horas.

### Opción C
Mantener CRM offline hasta finalizar completamente el análisis forense.

Selecciona una estrategia y justifica:

- disponibilidad;
- integridad;
- RPO;
- RTO;
- riesgo de reinfección;
- evidencia;
- impacto al negocio.

Puede existir más de una decisión defendible.

---

# 8. After Action Review

Prepara:

## Línea temporal

Al menos diez hitos.

## Decisiones correctas

Tres.

## Decisiones discutibles

Dos.

## Información que faltó

Tres elementos.

## Controles preventivos

Cinco.

## Controles de detección

Cinco.

## Mejoras de continuidad

Tres.

## Riesgo residual

Describe qué riesgo seguiría existiendo incluso después de implantar las mejoras.

---

# 9. Entregables del módulo

## P02.1

- mapa de dependencias;
- valoración C/I/D/A/T;
- cinco declaraciones formales de riesgo;
- matriz cualitativa;
- cálculo FAIR simplificado de R1;
- evaluación económica de C1;
- decisión de tratamiento y riesgo residual.

## P02.2

- matriz de impacto temporal;
- MTPD/RTO/RPO;
- combinación de estrategias ≤ 450.000 €;
- justificación y riesgo residual.

## P02.3

- registro de decisiones de los cinco injects;
- línea temporal;
- After Action Review.

---

# 10. Criterios de evaluación

| Criterio | Peso |
|---|---:|
| Modelado de activos y dependencias | 10 % |
| Calidad de los escenarios de riesgo | 10 % |
| Evaluación cualitativa | 10 % |
| Cuantificación FAIR simplificada | 15 % |
| Decisión de tratamiento | 10 % |
| BIA, MTPD, RTO y RPO | 15 % |
| Estrategia de continuidad | 10 % |
| Decisiones durante la crisis | 15 % |
| Gestión de incertidumbre y calidad documental | 5 % |

---

# 11. Principios que deben conservarse

- Una matriz no es el riesgo.
- El riesgo necesita un escenario.
- “Crítico” sin justificación no es análisis.
- El valor de un activo incluye sus dependencias.- RTO y RPO no son deseos: deben estar soportados por arquitectura y procedimientos.
- Alta disponibilidad, backup y continuidad resuelven problemas diferentes.
- Un control reduce riesgo; rara vez lo elimina.
- Una decisión de crisis debe poder explicarse con la información disponible en ese momento.
- El riesgo debe poder comunicarse en términos que permitan decidir.

---

**Fin del enunciado de M02**