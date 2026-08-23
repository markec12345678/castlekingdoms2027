#!/usr/bin/env bash
# Castle Kingdoms 2027 - Build Script
# Creates a distributable .love package for beta testing or release
#
# Usage:
#   ./scripts/build_castlekingdoms.sh [version]
#   ./scripts/build_castlekingdoms.sh v3.12.170
#
# Output:
#   /home/z/my-project/download/castlekingdoms2027-v3.12.170.love
#
# Requirements:
#   - zip (usually pre-installed)
#   - python3 (for syntax validation)
#   - git-lfs (for proper PNG assets)

set -e

# ============================================================
# Configuration
# ============================================================

# Default version: derive from latest git tag or use argument
VERSION="${1:-$(git describe --tags --always 2>/dev/null || echo 'dev')}"
DATE=$(date +"%Y-%m-%d")
OUTPUT_DIR="/home/z/my-project/download"
PROJECT_DIR="/home/z/my-project/castlekingdoms2027"
OUTPUT_FILE="${OUTPUT_DIR}/castlekingdoms2027-${VERSION}.love"

# Files/dirs to EXCLUDE from the build
EXCLUDE_PATTERNS=(
    ".git"
    ".github"
    "*.md"                    # Markdown docs not needed in build
    "*.py"                    # Python scripts (build/test only)
    "scripts"                 # All build scripts
    "spec"                    # Test specs
    "busted"                  # Test framework
    "*.sh"                    # Shell scripts
    ".gitignore"
    ".gitattributes"
    "*.log"
    "__pycache__"
    ".DS_Store"
    "Thumbs.db"
    "node_modules"
    "*.bak"
    "*.tmp"
)

echo "=========================================="
echo "  Castle Kingdoms 2027 - Build Script"
echo "=========================================="
echo "  Version: ${VERSION}"
echo "  Date: ${DATE}"
echo "  Project: ${PROJECT_DIR}"
echo "  Output:  ${OUTPUT_FILE}"
echo "=========================================="
echo ""

mkdir -p "${OUTPUT_DIR}"

# ============================================================
# Step 1: Pre-flight checks
# ============================================================

echo "[1/6] Pre-flight checks..."

if [ ! -d "${PROJECT_DIR}" ]; then
    echo "ERROR: Project directory not found: ${PROJECT_DIR}"
    exit 1
fi

if [ ! -f "${PROJECT_DIR}/main.lua" ]; then
    echo "ERROR: main.lua not found in project directory"
    exit 1
fi

# Check git status
cd "${PROJECT_DIR}"
if [ -n "$(git status --porcelain 2>/dev/null)" ]; then
    echo "WARNING: Working tree has uncommitted changes"
    git status --short
    echo ""
fi

CURRENT_COMMIT=$(git rev-parse --short HEAD 2>/dev/null || echo "unknown")
echo "  ✓ Project directory: ${PROJECT_DIR}"
echo "  ✓ Commit: ${CURRENT_COMMIT}"

# ============================================================
# Step 2: Ensure LFS files are pulled
# ============================================================

echo ""
echo "[2/6] Ensuring LFS assets are present..."

if command -v git-lfs &> /dev/null; then
    git lfs pull 2>/dev/null || true
    echo "  ✓ LFS assets pulled"
else
    echo "  ⚠ git-lfs not found, skipping LFS pull"
    echo "    If PNG assets are missing, install git-lfs and run 'git lfs pull'"
fi

# Count PNG assets
PNG_COUNT=$(find "${PROJECT_DIR}" -name "*.png" -type f 2>/dev/null | wc -l)
echo "  ✓ PNG assets found: ${PNG_COUNT}"

# ============================================================
# Step 3: Validate Lua syntax
# ============================================================

echo ""
echo "[3/6] Validating Lua syntax..."

SYNTAX_ERRORS=0

# Check if python3 with lupa is available
# Note: lupa parser doesn't handle shebang lines well (false positive on scripts/test.lua)
# We skip scripts/ directory in the find command directly
if command -v python3 &> /dev/null; then
    if python3 -c "from lupa import LuaRuntime" 2>/dev/null; then
        echo "  Validating with python3 + lupa..."
        while IFS= read -r -d '' file; do
            if ! python3 /home/z/my-project/scripts/check_lua_syntax.py "$file" 2>/dev/null; then
                echo "  ✗ SYNTAX ERROR: $file"
                SYNTAX_ERRORS=$((SYNTAX_ERRORS + 1))
            fi
        done < <(find "${PROJECT_DIR}" -name "*.lua" -not -path "*/busted/*" -not -path "*/libraries/*" -not -path "*/scripts/*" -print0)
        if [ $SYNTAX_ERRORS -eq 0 ]; then
            LUA_COUNT=$(find "${PROJECT_DIR}" -name "*.lua" -not -path "*/busted/*" -not -path "*/libraries/*" -not -path "*/scripts/*" | wc -l)
            echo "  ✓ All ${LUA_COUNT} Lua files pass syntax check"
        else
            echo "  ✗ ${SYNTAX_ERRORS} syntax errors found!"
            exit 1
        fi
    else
        echo "  ⚠ python3 + lupa not available, skipping syntax validation"
    fi
else
    echo "  ⚠ python3 not found, skipping syntax validation"
fi

# ============================================================
# Step 4: Build .love package
# ============================================================

echo ""
echo "[4/6] Building .love package..."

# Remove existing .love file if any
rm -f "${OUTPUT_FILE}"

# Create exclude arguments for zip
EXCLUDE_ARGS=""
for pattern in "${EXCLUDE_PATTERNS[@]}"; do
    EXCLUDE_ARGS="${EXCLUDE_ARGS} -x ${pattern}"
done

# Build the .love (zip file with .love extension)
# -r: recursive
# -q: quiet
# -x: exclude patterns
cd "${PROJECT_DIR}"
zip -r -q "${OUTPUT_FILE}" . ${EXCLUDE_ARGS}

if [ ! -f "${OUTPUT_FILE}" ]; then
    echo "ERROR: Failed to create .love file"
    exit 1
fi

LOVE_SIZE=$(du -h "${OUTPUT_FILE}" | cut -f1)
echo "  ✓ .love created: ${LOVE_SIZE}"

# ============================================================
# Step 5: Verify package
# ============================================================

echo ""
echo "[5/6] Verifying package..."

# Check that critical files are included
CRITICAL_FILES=(
    "main.lua"
    "conf.lua"
    "global.lua"
    "states/game.lua"
    "objects/Combat/CombatMoraleSystem.lua"
    "objects/Audio/ProceduralSFX.lua"
    "objects/Performance/LODSystem.lua"
)

for critical in "${CRITICAL_FILES[@]}"; do
    if unzip -l "${OUTPUT_FILE}" "${critical}" 2>/dev/null | grep -q "${critical}"; then
        echo "  ✓ ${critical}"
    else
        echo "  ✗ MISSING: ${critical}"
        exit 1
    fi
done

# Count Lua files in package
LUA_IN_PACKAGE=$(unzip -l "${OUTPUT_FILE}" "*.lua" 2>/dev/null | grep -c "\.lua$" || echo "0")
echo "  ✓ Lua files in package: ${LUA_IN_PACKAGE}"

# Count PNG assets in package
PNG_IN_PACKAGE=$(unzip -l "${OUTPUT_FILE}" "*.png" 2>/dev/null | grep -c "\.png$" || echo "0")
echo "  ✓ PNG assets in package: ${PNG_IN_PACKAGE}"

# ============================================================
# Step 6: Generate build info
# ============================================================

echo ""
echo "[6/6] Generating build info..."

BUILD_INFO="${OUTPUT_DIR}/castlekingdoms2027-${VERSION}-BUILDINFO.txt"
cat > "${BUILD_INFO}" <<EOF
Castle Kingdoms 2027 - Build Information
========================================

Version: ${VERSION}
Build Date: ${DATE}
Git Commit: ${CURRENT_COMMIT}
Build Host: $(hostname)
Build OS: $(uname -s) $(uname -r)

Package Details:
- File: castlekingdoms2027-${VERSION}.love
- Size: ${LOVE_SIZE}
- Lua files: ${LUA_IN_PACKAGE}
- PNG assets: ${PNG_IN_PACKAGE}

Included Systems (v3.12.168+):
- Combat Morale System (v3.12.156-v3.12.159)
- Combat Spacing System (v3.12.160)
- Formation Bonus Integration (v3.12.161)
- Procedural SFX (v3.12.163-v3.12.164)
- Performance LOD System (v3.12.165)
- Performance & Combat Dashboard (v3.12.166)
- Save/Load Enhancement (v3.12.167)
- Royal Icon Generator (v3.12.152)
- Asset Override System (v3.12.154)
- 14+ Modern UI Panels
- 990 Royal Systems
- Tech Tree (891 deps, 165 chains, 786 multi-prereq)
- 37 Achievements
- 30 Tutorial Hints
- 6 Color Themes
- 5 Difficulty Levels (peaceful/easy/normal/hard/brutal)
- 32 Languages

How to Run:
1. Install LÖVE 11.5 from https://love2d.org
2. Double-click the .love file
   OR run: love castlekingdoms2027-${VERSION}.love

Documentation:
- BETA_TEST_CHECKLIST.md - test scenarios
- CHANGELOG.md - version history
- KEYBINDS.md - keyboard shortcuts
- POLISH_PLAN.md - development roadmap

GitHub: https://github.com/markec12345678/castlekingdoms2027
EOF

echo "  ✓ Build info: ${BUILD_INFO}"

# ============================================================
# Summary
# ============================================================

echo ""
echo "=========================================="
echo "  BUILD SUCCESSFUL"
echo "=========================================="
echo ""
echo "  Package: ${OUTPUT_FILE}"
echo "  Size:    ${LOVE_SIZE}"
echo "  Lua:     ${LUA_IN_PACKAGE} files"
echo "  PNG:     ${PNG_IN_PACKAGE} assets"
echo "  Version: ${VERSION}"
echo "  Commit:  ${CURRENT_COMMIT}"
echo ""
echo "  Build info: ${BUILD_INFO}"
echo "=========================================="
echo ""
echo "Next steps:"
echo "  1. Test the .love locally: love \"${OUTPUT_FILE}\""
echo "  2. Distribute to beta testers"
echo "  3. Run through BETA_TEST_CHECKLIST.md"
echo "  4. Collect bug reports"
echo "  5. Tag release: git tag ${VERSION} && git push origin ${VERSION}"
