#!/usr/bin/env python3
"""Esqueleto MA06.A: completar la detección de cambios, no la lectura de archivos."""
import argparse
import json
from pathlib import Path

VALID = {"ok", "nxdomain", "timeout", "unavailable"}


def normalize_values(observation):
    """Orden y duplicados de un RRset DNS no deben crear falsas alertas."""
    if not observation or observation.get("status") != "ok":
        return None
    return set(str(v).strip().lower().rstrip(".") for v in observation.get("values", []))


def event(kind, subject, severity, details):
    return {"type": kind, "subject": subject, "severity": severity, "details": details}


def compare_dns(before, after):
    """TODO: usar estado, tipos, hostname y conjuntos. NO asumir desaparición con timeout."""
    # Iterar unión de nombres y tipos de DNS. Revisar statuses ANTES de comparar valores.
    # Ejemplo: si un record A pasa de ok a timeout, emitir SOURCE_UNAVAILABLE.
    # Si un hostname que tenía nxdomain pasa a tener A válido, marcar NEW_DNS_HOST.
    return []


def compare_ct(before, after):
    """TODO: detectar nuevos nombres SAN y distinguir CT de DNS activo."""
    # Comparar conjuntos de dns_names en ambas capturas.
    # Para cada nombre nuevo, consultar after["dns"][name] si contiene A/AAAA válido.
    return []


def compare_snapshots(before, after):
    if before.get("scope") != after.get("scope"):
        raise ValueError("Scopes distintos")
    return {"schema_version": "1.0",
            "case": after.get("case", ""),
            "events": compare_dns(before, after) + compare_ct(before, after)}


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("baseline")
    ap.add_argument("followup")
    ap.add_argument("--out", required=True)
    args = ap.parse_args()
    before = json.loads(Path(args.baseline).read_text(encoding="utf-8"))
    after = json.loads(Path(args.followup).read_text(encoding="utf-8"))
    output = compare_snapshots(before, after)
    out = Path(args.out)
    out.parent.mkdir(parents=True, exist_ok=True)
    out.write_text(json.dumps(output, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(f"Eventos generados: {len(output['events'])}")


if __name__ == "__main__":
    main()
