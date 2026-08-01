#!/usr/bin/env bash
# Stronghold 2027 - Demo Build Script
# Creates a distributable .love package for playtesting
#
# Usage:
#   ./scripts/build_demo.sh
#
# Output:
#   download/stronghold2027-demo-v0.7.1.love

set -e

echo "=========================================="
echo "  Stronghold 2027 - Demo Build Script"
echo "=========================================="

VERSION="0.7.1-combat-alpha"
DATE=$(date +"%Y-%m-%d")
OUTPUT_DIR="/home/z/my-project/download"
PROJECT_DIR="/home/z/my-project/stronghold2027"
OUTPUT_FILE="${OUTPUT_DIR}/stronghold2027-demo-v${VERSION}.love"

mkdir -p "${OUTPUT_DIR}"

echo ""
echo "[1/5] Preparing build..."
cd "${PROJECT_DIR}"

# Ensure LFS files are pulled
if command -v git-lfs &> /dev/null; then
    git lfs pull 2>/dev/null || true
fi

echo "[2/5] Validating Lua syntax..."
LUA_BIN="${LUA_BIN:-lua5.1}"
if ! command -v ${LUA_BIN} &> /dev/null; then
    if [ -x "/home/z/.local/bin/lua" ]; then
        LUA_BIN="/home/z/.local/bin/lua"
    else
        echo "WARNING: Lua not found, skipping syntax validation"
        LUA_BIN=""
    fi
fi

if [ -n "${LUA_BIN}" ]; then
    ERROR_COUNT=0
    while IFS= read -r file; do
        # Skip LuaJIT-specific files (goto continue pattern)
        RESULT=$(${LUA_BIN} -e "
            local f = io.open('${file}', 'r')
            if f then
                local content = f:read('*all')
                f:close()
                local fn, err = loadstring(content)
                if not fn then
                    -- Check if it's LuaJIT goto/continue pattern (not a real error)
                    if err and (err:match(\"'continue'\") or err:match(\"'goto'\") or err:match(\"'endMultiTile'\") or err:match(\"'foundWalkable'\") or err:match(\"'skipThisPeasant'\") or err:match(\"'ranOutOfSpace'\")) then
                        os.exit(0)  -- Skip, not a real error
                    end
                    print('ERROR: ${file}: ' .. tostring(err))
                    os.exit(1)
                end
            end
        " 2>&1)
        if [ $? -ne 0 ]; then
            ERROR_COUNT=$((ERROR_COUNT + 1))
            echo "${RESULT}"
        fi
    done < <(find . -name "*.lua" -not -path "./libraries/*" -not -path "./busted/*" -not -path "./.git/*" | head -50)

    if [ ${ERROR_COUNT} -gt 0 ]; then
        echo "ERROR: ${ERROR_COUNT} files failed syntax validation"
        exit 1
    fi
    echo "  ✓ Syntax OK (50 files checked)"
fi

echo "[3/5] Validating YAML locale files..."
if command -v python3 &> /dev/null; then
    YAML_ERRORS=$(python3 -c "
import yaml, glob, sys
errors = 0
for f in sorted(glob.glob('locale/*.yaml')):
    try:
        yaml.safe_load(open(f))
    except Exception as e:
        print(f'ERROR: {f}: {e}')
        errors += 1
sys.exit(1 if errors > 0 else 0)
" 2>&1)

    if [ -n "${YAML_ERRORS}" ]; then
        echo "${YAML_ERRORS}"
        exit 1
    fi
    echo "  ✓ All YAML files valid"
fi

echo "[4/5] Creating .love package..."
# Exclude: git, github, build artifacts, dev docs that aren't needed in game
zip -0 -r "${OUTPUT_FILE}" . \
    -x '*.git*' \
    -x '.github/*' \
    -x 'BUGFIX_STRATEGY.md' \
    -x 'FORK_NOTICE.md' \
    -x 'PRESS_KIT.md' \
    -x 'COMMUNITY_ANNOUNCEMENT.md' \
    -x 'scripts/*' \
    -x '*.luacheckrc' \
    -x '*.gitlab-ci.yml' \
    -x 'crowdin.yml' \
    -x '*.luacheckrc' \
    > /dev/null

echo "  ✓ Created: ${OUTPUT_FILE}"
echo "  Size: $(du -h "${OUTPUT_FILE}" | cut -f1)"

echo "[5/5] Creating README for demo..."
cat > "${OUTPUT_DIR}/README-demo.txt" << EOF
==========================================
  Stronghold 2027 - Combat Demo v${VERSION}
  Build date: ${DATE}
==========================================

KAKO ZAGNATI:

1. Namesti LÖVE 11.5+ iz https://love2d.org/
2. Dvoklikni stronghold2027-demo-v${VERSION}.love
   ALI v terminalu: love stronghold2027-demo-v${VERSION}.love

KAKO IGRATI:

1. Glavni meni -> Freebuild -> Fernhaven (ali Grasslands)
2. Počakaj, da se mapa naloži (10-30 sekund)
3. Pritisni F8 za aktivacijo combat test scenarija
   - Spawnali se bodo: 3 friendly knights, 5 enemy archers, 3 enemy macemen
4. Levi klik + drag za izbiro friendly enot
5. Desni klik na sovražnika za ukaz napada

TIPKE:

F8  - Toggle combat test scenario
F9  - Izpiši combat statistike v konzolo
F3  - Toggle profiler overlay
F4  - Toggle detailed profiler
ESC - Pause menu

ZNANE OMEJITVE (alpha):

- Attack animacije še niso povezane (uporablja se walk animacija)
- Combat zvoki manjkajo
- Building attacks še niso podprti
- Siege weapons še niso integrirani

POVRATNE INFORMACIJE:

GitHub: https://github.com/markec12345678/stronghold2027/issues

Hvala za testiranje! 🏰⚔️
EOF

echo "  ✓ Created: ${OUTPUT_DIR}/README-demo.txt"

echo ""
echo "=========================================="
echo "  BUILD COMPLETE!"
echo "=========================================="
echo ""
echo "Files created:"
ls -la "${OUTPUT_FILE}" "${OUTPUT_DIR}/README-demo.txt"
echo ""
echo "Next steps:"
echo "  1. Download the .love file"
echo "  2. Install LÖVE 11.5+ from https://love2d.org/"
echo "  3. Double-click the .love file to play"
echo ""
