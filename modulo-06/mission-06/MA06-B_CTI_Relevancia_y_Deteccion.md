# MA06.B — De CTI sectorial a detección
## Relevancia para TELVORA, ATT&CK selectivo y telemetría

**Modalidad:** individual y autónoma. **Entorno:** no requiere VMs. **Tipo:** ampliación intermedia-avanzada.

## 1. Escenario

Un aviso de amenazas reales contra operadores llega al SOC de TELVORA. Alguien sostiene que, por aparecer técnicas MITRE en el informe, el operador está comprometido. Tu misión es evaluar **relevancia, exposición, evidencia de ataque y necesidades defensivas** sin sobreatribuir.

## 2. Fuentes

- [Encargo del CISO](casebook/00_encargo_ciso.md).
- [Inventario técnico simulado](casebook/04_inventario_parcial.csv).
- [Observaciones SOC simuladas](casebook/03_observaciones_soc.csv).
- [Nota CTI de orientación](casebook/05_nota_cti.md).
- [P06.3: trabajo previo sobre AA25-239A](../laboratorios/P06.3_Real_CTI_Investigation_AA25-239A/ENUNCIADO.md).
- [Advisory real CISA AA25-239A](https://www.cisa.gov/news-events/cybersecurity-advisories/aa25-239a).
- [MITRE ATT&CK: Salt Typhoon G1045](https://attack.mitre.org/groups/G1045/).

**Separación de fuentes:** CISA y MITRE describen actividad del mundo real; TELVORA y sus eventos son ficticios. No existe evidencia de que el advisory se refiera a TELVORA. Si una URL externa no responde, documenta el fallo, la fecha y el alcance de las conclusiones posibles.

## 3. Fase 1 — Requisito y activos

En **b-requisitos.md**:

1. Formula un requisito prioritario de inteligencia y tres PIR.
2. Selecciona tres activos o dependencias del inventario que podrían ser relevantes para el escenario.
3. Identifica un activo cuyo riesgo no se pueda determinar con estos datos.
4. Distingue **relevancia sectorial**, **exposición**, **comportamiento observado** y **compromiso confirmado**.
5. Enumera tres intelligence gaps decisivos.

## 4. Fase 2 — Evidencia de comportamientos

Extrae **tres comportamientos** descritos en el advisory oficial; no basta con copiar la lista de técnicas de MITRE.

En **b-comportamientos.md** completa:

| Comportamiento | Referencia precisa a CISA | Activo TELVORA potencial | Evidencia de actividad propia | Limitación |
|---|---|---|---|---|
| | | | | |

La columna de evidencia interna puede y debe decir **no disponible** cuando corresponda. La ausencia de telemetría no equivale a ausencia de ataque.

## 5. Fase 3 — Mapeo ATT&CK reducido

Mapea **dos** comportamientos a una técnica o subtécnica ATT&CK, con ID, descripción, referencia de origen, justificación y confianza. Añade **un mapeo descartado** porque la fuente no respalda esa técnica.

El [P06.4](../laboratorios/P06.4_MITRE_ATTACK_Evidence_Mapping/ENUNCIADO.md) profundiza en este proceso. Es **opcional** y no se exige para realizar esta misión.

## 6. Fase 4 — Tres oportunidades de detección

En **b-deteccion.md**, crea una matriz:

| Comportamiento a detectar | Telemetría requerida | Origen de datos | Hipótesis de detección o hunting | Riesgo de falsos positivos | Owner |
|---|---|---|---|---|---|
| | | | | | |

Propón tres oportunidades y prioriza dos: una plausible con telemetría declarada en el casebook y otra condicionada a obtener una fuente que falta. No hace falta instalar herramientas, escribir reglas ejecutables, analizar IOC vivos ni acceder a dispositivos.

## 7. Fase 5 — Assessment del SOC

En **b-assessment.md**, máximo dos páginas, concluye:

- importancia del caso para un operador de telecomunicaciones;
- datos propios disponibles frente a no disponibles;
- dos medidas preventivas proporcionadas;
- evidencia que dispararía una investigación de incidentes;
- confianza y limitaciones del assessment.

Termina respondiendo: **¿qué evidencia concreta permitiría pasar de amenaza relevante a sospecha fundamentada de compromiso de TELVORA?**

## Entregables

Carpeta **ma06-b** con b-requisitos.md, b-comportamientos.md, b-attack.md, b-deteccion.md y b-assessment.md.

## Autoevaluación

- [ ] No he confundido amenaza sectorial con compromiso propio.
- [ ] Las técnicas ATT&CK están justificadas por comportamientos y citas, no copiadas por asociación.
- [ ] He rechazado al menos una atribución técnica insuficiente.
- [ ] Cada oportunidad de detección tiene telemetría concreta y limitaciones.
- [ ] Sé qué información adicional justificaría escalar.
