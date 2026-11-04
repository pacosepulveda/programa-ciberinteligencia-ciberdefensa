# MA06.B — Digital Evidence Investigation
## Verificación de imágenes, localización, cronología y propagación de afirmaciones

**Rol:** analista OSINT/SOCMINT y verificación digital de TELVORA. **Modalidad:** individual. **Recursos:** navegador, terminal, Python 3, y ExifTool si está disponible. No requiere cuentas ni pagos.

### Caso
Se han difundido mensajes simulados que afirman que dos fotografías muestran intervenciones de emergencia tras un supuesto ciberataque en instalaciones de comunicaciones de **Madrid en noviembre de 2026**. Otro mensaje reproduce una de las afirmaciones sin aportar fuente independiente.

El CISO solicita verificar las afirmaciones: **¿qué muestran realmente las imágenes? ¿Dónde y cuándo existen evidencias de su publicación? ¿Qué mensajes repiten el mismo origen?**

No se afirma que haya ocurrido un incidente real. TELVORA y todos los mensajes sociales son ficticios.

### Punto de partida
Clona o descarga el repositorio, abre **localmente en el navegador** el fichero ma06-b/semillas.html y consulta [publicaciones.csv](ma06-b/data/publicaciones.csv). La vista de código de GitHub no representa la galería visual. No leas las URLs de las imágenes como una conclusión: los nombres de archivos y los créditos son pistas, pero debes corroborar identidad, ubicación, fechas y contexto con fuentes independientes. Las imágenes se muestran desde Wikimedia bajo sus licencias y con atribución.

### CORE: investigación real en fuentes públicas
1. Conserva hashes de las dos imágenes que descargues desde la galería. Registra hora UTC y origen de tu copia.
2. Investiga cada fotografía mediante búsqueda visual o de texto, y encuentra su ficha pública original. **No se incluyen respuestas ni páginas originales como material del alumno.**
3. Busca fechas de publicación y versiones históricas en Wikimedia Commons u otros archivos públicos.
4. Con el título de archivo que hayas descubierto, ejecuta la herramienta [mediawiki_info.py](ma06-b/starter/mediawiki_info.py) para extraer datos mediante **MediaWiki API**, conservando respuesta y URL consultada.
5. Inspecciona metadatos (ExifTool, file, hash) de las imágenes descargadas. Distingue fecha EXIF, primera publicación pública, fecha del mensaje ficticio y fecha de consulta.
6. Localiza ambas instalaciones en un mapa público. Corrobora por lo menos una pista visual para cada una y separa coordenadas **del fotógrafo** de coordenadas **del objeto**.
7. Reconstruye en CSV la cronología y la dependencia entre mensajes usando data/publicaciones.csv; distingue la publicación que incorpora evidencia de la que simplemente la reproduce.
8. Crea locations.geojson con dos puntos y URLs cartográficas de corroboración. Ejecuta [check.py](ma06-b/checks/check.py) para comprobar estructura, no la veracidad de la investigación.

### SUPPORT
- [Pistas sin respuestas](ma06-b/PISTAS.md).
- [Plantilla GeoJSON](ma06-b/plantillas/locations.geojson).
- [Plantilla cronológica](ma06-b/plantillas/timeline.csv).
- Si la búsqueda inversa exige crear cuenta, utiliza búsquedas web o cartográficas sin registro.

### STRETCH
- Examina el historial de una fotografía con MediaWiki API y compara revisiones públicas.
- Comprueba si un recorte o una versión de baja resolución mantiene suficientes pistas para geolocalizar.
- Representa los mensajes como un grafo de dependencias (DOT, CSV o NetworkX).

### Entregables
Capturas o enlaces de las fuentes encontradas; resultados JSON de MediaWiki; hashes de las imágenes; locations.geojson; timeline.csv; grafo o tabla de propagación; **conclusión de máximo 250 palabras**.

### Criterio de éxito
Se verifica por separado **qué representa la imagen**, **dónde está el objeto**, **qué antigüedad documental tiene** y **si demuestra la afirmación de una emergencia actual**. La ausencia de información no se transforma en certeza.

**Ética y alcance:** no investigar autores reales de fotografías, datos privados, perfiles de terceros ni realizar ingeniería social. Utiliza fuentes públicas sin registro. Las referencias a Madrid y al incidente son elementos de ficción.
