#!/usr/bin/env bash
# Stronghold 2027 - LFS Diagnostic & Fix Script
#
# Preveri ali so PNG-ji prave slike ali LFS pointerji
# In pomaga pri popravilu
#
# Uporaba:
#   bash scripts/check_lfs.sh

set -e

echo "=========================================="
echo "  Stronghold 2027 - LFS Diagnostic"
echo "=========================================="
echo ""

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_DIR"

# Preveri ali je git-lfs nameščen
if ! command -v git-lfs &> /dev/null; then
    echo "❌ git-lfs NI nameščen!"
    echo ""
    echo "Namesti git-lfs:"
    echo "  Windows: https://git-lfs.github.com/"
    echo "  macOS:   brew install git-lfs"
    echo "  Linux:   sudo apt install git-lfs"
    echo ""
    echo "Po namestitvi zaženi:"
    echo "  git lfs install"
    echo "  git lfs pull"
    echo ""
    exit 1
fi

echo "✓ git-lfs je nameščen: $(git lfs version)"
echo ""

# Preveri LFS konfiguracijo
if ! git config --get filter.lfs.clean &> /dev/null; then
    echo "❌ Git LFS filter ni konfiguriran!"
    echo "Poženi: git lfs install"
    exit 1
fi
echo "✓ Git LFS filter je konfiguriran"
echo ""

# Preveri nekaj ključnih PNG-jev
echo "=== Preverjam PNG datoteke ==="
echo ""

PROBLEM_COUNT=0
OK_COUNT=0

check_file() {
    local file="$1"
    if [ ! -f "$file" ]; then
        echo "❌ MISSING: $file"
        PROBLEM_COUNT=$((PROBLEM_COUNT + 1))
        return
    fi

    local size=$(stat -c%s "$file" 2>/dev/null || stat -f%z "$file")

    # LFS pointerji so običajno < 200 bytov
    if [ "$size" -lt 200 ]; then
        local first_line=$(head -1 "$file")
        if echo "$first_line" | grep -q "version https://git-lfs"; then
            echo "❌ LFS POINTER (not real file): $file (size: $size)"
            PROBLEM_COUNT=$((PROBLEM_COUNT + 1))
            return
        fi
    fi

    # Preveri PNG signature
    local sig=$(head -c 4 "$file" | od -An -x | tr -d ' \n')
    if [ "$sig" = "8950 4e47" ] || [ "$sig" = "8950 4e47" ]; then
        echo "✓ OK: $file (size: $size)"
        OK_COUNT=$((OK_COUNT + 1))
    else
        echo "❌ NOT PNG: $file (size: $size, sig: $sig)"
        PROBLEM_COUNT=$((PROBLEM_COUNT + 1))
    fi
}

# Preveri ključne UI datoteke
echo "--- UI ikone ---"
check_file "assets/ui/woodcutter_hut_ab.png"
check_file "assets/ui/quarry_ab.png"
check_file "assets/ui/stockpile_ab.png"
check_file "assets/ui/house_ab.png"
check_file "assets/ui/ox_ab.png"
check_file "assets/ui/action_bar_background_clear.png"
check_file "assets/ui/action_bar_house.png"
echo ""

# Preveri tileset
echo "--- Tileset ---"
check_file "assets/tiles/stronghold_assets_packed_v12-hd.png"
check_file "assets/tiles/image_strip.png"
echo ""

# Preveri sounds
echo "--- Zvoki ---"
check_file "sounds/fx/Shieldclick.ogg"
check_file "sounds/fx/armourhit_01.ogg"
echo ""

echo "=========================================="
echo "  REZULTAT"
echo "=========================================="
echo "  ✓ OK:      $OK_COUNT datotek"
echo "  ❌ Problem: $PROBLEM_COUNT datotek"
echo ""

if [ $PROBLEM_COUNT -gt 0 ]; then
    echo "❌ IMATE PROBLEM Z LFS!"
    echo ""
    echo "Popravek:"
    echo "  1. Poženi: git lfs pull"
    echo "  2. Če ne deluje, poženi:"
    echo "     git lfs fetch --all"
    echo "     git lfs checkout"
    echo ""
    echo "  3. Če še vedno ne deluje, preveri GitHub LFS quota:"
    echo "     https://github.com/settings/billing"
    echo "     (Free plan = 1GB storage + 1GB bandwidth/mesec)"
    echo ""
    echo "  4. Alternativa: Prenesi zip direktno iz GitHub Releases"
    echo "     (ko bo na voljo)"
    echo ""
    exit 1
else
    echo "✓ VSE DATOTEKE SO V REDU!"
    echo "Problem s črnimi kvadratki ni v LFS."
    echo ""
    echo "Morda je problem v:"
    echo "  - LÖVE različici (potrebna 11.5+)"
    echo "  - Grafičnih gonilnikih"
    echo "  - Dovoljenjih datotek"
fi
echo ""
