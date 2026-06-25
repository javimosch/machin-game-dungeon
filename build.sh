#!/usr/bin/env bash
# Build machin-game-dungeon.
# Vendors a prebuilt static raylib if not installed system-wide.
set -euo pipefail
cd "$(dirname "$0")"
MACHIN="${MACHIN:-machin}"
SRC=dungeon.src
APP=machin-game-dungeon

have_system_raylib() {
    pkg-config --exists raylib 2>/dev/null && return 0
    [ -f /usr/include/raylib.h ] || [ -f /usr/local/include/raylib.h ]
}

if have_system_raylib; then
    echo "using system raylib"
    "$MACHIN" encode "$SRC" > "${APP}.mfl"
else
    RL_VER=5.0
    RL_TAR="raylib-${RL_VER}_linux_amd64"
    RL_DIR="vendor/${RL_TAR}"
    if [ ! -f "${RL_DIR}/lib/libraylib.a" ]; then
        echo "raylib not found system-wide; vendoring the prebuilt static release..."
        mkdir -p vendor
        curl -fsSL "https://github.com/raysan5/raylib/releases/download/${RL_VER}/${RL_TAR}.tar.gz" \
            | tar xz -C vendor
    fi
    INC="$PWD/${RL_DIR}/include"
    LIB="$PWD/${RL_DIR}/lib"
    tmp="$(mktemp)"
    echo "encoding with vendor paths: ${INC}"
    "$MACHIN" encode "$SRC" \
        | sed "s#header \"raylib.h\"#cflags \"-I${INC} -L${LIB}\" header \"raylib.h\"#; s#link \"raylib\"#link \":libraylib.a\"#" \
        > "$tmp"
    mv "$tmp" "${APP}.mfl"
fi

"$MACHIN" build "${APP}.mfl" -o "$APP"
echo "built ./${APP} ($(ls -lh "$APP" | awk '{print $5}'))"
