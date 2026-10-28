# P06.1 — External Surface Intelligence
## OSINT técnico sobre `cloudsecurityinpractice.com`

**Máquina de trabajo:** `KALI01`  
**Internet:** requerido  
**Instalación de software adicional:** no requerida  
**Scope autorizado:** `cloudsecurityinpractice.com` y sus subdominios

## 1. Escenario

TELVORA quiere evaluar cómo un tercero puede reconstruir la superficie pública de una organización utilizando exclusivamente fuentes abiertas y consultas de bajo impacto.

En este laboratorio utilizarás `cloudsecurityinpractice.com`, dominio expresamente autorizado por el instructor.

La misión es construir una visión técnica de:

```text
dominio
  ↓
hostnames
  ↓
DNS
  ↓
IP
  ↓
red / ASN / proveedor
  ↓
certificados
  ↓
servicios observados por terceros
```

> No realices explotación, fuerza bruta, port scanning ni acceso autenticado. Las consultas deben mantenerse dentro del scope indicado.

## 2. Directorio de trabajo

```bash
mkdir -p ~/labs/m06/p061/{dns,ct,tls,rdap,shodan,recon,evidence}
cd ~/labs/m06/p061
```

Registra el inicio:

```bash
date -u --iso-8601=seconds | tee evidence/start-time.txt
```

## 3. Baseline DNS

Obtén los registros principales:

```bash
dig cloudsecurityinpractice.com A

dig cloudsecurityinpractice.com AAAA

dig cloudsecurityinpractice.com NS

dig cloudsecurityinpractice.com MX

dig cloudsecurityinpractice.com TXT
```

Guarda una copia compacta:

```bash
{
  echo '### A'; dig +short cloudsecurityinpractice.com A
  echo '### AAAA'; dig +short cloudsecurityinpractice.com AAAA
  echo '### NS'; dig +short cloudsecurityinpractice.com NS
  echo '### MX'; dig +short cloudsecurityinpractice.com MX
  echo '### TXT'; dig +short cloudsecurityinpractice.com TXT
} | tee dns/baseline.txt
```

Responde:

1. ¿Qué proveedor parece gestionar el DNS?
2. ¿Qué revela el MX?
3. ¿Qué terceros aparecen en TXT/SPF/verificaciones?
4. ¿Qué datos constituyen hechos y cuáles son inferencias?

## 4. Certificate Transparency

Consulta crt.sh:

```bash
curl -s 'https://crt.sh/?q=%25.cloudsecurityinpractice.com&output=json' \
  -o ct/crtsh.json
```

Extrae nombres únicos:

```bash
jq -r '.[].name_value' ct/crtsh.json \
  | tr '\n' '\n' \
  | sed 's/^\*\.//' \
  | sort -u \
  | tee ct/hosts.txt
```

Revisa la lista.

> Un nombre presente en CT demuestra que apareció asociado a un certificado; no demuestra que siga activo hoy.

## 5. Contrasta CT con DNS actual

Ejecuta:

```bash
while read -r host; do
  printf '%-60s ' "$host"
  dig +short "$host" A | paste -sd ',' -
done < ct/hosts.txt | tee dns/ct-vs-dns.txt
```

Clasifica cada hostname relevante en una de estas categorías:

```text
A. aparece en CT y resuelve actualmente
B. aparece en CT pero no resuelve actualmente
C. aparece activo por otra fuente pero no lo localizaste en CT
```

Para al menos cinco hostnames, registra:

| Hostname | Fuente | DNS actual | IP | Estado analítico |
|---|---|---|---|---|
| | | | | |

## 6. theHarvester

Utiliza únicamente backends pasivos que funcionen sin credenciales en tu instalación.

Comienza comprobando ayuda y fuentes disponibles:

```bash
theHarvester -h
```

Prueba como mínimo:

```bash
theHarvester -d cloudsecurityinpractice.com -b crtsh
```

Si `certspotter` u otro backend pasivo está disponible y funciona sin API key, puedes compararlo:

```bash
theHarvester -d cloudsecurityinpractice.com -b certspotter
```

Documenta:

- qué fuentes funcionaron;
- qué resultados coincidieron con CT directo;
- qué resultados nuevos aparecieron;
- qué backend falló o requirió credenciales, si ocurrió.

No confundas fallo de una fuente externa con ausencia de infraestructura.

## 7. Recon-ng

Inicia:

```bash
recon-ng
```

Crea o carga un workspace dedicado:

```text
workspaces create csip
workspaces load csip
```

Explora el framework:

```text
help
marketplace search domains
marketplace search hosts
modules search
```

No instales software adicional para completar el laboratorio. Si ya existen módulos adecuados en tu entorno, utiliza únicamente módulos pasivos y dentro del scope.

Documenta en `recon/recon-ng-notes.md`:

1. workspace utilizado;
2. módulos disponibles relevantes;
3. cuáles requieren API keys;
4. qué valor aporta el framework frente a ejecutar consultas independientes;
5. qué limitaciones introduce depender de módulos/APIs externas.

## 8. Inspección TLS

Selecciona hasta tres hostnames HTTPS activos identificados durante la investigación.

Para cada uno:

```bash
openssl s_client \
  -connect HOSTNAME:443 \
  -servername HOSTNAME \
  </dev/null 2>/dev/null \
| openssl x509 -noout \
  -subject -issuer -dates -serial -ext subjectAltName
```

Guarda la salida en `tls/`.

Compara:

- Subject;
- Issuer;
- validez;
- SAN;
- nombres históricos vistos en CT.

Responde:

1. ¿El certificado actual coincide con lo esperado a partir de CT?
2. ¿Hay nombres SAN adicionales relevantes?
3. ¿Qué información es histórica y cuál corresponde a una observación actual?

## 9. IP, RDAP y contexto de proveedor

Para cada IP relevante obtenida:

```bash
curl -s "https://rdap.org/ip/IP" | jq .
```

Guarda cada resultado en `rdap/`.

Identifica:

```text
IP
network / CIDR
RIR
organization / entity
handle
country if present
```

Responde:

1. ¿La entidad registrada es necesariamente la organización que opera la aplicación?
2. ¿Aparece un proveedor cloud/CDN/hosting?
3. ¿Qué diferencia hay entre propiedad de red, alojamiento y propiedad del servicio?

## 10. Shodan sin cuenta: InternetDB

Para cada IP pública relevante:

```bash
curl -s "https://internetdb.shodan.io/IP" | jq .
```

Guarda las respuestas en `shodan/`.

Según la IP, InternetDB puede devolver:

```text
ports
hostnames
cpes
tags
vulns
```

Analiza:

1. ¿Qué servicios ha observado Shodan?
2. ¿Coinciden hostnames y puertos con tus otras fuentes?
3. ¿Existe información de vulnerabilidades?
4. ¿Puedes afirmar que una vulnerabilidad sigue presente? ¿Por qué no?
5. ¿Qué importancia tiene el timestamp o la posible antigüedad del dato?

Puedes utilizar también la interfaz web gratuita de Shodan como fuente adicional, pero el laboratorio no depende de disponer de una cuenta de pago.

## 11. Correlación de fuentes

Construye una tabla final:

| Hostname | CT | DNS | TLS | IP | RDAP / proveedor | Shodan | Observaciones |
|---|---:|---:|---:|---|---|---:|---|
| | | | | | | | |

No necesitas registrar todos los nombres: prioriza los que aporten contexto distinto.

## 12. Hecho, inferencia, assessment e incógnita

Selecciona cinco hallazgos y documenta:

```text
EVIDENCE:
FACT:
INFERENCE:
ASSESSMENT:
UNKNOWN:
CONFIDENCE: High / Medium / Low
WHY:
```

Ejemplo de disciplina analítica:

```text
FACT: un hostname aparece en CT y actualmente resuelve a una IP.
FACT: RDAP asocia el rango a un proveedor cloud.
INFERENCE: el servicio probablemente está alojado en ese proveedor.
UNKNOWN: no sabemos si la infraestructura es dedicada o compartida.
```

## 13. Debrief

Responde:

1. ¿Qué fuente produjo más descubrimientos?
2. ¿Qué fuente produjo más contexto?
3. ¿Qué diferencia existe entre CT y DNS actual?
4. ¿Por qué una IP de AWS, Cloudflare u otro proveedor no implica que el proveedor sea el objetivo?
5. ¿Por qué Shodan no sustituye a un scanner de vulnerabilidades interno?
6. ¿Qué ventaja aporta combinar varias fuentes?
7. ¿Qué resultados eliminarías de un informe por falta de evidencia suficiente?

## Entregable

```text
p061/
├── dns/
├── ct/
├── tls/
├── rdap/
├── shodan/
├── recon/recon-ng-notes.md
├── correlation-table.md
└── assessment.md
```

`assessment.md` debe incluir cinco hallazgos clasificados como **fact / inference / assessment / unknown**, su nivel de confianza y una breve evaluación de la superficie externa observable.
