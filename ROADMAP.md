# ROADMAP — machin-game-dungeon

*Updated with verticality, interior/exterior, and overland vision.*

---

## Legend

| Icon | Meaning |
|------|---------|
| ✅ | Shipped |
| 🔧 | Being built |
| 📐 | Designed (docs exist) |
| ⬜ | Not yet started |

---

## v1.0 — 3D Dungeon Explorer ✅ *(shipped)*

| Feature | Status |
|---------|--------|
| Raylib window (800×600) | ✅ |
| BSP procedural dungeon | ✅ |
| First-person WASD + mouse look | ✅ |
| Distance-shaded 3D walls (DrawCube) | ✅ |
| HUD: health bar, gold, FPS, crosshair | ✅ |
| Circle-based wall collision | ✅ |
| Vendored raylib build | ✅ |
| Project docs: README, VISION, ROADMAP, AGENTS, SKILL | ✅ |

---

## v2.0 — Multi-Level Dungeons 📐 *(designed)*

*Docs: `docs/GAMEPLAY.md` (verticality section)*

| Feature | Status |
|---------|--------|
| 3D tile map (`idx3d(x,y,z)`) | 📐 |
| Stairs up/down as special tiles | 📐 |
| Ladders (interactive: press E) | 📐 |
| Dungeon generation for N levels | 📐 |
| Level-themed color palettes | 📐 |
| Per-level ambient lighting | 📐 |
| Minimap: current level + level selector | 📐 |
| Shafts/pits (fall damage) | 📐 |
| Level indicator in HUD | 📐 |

**Estimated new code:** +300 lines (dungeon gen) + 100 lines (rendering) + 50 lines (HUD) = +450 lines.

---

## v2.1 — Interior ↔ Exterior Transition 📐 *(designed)*

*Docs: `docs/GAMEPLAY.md` (transitions section), `docs/GRAPHICS.md`*

| Feature | Status |
|---------|--------|
| Exit tile (`_TILE_EXIT`) | 📐 |
| Dungeon entrance on overland map | 📐 |
| Transition sequence (fade + map swap) | 📐 |
| State persistence across transition | 📐 |
| Overland terrain generation (noise2) | 📐 |
| Overland terrain types + colors | 📐 |
| Third-person exterior camera | 📐 |
| Sky gradient rendering | 📐 |
| Interior vs exterior fog parameters | 📐 |
| Dungeon → exterior coordinate mapping | 📐 |

**Estimated new code:** +250 lines (terrain gen) + 200 lines (camera) + 150 lines (transition) + 100 lines (rendering) = +700 lines.

---

## v2.2 — Overland Travel 📐 *(designed)*

*Docs: `docs/GAMEPLAY.md` (overland section), `docs/WORLD.md`*

| Feature | Status |
|--------|--------|
| Large overland map (256×256+) | 📐 |
| Points of interest (villages, dungeons, ruins) | 📐 |
| Compass HUD / navigation | 📐 |
| Random encounters (terrain-based) | 📐 |
| Encounter map (small combat area) | 📐 |
| Day/night cycle (24 min full cycle) | 📐 |
| Lighting changes with time | 📐 |
| Simple structures: trees, buildings, water | 📐 |
| POI distance/direction display | 📐 |

**Estimated new code:** +300 lines (encounter system) + 200 lines (day/night) + 150 lines (POI rendering) = +650 lines.

---

## v2.3 — Villages & Services 📐 *(designed)*

| Feature | Status |
|--------|--------|
| Village transition (enter village tile) | 📐 |
| Village view (simple top-down or isometric) | 📐 |
| Inn: rest, save, rumors | ⬜ |
| Smithy: buy/sell, repair | ⬜ |
| Temple: healing, blessings | ⬜ |
| Shop: general goods | ⬜ |
| Guild hall: quests, training | ⬜ |
| Bounty board | ⬜ |

**Estimated new code:** +400 lines.

---

## v2.4 — Creatures & Combat *(designed, partially)*

*Docs: `docs/BESTIARY.md`*

| Feature | Status |
|--------|--------|
| Enemy cubes with bob animation (interior) | 📐 |
| Enemy cubes on overland map | 📐 |
| Melee combat (click to attack, distance check) | 📐 |
| HP system with damage numbers | 📐 |
| Enemy death + loot drop | 📐 |
| Chase AI (detect → chase → attack) | 📐 |
| Multiple enemy types (undead, goblins, animals) | 📐 |
| Boss monsters (unique fights) | 📐 |
| Combat log / message feed | ⬜ |

**Estimated new code:** +400 lines.

---

## v3.0 — Full RPG

| Feature | Status |
|--------|--------|
| Character creation (stats, class) | ⬜ |
| Skill system (level by use) | ⬜ |
| Quest giver NPCs | ⬜ |
| Dialogue trees | ⬜ |
| Faction reputation | ⬜ |
| Save/load (JSON, full state) | ⬜ |
| Magic system | 📐 *`docs/MAGIC.md` pending* |

---

## Current Design Docs

| Doc | Covers | Status |
|-----|--------|--------|
| `docs/LORE.md` | World setting, history, factions, timeline | ✅ Complete |
| `docs/GAMEPLAY.md` | Verticality, transitions, overland, mechanics | ✅ Complete |
| `docs/GRAPHICS.md` | Color palettes, lighting, rendering approach | ✅ Complete |
| `docs/WORLD.md` | Geography, regions, points of interest, dungeon index | ✅ Complete |
| `docs/BESTIARY.md` | Creature catalog, AI design, combat stats | ✅ Complete |
| `docs/MAGIC.md` | Magic system *(pending)* | ⬜ |

---

*"The depth of the design determines the height of the implementation. These docs are the map. The code is the journey."*
