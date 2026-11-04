#!/usr/bin/env python3
"""Colección pasiva acotada: DNS público y CT opcional; solo biblioteca estándar."""
import argparse
import datetime as dt
import json
import pathlib
import time
import urllib.error
import urllib.parse
import urllib.request

DNS_URL = "https://dns.google/resolve"
CT_URL = "https://crt.sh/"
TYPES = {"A", "AAAA", "MX", "NS", "CNAME"}
DNS_CODES = {1: "A", 2: "NS", 5: "CNAME", 15: "MX", 28: "AAAA"}


def now():
    return dt.datetime.now(dt.timezone.utc).isoformat(timespec="seconds").replace("+00:00", "Z")


def get_json(url, timeout):
    req = urllib.request.Request(url, headers={"User-Agent": "Telvora-OSINT-Training/1.0"})
    with urllib.request.urlopen(req, timeout=timeout) as response:
        return json.load(response)


def dns_record(name, rrtype, timeout):
    ts = now()
    url = DNS_URL + "?" + urllib.parse.urlencode({"name": name, "type": rrtype})
    try:
        document = get_json(url, timeout)
        code = document.get("Status")
        if code == 3:
            return {"status": "nxdomain", "values": [], "observed_at": ts, "source": url}
        if code != 0:
            return {"status": "unavailable", "values": [], "observed_at": ts, "source": url, "note": f"DNS status {code}"}
        answers = document.get("Answer") or []
        # Representa respuestas limpias de tipo solicitado, no un resultado de escaneo activo.
        values = sorted(set(str(a.get("data", "")).strip().rstrip(".") for a in answers
                            if DNS_CODES.get(a.get("type")) == rrtype and a.get("data")))
        return {"status": "ok", "values": values, "observed_at": ts, "source": url}
    except (urllib.error.URLError, TimeoutError, ValueError, OSError) as exc:
        return {"status": "unavailable", "values": [], "observed_at": ts, "source": url,
                "note": type(exc).__name__}


def ct_entries(scope, timeout):
    url = CT_URL + "?" + urllib.parse.urlencode({"q": "%." + scope, "output": "json"})
    try:
        data = get_json(url, timeout)
        if not isinstance(data, list):
            raise ValueError("CT no es una lista")
        records = []
        seen = set()
        for record in data[:500]:
            names = sorted(set(n.strip().lower().lstrip("*.").rstrip(".")
                               for n in str(record.get("name_value", "")).splitlines()))
            names = [n for n in names if n == scope or n.endswith("." + scope)]
            if not names:
                continue
            key = (str(record.get("id", "")), tuple(names))
            if key in seen:
                continue
            seen.add(key)
            records.append({"id": str(record.get("id", "")), "dns_names": names,
                            "not_before": str(record.get("not_before", "")),
                            "observed_at": now(), "source": url})
        return {"status": "ok", "records": records, "source": url}
    except (urllib.error.URLError, TimeoutError, ValueError, OSError) as exc:
        return {"status": "unavailable", "records": [], "source": url,
                "note": type(exc).__name__}


def main():
    p = argparse.ArgumentParser()
    p.add_argument("--config", required=True)
    p.add_argument("--out", required=True)
    args = p.parse_args()
    config = json.loads(pathlib.Path(args.config).read_text(encoding="utf-8"))
    scope = str(config["scope"]).lower().strip(".")
    names = list(dict.fromkeys(str(n).lower().strip(".") for n in config["authorized_names"]))
    if len(names) > 15 or any(n != scope and not n.endswith("." + scope) for n in names):
        p.error("Scope no autorizado o más de 15 nombres")
    rtypes = list(dict.fromkeys(config.get("record_types", ["A", "MX", "NS"])))
    if any(t not in TYPES for t in rtypes):
        p.error("Tipo DNS no soportado")
    if len(names) * len(rtypes) > int(config.get("max_requests", 20)):
        p.error("Las consultas exceden el límite configurado")
    timeout = min(max(int(config.get("timeout_seconds", 8)), 2), 20)
    dns = {}
    for name in names:
        dns[name] = {t: dns_record(name, t, timeout) for t in rtypes}
    ct = ct_entries(scope, timeout) if config.get("ct_enabled", False) else {"status": "skipped", "records": []}
    doc = {"case": "LIVE_PASSIVE_OSINT", "synthetic": False, "scope": scope,
           "captured_at": now(), "dns": dns, "ct": ct.get("records", []),
           "provenance": {"dns": DNS_URL, "ct": ct.get("source"), "ct_status": ct["status"]}}
    output = pathlib.Path(args.out)
    output.parent.mkdir(parents=True, exist_ok=True)
    output.write_text(json.dumps(doc, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(f"Archivo generado: {output} | DNS: {len(names)} nombres | CT: {ct['status']}")


if __name__ == "__main__":
    main()
