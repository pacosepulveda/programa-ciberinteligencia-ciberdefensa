#!/usr/bin/env python3
"""Valida evidencias y secuencias de MA06.C; no conoce etiquetas de actor ni verdad interna."""
import argparse
import csv
import datetime as dt
import json
from pathlib import Path


def instant(value):
    return dt.datetime.fromisoformat(value.replace("Z", "+00:00"))


def main():
    p = argparse.ArgumentParser()
    p.add_argument("--events", required=True)
    p.add_argument("--changes", required=True)
    p.add_argument("--alerts", required=True)
    a = p.parse_args()
    try:
        events = [json.loads(line) for line in Path(a.events).read_text(encoding="utf-8").splitlines() if line.strip()]
        by_id = {e["event_id"]: e for e in events}
        if len(by_id) != len(events):
            raise ValueError("Eventos duplicados")
        with open(a.changes, encoding="utf-8", newline="") as file:
            changes = list(csv.DictReader(file))
        document = json.loads(Path(a.alerts).read_text(encoding="utf-8"))
        alerts = document["alerts"]
        gaps = document.get("visibility_gaps", [])
        if not isinstance(alerts, list) or not isinstance(gaps, list):
            raise ValueError("alerts y visibility_gaps deben ser listas")
        if not alerts:
            raise ValueError("Sin alertas: completa el TODO del detector para validar hunting")
        reported = set()
        for alert in alerts:
            ids = alert["event_ids"]
            if not isinstance(ids, list) or len(ids) < 3 or len(ids) != len(set(ids)):
                raise ValueError("Cada alerta debe contener >=3 event_id diferentes")
            if not all(x in by_id for x in ids):
                raise ValueError("event_id no encontrado en dataset")
            rows = [by_id[x] for x in ids]
            if {e["asset_id"] for e in rows} != {alert["asset_id"]}:
                raise ValueError("Correlación entre dispositivos distintos")
            if {e["user"] for e in rows} != {alert["user"]}:
                raise ValueError("Correlación entre usuarios distintos")
            if {e["session_id"] for e in rows} != {alert["session_id"]}:
                raise ValueError("Correlación entre sesiones distintas")
            if any(e.get("outcome") != "success" for e in rows):
                raise ValueError("Una evidencia no tiene outcome success")
            ordered = sorted(rows, key=lambda e: instant(e["timestamp"]))
            pattern = [e["event_type"] for e in ordered]
            indices = [next((i for i, x in enumerate(pattern) if x == typ), None)
                       for typ in ("auth", "config_export", "logging_change")]
            if None in indices or not (indices[0] < indices[1] < indices[2]):
                raise ValueError("El orden auth/config_export/logging_change no es válido")
            sequence = [ordered[i] for i in indices]
            if (instant(sequence[-1]["timestamp"]) - instant(sequence[0]["timestamp"])).total_seconds() > 900:
                raise ValueError("La secuencia excede 15 minutos")
            if not isinstance(alert.get("rationale"), str) or len(alert["rationale"].strip()) < 12:
                raise ValueError("Justificación insuficiente")
            if not isinstance(alert.get("priority"), str) or alert["priority"].lower() not in {"high", "medium", "low"}:
                raise ValueError("Prioridad inválida")
            for ch in changes:
                if (ch["status"] == "approved"
                        and ch["asset_id"] == alert["asset_id"]
                        and ch["approved_user"] == alert["user"]
                        and ch["change_id"]
                        and {e.get("change_id") for e in sequence} == {ch["change_id"]}
                        and {"config_export", "logging_change"}.issubset(set(ch["authorized_actions"].split(";")))
                        and all(instant(ch["window_start_utc"]) <= instant(e["timestamp"]) <= instant(ch["window_end_utc"]) for e in sequence)):
                    raise ValueError("Posible falso positivo: secuencia dentro de un cambio aprobado")
            key = (alert["asset_id"], alert["session_id"], alert["user"])
            if key in reported:
                raise ValueError("Alerta duplicada de la misma sesión")
            reported.add(key)
        known_gaps = {e["event_id"] for e in events if e.get("event_type") == "telemetry_gap"}
        if known_gaps and not known_gaps.issubset({g.get("event_id") for g in gaps}):
            raise ValueError("No se han documentado todos los gaps de visibilidad")
    except (OSError, KeyError, TypeError, ValueError, json.JSONDecodeError) as exc:
        print(f"INCOMPLETO / INCORRECTO: {exc}")
        return 1
    print(f"CORRECTO: {len(alerts)} alertas con secuencias y referencias estructuralmente coherentes.")
    print(f"Gaps reportados: {len(gaps)}. La validación no demuestra compromiso ni atribución.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
