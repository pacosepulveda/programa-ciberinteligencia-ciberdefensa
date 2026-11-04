# MA06.C — Pistas técnicas (sin identificar sesiones del caso)

1. Carga eventos JSONL línea a línea. Ordena siempre por timestamp UTC, no por número de línea.
2. Agrupa por session_id, asset_id y user. Trata session_id null como datos de contexto, no como una sesión correlacionable.
3. Busca auth con outcome success antes de config_export y después logging_change, todos en una ventana máxima de 15 minutos.
4. Consulta approved_sources.csv para conocer bastiones habituales, pero no des por confirmada una intrusión solo porque la IP sea desconocida.
5. Para autorizaciones, un change_id presente no basta: comprueba status approved, asset, approved_user, ventana y acciones.
6. En eventos de monitoring puede haber una zona sin logs. Eso indica falta de visibilidad, no ausencia de cambios.
7. Sigma en este ejercicio detecta el evento atómico; la lógica de secuencia corresponde a hunt.py.
8. Una técnica ATT&CK compatible con el comportamiento observado es una hipótesis de mapping; **no identifica al actor**.
