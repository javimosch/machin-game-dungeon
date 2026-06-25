# machin-game-dungeon 🏰

A **first-person 3D dungeon crawler** prototype in the spirit of *The Elder Scrolls II: Daggerfall* — built entirely in [MFL (machin)](https://github.com/javimosch/machin) through raylib's C FFI. Single native binary, statically linked.

```
machin encode dungeon.src → dungeon.mfl → machin build → machin-game-dungeon
```

[![Awesome machin](https://awesome.re/badge.svg)](https://github.com/javimosch/awesome-machin)

## What it is

A raylib-windowed 3D dungeon you can walk through. Procedurally generated via BSP room placement. First-person camera with WASD movement and mouse look. Colored 3D walls with distance-based shading for atmosphere.

- **Procedural dungeons** — BSP-generated rooms and corridors, different every run
- **First-person 3D** — raylib `Camera3D` with smooth movement and mouse look
- **Distance-shaded walls** — walls fade into darkness the farther they are
- **HUD overlay** — health bar, gold counter, FPS counter, crosshair
- **No external assets** — all graphics are procedural, binary is self-contained

## Controls

| Key | Action |
|-----|--------|
| W / S | Move forward / backward |
| A / D | Strafe left / right |
| Mouse | Look around (horizontal) |
| ESC | Toggle mouse capture |
| Q | Quit |

## Build

```bash
./build.sh
./machin-game-dungeon
```

The build script vendors a prebuilt static raylib if not installed system-wide. Requires [machin](https://github.com/javimosch/machin) (v0.45.0+) and a C compiler.

## Install

```bash
curl -fsSL https://github.com/javimosch/machin-game-dungeon/releases/latest/download/machin-game-dungeon -o machin-game-dungeon && chmod +x machin-game-dungeon
```

## Project docs

| File | What it covers |
|------|---------------|
| [`VISION.md`](VISION.md) | Long-term aspiration — where this project is going |
| [`ROADMAP.md`](ROADMAP.md) | Version plan — v1.0 through v3.0 |
| [`AGENTS.md`](AGENTS.md) | Agent guide — how AI agents can understand and extend this project |
| [`SKILL.md`](SKILL.md) | Reusable skill — how to build raylib 3D games in MFL |

## What it demonstrates

- **Raylib FFI** — `extern "raylib"` block with cstructs (Camera3D, Vector3, Color) and 25+ function declarations
- **Procedural dungeon gen** — BSP room placement with L-shaped corridors (reused from `machin-game-roguelike`)
- **First-person 3D** — WASD + mouse look with raylib's `BeginMode3D`/`EndMode3D`
- **Distance-based shading** — walls rendered with darker colors the farther they are (all MFL math)
- **Collision detection** — circle-based player collision against tile grid
- **Vendored raylib build** — self-contained binary via prebuilt static raylib

## Why this is novel

The existing MFL game ecosystem has:
- Terminal games (snake, roguelike)
- 2D raylib games (2048, flappy)
- Open-world 3D flyover (cyberpunk)

What it didn't have: **an indoor first-person 3D game** with room-to-room navigation and real-time rendering of a procedural dungeon. That's the gap this fills.

## Roadmap

See [`ROADMAP.md`](ROADMAP.md) for the full plan. Short term:
- **v1.1** — Enemy sprites (billboarded), melee combat, HP system
- **v1.2** — Doors, interactivity, minimap, torch lighting
- **v1.3** — Multiple dungeon themes, stairs between levels

## License

MIT
