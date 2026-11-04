# MA06.A — Operación Rumor
## OSINT/SOCMINT: verificar una narrativa sobre TELVORA

**Modalidad:** individual y autónoma. **Entorno:** no requiere VMs. **Tipo:** misión base recomendada.

## 1. Escenario

Publicaciones públicas afirman que TELVORA ha sufrido una filtración masiva y que una campaña de espionaje conocida explica anomalías recientes. El CISO pide un análisis defendible sobre **qué sabemos, qué inferimos y qué no hemos demostrado**. Los mensajes son ficticios; no hay que buscar a sus autores ni investigar personas reales.

## 2. Materiales

Revisa el [encargo del CISO](casebook/00_encargo_ciso.md), las [publicaciones](casebook/01_publicaciones.csv), el [comunicado de TELVORA](casebook/02_comunicado_corporativo.md) y las [observaciones del SOC](casebook/03_observaciones_soc.csv).

Trabaja sobre las copias locales y registra cada fuente por su identificador. No resuelvas nombres de host ni IP del escenario; están reservados para documentación.

## 3. Fase 1 — Requisitos de inteligencia y OPSEC

En un documento llamado **a-plan.md**:

1. Formula el requisito principal de inteligencia.
2. Propón tres preguntas prioritarias (PIR).
3. Clasifica las fuentes en primarias, secundarias, internas, externas y derivadas.
4. Explica qué riesgos de OPSEC o sesgos evitarías si la investigación fuera real.
5. Indica tres límites del material de partida.

## 4. Fase 2 — Matriz de afirmaciones

Registra al menos **seis afirmaciones**. Utiliza la tabla:

| Claim ID | Afirmación | Fuente original | Corroboración independiente | Evidencia a favor | Evidencia en contra | Veredicto |
|---|---|---|---|---|---|---|
| C01 | | | | | | |

El veredicto debe ser **supported**, **contradicted** o **unresolved**. Indica además si la frase es observación, inferencia, testimonio o especulación.

Detecta al menos dos casos en que una publicación reutiliza otra sin aportar evidencia nueva. No confundas volumen de mensajes con pluralidad de fuentes.

## 5. Fase 3 — Cronología

En **a-cronologia.md**, reconstruye como mínimo ocho hitos ordenados en UTC. Separa fecha del evento alegado, publicación del mensaje y observación técnica. Aclara qué hechos son contemporáneos y cuáles aluden a un advisory publicado en otro año.

## 6. Fase 4 — Hipótesis rivales

Mantén abiertas, como mínimo, estas tres:

- H1: un incidente de seguridad explica alguna anomalía;
- H2: existe principalmente una degradación operacional amplificada por rumores;
- H3: ambas circunstancias podrían coexistir, aunque aún no esté demostrado.

En **a-hipotesis.md** registra para cada hipótesis evidencia favorable, evidencia contradictoria, incertidumbres, dato que la refutaría y confianza razonada. No inventes probabilidades numéricas.

## 7. Fase 5 — Nota de verificación

Entrega **a-nota-verificacion.md**, máximo dos páginas, con:

- claim principal, veredicto provisional y confianza;
- tres hallazgos confirmados y sus fuentes;
- dos afirmaciones no demostradas;
- distinción entre afirmación corporativa y evidencia técnica;
- tres acciones de colección pasiva y proporcionada;
- respuesta explícita a la pregunta: **¿hay pruebas suficientes de filtración masiva o de atribución a un actor?**

## Entregables

Carpeta **ma06-a** con a-plan.md, a-matriz-claims.md, a-cronologia.md, a-hipotesis.md y a-nota-verificacion.md. Puedes adjuntar el [registro de evidencias](plantillas/REGISTRO_EVIDENCIAS.md).

## Autoevaluación

- [ ] He distinguido fuente original y republicaciones.
- [ ] He etiquetado las afirmaciones según su grado de verificación.
- [ ] He citado fuentes concretas, no opiniones sin origen.
- [ ] No he convertido un problema de disponibilidad en prueba de exfiltración.
- [ ] Sé qué evidencia cambiaría mi juicio.
