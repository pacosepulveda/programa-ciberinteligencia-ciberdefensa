#!/usr/bin/env python3
from pathlib import Path
import re
import sys

POLICIES = [
    ("G001", "SSH administrativo no expuesto a Internet"),
    ("G002", "S3 Public Access Block habilitado"),
    ("G003", "Volúmenes EBS cifrados"),
    ("G004", "Retención de logs definida (>= 90 días)"),
]


def resource_blocks(text, resource_type):
    pattern = re.compile(r'resource\s+"' + re.escape(resource_type) + r'"\s+"[^"]+"\s*\{', re.M)
    blocks = []
    for match in pattern.finditer(text):
        start = match.start()
        i = match.end()
        depth = 1
        while i < len(text) and depth:
            if text[i] == "{":
                depth += 1
            elif text[i] == "}":
                depth -= 1
            i += 1
        blocks.append(text[start:i])
    return blocks


def check_g001(text):
    for block in resource_blocks(text, "aws_security_group"):
        for ingress in re.finditer(r'ingress\s*\{(.*?)\}', block, re.S):
            body = ingress.group(1)
            ports = re.findall(r'(?:from_port|to_port)\s*=\s*(\d+)', body)
            if "22" in ports and re.search(r'cidr_blocks\s*=\s*\[[^\]]*"0\.0\.0\.0/0"', body, re.S):
                return False, "Se detecta SSH (22/TCP) permitido desde 0.0.0.0/0."
    return True, "No se detecta SSH administrativo abierto a 0.0.0.0/0."


def check_g002(text):
    blocks = resource_blocks(text, "aws_s3_bucket_public_access_block")
    if not blocks:
        return False, "No existe aws_s3_bucket_public_access_block."

    required = [
        "block_public_acls",
        "ignore_public_acls",
        "block_public_policy",
        "restrict_public_buckets",
    ]

    for block in blocks:
        if all(re.search(rf'\b{name}\s*=\s*true\b', block, re.I) for name in required):
            return True, "Las cuatro protecciones de acceso público están habilitadas."

    return False, "Alguna protección de S3 Public Access Block no está habilitada."


def check_g003(text):
    blocks = resource_blocks(text, "aws_ebs_volume")
    if not blocks:
        return False, "No se encuentra ningún volumen EBS."

    non_compliant = [block for block in blocks if not re.search(r'\bencrypted\s*=\s*true\b', block, re.I)]
    if non_compliant:
        return False, f"{len(non_compliant)} volumen(es) EBS no declaran encrypted = true."

    return True, "Todos los volúmenes EBS declaran encrypted = true."


def check_g004(text):
    blocks = resource_blocks(text, "aws_cloudwatch_log_group")
    if not blocks:
        return False, "No se encuentra ningún log group de CloudWatch."

    values = []
    for block in blocks:
        match = re.search(r'\bretention_in_days\s*=\s*(\d+)', block)
        if not match:
            return False, "Hay un log group sin retention_in_days."
        values.append(int(match.group(1)))

    if min(values) < 90:
        return False, f"La retención mínima encontrada es {min(values)} días; la política exige >= 90."

    return True, f"Retención explícita conforme: mínimo {min(values)} días."


CHECKS = [check_g001, check_g002, check_g003, check_g004]


def main():
    path = Path(sys.argv[1] if len(sys.argv) > 1 else "main.tf")
    if not path.is_file():
        print(f"ERROR: no se encuentra {path}", file=sys.stderr)
        return 2

    text = path.read_text(encoding="utf-8")
    passed = 0

    print(f"TELVORA IaC Guardrails — {path}\n")

    for (policy_id, title), check in zip(POLICIES, CHECKS):
        ok, detail = check(text)
        print(f"{'PASS' if ok else 'FAIL'} {policy_id} — {title}")
        print(f"     {detail}")
        passed += int(ok)

    print(f"\nResultado: {passed}/{len(POLICIES)} guardrails conformes")
    return 0 if passed == len(POLICIES) else 1


if __name__ == "__main__":
    raise SystemExit(main())
