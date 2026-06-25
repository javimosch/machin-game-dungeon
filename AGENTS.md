# AGENTS — machin-game-dungeon

This file helps AI agents understand, navigate, and contribute to this project.

## Project structure

```
machin-game-dungeon/
├── dungeon.src       # Main game source (MFL)
├── build.sh          # Build script — encodes, vendors raylib, links
├── README.md         # User-facing docs
├── VISION.md         # Long-term aspiration
├── ROADMAP.md        # Version plan
├── AGENTS.md         # This file — agent guide
├── SKILL.md          # Agent skill — how to build raylib games in MFL
└── vendor/           # Vendored raylib (created by build.sh, not committed)
```

## Key files an agent should read

| File | Why |
|------|-----|
| `dungeon.src` | All game logic in one file. Start here to understand the implementation. |
| `build.sh` | How the binary is built — raylib vendoring, FFI linkage. |
| `SKILL.md` | The reusable skill for building raylib games in MFL. Read this before writing your own. |
| `VISION.md` | Where this project is going. |

## Architecture overview

```
dungeon.src
├── extern "raylib"       FFI declarations (~30 functions, ~10 cstructs)
├── constants + globals   Map size, tile types, player state, enemies
├── dungeon generation    BSP room placement + corridors (flat []int grid)
├── mesh builder          Tile map → vertex data → UploadMesh → Model
├── camera                First-person: position + angle, WSAD + mouse
├── input                 IsKeyDown, GetMouseDelta, mouse button
├── enemy AI              Chase, patrol, attack
├── combat                Raycast, damage, death
├── rendering             3D (DrawModel, DrawCube) + 2D HUD overlay
├── main loop             Init, game tick, cleanup
```

## MFL patterns used

### Flat 1D arrays for tile maps
```mfl
var _map = []int{}
func idx(x, y) (i) { i = y * _MAP_W + x }
// Access: _map[idx(x, y)]
```

### Raylib FFI via extern blocks
```mfl
extern "raylib" {
    header "raylib.h"
    link "raylib" link "GL" link "m" ...
    cstruct Vector3 { x f32 y f32 z f32 }
    fn DrawCube(Vector3, f32, f32, f32, Color)
    ...
}
```

### Camera3D construction
```mfl
cam := Camera3D{Vector3{x, y, z}, Vector3{tx, ty, tz}, Vector3{0, 1, 0}, 75.0, 0}
```

### First-person movement (frame-rate independent)
```mfl
speed := GetFrameTime() * 3.0
if IsKeyDown(87) {  // W key
    px = px + cos(angle) * speed
    py = py + sin(angle) * speed
}
```

## Common pitfalls

1. **`string` params in extern blocks** — raylib functions that take `const char*` are declared with MFL's `string` type. machin marshals them correctly.
2. **Camera3D projection field** — the `projection i32` field is 0 for `CAMERA_PERSPECTIVE` and 1 for `CAMERA_ORTHOGRAPHIC`.
3. **IsKeyDown key codes** — raylib uses GLFW key codes. W=87, A=65, S=83, D=68, ESC=256, SPACE=32, E=69.
4. **GetMouseDelta** — returns the mouse movement since last frame as Vector2. Use `DisableCursor()` to lock the cursor to the window.
5. **Frame timing** — always multiply movement by `GetFrameTime()` for frame-rate independence.

## How an agent can help

- **Add a feature from ROADMAP.md**: pick a v1.1+ milestone and implement it.
- **Optimize the mesh builder**: replace individual `DrawCube` with a single batched mesh.
- **Add a new enemy type**: extend the enemy spawn table with new AI behaviors.
- **Improve the dungeon generator**: add loops, dead-ends, secret rooms.
- **Port to WASM**: compile dungeon.src with `--target wasm` for browser play.

## Testing

```bash
./build.sh && ./machin-game-dungeon
```

Requires a display (X11/Wayland). No test harness yet — manual playtesting.
