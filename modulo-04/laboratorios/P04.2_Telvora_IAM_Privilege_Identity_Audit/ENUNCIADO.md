# P04.2 — IAM Privilege & Identity Audit
## Standing privilege, group nesting y gobierno técnico de identidad

**Duración:** 45–60 minutos  
**Objetivo:** auditar identidades y privilegios de TELVORA y diseñar un target state que reduzca exposición permanente.

Esta práctica no consiste en explotar Active Directory. Se trabaja **gobierno técnico de identidad, privilegios efectivos y evidencia**.

## 1. Modalidades

### Modalidad principal — AD01

Si `AD01` está disponible, realiza la revisión sobre el dominio de laboratorio `telvora.test` usando herramientas de consulta del entorno Samba AD/LDAP proporcionadas por el instructor.

No debes modificar cuentas, grupos ni contraseñas durante la fase de auditoría.

### Modalidad de respaldo — Evidence Pack

Si no tienes acceso directo a `AD01`, utiliza los CSV de [`evidence/`](evidence/). Representan una exportación controlada del mismo escenario y permiten completar el análisis sin inventar datos.

## 2. Alcance

La revisión incluye identidades similares a:

```text
alice.admin
bob.ops
carla.net
svc_backup
svc_legacy
vendor_noc
breakglass01
former.contractor
```

Y grupos como:

```text
Domain Admins
Server Admins
Network Operators
NOC Vendors
Backup Operators
Remote Access Users
```

## 3. Inventario de privilegios

Identifica:

- miembros directos de grupos privilegiados;
- privilegios indirectos por group nesting;
- cuentas deshabilitadas/obsoletas que conservan membership;
- service accounts con credenciales de larga duración;
- privilegio administrativo permanente;
- break-glass accounts;
- cuentas de terceros/proveedores;
- restricciones temporales o ausencia de expiración.

Construye:

| Identity | Type | Privilege path | Direct/indirect | Standing? | Justification known? | Risk |
|---|---|---|---|---|---|---|
| | | | | | | |

## 4. Cinco findings

Documenta al menos cinco hallazgos:

```text
Finding ID:
Evidence:
Privilege path / affected identity:
Security impact:
Likely abuse scenario:
Recommended control:
How to validate remediation:
Residual risk:
```

No se acepta como hallazgo una hipótesis sin evidencia.

## 5. Target state

Para cada rol diseña un modelo objetivo:

```text
Domain administration
Server administration
Backup operations
Vendor access
Emergency access
Service workloads
```

Incluye:

| Role | Authentication | Privilege model | Standing/JIT | Duration | Source restriction | Telemetry | Review |
|---|---|---|---|---|---|---|---|
| | | | | | | | |

Puedes proponer, cuando sea razonable, controles como JIT/JEA/PAM, separación de cuentas administrativas, gMSA/workload identity, expiración de acceso de terceros, MFA, dispositivos administrativos dedicados y revisiones periódicas.

No basta con nombrar una tecnología: explica qué riesgo reduce.

## 6. Prioriza

Solo puedes aplicar **tres cambios esta semana**.

Prioriza considerando:

```text
abuse potential
× privilege impact
× exposure duration
× business dependency
```

No se exige una fórmula matemática.

## 7. Debrief

1. ¿Por qué el group nesting puede ocultar privilegio efectivo?
2. ¿Por qué una cuenta deshabilitada sigue siendo un hallazgo si permanece en grupos críticos?
3. ¿Qué diferencia hay entre una service account necesaria y una service account bien gobernada?
4. ¿Por qué `PasswordNeverExpires` es especialmente sensible en identidades no humanas?
5. ¿Qué controles compensatorios exige una break-glass account?
6. ¿Por qué eliminar standing privilege reduce exposición incluso si la autenticación ya es fuerte?
7. ¿Qué evidencias guardarías para una auditoría de accesos privilegiados?

## Entregable

`iam-audit.md`, máximo 2 páginas, con:

- mapa de privilegios;
- cinco findings;
- tres acciones priorizadas;
- target state;
- validación propuesta;
- riesgo residual.
