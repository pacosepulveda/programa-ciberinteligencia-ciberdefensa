#!/usr/bin/env python3
"""Validación de estructura: no revela las identidades ni lugares de las fotografías."""
import argparse
import csv
import json
import math
from pathlib import Path


def check_geojson(path):
    doc = json.loads(Path(path).read_text(encoding="utf-8"))
    if doc.get("type") != "FeatureCollection":
        raise ValueError("GeoJSON debe ser FeatureCollection")
    features = doc.get("features", [])
    if len(features) != 2 or {f.get("properties", {}).get("id") for f in features} != {"A", "B"}:
        raise ValueError("Se requieren dos features (A y B)")
    for f in features:
        coords = f.get("geometry", {}).get("coordinates", [])
        if f.get("geometry", {}).get("type") != "Point" or len(coords) != 2:
            raise ValueError("Cada feature debe ser un Point [longitud, latitud]")
        lon, lat = coords
        if any(isinstance(v, bool) or not isinstance(v, (float, int)) or not math.isfinite(v) for v in coords):
            raise ValueError("Completa coordenadas numéricas finitas, sin null")
        if not (-180 <= lon <= 180 and -90 <= lat <= 90):
            raise ValueError("Coordenadas fuera de rango")
        p = f["properties"]
        for field in ("source_url", "map_source_url", "evidence", "confidence"):
            if not isinstance(p.get(field), str) or not p[field].strip():
                raise ValueError(f"Falta campo de justificación {field}")
    return True


def check_timeline(path):
    with open(path, encoding="utf-8", newline="") as f:
        rows = list(csv.DictReader(f))
    if len(rows) < 5:
        raise ValueError("La cronología debe incluir al menos cinco hitos")
    for r in rows:
        for field in ("event_id", "timestamp_utc", "tipo", "fuente_url"):
            if not r.get(field, "").strip():
                raise ValueError(f"Campo obligatorio vacío: {field}")
    return True


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--geojson", required=True)
    parser.add_argument("--timeline", required=True)
    a = parser.parse_args()
    try:
        check_geojson(a.geojson)
        check_timeline(a.timeline)
    except (OSError, ValueError, TypeError, KeyError, json.JSONDecodeError) as exc:
        print(f"INCOMPLETO: {exc}")
        return 1
    print("CORRECTO: estructura GeoJSON y cronología comprobadas.")
    print("La identidad de las imágenes y la fiabilidad de las fuentes requieren revisión de evidencias.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
