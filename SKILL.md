---
name: mfl-raylib-3d
description: "Build a 3D raylib game in MFL (machin). Covers: FFI extern declarations, cstructs for raylib types, Camera3D setup, first-person controls, mesh building from tile maps, DrawCube rendering, 2D HUD overlay, vendored raylib static linking. Prerequisites: machin v0.45.0+, a C compiler."
---

# Building Raylib 3D Games in MFL

This skill documents how to build a 3D game in MFL using raylib's C FFI. It is distilled from [machin-game-dungeon](https://github.com/javimosch/machin-game-dungeon), a Daggerfall-style first-person dungeon crawler.

---

## 1. Raylib FFI Extern Block

Every raylib function or type you use in MFL must be declared in an `extern "raylib"` block:

```mfl
extern "raylib" {
    header "raylib.h"
    link "raylib" link "GL" link "m" link "pthread" link "dl" link "rt" link "X11"

    // ── cstructs ──
    cstruct Color          { r u8 g u8 b u8 a u8 }
    cstruct Vector2        { x f32 y f32 }
    cstruct Vector3        { x f32 y f32 z f32 }
    cstruct Camera3D       { position Vector3 target Vector3 up Vector3 fovy f32 projection i32 }
    cstruct Rectangle      { x f32 y f32 width f32 height f32 }

    // ── window ──
    fn InitWindow(i32, i32, string)
    fn SetTargetFPS(i32)
    fn WindowShouldClose() bool
    fn CloseWindow()

    // ── frame ──
    fn BeginDrawing()
    fn EndDrawing()
    fn ClearBackground(Color)

    // ── 3D ──
    fn BeginMode3D(Camera3D)
    fn EndMode3D()
    fn DrawCube(Vector3, f32, f32, f32, Color)
    fn DrawGrid(i32, f32)

    // ── input ──
    fn IsKeyDown(i32) bool
    fn IsMouseButtonPressed(i32) bool
    fn IsMouseButtonDown(i32) bool
    fn GetMouseDelta() Vector2
    fn DisableCursor()
    fn EnableCursor()

    // ── time ──
    fn GetFrameTime() float

    // ── 2D overlay ──
    fn DrawText(string, i32, i32, i32, Color)
    fn DrawRectangle(i32, i32, i32, i32, Color)
    fn DrawFPS(i32, i32)
}
```

**Rules:**
- `string` maps to `const char*` in C — machin marshals it automatically.
- `bool` maps to C's `bool` (from `stdbool.h`).
- `i32` maps to `int` (32-bit).
- `f32` maps to `float`.
- `float` in MFL is `double` in C — raylib uses `float` (32-bit), so use `f32` in extern fn signatures.
- Structs are passed by value — MFL's cstruct lays out the fields in C-compatible order.

## 2. Vendored Raylib Build

For a self-contained build without system raylib, vendor the prebuilt static release:

```bash
# In build.sh:
RL_VER=5.0
RL_TAR="raylib-${RL_VER}_linux_amd64"
RL_DIR="vendor/${RL_TAR}"

# Download if not present
if [ ! -f "${RL_DIR}/lib/libraylib.a" ]; then
    mkdir -p vendor
    curl -fsSL "https://github.com/raysan5/raylib/releases/download/${RL_VER}/${RL_TAR}.tar.gz" \
        | tar xz -C vendor
fi

# Encode and inject vendor paths
INC="$PWD/${RL_DIR}/include"
LIB="$PWD/${RL_DIR}/lib"
machin encode dungeon.src \
    | sed "s#header \"raylib.h\"#cflags \"-I${INC} -L${LIB}\" header \"raylib.h\"#; s#link \"raylib\"#link \":libraylib.a\"#" \
    > dungeon.mfl
machin build dungeon.mfl -o machin-game-dungeon
```

The `sed` substitution rewrites:
- `header "raylib.h"` → `cflags "-I<path>/include -L<path>/lib" header "raylib.h"` (adds include/library search paths)
- `link "raylib"` → `link ":libraylib.a"` (links the static .a directly, bypassing `-l` search)

## 3. Camera3D Setup

Construct a first-person camera each frame:

```mfl
// Player state
var _px = 2.5
var _py = 2.5
var _pangle = 0.0  // radians, 0 = east

// In render loop:
eye_y := 0.7  // eye height
cam_pos := Vector3{_px, eye_y, _py}
cam_target := Vector3{_px + cos(_pangle), eye_y, _py + sin(_pangle)}
cam_up := Vector3{0.0, 1.0, 0.0}
cam := Camera3D{cam_pos, cam_target, cam_up, 75.0, 0}
// projection: 0 = CAMERA_PERSPECTIVE
```

The camera position is at player eye height. The target is one unit forward from the player. The up vector is straight up (y-axis).

## 4. First-Person Movement

Frame-rate independent movement using `GetFrameTime()`:

```mfl
dt := GetFrameTime()
speed := dt * 3.0  // 3 units/second
rot_speed := dt * 2.5  // radians/second

if IsKeyDown(87) {  // W
    _px = _px + cos(_pangle) * speed
    _py = _py + sin(_pangle) * speed
}
if IsKeyDown(83) {  // S
    _px = _px - cos(_pangle) * speed
    _py = _py - sin(_pangle) * speed
}
if IsKeyDown(65) {  // A — strafe left
    strafe := _pangle - 1.5708  // -90°
    _px = _px + cos(strafe) * speed
    _py = _py + sin(strafe) * speed
}
if IsKeyDown(68) {  // D — strafe right
    strafe := _pangle + 1.5708  // +90°
    _px = _px + cos(strafe) * speed
    _py = _py + sin(strafe) * speed
}

// Mouse look:
md := GetMouseDelta()
_pangle = _pangle + float(md.x) * dt * 3.0
```

**Key codes** (GLFW): W=87, A=65, S=83, D=68, ESC=256, SPACE=32, E=69, Q=81.

## 5. Dungeon as Flat Tile Map

The same pattern used by `machin-game-roguelike` and `machin-game-demo-dungeon`:

```mfl
var _MAP_W = 24
var _MAP_H = 24
var _map = []int{}  // flat 1D array, index = y * _MAP_W + x

func idx(x, y) (i) { i = y * _MAP_W + x }

// Tile types
var _TILE_FLOOR = 0
var _TILE_WALL = 1
```

BSP room generation (from the roguelike) works identically here — just use `idx(x, y)` for access.

## 6. Rendering Walls with DrawCube

For each wall tile, draw a colored cube:

```mfl
func render_walls() {
    y := 0
    while y < _MAP_H {
        x := 0
        while x < _MAP_W {
            if _map[idx(x, y)] == _TILE_WALL {
                // Wall at (x+0.5, 0.5, y+0.5), size 1×1×1
                pos := Vector3{float(x) + 0.5, 0.5, float(y) + 0.5}
                DrawCube(pos, 1.0, 1.0, 1.0, Color{90, 85, 80, 255})  // stone gray
            }
            x = x + 1
        }
        y = y + 1
    }
}
```

For floor tiles, draw a thin flat box:
```mfl
pos := Vector3{float(x) + 0.5, -0.01, float(y) + 0.5}
DrawCube(pos, 1.0, 0.02, 1.0, Color{40, 35, 30, 255})  // dark floor
```

**Performance note:** For dungeons with >200 wall tiles, consider building a single mesh instead (see the planet demo's `UploadMesh` + `LoadModelFromMesh` pattern).

## 7. 2D HUD Overlay

Drawn after `EndMode3D()` but before `EndDrawing()`:

```mfl
// Health bar
DrawRectangle(20, 20, 200, 20, Color{60, 60, 60, 255})           // background
DrawRectangle(20, 20, hp * 2, 20, Color{200, 40, 40, 255})       // fill

// Text
DrawText("HP: " + str(_hp) + "/" + str(_max_hp), 20, 45, 14, Color{255, 255, 255, 255})

// FPS
DrawFPS(750, 20)
```

## 8. Common pitfalls

- **String params:** raylib functions that take `const char*` are declared with MFL's `string` type. Examples: `InitWindow`, `DrawText`.
- **f32 vs float:** raylib uses `float` (32-bit). MFL's `f32` maps to C's `float`. MFL's `float` type (64-bit double) should NOT be used in extern fn params for raylib functions — use `f32`.
- **cstruct field order:** Struct fields must be declared in the exact order they appear in the C header. `Camera3D` is `{position, target, up, fovy, projection}` — that matches raylib's definition.
- **Mouse capture:** Call `DisableCursor()` after creating the window to capture the mouse. Call `EnableCursor()` on ESC to release it.
- **GetFrameTime:** Returns seconds since last frame as `float` (MFL's 64-bit double). Multiply movement by this for frame-rate independence.
- **Exit:** If the window is closed (WindowShouldClose returns true), exit the loop and call CloseWindow(). Don't forget to call `EnableCursor()` before exit.

## 9. Full extern reference

See `dungeon.src` in this repository for a complete, working extern block. The minimal set for a 3D dungeon crawler is ~30 function declarations and ~8 cstructs.
