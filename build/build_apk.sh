#!/usr/bin/env bash
set -euo pipefail

GODOT_BIN=${GODOT_BIN:-godot4}
mkdir -p build
"$GODOT_BIN" --headless --export-release "Android" build/Sool.apk

echo "APK gerado em build/Sool.apk"
