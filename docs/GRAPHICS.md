# GRAPHICS — Visual Design and Rendering Approach

*Color palettes, rendering techniques, and visual identity for `machin-game-dungeon`.*

---

## 1. Design Philosophy

**"Readable gloom."** The game is dark, but never so dark you can't see what matters. Every color choice prioritizes:
1. **Readability** — Can the player understand the geometry at a glance?
2. **Atmosphere** — Does the palette evoke the intended mood?
3. **Performance** — Can we render this with `DrawCube` and basic primitives?

No textures. No shaders (for v1). Everything is flat color with distance-based shading.

## 2. Interior Color Palette

### Wall Colors (by depth)

| Level | Name | Base Color | Distant Shade |
|-------|------|-----------|---------------|
| 0 | Mossy crypt | `rgb(90,85,80)` | `rgb(40,38,36)` |
| 1 | Dry stone | `rgb(100,95,90)` | `rgb(45,43,40)` |
| 2 | Wet cavern | `rgb(75,78,85)` | `rgb(35,36,40)` |
| 3 | Crystal cave | `rgb(60,70,95)` | `rgb(28,32,45)` |
| 4 | Volcanic | `rgb(100,50,40)` | `rgb(45,22,18)` |
| 5 | Ancient core | `rgb(80,70,50)` | `rgb(38,33,24)` |

### Floor Colors

| Level | Color | Notes |
|-------|-------|-------|
| All | `rgb(45,40,35)` | Dark stone floor |
| Water tiles | `rgb(25,50,80)` | Slightly blue tint |

### Ceiling Colors

| Level | Color |
|-------|-------|
| All | `rgb(25,22,20)` | Very dark — barely visible |

### Special Tiles

| Tile | Color | Purpose |
|------|-------|---------|
| Stairs up | `rgb(200,180,100)` yellow arrow on floor | Easy to spot |
| Stairs down | `rgb(180,100,200)` purple arrow on floor | Distinct from up |
| Ladder | `rgb(150,120,80)` brown vertical | Looks climbable |
| Exit | `rgb(200,220,255)` bright blue-white | Calls attention |
| Door | `rgb(130,95,55)` brown | Distinct from wall |
| Chest | `rgb(200,170,50)` gold | Reward signal |

### Distance Shading Formula

```mfl
shade = max(20, 100 - dist * 25)
// Where:
//   dist = distance from player in tiles (sqrt(dx² + dz²))
//   100 = base brightness at dist=0
//   25 = falloff rate per tile
//   20 = minimum brightness (never completely black)
```

The result is a smooth darkness gradient. Walls at dist=1 are ~75% bright. Walls at dist=4 are ~0% bright (clamped to 20).

### Side Detection for Lighting

Currently all wall faces use the same color. Future improvement: detect which face of the cube the ray hit (via `side` parameter in raycasting) and shade the front face brighter, side faces darker, for a 3D lighting effect.

## 3. Exterior Color Palette

### Sky

| Time | Top Color | Horizon Color |
|------|-----------|---------------|
| Dawn (5-7) | `rgb(80,60,120)` purple | `rgb(240,180,80)` orange |
| Morning (7-10) | `rgb(60,100,180)` blue | `rgb(200,200,220)` light blue |
| Midday (10-16) | `rgb(40,80,200)` deep blue | `rgb(180,200,240)` bright blue |
| Afternoon (16-19) | `rgb(80,90,180)` blue | `rgb(220,180,120)` golden |
| Dusk (19-21) | `rgb(120,50,80)` red | `rgb(240,120,60)` orange-red |
| Night (21-5) | `rgb(10,10,30)` black | `rgb(20,20,50)` dark blue |

Sky rendered as a vertical gradient (top→bottom).

### Terrain

| Tile | Color | Variation |
|------|-------|-----------|
| Grass | `rgb(74,124,63)` | ±5 per channel |
| Dirt | `rgb(139,111,71)` | ±5 per channel |
| Rock | `rgb(122,122,122)` | ±3 per channel |
| Water | `rgb(42,90,138)` | Animated: slight brightness oscillation |
| Sand | `rgb(212,184,106)` | ±5 per channel |
| Snow | `rgb(232,232,232)` | ±2 per channel |
| Road | `rgb(184,154,106)` | Slightly lighter than dirt |

### Vegetation

| Object | Color | Shape |
|--------|-------|-------|
| Tree trunk | `rgb(100,70,40)` | Cylinder |
| Tree canopy | `rgb(50,120,40)` | Cone on cylinder |
| Bush | `rgb(60,130,50)` | Small sphere |

### Structures

| Building | Wall Color | Roof Color |
|----------|-----------|------------|
| Village house | `rgb(160,140,110)` | `rgb(140,80,40)` |
| Stone tower | `rgb(130,125,115)` | `rgb(100,95,85)` |
| Temple | `rgb(190,180,160)` | `rgb(120,70,130)` purple |
| Inn | `rgb(170,130,80)` | `rgb(150,90,40)` |

## 4. Lighting System

### Interior: Torch Light

The player carries a torch (infinite, always on). It creates a sphere of light:
- Radius: ~6 tiles
- Falloff: smooth from center to edge
- Detection: tiles outside torch radius but within 8 tiles get dim rendering

```mfl
// Torch lighting
torch_radius = 6.0
tile_dist = sqrt(dx*dx + dz*dz)
if tile_dist < torch_radius:
    brightness = 1.0 - (tile_dist / torch_radius) * 0.3
else:
    brightness = max(0.15, 1.0 - (tile_dist / 10.0))
```

### Exterior: Sun/Moon

- Sun intensity: varies by time of day (sine curve, peak at noon)
- Moon intensity: ~15% of sun
- Night vision: player can carry a lantern (toggle, drains oil)

### Torch Flicker Effect

The torch light radius oscillates slightly (between 5.5 and 6.5) using `sin(frame_time)` for a flickering feel. This is subtle — just enough to feel alive, not enough to be disorienting.

```mfl
flicker = 1.0 + 0.08 * sin(now_ms() * 0.005)
torch_radius = 6.0 * flicker
```

### Distance Fog

Same as current system but with different parameters for interior vs exterior:

| Environment | Base Fog | Max Distance |
|-------------|----------|-------------|
| Interior (level 0) | Starts at 3 tiles | 12 tiles |
| Interior (level 3) | Starts at 2 tiles | 8 tiles |
| Exterior (day) | Starts at 30 tiles | 120 tiles |
| Exterior (night) | Starts at 8 tiles | 30 tiles |
| Exterior (fog) | Starts at 5 tiles | 20 tiles |

## 5. Rendering Approach

### Current (v1.0)
- Each wall = one `DrawCube` call
- Each floor tile = one thin `DrawCube`
- ~50-200 draw calls per frame

### Proposed (v2.0)
Same approach for v2.0, with these additions:

**Interior:**
- Wall cubes per tile (same as v1)
- Stairs/ladders as additional colored cubes at angles
- Animated elements: dripping water (small falling blue cube), torch glow (yellow point)

**Exterior:**
- Terrain as a single large ground plane (colored)
- Trees as cone+cylinder combo (2 `DrawCube` calls per tree)
- Buildings as rectangular boxes
- Water as a semi-transparent blue plane
- Sky as a large hemisphere or gradient background

### Billboard Sprites (future)

For enemies, items, and special effects, billboarded sprites (always-facing quads) will replace `DrawCube`:

```mfl
// Billboard approach (future):
// Draw a quad that always faces the camera
// raylib doesn't have DrawBillboard with only Color,
// but we can use BeginMode3D + rlgl matrix tricks
```

### Minimap

**Interior minimap:**
- Top-down view of current Z-level
- Player as white dot
- Explored areas shown, unexplored hidden
- Stairs marked as ▲/▼
- Scale: 1 tile = 4 pixels

**Exterior minimap:**
- Top-down view of overland
- Player as white dot with direction arrow
- Terrain colored by type
- POIs marked with colored dots
- Scale: 1 tile = 2 pixels (larger area visible)

## 6. Color Coding for Gameplay

Players should be able to understand the world at a glance:

| Color | Meaning | Example |
|-------|---------|---------|
| Yellow/gold | Interactive, valuable | Stairs, chests, gold |
| Blue | Safe, helpful | Exit, healing fountain |
| Red | Dangerous | Enemy, trap, lava |
| Green | Nature, rest | Village, grass, inn |
| Brown | Structure, mundane | Walls, doors, roads |
| White | Player, attention | Player dot, crosshair, text |
| Purple | Magic, special | Magic items, rare loot |
| Black | Void, death | Pit, bottomless shaft |

---

*"The darkness is not empty. It has colors — you just have to learn to see them."*

— Old delver's saying
