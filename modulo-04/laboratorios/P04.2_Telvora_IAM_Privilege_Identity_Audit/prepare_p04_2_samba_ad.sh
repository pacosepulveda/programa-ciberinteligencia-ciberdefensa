#!/usr/bin/env bash
set -Eeuo pipefail

TARGET_DOMAIN="telvora.lab"

log() {
  printf '[P04.2] %s\n' "$*"
}

fail() {
  printf '[P04.2] ERROR: %s\n' "$*" >&2
  exit 1
}

if [[ ${EUID} -ne 0 ]]; then
  fail "Ejecuta este script con sudo o como root."
fi

command -v samba-tool >/dev/null 2>&1 || fail "No se encuentra samba-tool."
command -v base64 >/dev/null 2>&1 || fail "No se encuentra base64."

DOMAIN_INFO="$(samba-tool domain info 127.0.0.1 2>/dev/null || true)"
if ! grep -Eqi "Domain[[:space:]]*:[[:space:]]*${TARGET_DOMAIN//./\.}" <<<"${DOMAIN_INFO}"; then
  fail "Este script solo debe ejecutarse en el DC del laboratorio TELVORA."
fi

user_exists() {
  samba-tool user list 2>/dev/null | grep -Fxiq -- "$1"
}

group_exists() {
  samba-tool group list 2>/dev/null | grep -Fxiq -- "$1"
}

member_exists() {
  local group="$1"
  local member="$2"
  samba-tool group listmembers "$group" 2>/dev/null | grep -Fxiq -- "$member"
}

ensure_user() {
  local user="$1"
  local password="$2"

  if ! user_exists "$user"; then
    samba-tool user create "$user" "$password" >/dev/null
  fi
}

ensure_group() {
  local group="$1"

  if ! group_exists "$group"; then
    samba-tool group add "$group" >/dev/null
  fi
}

ensure_member() {
  local group="$1"
  local member="$2"

  if ! member_exists "$group" "$member"; then
    samba-tool group addmembers "$group" "$member" >/dev/null
  fi
}

decode() {
  printf '%s' "$1" | base64 -d
}

# Los registros del escenario se almacenan codificados para evitar revelar
# accidentalmente la respuesta durante la preparación del laboratorio.
# No constituyen un mecanismo de seguridad ni pretenden impedir su inspección.
USER_RECORDS=(
  'YWxpY2UuYWRtaW58VGVsdm9yYS1BbGljZS1QMDQhMjAyNnwwfDA='
  'Ym9iLm9wc3xUZWx2b3JhLUJvYi1QMDQhMjAyNnwwfDA='
  'Y2FybGEubmV0fFRlbHZvcmEtQ2FybGEtUDA0ITIwMjZ8MHww'
  'c3ZjX2JhY2t1cHxUZWx2b3JhLUJhY2t1cC1QMDQhMjAyNnwxfDA='
  'c3ZjX2xlZ2FjeXxUZWx2b3JhLUxlZ2FjeS1QMDQhMjAyNnwxfDA='
  'dmVuZG9yX25vY3xUZWx2b3JhLVZlbmRvci1QMDQhMjAyNnwwfDA='
  'YnJlYWtnbGFzczAxfFRlbHZvcmEtQnJlYWtHbGFzcy1QMDQhMjAyNnwxfDA='
  'Zm9ybWVyLmNvbnRyYWN0b3J8VGVsdm9yYS1Gb3JtZXItUDA0ITIwMjZ8MHwx'
)

GROUP_RECORDS=(
  'U2VydmVyIEFkbWlucw=='
  'TmV0d29yayBPcGVyYXRvcnM='
  'Tk9DIFZlbmRvcnM='
  'UmVtb3RlIEFjY2VzcyBVc2Vycw=='
)

MEMBERSHIP_RECORDS=(
  'RG9tYWluIEFkbWluc3xhbGljZS5hZG1pbg=='
  'RG9tYWluIEFkbWluc3xTZXJ2ZXIgQWRtaW5z'
  'RG9tYWluIEFkbWluc3xicmVha2dsYXNzMDE='
  'U2VydmVyIEFkbWluc3xib2Iub3Bz'
  'U2VydmVyIEFkbWluc3xzdmNfbGVnYWN5'
  'TmV0d29yayBPcGVyYXRvcnN8Y2FybGEubmV0'
  'QmFja3VwIE9wZXJhdG9yc3xzdmNfYmFja3Vw'
  'UmVtb3RlIEFjY2VzcyBVc2Vyc3xOT0MgVmVuZG9ycw=='
  'Tk9DIFZlbmRvcnN8dmVuZG9yX25vYw=='
  'Tk9DIFZlbmRvcnN8Zm9ybWVyLmNvbnRyYWN0b3I='
)

log "Validando entorno del laboratorio..."
log "Preparando escenario IAM..."

for record in "${USER_RECORDS[@]}"; do
  IFS='|' read -r user password noexpiry disabled <<<"$(decode "$record")"
  ensure_user "$user" "$password"

  if [[ "$noexpiry" == "1" ]]; then
    samba-tool user setexpiry "$user" --noexpiry >/dev/null
  fi

  if [[ "$disabled" == "1" ]]; then
    samba-tool user disable "$user" >/dev/null 2>&1 || true
  fi
done

for record in "${GROUP_RECORDS[@]}"; do
  group="$(decode "$record")"
  ensure_group "$group"
done

for record in "${MEMBERSHIP_RECORDS[@]}"; do
  IFS='|' read -r group member <<<"$(decode "$record")"
  ensure_member "$group" "$member"
done

log "Escenario preparado correctamente."
log "Ya puedes continuar con el enunciado del laboratorio."
