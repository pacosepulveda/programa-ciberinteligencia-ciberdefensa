#!/usr/bin/env bash
set -u

TARGET="${1:-10.20.0.20}"

printf 'TELVORA M03 — Flow validation\n'
printf 'Target: %s\n\n' "$TARGET"

printf '[HTTP/80] '
HTTP_CODE=$(curl -sS -o /dev/null --connect-timeout 3 -w '%{http_code}' "http://$TARGET/" 2>/dev/null || true)
if [[ -n "$HTTP_CODE" && "$HTTP_CODE" != "000" ]]; then
  printf 'REACHABLE (HTTP %s)\n' "$HTTP_CODE"
else
  printf 'NOT REACHABLE\n'
fi

printf '[SSH/22]  '
if nc -z -w 3 "$TARGET" 22 >/dev/null 2>&1; then
  printf 'REACHABLE\n'
else
  printf 'NOT REACHABLE\n'
fi

printf '\nInterpreta el resultado comparándolo con la política esperada.\n'
