"""Lectura y normalización de registros JSONL (herramienta base de MA06.C)."""
import csv
import datetime as dt
import json
from collections import defaultdict
from pathlib import Path


def parse_utc(value):
    parsed = dt.datetime.fromisoformat(value.replace("Z", "+00:00"))
    if parsed.tzinfo is None:
        raise ValueError(f"timestamp sin zona horaria: {value}")
    return parsed.astimezone(dt.timezone.utc)


def read_events(path):
    result, seen = [], set()
    with Path(path).open(encoding="utf-8") as reader:
        for line_no, line in enumerate(reader, 1):
            if not line.strip():
                continue
            try:
                event = json.loads(line)
                event_id = event["event_id"]
                parse_utc(event["timestamp"])
            except (json.JSONDecodeError, KeyError, ValueError, TypeError) as exc:
                raise ValueError(f"JSONL incorrecto en línea {line_no}: {exc}") from exc
            if event_id in seen:
                raise ValueError(f"event_id duplicado: {event_id}")
            seen.add(event_id)
            result.append(event)
    return sorted(result, key=lambda e: (parse_utc(e["timestamp"]), e["event_id"]))


def read_csv(path):
    with Path(path).open(encoding="utf-8", newline="") as file:
        return list(csv.DictReader(file))


def group_sessions(events):
    """Las sesiones sin session_id no pueden correlacionarse como secuencias."""
    groups = defaultdict(list)
    for event in events:
        if event.get("session_id"):
            key = (event.get("asset_id"), event.get("user"), event["session_id"])
            groups[key].append(event)
    return {key: sorted(rows, key=lambda e: parse_utc(e["timestamp"]))
            for key, rows in groups.items()}


def is_approved_change(events, changes):
    """Un cambio válido exige ticket, usuario, dispositivo, acciones, ventana y estado."""
    if not events:
        return False
    first = events[0]
    keys = {e.get("change_id") for e in events}
    if len(keys) != 1:
        return False
    change_id = first.get("change_id")
    if not change_id:
        return False
    actions = {e.get("event_type") for e in events if e.get("event_type") != "auth"}
    for change in changes:
        if (change.get("change_id") == change_id
                and change.get("status") == "approved"
                and change.get("asset_id") == first.get("asset_id")
                and change.get("approved_user") == first.get("user")
                and actions.issubset(set(change.get("authorized_actions", "").split(";")))):
            start = parse_utc(change["window_start_utc"])
            end = parse_utc(change["window_end_utc"])
            return all(start <= parse_utc(e["timestamp"]) <= end for e in events)
    return False
