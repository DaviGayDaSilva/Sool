# Sool

Sool é um FPS 3D open-source inspirado em clássicos como Doom, com foco em ação rápida, bots e suporte offline.

## Modos de jogo

- **Single-player**: entra no mapa com bots agressivos e respawn contínuo.
- **Multiplayer LAN**: host e cliente via ENet (porta padrão `7777`) com bots ativos na partida.

## Controles

- `WASD`: mover
- `Mouse`: mirar
- `Espaço`: pular
- `Botão esquerdo`: atirar
- `ESC`: liberar o cursor

### Controles touch (Android/iOS)

- **Metade esquerda da tela**: arrastar para mover
- **Metade direita da tela**: arrastar para mirar
- **Botão ATIRAR**: tiro contínuo
- **Botão PULAR**: salto

## Requisitos

- Godot **4.2+** com suporte de exportação Android/Linux.
- Para gerar `.deb`: `dpkg-deb` instalado.

## Instalar dependências (Debian/Ubuntu)

```bash
./build/install_dependencies.sh
./build/get_godot.sh 4.2.2
```

> Se sua rede bloquear downloads externos, defina `GODOT_BASE_URL` para um mirror interno acessível e execute novamente `build/get_godot.sh`.

## Rodar localmente

```bash
godot4 --path .
```

## Build Android (`.apk`)

```bash
./build/build_apk.sh
```

Saída esperada: `build/Sool.apk`.

## Build Debian (`.deb`)

```bash
./build/build_deb.sh 0.1.0 amd64
```

Saída esperada: `build/sool_0.1.0_amd64.deb`.

## Estrutura

- `scenes/Main.tscn`: cena principal.
- `scripts/main.gd`: bootstrap, menu, mundo, spawns e rede.
- `scripts/player.gd`: controle de player FPS e tiro por raycast.
- `scripts/bot.gd`: IA simples de perseguição e ataque.
- `build/`: scripts de build para APK e DEB.
