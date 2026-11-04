#!/usr/bin/env python3
"""Comprobador de MA06.A: cinco hallazgos esperados y dos falsos positivos a evitar."""
import json
import sys
from pathlib import Path

EXPECTED = {
    ("MX_CHANGED", "telvora.example"),
    ("A_CHANGED", "portal.telvora.example"),
    ("NEW_DNS_HOST", "monitor.telvora.example"),
    ("CT_NEW_NAME_UNRESOLVED", "preprod.telvora.example"),
    ("SOURCE_UNAVAILABLE", "api.telvora.example"),
}


def main():
    if len(sys.argv) != 2:
        print("Uso: python3 checks/check.py resultados/changes.json")
        return 2
    try:
        doc = json.loads(Path(sys.argv[1]).read_text(encoding="utf-8"))
        items = doc["events"]
        if not isinstance(items, list):
            raise ValueError("events debe ser una lista")
        observed = {(e["type"], e["subject"]) for e in items}
    except (OSError, ValueError, TypeError, KeyError) as exc:
        print(f"Error de formato: {exc}")
        return 2
    right = len(EXPECTED & observed)
    extras = observed - EXPECTED
    print(f"Checkpoints esperados detectados: {right}/{len(EXPECTED)}")
    print(f"Eventos adicionales no justificados por el caso: {len(extras)}")
    if extras:
        print("Revisa estados y diferencias de orden, y documenta los eventos adicionales.")
    return 0 if right == len(EXPECTED) and not extras else 1


if __name__ == "__main__":
    raise SystemExit(main())
