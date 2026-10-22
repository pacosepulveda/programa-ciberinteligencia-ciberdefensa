#!/usr/bin/env bash
set -euo pipefail

PREFIX='[P04.2]'
PASSWORD='TlvP042!2026Lab#'

log() {
  printf '%s %s\n' "$PREFIX" "$1"
}

fail() {
  printf '%s ERROR: %s\n' "$PREFIX" "$1" >&2
  exit 1
}

if [[ ${EUID:-$(id -u)} -ne 0 ]]; then
  fail 'Ejecuta este script con sudo o como root en AD01.'
fi

command -v samba-tool >/dev/null 2>&1 || fail 'No se encuentra samba-tool en AD01.'

DOMAIN_INFO="$(samba-tool domain info 127.0.0.1 2>/dev/null || true)"
if ! grep -qi 'Domain.*telvora.lab\|Forest.*telvora.lab' <<<"$DOMAIN_INFO"; then
  fail 'Este equipo no parece ser el controlador Samba AD de telvora.lab.'
fi

user_exists() {
  samba-tool user list 2>/dev/null | grep -Fxiq -- "$1"
}

group_exists() {
  samba-tool group list 2>/dev/null | grep -Fxiq -- "$1"
}

ensure_user() {
  local user="$1"
  if ! user_exists "$user"; then
    samba-tool user create "$user" "$PASSWORD" >/dev/null
  fi
  samba-tool user enable "$user" >/dev/null 2>&1 || true
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
  if ! samba-tool group listmembers "$group" 2>/dev/null | grep -Fxiq -- "$member"; then
    samba-tool group addmembers "$group" "$member" >/dev/null
  fi
}

log 'Validando AD01 y preparando el escenario IAM...'

# Scenario users
for user in \
  'alice.admin' \
  'bob.ops' \
  'carla.net' \
  'svc_backup' \
  'svc_legacy' \
  'vendor_noc' \
  'breakglass01' \
  'former.contractor'
do
  ensure_user "$user"
done

# Scenario groups
for group in \
  'Server Admins' \
  'Network Operators' \
  'NOC Vendors' \
  'Remote Access Users'
do
  ensure_group "$group"
done

# Password-never-expires findings
samba-tool user setexpiry 'svc_backup' --noexpiry >/dev/null
samba-tool user setexpiry 'svc_legacy' --noexpiry >/dev/null
samba-tool user setexpiry 'breakglass01' --noexpiry >/dev/null

# Privilege and access paths
ensure_member 'Domain Admins' 'alice.admin'
ensure_member 'Domain Admins' 'Server Admins'
ensure_member 'Domain Admins' 'breakglass01'
ensure_member 'Server Admins' 'bob.ops'
ensure_member 'Server Admins' 'svc_legacy'
ensure_member 'Network Operators' 'carla.net'
ensure_member 'Backup Operators' 'svc_backup'
ensure_member 'Remote Access Users' 'NOC Vendors'
ensure_member 'NOC Vendors' 'vendor_noc'
ensure_member 'NOC Vendors' 'former.contractor'

# Offboarded identity deliberately left in an access group
samba-tool user disable 'former.contractor' >/dev/null

log 'Escenario preparado correctamente.'
log 'Continua la practica desde MEMBER01 con Active Directory Users and Computers (dsa.msc).'
