#!/usr/bin/env bash
set -euo pipefail

export DEBIAN_FRONTEND=noninteractive

apt-get update
apt-get install -y --no-install-recommends \
  ca-certificates \
  curl \
  unzip \
  xz-utils \
  dpkg-dev \
  openjdk-17-jre-headless

echo "Dependências básicas instaladas."

echo "Tentando instalar Godot 4 via apt (quando disponível)..."
if apt-cache show godot4 >/dev/null 2>&1; then
  apt-get install -y godot4
  echo "godot4 instalado via apt"
else
  echo "Pacote godot4 não disponível no repositório apt atual."
  echo "Use ./build/get_godot.sh para baixar binário oficial quando a rede permitir."
fi
