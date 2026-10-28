# P06.3 — Real CTI Investigation: AA25-239A
## IOC, STIX, enriquecimiento y Diamond Model sobre un caso real de telecomunicaciones

**Máquina de trabajo:** `KALI01`  
**Internet:** requerido  
**Instalación de software adicional:** no requerida

## 1. Escenario

TELVORA quiere analizar una campaña real contra infraestructura de telecomunicaciones y comprender qué información puede obtenerse de un producto CTI público.

Trabajarás con el advisory conjunto de CISA:

```text
AA25-239A — Countering Chinese State-Sponsored Actors Compromise of Networks Worldwide to Feed Global Espionage System
```

Fuente oficial:

```text
https://www.cisa.gov/news-events/cybersecurity-advisories/aa25-239a
```

PDF del advisory:

```text
https://www.cisa.gov/sites/default/files/2025-08/CSA_COUNTERING_CHINA_STATE_ACTORS_COMPROMISE_OF_NETWORKS.pdf
```

La página oficial proporciona además una lista descargable de IOC en STIX XML y STIX JSON.

> No interactúes con ninguna infraestructura indicada en el advisory más allá de consultas pasivas a servicios de enriquecimiento públicos. No realices escaneo, explotación ni conexiones directas a sistemas listados como IOC.

## 2. Directorio de trabajo

```bash
mkdir -p ~/labs/m06/p063/{source,stix,ioc,enrichment,diamond,evidence}
cd ~/labs/m06/p063
```

Registra la fecha:

```bash
date -u --iso-8601=seconds | tee evidence/start-time.txt
```

## 3. Obtención y preservación de fuentes

Desde la página oficial descarga:

- el advisory PDF;
- el fichero STIX JSON de IOC.

Guárdalos como:

```text
source/AA25-239A.pdf
stix/AA25-239A.json
```

Calcula hashes:

```bash
sha256sum source/AA25-239A.pdf stix/AA25-239A.json \
  | tee evidence/SHA256SUMS
```

Registra también las URLs de origen y la fecha/hora de descarga.

## 4. Lee primero el contexto

Antes de extraer IOC, revisa en el advisory:

- sectores objetivo;
- tipo de infraestructura comprometida;
- uso de routers de backbone, PE y CE;
- conexiones de confianza;
- persistencia;
- pivoting;
- observación sobre nombres de industria como Salt Typhoon, OPERATOR PANDA, RedMike, UNC5807 y GhostEmperor.

Crea `source/context-notes.md` y responde:

1. ¿Cuál es el objetivo operativo descrito por las agencias?
2. ¿Por qué la infraestructura de telecomunicaciones tiene un valor estratégico especial?
3. ¿Qué papel cumplen las trusted connections?
4. ¿Por qué los nombres de industria no deben tratarse como equivalencias 1:1?

## 5. Inspección STIX

Comprueba el fichero:

```bash
file stix/AA25-239A.json
jq . stix/AA25-239A.json | less
```

Cuenta objetos:

```bash
jq '.objects | length' stix/AA25-239A.json
```

Enumera tipos STIX:

```bash
jq -r '.objects[].type' stix/AA25-239A.json \
  | sort \
  | uniq -c \
  | tee stix/object-types.txt
```

Busca objetos `indicator` si existen:

```bash
jq '.objects[] | select(.type=="indicator")' \
  stix/AA25-239A.json \
  | less
```

Busca relaciones:

```bash
jq '.objects[] | select(.type=="relationship")' \
  stix/AA25-239A.json \
  | less
```

Responde:

1. ¿Qué tipos de objetos aparecen?
2. ¿Hay objetos que representen observables/indicadores?
3. ¿Hay relaciones explícitas entre objetos?
4. ¿Qué aporta STIX frente a una lista plana de IOC?

## 6. Extrae IOC

Extrae los patrones de `indicator`:

```bash
jq -r '
.objects[]
| select(.type=="indicator")
| .pattern
' stix/AA25-239A.json \
  | tee ioc/indicator-patterns.txt
```

Clasifica manualmente una muestra en:

```text
IPv4
Domain
URL
Hash
Other
```

No asumas que todos los objetos del fichero representan IOC directamente bloqueables.

## 7. Enriquecimiento pasivo

Selecciona varias IP públicas presentes en el dataset.

Para cada una consulta RDAP:

```bash
curl -s "https://rdap.org/ip/IP" | jq .
```

Y Shodan InternetDB:

```bash
curl -s "https://internetdb.shodan.io/IP" | jq .
```

Guarda cada respuesta en `enrichment/`.

Opcionalmente realiza DNS inverso:

```bash
dig -x IP
```

No ejecutes `nmap`, `masscan`, `curl` contra los IOC ni otras formas de interacción directa con la infraestructura listada.

## 8. IOC ≠ actor

Selecciona tres IOC y completa:

```text
IOC:
SOURCE:
OBSERVED CONTEXT:
RDAP CONTEXT:
SHODAN CONTEXT:
WHAT THIS PROVES:
WHAT THIS DOES NOT PROVE:
TIMESTAMP / TEMPORAL LIMITATION:
CONFIDENCE:
```

Responde:

1. ¿Que una IP esté en el advisory demuestra que actualmente sigue siendo maliciosa?
2. ¿Que RDAP muestre un proveedor implica que ese proveedor sea el actor?
3. ¿Qué riesgo tiene bloquear indefinidamente una IP cloud o de hosting compartido?
4. ¿Qué contexto necesitarías antes de convertir un observable en IOC operativo interno?

## 9. Diamond Model

Construye un Diamond Model basado **solo** en evidencia del advisory.

Completa:

```text
                    ADVERSARY
                       |
                       |
CAPABILITY ------------+------------ INFRASTRUCTURE
                       |
                       |
                     VICTIM
```

Para cada vértice registra:

### Adversary

- qué puede afirmarse;
- qué nombres de tracking aparecen;
- qué incertidumbre existe.

### Capability

- técnicas, herramientas o procedimientos documentados;
- vulnerabilidades o mecanismos de acceso cuando se indiquen.

### Infrastructure

- tipos de infraestructura;
- IOC concretos solo cuando estén documentados;
- routers comprometidos, VPS u otros elementos si aparecen.

### Victim

- sectores;
- tipos de red/dispositivo;
- relaciones proveedor-cliente relevantes.

Añade al menos cuatro relaciones entre vértices y cita la evidencia del advisory que las sustenta.

## 10. Niveles de CTI

A partir del mismo caso produce un ejemplo de cada nivel:

```text
TECHNICAL:
TACTICAL:
OPERATIONAL:
STRATEGIC:
```

Cada nivel debe dirigirse a un consumidor diferente.

## 11. Assessment

Crea `assessment.md` con:

```text
INTELLIGENCE REQUIREMENT:

KEY JUDGMENTS:

EVIDENCE:

ANALYSIS:

CONFIDENCE:

INTELLIGENCE GAPS:

IMPLICATIONS FOR A TELECOM OPERATOR:

RECOMMENDED COLLECTION:
```

No atribuyas actividad a un actor concreto más allá de lo que sostenga la fuente oficial.

## 12. Debrief

Responde:

1. ¿Qué aporta STIX frente a IOC en CSV?
2. ¿Qué información del advisory es estratégica y cuál es técnica?
3. ¿Qué IOC consideras más frágiles temporalmente?
4. ¿Qué TTP parecen más valiosas defensivamente que los IOC?
5. ¿Qué diferencia existe entre correlación de infraestructura y atribución?
6. ¿Por qué distintos vendors pueden usar nombres distintos para actividad parcialmente solapada?

## Entregable

```text
p063/
├── source/
│   ├── AA25-239A.pdf
│   └── context-notes.md
├── stix/
│   ├── AA25-239A.json
│   └── object-types.txt
├── ioc/indicator-patterns.txt
├── enrichment/
├── diamond/diamond-model.md
├── evidence/SHA256SUMS
└── assessment.md
```

El objetivo no es acumular IOC, sino demostrar que puedes transformar una fuente CTI pública en **contexto, relaciones, incertidumbre y decisiones de colección**.
