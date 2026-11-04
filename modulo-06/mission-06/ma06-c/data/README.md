# Datos de MA06.C

Contiene 800+ eventos **completamente ficticios** de TELVORA. Las IP pertenecen a rangos de documentación RFC 5737. No son IOC reales ni trazas de una campaña atribuida.

- events.jsonl: un JSON por línea, ordenado cronológicamente, con event_id estable, timestamp UTC, source, asset_id, event_type, user, src_ip, dst_ip, session_id, outcome, command, change_id, bytes_out y campos opcionales.
- assets.csv: rol y criticidad del equipo.
- admins.csv: inventario parcial de usuarios administrativos.
- approved_sources.csv: bastiones autorizados y orígenes desconocidos.
- changes.csv: calendario de solicitudes de cambio, incluidas peticiones canceladas.

Fuentes de evento: tacacs, command_audit, router_syslog, netflow, monitoring.
Algunas observaciones son legítimas, otras merecen investigación y otras no tienen suficiente contexto para concluir nada. El dataset **no** contiene etiquetas de verdad ni atribución.

Una autorización exige coincidencia de usuario, activo, acción, ventana temporal y estado approved. Un campo change_id presente **no es suficiente**.
