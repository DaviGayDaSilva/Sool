#!/usr/bin/env bash
set -euo pipefail

GODOT_BIN=${GODOT_BIN:-godot4}
VERSION=${1:-0.1.0}
ARCH=${2:-amd64}
ROOT="packaging/debian"

rm -rf "$ROOT/usr/local/games/Sool"/*
mkdir -p "$ROOT/usr/local/games/Sool"
"$GODOT_BIN" --headless --export-release "Linux/X11" "$ROOT/usr/local/games/Sool/Sool.x86_64"
chmod +x "$ROOT/usr/local/games/Sool/Sool.x86_64"

cat > "$ROOT/DEBIAN/control" <<CTRL
Package: sool
Version: ${VERSION}
Section: games
Priority: optional
Architecture: ${ARCH}
Maintainer: Sool Community <opensource@sool.game>
Description: Sool - FPS 3D open-source inspirado em Doom com bots offline.
CTRL

cat > "$ROOT/usr/share/applications/sool.desktop" <<DESKTOP
[Desktop Entry]
Name=Sool
Exec=/usr/local/games/Sool/Sool.x86_64
Type=Application
Categories=Game;
DESKTOP

mkdir -p build
DEB_PATH="build/sool_${VERSION}_${ARCH}.deb"
dpkg-deb --build "$ROOT" "$DEB_PATH"
echo "Pacote .deb gerado em $DEB_PATH"
