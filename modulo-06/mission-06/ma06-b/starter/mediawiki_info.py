#!/usr/bin/env python3
"""API pública de Wikimedia Commons: usar título de archivo descubierto por el alumno."""
import argparse
import json
from pathlib import Path
from urllib.parse import urlencode
from urllib.request import Request, urlopen
from urllib.error import HTTPError, URLError


def main():
    p = argparse.ArgumentParser()
    p.add_argument("--title", required=True, help="Nombre del archivo descubierto en Commons")
    p.add_argument("--out", required=True)
    args = p.parse_args()
    title = args.title.strip()
    if not title.lower().startswith(("file:", "archivo:")):
        title = "File:" + title
    query = urlencode({
        "action": "query", "format": "json", "formatversion": "2",
        "prop": "imageinfo", "iiprop": "timestamp|size|metadata|extmetadata",
        "iilimit": "5", "titles": title,
    })
    url = "https://commons.wikimedia.org/w/api.php?" + query
    req = Request(url, headers={
        "User-Agent": "TelvoraOSINTTraining/1.0 (educational research; no bulk downloads)"
    })
    try:
        with urlopen(req, timeout=18) as response:
            doc = json.load(response)
    except (HTTPError, URLError, TimeoutError, ValueError, OSError) as e:
        print(f"Error consultando Wikimedia: {type(e).__name__} - {e}")
        return 1
    pages = doc.get("query", {}).get("pages", [])
    if not pages or "missing" in pages[0]:
        print("No existe un archivo público con ese título.")
        return 1
    output = Path(args.out)
    output.parent.mkdir(parents=True, exist_ok=True)
    output.write_text(json.dumps({
        "queried_title": title, "source_url": url,
        "page": pages[0]
    }, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(f"Guardado: {output}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
