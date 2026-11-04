# MA06.C — Intelligence Brief: la decisión del CISO
## Transformar información incompleta en decisiones

**Modalidad:** individual y autónoma. **Entorno:** no requiere VMs. **Tipo:** ampliación integradora.

## 1. Situación

El CISO debe decidir cómo reaccionar ante los rumores sobre TELVORA y la información de amenazas a operadores. ¿Comunicar una brecha, abrir investigación, reforzar controles o mantener vigilancia? Tu trabajo es indicar **qué recomienda la evidencia**, con límites y desencadenantes claros.

Puedes utilizar resultados de MA06.A y MA06.B o, si no completaste alguna, trabajar directamente sobre el [material del caso](README.md#material-de-caso) sin presentar como hechos análisis que no has realizado.

## 2. Fase 1 — Evidencia ejecutiva

En **c-evidencias.md**, incluye al menos ocho afirmaciones o conclusiones que dependan de **tres familias de fuentes** distintas. Registra:

| ID | Afirmación | Fuente y referencia | Hecho/inferencia/hipótesis | Confianza | Limitación |
|---|---|---|---|---|---|
| | | | | | |

Explica qué fuentes derivan unas de otras. Puedes utilizar la [plantilla de evidencias](plantillas/REGISTRO_EVIDENCIAS.md).

## 3. Fase 2 — Opciones de decisión

En **c-decisiones.md**, valora tres decisiones:

| Acción o decisión | Evidencia que la sostiene | Riesgo de actuar prematuramente | Riesgo de esperar | Responsable | Trigger de revisión |
|---|---|---|---|---|---|
| | | | | | |

Incluye obligatoriamente:

1. una medida preventiva razonable con la información actual;
2. una actuación condicionada a validar un dato;
3. una actuación que **todavía no recomendarías** por evidencia insuficiente.

No des por cumplidos los requisitos legales de notificación de una brecha que no está demostrada. Si surge una posible obligación jurídica, indica qué hechos deben establecerse y que la valoración corresponde al equipo competente.

## 4. Fase 3 — Brief ejecutivo

Completa la [plantilla de briefing](plantillas/INTELLIGENCE_BRIEF.md) en **una página**:

- **BLUF:** conclusión y recomendación en dos o tres frases;
- **key judgments:** hasta tres juicios con confianza;
- **hechos establecidos y límites**;
- **hipótesis alternativas**;
- **relevancia de CTI externo**;
- **decisiones recomendadas y prioridades**;
- **tres PIR y triggers de revisión**.

El CISO debe entender qué decidir sin leer primero los anexos.

## 5. Fase 4 — Revisión crítica

En **c-revision-critica.md**, formula dos objeciones serias a tu propio análisis y describe cómo cambiarían la recomendación si se confirmaran.

Comprueba en particular que no hayas confundido republicaciones con corroboración, ausencia de logs con ausencia de amenaza, ni asociación de TTP a un actor con evidencia de actividad en TELVORA.

## Entregables

Carpeta **ma06-c** con c-evidencias.md, c-decisiones.md, c-revision-critica.md y c-intelligence-brief.md.

## Posible puesta en común

El **27 de enero de 2027**, si el instructor lo propone, el alumno podrá presentar su BLUF, defender una decisión y explicar la principal incertidumbre pendiente. No se requieren datos personales ni capturas de infraestructuras privadas.

## Autoevaluación

- [ ] La recomendación aparece en el primer párrafo.
- [ ] Cada juicio tiene una fuente y un nivel de confianza justificado.
- [ ] He distinguido vigilancia, investigación, contención y comunicación.
- [ ] He establecido triggers que podrían cambiar la decisión.
- [ ] Los vacíos de inteligencia se ven en el briefing, no quedan ocultos.
