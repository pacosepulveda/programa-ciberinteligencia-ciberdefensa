#!/usr/bin/env python3
"""MA06.C: completar detección de secuencias administrativas, sin dependencias externas.

Una coincidencia exige auth->config_export->logging_change (en ese orden),
mismo user, asset_id y session_id, todas exitosas, <= 15 minutos.
Antes de alertar como actividad no autorizada consulta cambios aprobados.
"""
import argparse
import json
from pathlib import Path

from parse_events import group_sessions, is_approved_change, read_csv, read_events


def detect_sessions(events, changes):
    """TODO ALUMNO: implementar la correlación temporal y los controles de autorización.

    Estructura de alerta:
    {
      "alert_id": "AL-001",
      "asset_id": "BR-EDGE-01",
      "session_id": "TV-S-...",
      "user": "some-user",
      "priority": "high",
      "event_ids": ["TV-E...", "TV-E...", "TV-E..."],
      "rationale": "justificación basada en contexto, sin atribución"
    }

    Sugerencia: for (asset_id, user, session_id), rows in group_sessions(events).items()
    Después ordena por fecha y comprueba tres eventos de tipo y outcome correctos.
    No olvides is_approved_change(tres_eventos, changes).
    """
    return []


def extract_gaps(events):
    return [{"event_id": e["event_id"], "asset_id": e.get("asset_id"),
             "timestamp": e["timestamp"], "description": e.get("detail", "")}
            for e in events if e.get("event_type") == "telemetry_gap"]


def main():
    p = argparse.ArgumentParser()
    p.add_argument("--events", required=True)
    p.add_argument("--changes", required=True)
    p.add_argument("--out", required=True)
    args = p.parse_args()
    events = read_events(args.events)
    changes = read_csv(args.changes)
    output = {"schema_version": "1.0",
              "alerts": detect_sessions(events, changes),
              "visibility_gaps": extract_gaps(events)}
    target = Path(args.out)
    target.parent.mkdir(parents=True, exist_ok=True)
    target.write_text(json.dumps(output, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(f"Procesados {len(events)} eventos; alertas={len(output['alerts'])}; "
          f"gaps={len(output['visibility_gaps'])}; salida={target}")


if __name__ == "__main__":
    main()
