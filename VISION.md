# VISION — machin-game-dungeon

*A first-person 3D dungeon crawler in the spirit of Daggerfall, built in MFL through raylib's C FFI.*

---

## The Dream

A procedurally generated world you can walk through from end to end. Not a dungeon — a world. Dungeons beneath it, landscapes above it, villages scattered across it. All in one binary, all in MFL, all fitting in under 5 MB.

## Current State (v1.0 ✅)

A raylib window with procedural 3D dungeons. You walk through rooms and corridors. Walls fade into darkness with distance. A health bar, gold counter, and crosshair overlay the view.

## The Next Horizon (v2.0 📐)

The design is complete. Five docs under `docs/` lay out the full vision:

| Layer | What it adds |
|-------|-------------|
| **Verticality** | Stairs, ladders, pits. Dungeons 3-7 levels deep. Each level has its own look and feel. |
| **Interior → Exterior** | Walk out of a cave and see the sky. The dungeon is part of a landscape. |
| **Overland World** | 256×256 terrain. Villages, forests, mountains, coast. A world to explore. |
| **Creatures** | 30+ enemy types with AI. Undead in crypts, goblins in mountains, beasts in forests. |
| **Villages** | Rest, trade, quests. Services that make the world feel lived in. |

## Long-term Aspiration (v3.0+)

A full RPG living in a terminal-native binary:

- Character creation with stats, skills, and birthsigns
- A magic system where every spell is a bargain with a fading world
- Factions that remember your choices
- Quests that chain across dungeons, villages, and wilderness
- A world that does not revolve around you — but reacts to what you do
- All procedural, all infinite, all in one binary

## What Makes This Unique

1. **Single binary, zero assets.** Everything is procedural — the dungeons, the terrain, the sky, the colors. Download and run. 1.3 MB today.

2. **MFL through raylib FFI.** All game logic is MFL. Rendering is raylib through a thin FFI boundary. No C extensions, no Lua scripts, no engine. Just the language and a graphics library.

3. **Indoor 3D.** The existing MFL ecosystem had outdoor 3D (cyberpunk's flyover). It didn't have rooms, corridors, staircases, and caves. Indoor 3D is a different rendering and design challenge — and it's solved here.

4. **Agent-readable design.** Every design doc is written for AI agents to read, understand, and implement. The lore, the gameplay mechanics, the color palettes — all laid out for another agent to build from.

## The North Star

A player downloads one file, runs it, and enters a world that feels alive — a world with depth (literal and figurative), with history, with danger, with places to go and things to find. No tutorials, no cutscenes, no handholding. Just a cave entrance, a torch, and the dark beyond.

---

*"The Fracture took everything. The Blooms take the rest. But you — you can go deeper. You can find what was lost. You can bring it back."*

— From the loading screen that will never exist
