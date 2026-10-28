# P06.2 — Multimedia Verification & Geolocation
## Verificar una afirmación pública mediante metadata, geolocalización y cronología

**Máquina de trabajo:** `KALI01`  
**Internet:** requerido  
**Instalación de software adicional:** no requerida

## 1. Escenario

Una cuenta publica una fotografía y afirma:

> «La imagen fue tomada recientemente en las afueras de Madrid y demuestra presencia física en España.»

Tu misión es verificar o refutar la afirmación utilizando únicamente información pública, metadata y fuentes abiertas.

No investigues al autor de la fotografía ni perfiles personales. El objeto de investigación es exclusivamente **la imagen y la afirmación asociada**.

## 2. Hipótesis iniciales

Antes de analizar la imagen, crea `hypotheses.md` y registra:

```text
H1 — La imagen corresponde al lugar y periodo declarados.
H2 — La imagen corresponde a España, pero no a Madrid o no al periodo declarado.
H3 — La imagen procede de otro país o contexto.
```

Añade qué evidencia necesitarías para aumentar o reducir la plausibilidad de cada hipótesis.

## 3. Obtención de la evidencia

Utiliza como evidencia una fotografía pública de Wikimedia Commons indicada por el instructor.

Fuente de referencia del laboratorio:

```text
https://commons.wikimedia.org/wiki/File:IMG_摩文仁の丘.jpg
```

Descarga el fichero original desde la página de Wikimedia y guárdalo con un nombre neutro:

```text
evidence-original.jpg
```

No utilices todavía la descripción de Wikimedia como conclusión; primero analiza el fichero.

Crea el directorio:

```bash
mkdir -p ~/labs/m06/p062/{evidence,metadata,notes}
cd ~/labs/m06/p062
```

Mueve o copia la imagen a `evidence/`.

Calcula su hash:

```bash
sha256sum evidence/evidence-original.jpg \
  | tee evidence/SHA256SUMS
```

## 4. Inspección básica

```bash
file evidence/evidence-original.jpg
identify evidence/evidence-original.jpg 2>/dev/null || true
```

Si `identify` no está disponible, continúa sin instalar nada.

Registra:

```text
MIME/type:
Dimensions:
File size:
SHA256:
```

## 5. Metadata EXIF

Ejecuta:

```bash
exiftool evidence/evidence-original.jpg \
  | tee metadata/exif-original.txt
```

Busca especialmente:

```text
Date/Time Original
Create Date
Camera Make / Model
GPS Latitude
GPS Longitude
GPS Altitude
Software
Orientation
```

No asumas que todos los campos son fiables por el simple hecho de existir.

Responde:

1. ¿Existe información GPS?
2. ¿Existe una fecha de captura?
3. ¿Qué dispositivo parece haber creado la imagen?
4. ¿Qué partes de EXIF considerarías pistas y cuáles necesitarían corroboración?

## 6. Simula una copia de red social

Muchas plataformas eliminan metadata. Crea una copia local y elimina EXIF de **la copia**, no del original:

```bash
cp evidence/evidence-original.jpg evidence/evidence-social.jpg

exiftool -all= -overwrite_original \
  evidence/evidence-social.jpg
```

Comprueba:

```bash
exiftool evidence/evidence-social.jpg \
  | tee metadata/exif-social.txt
```

Calcula también su hash:

```bash
sha256sum evidence/evidence-social.jpg
```

Responde:

1. ¿Los dos hashes coinciden?
2. ¿La imagen visible sigue siendo esencialmente la misma?
3. ¿Qué información se ha perdido?
4. ¿Por qué ausencia de EXIF no implica que una imagen sea falsa?

## 7. Geolocalización

Utiliza primero las coordenadas si existen, pero no termines ahí.

Consulta al menos dos fuentes cartográficas públicas, por ejemplo:

- OpenStreetMap;
- Google Maps;
- otra fuente pública equivalente.

Documenta:

```text
COORDINATES:
COUNTRY:
REGION/CITY:
NEARBY LANDMARKS:
MAP SOURCE 1:
MAP SOURCE 2:
```

Después inspecciona visualmente la fotografía.

Busca pistas como:

- relieve;
- costa;
- vegetación;
- señalización;
- arquitectura;
- monumentos;
- idioma;
- infraestructura;
- posición aparente del sol si resulta útil.

Registra al menos **tres pistas independientes**.

## 8. Cronología

Compara:

- fecha EXIF;
- fecha de publicación en Wikimedia;
- historial del fichero;
- fecha implícita en la afirmación del escenario.

Visita la página de Wikimedia solamente después de haber realizado tu primera evaluación técnica.

Determina:

```text
EARLIEST VERIFIED PUBLIC DATE:
EXIF DATE:
CLAIMED PERIOD:
CONSISTENT?: Yes / No / Uncertain
```

## 9. Corroboración y fuente original

En la página de Wikimedia revisa:

- descripción;
- fecha;
- autor;
- ubicación;
- historial del archivo;
- licencia.

Distingue:

```text
metadata embebida en el fichero
```

frente a:

```text
metadata / información publicada por la plataforma
```

No son la misma fuente de evidencia.

## 10. Assessment

Crea `verification-report.md` con esta estructura:

```text
CLAIM:

KEY JUDGMENT:

CONFIDENCE: High / Medium / Low

SUPPORTING EVIDENCE:
1.
2.
3.

CONTRADICTING EVIDENCE:
1.
2.

GEOLOCATION ASSESSMENT:

CHRONOLOCATION ASSESSMENT:

INTELLIGENCE GAPS:

FINAL ASSESSMENT:
```

Debes justificar expresamente por qué una fotografía auténtica puede difundirse con un contexto falso o engañoso.

## 11. Debrief

Responde:

1. ¿Qué diferencia existe entre autenticidad del fichero y veracidad del claim?
2. ¿Qué habría ocurrido si solo dispusieras de `evidence-social.jpg` sin EXIF?
3. ¿Por qué una única pista visual no suele ser suficiente?
4. ¿Qué aporta la búsqueda inversa de imágenes en un caso real?
5. ¿Qué datos de geolocalización considerarías suficientemente sólidos para un assessment de alta confianza?
6. ¿Qué elementos podrían haber sido manipulados deliberadamente?

## Entregable

```text
p062/
├── evidence/
│   ├── evidence-original.jpg
│   ├── evidence-social.jpg
│   └── SHA256SUMS
├── metadata/
│   ├── exif-original.txt
│   └── exif-social.txt
├── hypotheses.md
└── verification-report.md
```

El informe final debe concluir si la afirmación es **supported, contradicted o unresolved**, e indicar un nivel de confianza.
