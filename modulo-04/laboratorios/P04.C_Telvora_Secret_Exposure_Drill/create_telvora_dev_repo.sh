#!/usr/bin/env bash
set -euo pipefail

TARGET="${1:-$HOME/m04/telvora-dev-repo}"
rm -rf "$TARGET"
mkdir -p "$TARGET"/{deploy,docs}
cd "$TARGET"

git init -q
git config user.name "Telvora Lab Builder"
git config user.email "lab-builder@telvora.test"

LAB_VALUE_A="TELVORA_LAB_VALUE_A_$(openssl rand -hex 8)"
LAB_VALUE_B="TELVORA_LAB_VALUE_B_$(openssl rand -hex 8)"
LAB_VALUE_C="TELVORA_LAB_VALUE_C_$(openssl rand -hex 8)"

cat > LAB_ONLY.md <<'TXT'
# TELVORA LAB ONLY

Este repositorio se genera localmente para una práctica defensiva de revisión de configuración e historial Git.
Todos los valores son sintéticos y no autentican contra ningún sistema real.
No publicar el repositorio generado en remotos.
TXT

cat > app.py <<EOF2
API_ENDPOINT = "https://api.internal.telvora.test"
TELVORA_LAB_VALUE = "${LAB_VALUE_A}"

def health():
    return {"status": "ok", "endpoint": API_ENDPOINT}
EOF2

cat > config.yaml <<EOF2
database:
  host: db.internal.telvora.test
  user: codg_app
  lab_value: "${LAB_VALUE_B}"
EOF2

cat > deploy/legacy-value.env <<EOF2
TELVORA_LEGACY_LAB_VALUE=${LAB_VALUE_C}
EOF2

git add .
git commit -q -m "Initial CODG development configuration"

rm deploy/legacy-value.env
cat > deploy/README.md <<'EOF2'
# Deploy

El valor legacy fue retirado de la versión actual, pero el commit anterior sigue formando parte del historial del laboratorio.
EOF2

git add -A
git commit -q -m "Remove legacy deployment value"

printf '\n# review pending\n' > docs/operations.md
git add docs/operations.md
git commit -q -m "Update operations notes"

printf 'Repositorio de laboratorio creado en: %s\n' "$TARGET"
printf 'Commits: %s\n' "$(git rev-list --count HEAD)"
printf 'Todos los valores son sintéticos y locales.\n'
