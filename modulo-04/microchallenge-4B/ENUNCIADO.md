# Microchallenge 4.B — OAuth/OIDC Security Review

**Duración:** 15–20 minutos

## Contexto

TELVORA desarrolla una aplicación desktop y un portal web. El equipo propone:

```text
Flow: Authorization Code
redirect_uri: https://app.telvora.test/callback/*
PKCE: disabled
Access token: 24 hours
Refresh token rotation: disabled
Desktop client_secret: embedded in executable
Backend client authentication: client_secret_post
```

Adicionalmente, el portal acepta bearer tokens desde cualquier dispositivo.

## Tarea

Clasifica cada elemento como:

```text
ACCEPTABLE
WEAK
HIGH RISK
NEEDS CONTEXT
```

| Elemento | Clasificación | Riesgo | Mejora |
|---|---|---|---|
| redirect wildcard | | | |
| PKCE disabled | | | |
| access token de 24 h | | | |
| sin refresh-token rotation | | | |
| desktop client secret embebido | | | |
| backend `client_secret_post` | | | |
| bearer token sin restricción adicional | | | |

## Preguntas

1. ¿Por qué una aplicación desktop debe tratarse normalmente como *public client*?
2. ¿Qué ataque intenta dificultar PKCE?
3. ¿Por qué una redirect URI flexible amplía la superficie de ataque?
4. ¿Qué riesgo conserva un bearer token aunque se obtuviese después de MFA fuerte?
5. ¿Qué significa *sender-constrained token*?
6. ¿Qué logs necesitarías para investigar un posible abuso de tokens?
