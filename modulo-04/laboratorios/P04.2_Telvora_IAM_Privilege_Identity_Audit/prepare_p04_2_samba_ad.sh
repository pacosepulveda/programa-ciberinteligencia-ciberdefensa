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

DOMAIN_INFO="$(samba-tool domain info 127.0.0.1 2>/dev/null || true)"
if ! grep -Eqi "Domain[[:space:]]*:[[:space:]]*${TARGET_DOMAIN//./\.}" <<<"${DOMAIN_INFO}"; then
  printf '%s\n' "${DOMAIN_INFO}"
  fail "Este script solo debe ejecutarse en el DC del dominio ${TARGET_DOMAIN}."
fi

log "Dominio validado: ${TARGET_DOMAIN}"

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

  if user_exists "$user"; then
    log "Usuario ya existente: $user"
  else
    log "Creando usuario: $user"
    samba-tool user create "$user" "$password" >/dev/null
  fi
}

ensure_group() {
  local group="$1"

  if group_exists "$group"; then
    log "Grupo ya existente: $group"
  else
    log "Creando grupo: $group"
    samba-tool group add "$group" >/dev/null
  fi
}

ensure_member() {
  local group="$1"
  local member="$2"

  if member_exists "$group" "$member"; then
    log "Membresía ya existente: $group <- $member"
  else
    log "Añadiendo membresía: $group <- $member"
    samba-tool group addmembers "$group" "$member" >/dev/null
  fi
}

set_noexpiry() {
  local user="$1"
  log "Configurando sin expiración: $user"
  samba-tool user setexpiry "$user" --noexpiry >/dev/null
}

set_disabled() {
  local user="$1"
  log "Deshabilitando cuenta: $user"
  samba-tool user disable "$user" >/dev/null || true
}

# -----------------------------------------------------------------------------
# Identidades del escenario P04.2
# -----------------------------------------------------------------------------

ensure_user "alice.admin"       'Telvora-Alice-P04!2026'
ensure_user "bob.ops"           'Telvora-Bob-P04!2026'
ensure_user "carla.net"         'Telvora-Carla-P04!2026'
ensure_user "svc_backup"        'Telvora-Backup-P04!2026'
ensure_user "svc_legacy"        'Telvora-Legacy-P04!2026'
ensure_user "vendor_noc"        'Telvora-Vendor-P04!2026'
ensure_user "breakglass01"      'Telvora-BreakGlass-P04!2026'
ensure_user "former.contractor" 'Telvora-Former-P04!2026'

# -----------------------------------------------------------------------------
# Grupos adicionales del escenario
# -----------------------------------------------------------------------------

ensure_group "Server Admins"
ensure_group "Network Operators"
ensure_group "NOC Vendors"
ensure_group "Remote Access Users"

# -----------------------------------------------------------------------------
# Membresías
# -----------------------------------------------------------------------------

ensure_member "Domain Admins" "alice.admin"
ensure_member "Domain Admins" "Server Admins"
ensure_member "Domain Admins" "breakglass01"

ensure_member "Server Admins" "bob.ops"
ensure_member "Server Admins" "svc_legacy"

ensure_member "Network Operators" "carla.net"
ensure_member "Backup Operators" "svc_backup"

ensure_member "Remote Access Users" "NOC Vendors"
ensure_member "NOC Vendors" "vendor_noc"
ensure_member "NOC Vendors" "former.contractor"

# -----------------------------------------------------------------------------
# Propiedades específicas del escenario
# -----------------------------------------------------------------------------

set_noexpiry "svc_backup"
set_noexpiry "svc_legacy"
set_noexpiry "breakglass01"

set_disabled "former.contractor"

printf '\n'
log "Preparación completada."
log "El script puede volver a ejecutarse: no recreará usuarios, grupos ni membresías existentes."
printf '\n'
log "Comprobaciones básicas sugeridas:"
printf '%s\n' \
  "  samba-tool user list" \
  "  samba-tool group list" \
  "  samba-tool group listmembers 'Domain Admins'" \
  "  samba-tool group listmembers 'Server Admins'" \
  "  samba-tool group listmembers 'NOC Vendors'"
