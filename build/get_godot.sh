#!/usr/bin/env bash
set -euo pipefail

VERSION="${1:-4.2.2}"
STABLE_TAG="${VERSION}-stable"
BASE_URL="${GODOT_BASE_URL:-https://github.com/godotengine/godot/releases/download}"
TMP_DIR="$(mktemp -d)"
TARGET_BIN="/usr/local/bin/godot4"
TEMPLATE_DIR="${HOME}/.local/share/godot/export_templates/${VERSION}.stable"

cleanup() { rm -rf "$TMP_DIR"; }
trap cleanup EXIT

ZIP_NAME="Godot_v${VERSION}-stable_linux.x86_64.zip"
TPZ_NAME="Godot_v${VERSION}-stable_export_templates.tpz"

curl -fL "${BASE_URL}/${STABLE_TAG}/${ZIP_NAME}" -o "$TMP_DIR/godot.zip"
curl -fL "${BASE_URL}/${STABLE_TAG}/${TPZ_NAME}" -o "$TMP_DIR/templates.tpz"

unzip -q "$TMP_DIR/godot.zip" -d "$TMP_DIR"
install -m 755 "$TMP_DIR/Godot_v${VERSION}-stable_linux.x86_64" "$TARGET_BIN"

mkdir -p "$TEMPLATE_DIR"
unzip -q "$TMP_DIR/templates.tpz" -d "$TMP_DIR/templates"
cp -f "$TMP_DIR/templates/templates"/* "$TEMPLATE_DIR/"

echo "Godot instalado em $TARGET_BIN"
echo "Templates instalados em $TEMPLATE_DIR"
"$TARGET_BIN" --version
