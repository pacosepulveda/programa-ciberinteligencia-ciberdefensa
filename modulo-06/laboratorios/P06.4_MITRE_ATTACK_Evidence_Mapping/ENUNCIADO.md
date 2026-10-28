# P06.4 — MITRE ATT&CK Evidence Mapping
## De evidencia CTI a técnicas, telemetría y oportunidades de detección

**Máquina de trabajo:** `KALI01` + navegador  
**Internet:** requerido  
**Instalación de software adicional:** no requerida

## 1. Escenario

TELVORA necesita convertir la inteligencia obtenida del advisory `AA25-239A` en conocimiento defensivo utilizable por SOC, Threat Hunting y Detection Engineering.

Tu misión es mapear comportamientos documentados a MITRE ATT&CK con una regla estricta:

> **Cada técnica mapeada debe tener evidencia explícita. Una técnica plausible pero no sustentada por la fuente no debe incluirse.**

Fuentes principales:

```text
CISA AA25-239A
https://www.cisa.gov/news-events/cybersecurity-advisories/aa25-239a
```

```text
MITRE ATT&CK — Salt Typhoon G1045
https://attack.mitre.org/groups/G1045/
```

Durante la primera fase **no consultes todavía la ficha G1045 de MITRE**. Realiza primero tu propio mapping desde el advisory.

## 2. Directorio de trabajo

```bash
mkdir -p ~/labs/m06/p064/{evidence,mapping,detection,comparison}
cd ~/labs/m06/p064
```

Utiliza el PDF de AA25-239A descargado en P06.3 o vuelve a obtenerlo desde la fuente oficial.

## 3. Extrae comportamientos, no técnicas

Lee el advisory y crea `evidence/observed-behaviours.md`.

Registra al menos **ocho comportamientos diferentes** utilizando este formato:

```text
BEHAVIOUR-ID: B01
SOURCE SECTION / PAGE:
EVIDENCE SUMMARY:
OBSERVED BEHAVIOUR:
WHAT IS NOT KNOWN:
```

Busca comportamientos relacionados con categorías como:

- reconocimiento;
- explotación de servicios/dispositivos expuestos;
- uso de relaciones de confianza;
- credenciales y autenticación;
- comandos en dispositivos de red;
- cambios de configuración;
- persistencia;
- tunneling/proxy;
- recolección;
- exfiltración;
- evasión o reducción de logging.

No añadas un comportamiento solo porque «Salt Typhoon suele hacerlo». Debe aparecer en la fuente que estás analizando.

## 4. Mapea cada comportamiento a ATT&CK

Ahora utiliza el sitio oficial de MITRE ATT&CK para buscar la técnica que mejor representa cada comportamiento:

```text
https://attack.mitre.org/
```

Crea `mapping/evidence-to-attack.md` con una tabla:

| Behaviour ID | Evidence summary | ATT&CK ID | Technique / Sub-technique | Tactic | Confidence | Rationale |
|---|---|---|---|---|---|---|
| B01 | | | | | | |

Utiliza:

```text
High confidence
```

cuando la conducta descrita encaje directamente con la técnica.

Utiliza:

```text
Medium confidence
```

cuando exista evidencia relevante pero haya ambigüedad en la técnica o subtécnica concreta.

Evita mapear con `Low confidence`: en ese caso registra el gap y no añadas la técnica al mapping principal.

## 5. Ejemplo de disciplina analítica

Si la evidencia indica que un actor accedió utilizando credenciales legítimas de una cuenta existente, puedes investigar si el comportamiento corresponde a:

```text
T1078 — Valid Accounts
```

Pero esa misma evidencia **no demuestra automáticamente**:

```text
Phishing
Credential Dumping
Brute Force
Privilege Escalation
```

Para incluir cualquiera de ellas necesitarías evidencia independiente.

## 6. Evita overmapping

Crea `mapping/rejected-mappings.md`.

Documenta al menos tres técnicas que inicialmente parecían plausibles pero que decidiste **no mapear** por falta de evidencia suficiente:

```text
TECHNIQUE:
WHY IT SEEMED PLAUSIBLE:
MISSING EVIDENCE:
DECISION: REJECTED
```

Esta parte forma parte del entregable y se valora tanto como los mappings aceptados.

## 7. De ATT&CK a telemetría

Selecciona al menos cinco técnicas mapeadas y completa `detection/telemetry-matrix.md`:

| ATT&CK | Behaviour | Required telemetry | Relevant fields | Detection opportunity | Limitations |
|---|---|---|---|---|---|
| | | | | | |

Considera fuentes como:

```text
AAA / authentication logs
router and switch syslog
configuration-change logs
TACACS+ / RADIUS logs
NetFlow / IPFIX
firewall logs
VPN logs
DNS
proxy logs
EDR where applicable
network management systems
```

Recuerda que un router o dispositivo de red no ofrece necesariamente la misma telemetría que un endpoint Windows/Linux con EDR.

## 8. Diseña detecciones conceptuales

Para tres técnicas crea una estrategia con este formato:

```text
ATT&CK:

OBSERVED BEHAVIOUR:

TELEMETRY:

ANALYTIC IDEA:

POSSIBLE FALSE POSITIVES:

VALIDATION METHOD:
```

Ejemplo de nivel esperado —no copiar literalmente como solución—:

```text
privileged authentication from a previously unseen source
+
configuration change shortly afterwards
```

La detección debe centrarse en comportamiento, no únicamente en bloquear una IP concreta.

## 9. Compara con la ficha pública de Salt Typhoon

Solo después de terminar tu mapping inicial abre:

```text
https://attack.mitre.org/groups/G1045/
```

Compara tu resultado con las técnicas que MITRE atribuye públicamente a Salt Typhoon.

Crea `comparison/mitre-comparison.md`:

```text
TECHNIQUES IN BOTH:

TECHNIQUES IN MY AA25-239A MAPPING BUT NOT VISIBLE IN G1045:

TECHNIQUES IN G1045 BUT NOT MAPPED FROM MY SOURCE:

EXPLANATION:
```

Responde:

1. ¿Por qué MITRE puede tener más técnicas que tu mapping?
2. ¿Significa que tu mapping está incompleto o que trabaja con un scope de evidencia distinto?
3. ¿Qué fuentes cita MITRE para las técnicas adicionales?
4. ¿Por qué no debes copiar todas las técnicas de G1045 y afirmar que aparecen en AA25-239A?

## 10. ATT&CK Navigator — opcional

Si el navegador tiene acceso al ATT&CK Navigator web, puedes representar visualmente las técnicas mapeadas.

Fuente:

```text
https://mitre-attack.github.io/attack-navigator/
```

No es necesario instalar Navigator localmente.

Diferencia visualmente, mediante las opciones de la herramienta si lo deseas:

- técnicas con evidencia directa;
- técnicas con evidencia parcial;
- técnicas descartadas.

Si exportas un layer JSON, consérvalo como:

```text
mapping/aa25-239a-navigator.json
```

## 11. De IOC a TTP

Selecciona un IOC del laboratorio P06.3 y compara su utilidad con una de las TTP mapeadas.

Responde:

```text
IOC:
HOW QUICKLY CAN IT CHANGE?:

TTP:
WHAT WOULD THE ACTOR NEED TO CHANGE TO AVOID THE DETECTION?:

WHICH ONE IS MORE DURABLE DEFENSIVELY?:
WHY?:
```

## 12. Mini Intelligence-to-Detection Brief

Crea `detection/intelligence-to-detection-brief.md` con:

```text
SCOPE

KEY BEHAVIOURS

HIGH-CONFIDENCE ATT&CK MAPPINGS

PRIORITY TELEMETRY

TOP 3 DETECTION OPPORTUNITIES

GAPS

RECOMMENDED ACTIONS
```

El documento debe poder ser utilizado por un responsable de SOC o Detection Engineering sin tener que leer el advisory completo.

## 13. Debrief

Responde:

1. ¿Qué diferencia existe entre táctica, técnica y subtécnica?
2. ¿Por qué mapear más técnicas no significa producir mejor CTI?
3. ¿Qué mapping fue más difícil y por qué?
4. ¿Qué técnica rechazaste por falta de evidencia?
5. ¿Qué telemetría de dispositivos de red consideras prioritaria para este caso?
6. ¿Qué detecciones serían más resistentes a la rotación de IOC?
7. ¿Cómo conecta ATT&CK Threat Intelligence con Threat Hunting y Detection Engineering?

## Entregable

```text
p064/
├── evidence/observed-behaviours.md
├── mapping/
│   ├── evidence-to-attack.md
│   ├── rejected-mappings.md
│   └── aa25-239a-navigator.json        # opcional
├── detection/
│   ├── telemetry-matrix.md
│   └── intelligence-to-detection-brief.md
└── comparison/mitre-comparison.md
```

La calidad del laboratorio se mide por la **trazabilidad entre evidencia y técnica**, no por el número total de técnicas mapeadas.
