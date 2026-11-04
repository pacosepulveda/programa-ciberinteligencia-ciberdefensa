# MA06.A — External Intelligence Watch
## Monitorización técnica de superficie externa y cambios observados

**Rol:** analista de External Threat Intelligence de TELVORA. **Modalidad:** individual, autónoma. **Entorno:** Python 3, terminal y navegador. No requiere suscripciones, API keys ni máquinas del cyber range.

### Encargo
Debes construir una herramienta pequeña que pueda recopilar datos públicos de un dominio autorizado, comparar observaciones, detectar cambios y representar relaciones técnicas. El CISO no quiere un inventario estático: necesita alertas reproducibles y que se reconozca cuándo una fuente falla.

El trabajo combina:
- **LIVE:** OSINT pasivo sobre cloudsecurityinpractice.com y nombres incluidos expresamente en la configuración.
- **CASE:** dos snapshots ficticios de telvora.example con cambios y fallos deliberados. Este banco de pruebas garantiza que puedas validar tu lógica aunque una fuente pública esté caída. **No representa un incidente real.**

### Preparación
Desde la raíz del repositorio:

~~~bash
cd modulo-06/mission-06/ma06-a
python3 --version
python3 starter/collect.py --config config.json --out resultados/live.json
python3 starter/compare.py data/baseline.json data/followup.json --out resultados/changes.json
python3 checks/check.py resultados/changes.json
python3 starter/graph.py data/followup.json --out resultados/graph.dot
~~~

**Importante:** el comparador tiene funciones por completar. Es normal que, antes de desarrollarlas, el validador indique resultados incompletos. Crea la carpeta de resultados antes de empezar si no existe; los scripts también pueden crearla.

### CORE — Investigación y automatización
1. Revisa config.json. Comprueba que todos los nombres están dentro del dominio expresamente autorizado. No hagas enumeración por diccionario, escaneo activo ni conexiones a aplicaciones.
2. Ejecuta el colector para consultas DNS pasivas a Google DNS. **Registra las fuentes disponibles e indisponibles**; si crt.sh no responde, no improvises resultados.
3. Inspecciona los snapshots de entrenamiento con jq o Python. Identifica campos de timestamp, procedencia, estados y valores.
4. Completa las funciones TODO de starter/compare.py. Compara conjuntos de A, CNAME, MX y NS sin depender del orden de las respuestas. Ignora duplicados.
5. Para estados timeout/unavailable, emite advertencias de falta de observación; **no inventes desapariciones de activos**.
6. Distingue un nombre nuevo en Certificate Transparency de un servidor DNS activo. CT por sí solo no confirma que un hostname resuelva.
7. Genera changes.json. Verifica su contrato con checks/check.py. Justifica qué alertas merecen revisión.
8. Ejecuta graph.py y abre el DOT usando una herramienta local compatible o visualízalo como texto. Comprueba relaciones y explica por qué IP compartida no equivale a propiedad de una organización.

### SUPPORT
- Consulta [schema.md](ma06-a/data/schema.md) para entender cada campo.
- Consulta [PISTAS.md](ma06-a/PISTAS.md) si necesitas ayuda con normalización y estados.
- No hay que instalar NetworkX ni Graphviz para completar CORE.

### STRETCH
- Añade una tercera captura LIVE en otra fecha y compara solo observaciones válidas.
- Incorpora una nueva regla que priorice cambios por criticidad de servicio.
- Exporta también changes.csv y añade tests con DNS duplicado y respuestas desordenadas.

### Entregables
Directorio personal con live.json, changes.json, graph.dot y notas técnicas breves (hasta 250 palabras) que indiquen dos hallazgos, una limitación de fuente y dos verificaciones defensivas.

### Criterios de éxito
El programa debe detectar cambios de registros y nombres, evitar falsos positivos por cambios de orden y tolerar fuentes que fallan. Los hallazgos deben ser reproducibles y distinguir **observación, inferencia y confirmación interna**.
