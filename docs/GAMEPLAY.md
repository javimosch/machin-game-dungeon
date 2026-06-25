# GAMEPLAY — Verticality, Transitions, and Overland Travel

*Design of the core gameplay systems for v2.0+ of `machin-game-dungeon`.*

---

## 1. Verticality — Multi-Level Dungeons

### Current state
Dungeons are flat 2D tile maps (24×24). Player moves on one plane.

### Target state
Dungeons have 3-7 levels stacked vertically. The player ascends/descends via stairs, ladders, shafts, or ramps.

### Data Structure

The map becomes a 3D volume: `[z][y][x]` accessed as a flat `[]int`:

```mfl
func idx3d(x, y, z) (i) {
    i = z * _MAP_W * _MAP_H + y * _MAP_W + x
}
```

New tile types for verticality:

| Tile | Value | Behavior |
|------|-------|----------|
| `_TILE_STAIRS_UP` | 10 | Ascend one level when walked onto |
| `_TILE_STAIRS_DOWN` | 11 | Descend one level when walked onto |
| `_TILE_LADDER_UP` | 12 | Ascend — requires E key to use (interactive) |
| `_TILE_LADDER_DOWN` | 13 | Descend — requires E key |
| `_TILE_SHAFT` | 14 | Pit/hole — fall down, take damage, or rope required |
| `_TILE_RAMP` | 15 | Slope connecting two levels gradually |
| `_TILE_PLATFORM` | 16 | Elevated floor section — can walk under |

### Dungeon Generation for Multi-Level

**Algorithm: Layered BSP**

1. Generate level 0 (surface/near-surface) using standard BSP
2. For each room on level 0, roll a chance (40%) for a stair/ladder down
3. Below each stair down, carve a new room on level 1
4. Repeat recursively for N levels
5. Deeper levels are smaller (tighter corridors, fewer rooms)
6. Deepest level has a "boss room" or treasure vault

**Visual indicators on minimap:**
- Stairs shown as `▲` (up) / `▼` (down)
- Current level number displayed in HUD
- Known stairs on other levels shown dimmed

### Rendering Multi-Level Dungeons

**Approach: Single-level render with peek**

The 3D view renders only the **current Z-level**. Stairs/ladders are marked with special visual indicators:
- Stairs up: bright arrow on floor
- Ladder: vertical shaft visible in wall
- Hole: dark opening in floor

The **minimap** shows all explored levels, with the current level highlighted. Players can toggle level view with a key.

**Fall-through shafts:**
If a tile is `_TILE_SHAFT` and the player walks onto it, they fall to the next level down, taking fall damage proportional to distance.

### Level-themed environments

| Level | Depth | Theme | Wall Color | Lighting |
|-------|-------|-------|------------|----------|
| 0 | Near-surface | Mossy stone, roots | Dark green-gray | Dim (50%) |
| 1 | Shallow | Dry stone, cobwebs | Gray-brown | Dark (35%) |
| 2 | Mid | Wet stone, dripping water | Dark gray | Very dark (20%) |
| 3 | Deep | Crystal-lit caverns | Blue-gray | Crystal glow (25%, localized) |
| 4 | Abyss | Volcanic rock, lava glow | Red-black | Lava glow (30%, pulsing) |
| 5 | Core | Ancient machinery | Brass/iron | Flickering (15%) |

### Lighting Per Level

Each level has a base ambient light level (percentage). The player's torch adds a radius of full brightness. Distance shading (already implemented) is layered on top.

## 2. Interior → Exterior Transition

### Design Goal

Seamless transition from dungeon interior to outdoor landscape. The player walks through a cave entrance and emerges on a hillside under an open sky.

### The Entrance Tile

Each dungeon has an `_TILE_EXIT` tile (value 20). When the player walks onto it:

1. **Transition sequence:**
   - Screen fades to black (or white for bright exterior)
   - Camera pulls back/pans up
   - New map loads (overland terrain)
   - Player appears at the dungeon entrance coordinates on the overland map
   - Sky renders, distant terrain visible

2. **Data flow:**
   - Current dungeon coordinate + entrance coordinate → overland coordinate mapping
   - Player's inventory, stats, and state persist
   - Time passes (exterior time continues)

### Visual Transition Effects

| Effect | Implementation |
|--------|---------------|
| Light adaptation | Gradual brightness increase over ~1 second (lerp ClearBackground color) |
| Fog lift | Interior fog density → 0 over transition |
| Sky reveal | Ceiling tiles → sky gradient over ~0.5 seconds |
| Sound change | (future) Echo → open air reverb |

### The Overland Map

A separate, much larger tile map (256×256 or larger):

| Tile | Value | Color |
|------|-------|-------|
| Grass | 0 | Green (#4a7c3f) |
| Dirt | 1 | Brown (#8b6f47) |
| Rock | 2 | Gray (#7a7a7a) |
| Water | 3 | Blue (#2a5a8a) |
| Sand | 4 | Tan (#d4b86a) |
| Snow | 5 | White (#e8e8e8) |
| Road | 6 | Light brown (#b89a6a) |
| Village | 10 | Cluster of buildings |
| City | 11 | Large building cluster |
| Dungeon entrance | 12 | Cave/door marker |
| Ruin | 13 | Broken wall marker |
| Tree | 20 | Forest canopy |
| Mountain | 21 | Elevated rock |

### Overland Generation

Use `noise2` (Perlin noise) for terrain height:
- Low noise → water/flat
- Mid noise → grass/forest
- High noise → hills/mountains

Place features:
- Villages at river junctions or coastlines
- Dungeon entrances in hills or remote areas
- Roads connecting villages
- Forests in mid-noise areas

### Third-Person Camera (Exterior)

When outside, the camera pulls back to a **third-person perspective**:
- Camera hovers above and behind the player
- Shows the player character as a small figure on the landscape
- WASD moves the character, mouse rotates camera orbit
- Camera distance adjustable with scroll wheel

This is a dramatic shift from the first-person interior view and signals "you are outside now."

### Exterior Rendering

| Feature | Implementation |
|---------|---------------|
| Sky | Gradient hemisphere — blue at zenith, lighter at horizon, orange near sunrise/sunset |
| Sun | Position based on time of day (simple circle) |
| Terrain | Colored 3D ground plane with slight height variation |
| Trees | Simple cone + cylinder (green cone on brown trunk) |
| Buildings | Rectangular boxes with flat roofs, varied colors |
| Water | Flat blue plane, slight animation possible |
| Mountains | Distant tall cones, fog-colored (distance fade) |

### View Distance

- Interior: max 20 tiles (heavily fogged, current system)
- Exterior: max 100+ tiles (fog at horizon)
- Uses the same distance shading but with much larger range

## 3. Overland Travel

### Movement Speed

- Walking: 1 tile per ~0.5 seconds (3 tiles/second)
- Running: 2x walking (stamina cost) — future feature
- Fast travel: (future) click on known location → auto-walk with time compression

### Points of Interest

Visible on the overland map as colored markers:
- **Green dot**: Village (safe rest, trade, quests)
- **Red dot**: Dungeon entrance
- **Gray dot**: Ruin
- **Gold dot**: City
- **Blue dot**: Shrine / sanctuary

Distance to nearest POI shown in HUD.

### Encounters While Traveling

Random events trigger based on terrain type and distance from civilization:

| Terrain | Encounter Rate | Common Encounters |
|---------|---------------|-------------------|
| Road (near village) | Very low | Traveling merchant, patrol |
| Grassland | Low | Wild dog, bandit scout |
| Forest | Medium | Wolf, bear, spider, bandit camp |
| Hills | Medium | Goblin scout, mountain lion |
| Mountains | High | Harpy, troll, goblin patrol |
| Wastes | High | Frost wraith, skeleton patrol |
| Night (any) | +50% | Wraith, will-o'-wisp, undead |

Encounters trigger a **transition to a small encounter map** (a 20×20 area) where combat takes place. After combat, the player returns to the overland map.

### Time and Day/Night

- Day/night cycle: 24 minutes real-time per full cycle (1 game hour = 1 real minute)
- Day: 5:00-20:00 (15 hours)
- Night: 20:00-5:00 (9 hours)
- Light level changes gradually
- Night is dangerous — more monsters, harder to see
- Villages close gates at night (cannot enter until morning)

### Compass and Navigation

- Compass rose in HUD corner
- Cardinal directions labeled (N, S, E, W)
- Current coordinates (optional)
- Distance and direction to last/next POI

## 4. Player State Across Transitions

All state persists across interior↔exterior transitions:

| State | Persists? | Notes |
|-------|-----------|-------|
| HP/MP/Stamina | Yes | May change during travel (rest, encounter) |
| Inventory | Yes | |
| Equipment | Yes | |
| Level/XP | Yes | |
| Gold | Yes | |
| Time of day | Yes | Time passes while traveling |
| Dungeon explored map | Yes | Returns when re-entering same dungeon |
| Overland explored map | Yes | Persistent |
| Quest progress | Yes | |

## 5. Villages and Cities

### Village Structure

When entering a village tile on the overland map, the player transitions to a **village view**:
- Top-down or isometric 2D view (simpler than 3D dungeon)
- Player walks to buildings to interact
- Buildings: Inn, Smithy, Temple, Shop, Guild Hall, Homes

### Services

| Building | Service |
|----------|---------|
| Inn | Rest (restore HP), save, rumors |
| Smithy | Buy/sell weapons and armor, repair |
| Temple | Healing (expensive), blessing (temporary buff) |
| Shop | Buy/sell general goods, potions |
| Guild Hall | Quests, training, faction reputation |
| Town hall | Bounty board, local news |

### City Structure

Same as village but larger — multiple districts, more services, faction headquarters, quest givers, guilds.

## 6. Future Verticality Features

Beyond stairs and levels:

| Feature | Description | Complexity |
|---------|-------------|------------|
| Balconies | Walkable area above another area, visible as overhang | Medium |
| Bridges | Walk across a gap, see below | Medium |
| Elevators | Moving platform between levels | High |
| Teleporters | Instant travel between distant tiles on same/different level | Low |
| Collapse | Destroy floor to fall to lower level | Medium |
| Climbing | Face a wall, press E to climb (simple animation) | Medium |
| Jumping | Space to jump over gaps/pits | Low |
| Flying | (rare item) Limited flight for short durations | High |

---

*"The world is not flat. The dungeons are not shallow. And you — you are not ready for what lies beneath."*
