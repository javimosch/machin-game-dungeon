# VISION — machin-game-dungeon

A **first-person 3D dungeon crawler** in the spirit of *The Elder Scrolls II: Daggerfall*, built entirely in [MFL (machin)](https://github.com/javimosch/machin) — a single native binary, zero runtime dependencies, rendered through raylib's C FFI.

## Why this exists

MFL has proven it can do:
- Terminal games (snake, roguelike)
- 2D GUI via raylib FFI (2048, flappy)
- 3D scenes and procedural worlds (3D demo, cyberpunk)

What it hasn't done: **an indoor first-person 3D game** with room-to-room navigation, real-time combat, and a living dungeon. Cyberpunk is an open-world flyover — impressive, but you don't walk through corridors fighting enemies. This project closes that gap.

## Long-term aspiration

A full Daggerfall-like experience in a ~100 KB native binary:

| Tier | Feature | Status |
|------|---------|--------|
| **v1.0** | Raylib window, procedural dungeon, first-person movement, wall rendering, HUD | ✅ *This build* |
| **v1.1** | Enemy billboard sprites, melee combat, HP system | ⬜ |
| **v1.2** | Mouse-look, crosshair, interact (doors, switches) | ⬜ |
| **v1.3** | Multiple dungeon themes (crypt, mine, temple) | ⬜ |
| **v2.0** | Overland map, towns, quest givers | ⬜ |
| **v3.0** | Full Daggerfall-sized procedural world | ⬜ |

## Design principles

1. **One binary, no assets.** All textures, sounds, and data are procedurally generated or embedded. Download and run.
2. **Pure MFL game logic.** Dungeon gen, enemy AI, combat, and physics are all MFL — no C, no Lua scripts.
3. **Raylib for rendering only.** The FFI boundary is thin: raylib draws triangles and plays audio; MFL does everything else.
4. **Agent-friendly.** Every source file is documented for AI agents to read, understand, and extend. The SKILL.md and AGENTS.md are first-class deliverables.
