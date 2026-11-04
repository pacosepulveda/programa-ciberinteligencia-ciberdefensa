# MA06.C — Threat Intelligence to Detection
## Hunting, MITRE ATT&CK y reglas Sigma sobre registros simulados de TELVORA

**Rol:** analista CTI / Threat Hunter del SOC. **Entorno:** Python 3, terminal y navegador. **Coste:** gratuito; no se requiere SIEM ni API comercial.

### Escenario
Tras revisar un advisory de amenazas contra operadores de telecomunicaciones, TELVORA quiere comprobar si sus registros administrativos contienen **secuencias** compatibles con los comportamientos descritos. Los eventos de entrenamiento son **sintéticos**, no evidencias del advisory ni IOC reales, y **no permiten atribuir actividad a un actor**.

P06.3 ya explicó CTI e IOC; P06.4 explicó mappings ATT&CK. Aquí debes dar el siguiente paso: **buscar eventos, ejecutar correlaciones y validar detecciones**.

### Inicio
~~~bash
cd modulo-06/mission-06/ma06-c
python3 --version
python3 starter/hunt.py --events data/events.jsonl --changes data/changes.csv --out resultados/alerts.json
python3 checks/check.py --events data/events.jsonl --changes data/changes.csv --alerts resultados/alerts.json
~~~

El detector contiene TODOs que debes implementar. La primera ejecución puede generar cero alertas; eso **no significa ausencia de actividad**, sino que aún no has implementado la lógica.

### CORE — Cinco fases técnicas

**Fase 1: inteligencia de amenazas.** Consulta la fuente pública oficial [CISA AA25-239A](https://www.cisa.gov/news-events/cybersecurity-advisories/aa25-239a) y [MITRE ATT&CK](https://attack.mitre.org/). Selecciona dos comportamientos relevantes para la administración de routers y registra cita o sección y limitaciones en un JSON de trabajo. No extrapoles todas las TTP de un grupo a este expediente.

**Fase 2: hunting reproducible.** Inspecciona data/events.jsonl (JSONL) y los inventarios CSV. Selecciona una secuencia de interés: autenticación privilegiada, exportación de configuración y cambio de logging, con **mismo usuario, dispositivo y sesión** dentro de 15 minutos. Investiga también los gaps de telemetría. Revisa el orden: que todos los eventos existan no implica que la secuencia haya ocurrido correctamente.

**Fase 3: contexto y falsos positivos.** Cruza las coincidencias con data/changes.csv, data/approved_sources.csv y data/admins.csv. Un ticket sólo autoriza si coincide estado approved, usuario, activo, acción y ventana. Un ticket cancelled o una estación desconocida requieren revisión, pero no son prueba de intrusión.

**Fase 4: detecciones.** Completa starter/hunt.py para generar resultados/alerts.json. Edita una regla atómica Sigma basada en [plantilla](ma06-c/templates/router_logging_change.yml). La regla Sigma expresa el evento; la correlación multievento se ejecuta en Python y **no queda validada por crear el YAML**.

**Fase 5: ATT&CK y tests.** Construye un layer JSON importable desde [plantilla](ma06-c/templates/attack-layer.json) para ATT&CK Navigator, con únicamente técnicas sustentadas y notas de evidencias. Ejecuta checks/check.py con tus alertas y explica discrepancias. Registra al menos una posible falsa alerta y una limitación de cobertura.

### SUPPORT
- [Diccionario de datos](ma06-c/data/README.md).
- [Pistas progresivas](ma06-c/PISTAS.md).
- [Parser proporcionado](ma06-c/starter/parse_events.py), con carga y normalización listas.
- [Ejemplo reducido](ma06-c/checks/demo_events.jsonl) para que puedas comprobar tu lógica antes de trabajar con el fichero grande.

### STRETCH
- Una segunda correlación sobre fallos de autenticación, conservando contexto para evitar atribución incorrecta.
- Comparar correlación por IP frente a usuario+sesión+dispositivo.
- Añadir tests de eventos desordenados, repetidos y ventanas cruzando medianoche.
- Modelar la correlación con Sigma Correlation (si tienes backend compatible), sin afirmar que el YAML atómico la implementa.

### Entregables
1. resultados/alerts.json y el fichero de búsqueda Python ejecutable.
2. Un YAML Sigma con logsource, selection, condition y falsos positivos.
3. Un layer JSON ATT&CK Navigator con técnicas concretas y referencias.
4. Tabla breve de evidencias por event_id y un máximo de 250 palabras de conclusiones.

### Criterios de éxito
Detectar **secuencias, no palabras clave**; distinguir ventanas autorizadas de actividad que merece investigación; reconocer gaps; referenciar event_id; mapear técnicas sólo cuando exista evidencia; verificar que las reglas pasan los tests pertinentes.

No conectes con IOC reales, direcciones del advisory ni dispositivos de terceros.
