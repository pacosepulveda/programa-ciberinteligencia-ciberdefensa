# P06.0 — Investigator OPSEC Exposure Assessment
## ¿Qué revela el investigador mientras investiga?

**Máquina de trabajo:** `KALI01`  
**Internet:** requerido  
**Instalación de software adicional:** no requerida

## 1. Escenario

Antes de comenzar una investigación OSINT, TELVORA quiere evaluar la exposición operacional del propio analista.

Tu objetivo es determinar qué información puede observar un servicio externo cuando investigas desde `KALI01` y aplicar compartimentación para reducir la mezcla entre identidad personal/corporativa e identidad de investigación.

> Este laboratorio no busca anonimato absoluto. El objetivo es identificar y reducir exposición de acuerdo con el riesgo.

## 2. Threat model del investigador

Antes de realizar ninguna prueba, responde en `opsec-notes.md`:

1. ¿Quién podría observar tus consultas?
2. ¿Qué podría aprender un sitio web sobre tu estación?
3. ¿Qué consecuencias tendría mezclar una sesión corporativa con una investigación sensible?
4. ¿Qué nivel de separación necesitas para una investigación OSINT pasiva?

## 3. Baseline de red

Obtén la IP pública observada por un servicio externo:

```bash
curl -s https://ifconfig.co/json | tee network-baseline.json
```

Si el servicio anterior no responde, utiliza:

```bash
curl -s https://api.ipify.org ; echo
```

Revisa la configuración DNS local:

```bash
cat /etc/resolv.conf
```

Si está disponible:

```bash
resolvectl status
```

Documenta:

```text
PUBLIC IP:
ISP / ORGANIZATION IF SHOWN:
LOCAL DNS CONFIGURATION:
VPN/TUNNEL OBSERVED?:
NOTES:
```

## 4. Observa una consulta DNS

Abre dos terminales.

En la primera:

```bash
sudo tcpdump -i any -nn port 53
```

En la segunda:

```bash
dig example.com
```

Detén `tcpdump` después de observar la consulta.

Responde:

1. ¿La consulta DNS sale en claro desde la máquina?
2. ¿A qué resolver se envía?
3. ¿Qué actores podrían conocer el dominio consultado?
4. ¿Cambiaría la respuesta si se utilizase DoH/DoT o un túnel VPN?

> No asumas que una VPN elimina fingerprinting, cookies o identificación mediante cuentas.

## 5. Browser exposure

Abre Firefox en `KALI01` y visita:

- `https://browserleaks.com/webrtc`
- `https://coveryourtracks.eff.org/`

Registra, sin publicar datos personales, qué categorías de información aparecen disponibles:

```text
Remote/public IP
User-Agent / browser
Operating system / platform
Language
Timezone
Screen characteristics
WebGL / Canvas
WebRTC
Cookie/tracker behaviour
Fingerprint uniqueness
```

No es necesario copiar valores sensibles concretos al entregable. El objetivo es identificar **qué clases de información** son observables.

## 6. WebRTC

En Firefox abre:

```text
about:config
```

Localiza:

```text
media.peerconnection.enabled
```

Registra su valor actual.

Si el instructor autoriza modificar la configuración durante el laboratorio, cambia temporalmente el valor a `false`, repite la prueba de BrowserLeaks y documenta qué cambia.

Al terminar, devuelve la configuración al valor inicial salvo indicación contraria del instructor.

Responde:

1. ¿Qué problema intenta reducir este control?
2. ¿Deshabilitar WebRTC elimina el browser fingerprint?
3. ¿Por qué modificar muchos parámetros individuales puede incluso hacer más singular un navegador?

## 7. Compartimentación mediante perfiles

Comprueba los perfiles de Firefox:

```bash
firefox -P
```

Crea un perfil denominado:

```text
OSINT-RESEARCH
```

El perfil de investigación debe cumplir:

- sin login personal;
- sin SSO corporativo;
- sin Firefox Sync;
- sin extensiones innecesarias;
- cookies separadas del perfil habitual;
- historial separado;
- descargas de investigación en un directorio dedicado.

Crea:

```bash
mkdir -p ~/research/p06/{downloads,evidence,notes}
```

No borres ni modifiques el perfil habitual.

## 8. Comparación

Completa esta tabla en `opsec-assessment.md`:

| Vector | Situación inicial | Control aplicado | Situación posterior | Riesgo residual |
|---|---|---|---|---|
| IP pública | | | | |
| DNS | | | | |
| Cookies | | | | |
| WebRTC | | | | |
| Browser fingerprint | | | | |
| Identidad personal/corporativa | | | | |
| Descargas | | | | |

## 9. Análisis

Responde:

1. ¿Qué puede aprender un sitio web aunque no inicies sesión?
2. ¿Qué cambia al separar perfiles y qué no cambia?
3. ¿Por qué una VPN cambia la ruta pero no elimina cookies ni fingerprinting?
4. ¿Por qué Tor Browser tampoco corrige un login con una identidad real?
5. ¿Qué tres errores operacionales considerarías más graves durante una investigación sensible?
6. ¿Qué controles aplicarías para una investigación de bajo, medio y alto riesgo?

## 10. Debrief

Clasifica las siguientes afirmaciones como **verdaderas o falsas** y justifica:

1. «Si cambio mi IP ya no pueden correlacionarme.»
2. «El modo privado del navegador proporciona anonimato.»
3. «Separar perfiles reduce contaminación entre identidades.»
4. «Passive OSINT significa zero-risk.»
5. «OPSEC significa aplicar siempre el máximo anonimato posible.»

## Entregable

```text
p060/
├── network-baseline.json
├── opsec-notes.md
└── opsec-assessment.md
```

`opsec-assessment.md` debe terminar con un **threat model del investigador** y cinco controles priorizados para futuras investigaciones OSINT.
