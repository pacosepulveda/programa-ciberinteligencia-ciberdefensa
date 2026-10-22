# P04.2 — IAM Privilege & Identity Audit
## Standing privilege, group nesting y gobierno técnico de identidad

**Objetivo:** auditar identidades y privilegios reales en el dominio Samba AD de TELVORA y diseñar un target state que reduzca la exposición permanente.

Esta práctica no consiste en explotar Active Directory. Se trabaja **gobierno técnico de identidad, privilegio efectivo, mínimo privilegio y evidencia**.

---

## 1. Preparación del escenario

En `AD01`, actualiza o clona el repositorio del curso y entra en el directorio del laboratorio:

```bash
git clone https://github.com/pacosepulveda/programa-ciberinteligencia-ciberdefensa.git
cd programa-ciberinteligencia-ciberdefensa/modulo-04/laboratorios/P04.2_Telvora_IAM_Privilege_Identity_Audit
```

Si ya tienes el repositorio:

```bash
cd ~/programa-ciberinteligencia-ciberdefensa
git pull
cd modulo-04/laboratorios/P04.2_Telvora_IAM_Privilege_Identity_Audit
```

Prepara el escenario:

```bash
sudo bash prepare_p04_2_samba_ad.sh
```

El script solo prepara los objetos necesarios para la práctica. A partir de este punto, **no debes modificar cuentas, grupos ni contraseñas durante la fase de auditoría**.

Comprueba que estás trabajando sobre el dominio correcto:

```bash
sudo samba-tool domain info 127.0.0.1
```

El dominio esperado es:

```text
telvora.lab
```

---

## 2. Investigación inicial

Tu objetivo es descubrir la estructura IAM del dominio, no recibirla ya resuelta.

Empieza por enumerar usuarios y grupos:

```bash
sudo samba-tool user list
sudo samba-tool group list
```

Investiga los grupos que puedan otorgar capacidades administrativas, operativas, remotas o de backup.

Para revisar los miembros directos de un grupo:

```bash
sudo samba-tool group listmembers "NOMBRE DEL GRUPO"
```

No te limites a una única profundidad. Si un grupo contiene a otro grupo, continúa la investigación hasta llegar a identidades finales.

Para conocer los grupos directos de una identidad:

```bash
sudo samba-tool user getgroups "USUARIO"
```

---

## 3. Revisar propiedades de las cuentas

Para inspeccionar un objeto de usuario:

```bash
sudo samba-tool user show "USUARIO"
```

Para reducir la salida a atributos útiles:

```bash
sudo samba-tool user show "USUARIO" \
  --attributes=sAMAccountName,userAccountControl,accountExpires,memberOf
```

Presta especial atención a `userAccountControl`.

Algunos flags relevantes son:

```text
0x0002  ACCOUNTDISABLE
0x0200  NORMAL_ACCOUNT
0x10000 DONT_EXPIRE_PASSWORD
```

Ejemplo de interpretación:

```text
512    = cuenta normal
514    = cuenta normal deshabilitada
66048  = cuenta normal + password no expira
66050  = cuenta normal deshabilitada + password no expira
```

No clasifiques una cuenta únicamente por su nombre. Combina:

```text
propiedades de la cuenta
+
memberships
+
privilegio efectivo
+
función aparente
```

---

## 4. Construir el mapa de privilegios

Identifica al menos:

- miembros directos de grupos privilegiados;
- privilegios indirectos por **group nesting**;
- cuentas deshabilitadas que conservan memberships;
- identidades no humanas con credenciales de larga duración;
- privilegio administrativo permanente;
- posibles cuentas de emergencia;
- posibles cuentas de terceros/proveedores;
- grupos que conceden acceso remoto u operativo.

Construye una tabla como esta:

| Identity | Type | Privilege path | Direct/indirect | Enabled? | Password expires? | Risk |
|---|---|---|---|---|---|---|
| | | | | | | |

Importante: diferencia entre **membership directo** y **privilegio efectivo**.

---

## 5. Cinco findings

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

Si una afirmación de gobierno no puede demostrarse técnicamente —por ejemplo, que una identidad carece de owner, MFA, aprobación o revisión periódica— debe redactarse como **pregunta de auditoría o evidencia pendiente**, no como hecho.

---

## 6. Diseñar el target state

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

## 7. Prioriza

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

## 8. Debrief

1. ¿Por qué el group nesting puede ocultar privilegio efectivo?
2. ¿Por qué una cuenta deshabilitada sigue siendo un hallazgo si permanece en grupos con acceso?
3. ¿Qué diferencia hay entre una service account necesaria y una service account bien gobernada?
4. ¿Por qué `DONT_EXPIRE_PASSWORD` es especialmente sensible en identidades no humanas?
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