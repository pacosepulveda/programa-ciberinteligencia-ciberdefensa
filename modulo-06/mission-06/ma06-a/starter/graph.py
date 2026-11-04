#!/usr/bin/env python3
"""Grafo DOT de observaciones documentadas. No atribuye propiedad de IP/hostname."""
import argparse
import json
from pathlib import Path


def quote(value):
    return json.dumps(str(value), ensure_ascii=False)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("snapshot")
    ap.add_argument("--out", required=True)
    args = ap.parse_args()
    snapshot = json.loads(Path(args.snapshot).read_text(encoding="utf-8"))
    edges = set()
    for host, types in snapshot.get("dns", {}).items():
        for kind, record in types.items():
            if record.get("status") != "ok":
                continue
            for value in record.get("values", []):
                edges.add((host, str(value), kind))
    for cert in snapshot.get("ct", []):
        for name in cert.get("dns_names", []):
            edges.add((str(cert.get("id", "CT")), name, "CT SAN"))
    lines = ["digraph osint {", "  rankdir=LR;", '  label="Relaciones observadas - no atribucion de propiedad";']
    for src, dst, kind in sorted(edges):
        lines.append(f"  {quote(src)} -> {quote(dst)} [label={quote(kind)}];")
    lines.append("}")
    output = Path(args.out)
    output.parent.mkdir(parents=True, exist_ok=True)
    output.write_text("\n".join(lines) + "\n", encoding="utf-8")
    print(f"Grafo DOT: {output}; aristas observadas: {len(edges)}")


if __name__ == "__main__":
    main()
