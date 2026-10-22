# P04.2 — IAM Privilege & Identity Audit
## Standing privilege, group nesting y gobierno técnico de identidad

**Objetivo:** auditar identidades y privilegios reales del dominio TELVORA desde una estación administrativa Windows y diseñar un *target state* que reduzca la exposición permanente.

Esta práctica no consiste en explotar Active Directory. Se trabaja **gobierno técnico de identidad, privilegio efectivo, mínimo privilegio y evidencia**.

La investigación se realizará desde **MEMBER01**, con Windows Server 2025 Standard Desktop Experience. `AD01` seguirá actuando como controlador de dominio Samba AD de `telvora.lab`.

---

## 1. Máquinas necesarias

Arranca:

```text
AD01
MEMBER01
```

La preparación inicial del escenario se realiza una sola vez en **AD01**. Después, toda la auditoría se realiza desde **MEMBER01** con Active Directory Users and Computers.

> Para administrar el Samba AD utiliza **Active Directory Users and Computers** (`dsa.msc`). No utilices Active Directory Administrative Center (`dsac.exe`).

---

## 2. Preparar el escenario en AD01

El directorio del laboratorio contiene:

```text
prepare_p04_2_samba_ad.sh
```

En AD01, sitúate en el directorio del laboratorio y ejecuta:

```bash
chmod +x prepare_p04_2_samba_ad.sh
sudo ./prepare_p04_2_samba_ad.sh
```

El script utiliza `samba-tool` para preparar las identidades, grupos y memberships necesarios para el escenario.

La salida normal es:

```text
[P04.2] Validando AD01 y preparando el escenario IAM...
[P04.2] Escenario preparado correctamente.
[P04.2] Continua la practica desde MEMBER01 con Active Directory Users and Computers (dsa.msc).
```

El script es idempotente: puede ejecutarse de nuevo sin duplicar usuarios, grupos o memberships.

A partir de este momento, **no modifiques cuentas, grupos ni contraseñas durante la fase de auditoría**.

---

## 3. Abrir Active Directory Users and Computers en MEMBER01

Inicia sesión en MEMBER01 con la cuenta administrativa del dominio TELVORA.

Desde MEMBER01 pulsa:

```text
Win + R
```

Ejecuta:

```text
dsa.msc
```

También puedes abrirlo desde:

```text
Server Manager
→ Tools
→ Active Directory Users and Computers
```

Comprueba que puedes navegar por:

```text
telvora.lab
```

Activa:

```text
View
→ Advanced Features
```

Trabaja principalmente sobre los contenedores y grupos del dominio.

---

## 4. Inventario inicial

Sin conocer previamente la respuesta, identifica:

- cuentas añadidas al dominio para funciones administrativas u operativas;
- identidades que parezcan corresponder a servicios;
- posibles cuentas externas o de terceros;
- posibles cuentas de emergencia;
- cuentas deshabilitadas;
- grupos adicionales a los grupos estándar de Active Directory.

No clasifiques una identidad únicamente por su nombre. El nombre puede orientar la investigación, pero la conclusión debe apoyarse en sus propiedades y memberships.

---

## 5. Investigar grupos privilegiados y group nesting

Empieza por grupos que claramente puedan conceder privilegios elevados, por ejemplo:

```text
Domain Admins
```

Para cada grupo relevante:

1. abre **Properties**;
2. revisa la pestaña **Members**;
3. diferencia entre usuarios y grupos;
4. si aparece otro grupo como miembro, ábrelo y continúa la cadena;
5. repite hasta llegar a identidades finales.

También puedes estudiar una identidad desde:

```text
Properties
→ Member Of
```

No te limites a una sola profundidad.

Tu objetivo es reconstruir rutas como:

```text
identidad
→ grupo
→ grupo superior
→ privilegio efectivo
```

La pestaña **Member Of** muestra principalmente memberships directos; el privilegio efectivo puede depender de grupos anidados.

---

## 6. Revisar propiedades de las cuentas

Para las identidades que consideres relevantes, abre:

```text
Properties
→ Account
```

Comprueba especialmente:

- si la cuenta está habilitada o deshabilitada;
- si aparece marcada la opción **Password never expires**;
- si existe una fecha de expiración de cuenta;
- qué memberships directos conserva.

Una cuenta deshabilitada puede seguir siendo un hallazgo si conserva autorizaciones mediante grupos.

---

## 7. Validación opcional desde PowerShell/CMD

La investigación principal debe hacerse gráficamente con ADUC.

Si quieres contrastar algún dato desde MEMBER01 puedes usar herramientas clásicas que no dependen de Active Directory Web Services, por ejemplo:

```powershell
net user NOMBRE_USUARIO /domain
```

```powershell
net group "NOMBRE_GRUPO" /domain
```

Estas comprobaciones son de apoyo; no sustituyen la reconstrucción visual del privilegio efectivo.

---

## 8. Construir el mapa de privilegios

Identifica al menos:

- miembros directos de grupos privilegiados;
- privilegios indirectos por **group nesting**;
- cuentas deshabilitadas que conservan memberships;
- identidades no humanas con credenciales de larga duración;
- privilegio administrativo permanente;
- posibles cuentas de emergencia;
- posibles cuentas de terceros/proveedores;
- grupos que conceden acceso remoto u operativo.

Construye:

| Identity | Type | Privilege path | Direct/indirect | Enabled? | Password expires? | Risk |
|---|---|---|---|---|---|---|
| | | | | | | |

Importante: diferencia siempre entre **membership directo** y **privilegio efectivo**.

---

## 9. Cinco findings

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

No se acepta como hallazgo una hipótesis sin evidencia obtenida del dominio.

Si una afirmación de gobierno no puede demostrarse técnicamente —por ejemplo owner, MFA, aprobación, JIT o revisión periódica— debe redactarse como **pregunta de auditoría o evidencia pendiente**, no como hecho.

---

## 10. Diseñar el target state

A partir de los problemas encontrados, diseña un modelo objetivo para funciones como:

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

Puedes proponer, cuando sea razonable:

- JIT/JEA/PAM;
- separación de cuentas administrativas;
- gMSA o identidad gestionada para workloads;
- expiración de accesos de terceros;
- MFA resistente a phishing;
- dispositivos o redes administrativas dedicadas;
- logging de privilegios;
- revisiones periódicas.

No basta con nombrar una tecnología: explica qué riesgo reduce.

---

## 11. Prioriza

Solo puedes aplicar **tres cambios esta semana**.

Prioriza considerando:

```text
abuse potential
× privilege impact
× exposure duration
× business dependency
```

No se exige una fórmula matemática.

---

## 12. Debrief

1. ¿Por qué el group nesting puede ocultar privilegio efectivo?
2. ¿Por qué una cuenta deshabilitada sigue siendo un hallazgo si permanece en grupos con acceso?
3. ¿Qué diferencia hay entre una service account necesaria y una service account bien gobernada?
4. ¿Por qué `Password never expires` es especialmente sensible en identidades no humanas?
5. ¿Qué controles compensatorios exige una break-glass account?
6. ¿Por qué eliminar standing privilege reduce exposición incluso si la autenticación ya es fuerte?
7. ¿Qué aspectos importantes del gobierno IAM no puedes demostrar únicamente mirando Active Directory?
8. ¿Qué evidencias adicionales pedirías para una auditoría completa de accesos privilegiados?

---

## Entregable

Crea `iam-audit.md`, máximo 2 páginas, con:

- mapa de privilegios efectivo;
- cinco findings sustentados por evidencia;
- tres acciones priorizadas;
- target state;
- validación propuesta;
- riesgo residual;
- evidencias de gobierno que faltaría solicitar fuera de AD.