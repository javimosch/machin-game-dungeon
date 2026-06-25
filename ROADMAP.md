# ROADMAP — machin-game-dungeon

## v1.0 (current) — 3D Dungeon Explorer

**Goal:** A native window showing a procedurally generated 3D dungeon you can walk through.

| Area | Deliverable | Tech |
|------|-------------|------|
| Window | 800×600 OpenGL window with raylib | `InitWindow`, `extern "raylib"` FFI |
| Dungeon | BSP-generated tile map | Same algorithm as `machin-game-roguelike`, adapted |
| Rendering | Colored 3D walls via `DrawCube` | raylib `BeginMode3D`/`EndMode3D` |
| Camera | First-person WASD movement, auto-rotate with mouse | `IsKeyDown`, `GetMouseDelta`, `DisableCursor` |
| HUD | Health bar, gold, FPS counter | `DrawRectangle`, `DrawText`, `DrawFPS` |
| Build | Self-contained binary with vendored raylib | `build.sh` vendoring pattern from 3D demo |

**Not in v1.0:** enemies, combat, textures, audio, minimap, doors, save/load.

## v1.1 — Enemies & Combat

- Enemy cubes with bob animation
- Click-to-attack (raycast forward, distance check)
- HP system with damage numbers
- Enemy death + loot drop
- Simple chase AI (move toward player when in range)

## v1.2 — Interactive Dungeon

- Doors (open/close with E key)
- Mouse-look toggle (ESC to release cursor)
- Crosshair + attack feedback
- Minimap overlay (auto-explored)
- Torch flicker lighting effect

## v1.3 — Dungeon Variety

- Multiple dungeon themes with different colors (stone crypt, ice cave, lava mine, temple)
- Stairs between levels
- Lore books / notes as wall pickups
- Ambient FX (dripping water particles, glowing crystals)

## v2.0 — Overland World

- 2D overland map with cities, dungeons, temples
- Fast travel between locations
- Day/night cycle
- Weather effects (rain, fog)

## v3.0 — Full RPG

- Character creation (stats, class, birthsign)
- Skill system (level by using)
- Quest giver NPCs
- Dialogue trees
- Faction reputation
- Save/load

## How we build

Each version is driven by a concrete milestone, not speculation. The rule: ship something playable, then add one layer at a time. This document is updated as the project evolves.
