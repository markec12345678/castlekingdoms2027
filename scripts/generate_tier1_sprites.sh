#!/usr/bin/env bash
# Castle Kingdoms 2027 - Tier 1 Sprite Auto-Generation Pipeline
#
# Generates ALL remaining Tier 1 sprites using AI + PIL conversion.
# Usage: ./scripts/generate_tier1_sprites.sh [count]
#   count = number of sprites to generate (default: all remaining)
#
# Pipeline:
#   1. Read sprite list from HD_SPRITE_PACK_GUIDE.md prompts
#   2. For each sprite:
#      a. Check if PNG already exists (skip if yes)
#      b. Generate with z-ai image CLI
#      c. Convert JPEG → PNG with alpha (Python PIL)
#   3. Git add + commit batch
#
# Requirements:
#   - z-ai CLI (for image generation)
#   - python3 + PIL (for JPEG → PNG conversion)

set -e

TIER1_DIR="assets/royal_systems/tier1"
SCRIPTS_DIR="scripts"
MAX_COUNT="${1:-40}"  # Default: generate up to 40 remaining
GENERATED=0
SKIPPED=0
FAILED=0

echo "=========================================="
echo "  Castle Kingdoms 2027 - Tier 1 Sprite Generator"
echo "=========================================="
echo "  Output: ${TIER1_DIR}/"
echo "  Max count: ${MAX_COUNT}"
echo "=========================================="
echo ""

mkdir -p "${TIER1_DIR}"

# ============================================================
# Sprite definitions: name | prompt
# Format: "Name|prompt text"
# ============================================================

SPRITES=(
    "BoardGame|A medieval chess set: ornate wooden board with carved pieces, half through a game, ivory and dark wood pieces, hand-painted look, top-down 45-degree perspective, warm earthy colors, soft top-down lighting, square composition centered, transparent background, soft shadow, weathered look, 256x256, no text, no border"
    "CardDeck|A deck of medieval playing cards: hand-painted court cards king queen jack fanned out, weathered edges, hand-painted look, top-down 45-degree perspective, warm earthy colors, soft top-down lighting, square composition centered, transparent background, soft shadow, weathered look, 256x256, no text, no border"
    "Domino|A set of medieval bone dominoes with black pips, arranged in a snake pattern on a wooden table, hand-painted look, top-down 45-degree perspective, warm earthy colors (cream bone, dark wood, black pips), soft top-down lighting, square composition centered, transparent background, soft shadow, weathered look, 256x256, no text, no border"
    "DollHouse|A miniature medieval timber-framed dollhouse, with tiny furniture visible through open windows, weathered wood, hand-painted look, top-down 45-degree perspective, warm earthy colors, soft top-down lighting, square composition centered, transparent background, soft shadow, weathered look, 256x256, no text, no border"
    "Calendar|A medieval perpetual calendar: a circular wooden disk with rotating inner wheel, zodiac symbols, brass fittings, hand-painted look, top-down 45-degree perspective, warm earthy colors (wood, brass, gold), soft top-down lighting, square composition centered, transparent background, soft shadow, weathered look, 256x256, no text, no border"
    "ClockFacePainter|A medieval clock face: a brass disk with Roman numerals, ornate hands, decorative scrollwork around the edge, hand-painted look, top-down 45-degree perspective, warm earthy colors (brass, gold, dark patina), soft top-down lighting, square composition centered, transparent background, soft shadow, weathered look, 256x256, no text, no border"
    "Candelabra|A 5-armed medieval brass candelabra with all candles lit, ornate scrollwork, warm glow, soft shadows, hand-painted look, top-down 45-degree perspective, warm earthy colors (brass, gold, amber flame), soft top-down lighting, square composition centered, transparent background, soft shadow, weathered look, 256x256, no text, no border"
    "CrystalGoblet|A medieval crystal goblet with red wine, faceted glass catching light, ornate silver base, on a dark surface, hand-painted look, top-down 45-degree perspective, warm earthy colors (crystal, silver, deep red wine), soft top-down lighting, square composition centered, transparent background, soft shadow, weathered look, 256x256, no text, no border"
    "Drummer|A medieval drum with wooden frame and leather head, two drumsticks crossed on top, decorative red trim, hand-painted look, top-down 45-degree perspective, warm earthy colors (wood, leather, red trim), soft top-down lighting, square composition centered, transparent background, soft shadow, weathered look, 256x256, no text, no border"
    "Flute|A medieval wooden flute with brass fittings, carved with decorative patterns, lying diagonally, hand-painted look, top-down 45-degree perspective, warm earthy colors (dark wood, brass), soft top-down lighting, square composition centered, transparent background, soft shadow, weathered look, 256x256, no text, no border"
    "Fiddle|A medieval fiddle with a curved bow, wooden body, gut strings, ornate scroll at the neck, hand-painted look, top-down 45-degree perspective, warm earthy colors (warm wood, amber), soft top-down lighting, square composition centered, transparent background, soft shadow, weathered look, 256x256, no text, no border"
    "Crumhorn|A medieval crumhorn: a curved wooden wind instrument with a brass reed cap, dark wood with decorative carving, hand-painted look, top-down 45-degree perspective, warm earthy colors (dark wood, brass), soft top-down lighting, square composition centered, transparent background, soft shadow, weathered look, 256x256, no text, no border"
    "Cymbal|A pair of medieval brass finger cymbals with leather straps, ornate engraved pattern, slightly tarnished, hand-painted look, top-down 45-degree perspective, warm earthy colors (brass, gold), soft top-down lighting, square composition centered, transparent background, soft shadow, weathered look, 256x256, no text, no border"
    "Confectioner|An assortment of medieval sweets: marzipan fruits, honeyed nuts, and candied citrus peel on a small silver tray, hand-painted look, top-down 45-degree perspective, warm earthy colors (gold, amber, silver), soft top-down lighting, square composition centered, transparent background, soft shadow, weathered look, 256x256, no text, no border"
    "ButterChurner|A wooden butter churn with a wooden plunger, butter pat on a wooden board beside it, churned cream visible, hand-painted look, top-down 45-degree perspective, warm earthy colors (wood, cream), soft top-down lighting, square composition centered, transparent background, soft shadow, weathered look, 256x256, no text, no border"
    "Cheese|A wheel of aged medieval cheese with a rind, cut to show interior, with a cheese knife, on a wooden board, hand-painted look, top-down 45-degree perspective, warm earthy colors (golden cheese, wood), soft top-down lighting, square composition centered, transparent background, soft shadow, weathered look, 256x256, no text, no border"
    "CiderPress|A wooden cider press with a screw mechanism, crushed apples visible, juice flowing into a bucket, hand-painted look, top-down 45-degree perspective, warm earthy colors (wood, red apples, amber juice), soft top-down lighting, square composition centered, transparent background, soft shadow, weathered look, 256x256, no text, no border"
    "CoffeeRoaster|A medieval coffee roasting pan: a long-handled iron pan with green and roasted coffee beans, smoke rising, hand-painted look, top-down 45-degree perspective, warm earthy colors (dark iron, brown beans), soft top-down lighting, square composition centered, transparent background, soft shadow, weathered look, 256x256, no text, no border"
    "FishSmoker|A wooden fish smoking rack with 3 hanging smoked fish, small fire underneath, smoke wisps, hand-painted look, top-down 45-degree perspective, warm earthy colors (wood, silver fish, smoke), soft top-down lighting, square composition centered, transparent background, soft shadow, weathered look, 256x256, no text, no border"
    "Fisherman|A wooden fishing rod with a brass reel, a wicker basket with fish, a coil of rope, hand-painted look, top-down 45-degree perspective, warm earthy colors (wood, brass, silver fish), soft top-down lighting, square composition centered, transparent background, soft shadow, weathered look, 256x256, no text, no border"
    "FishingRod|A medieval fishing rod made of bamboo, with a bone handle, brass hooks, and a line wound around a wooden spool, hand-painted look, top-down 45-degree perspective, warm earthy colors (bamboo, bone, brass), soft top-down lighting, square composition centered, transparent background, soft shadow, weathered look, 256x256, no text, no border"
    "CanvasWeaver|A medieval loom with half-woven canvas, wooden frame, shuttle visible, woven cloth in earthy tones, hand-painted look, top-down 45-degree perspective, warm earthy colors (wood, tan cloth), soft top-down lighting, square composition centered, transparent background, soft shadow, weathered look, 256x256, no text, no border"
    "CarpetLoom|An ornate oriental rug on a wooden loom, intricate geometric patterns in reds and golds, half-rolled, hand-painted look, top-down 45-degree perspective, warm earthy colors (red, gold, dark wood), soft top-down lighting, square composition centered, transparent background, soft shadow, weathered look, 256x256, no text, no border"
    "Crocheter|A wooden crochet hook with a half-finished doily in cream thread, a ball of yarn beside it, hand-painted look, top-down 45-degree perspective, warm earthy colors (wood, cream), soft top-down lighting, square composition centered, transparent background, soft shadow, weathered look, 256x256, no text, no border"
    "Bobbin|Wooden bobbins wound with colored thread red blue green arranged in a stack with a thimble on top, hand-painted look, top-down 45-degree perspective, warm earthy colors (wood, red blue green thread, brass thimble), soft top-down lighting, square composition centered, transparent background, soft shadow, weathered look, 256x256, no text, no border"
    "Curtain|Heavy medieval velvet curtains in deep crimson, drawn back with a gold tassel cord, brass rod visible, hand-painted look, top-down 45-degree perspective, warm earthy colors (crimson, gold, brass), soft top-down lighting, square composition centered, transparent background, soft shadow, weathered look, 256x256, no text, no border"
    "Furrier|A pile of medieval furs: fox pelts, rabbit skins, and a beaver pelt, arranged on a wooden table, hand-painted look, top-down 45-degree perspective, warm earthy colors (brown fur, wood), soft top-down lighting, square composition centered, transparent background, soft shadow, weathered look, 256x256, no text, no border"
    "DyeStuff|Bundles of dried dye plants: woad blue madder red weld yellow tied with twine in a basket, hand-painted look, top-down 45-degree perspective, warm earthy colors (blue red yellow plants, wood basket), soft top-down lighting, square composition centered, transparent background, soft shadow, weathered look, 256x256, no text, no border"
    "Brick|A stack of handmade medieval clay bricks, reddish-orange, with straw imprints, weathered edges, hand-painted look, top-down 45-degree perspective, warm earthy colors (red-orange clay, straw), soft top-down lighting, square composition centered, transparent background, soft shadow, weathered look, 256x256, no text, no border"
    "ClayDigger|A wooden shovel stuck in a pile of grey clay, with a wicker basket beside it, muddy ground, hand-painted look, top-down 45-degree perspective, warm earthy colors (wood, grey clay), soft top-down lighting, square composition centered, transparent background, soft shadow, weathered look, 256x256, no text, no border"
    "CharcoalBurner|A medieval charcoal burner mound: a smoking earth mound with a wooden air vent, surrounded by split logs, hand-painted look, top-down 45-degree perspective, warm earthy colors (dark earth, black charcoal, wood), soft top-down lighting, square composition centered, transparent background, soft shadow, weathered look, 256x256, no text, no border"
    "CookwareFounder|A set of medieval copper cooking pots: a large cauldron, a saucepan, and a ladle, arranged diagonally, weathered patina, hand-painted look, top-down 45-degree perspective, warm earthy colors (copper, brass, patina), soft top-down lighting, square composition centered, transparent background, soft shadow, weathered look, 256x256, no text, no border"
    "CottonGin|A medieval cotton gin: a wooden hand-cranked machine with rollers, cotton fibers visible, on a wooden frame, hand-painted look, top-down 45-degree perspective, warm earthy colors (wood, white cotton), soft top-down lighting, square composition centered, transparent background, soft shadow, weathered look, 256x256, no text, no border"
    "AloeCultivator|A wooden planter with three aloe vera plants in terra cotta pots, a small bronze trowel beside them, hand-painted look, top-down 45-degree perspective, warm earthy colors (green plants, terra cotta, wood), soft top-down lighting, square composition centered, transparent background, soft shadow, weathered look, 256x256, no text, no border"
    "ApiaryKeeper|A medieval woven beehive skep with a wooden base, bees flying around, honeycomb visible at the entrance, hand-painted look, top-down 45-degree perspective, warm earthy colors (woven straw, golden honey), soft top-down lighting, square composition centered, transparent background, soft shadow, weathered look, 256x256, no text, no border"
    "AviaryKeeper|A medieval birdcage with a falcon inside, ornate ironwork, perch with leather jess, decorative top, hand-painted look, top-down 45-degree perspective, warm earthy colors (iron, leather, brown falcon), soft top-down lighting, square composition centered, transparent background, soft shadow, weathered look, 256x256, no text, no border"
    "ButterflyBreeder|A collection of pinned medieval butterflies in a wooden display case: 6 species, hand-written Latin labels, hand-painted look, top-down 45-degree perspective, warm earthy colors (wood, colorful butterflies), soft top-down lighting, square composition centered, transparent background, soft shadow, weathered look, 256x256, no text, no border"
    "CattleRancher|A medieval brown cow with horns, standing in profile, branding visible on flank, in a wooden pen, hand-painted look, top-down 45-degree perspective, warm earthy colors (brown cow, wood), soft top-down lighting, square composition centered, transparent background, soft shadow, weathered look, 256x256, no text, no border"
    "BeakerBlower|A medieval glassblower setup: a long blowpipe with a molten glass bulb at the end, glowing orange-red, on a wooden stand, hand-painted look, top-down 45-degree perspective, warm earthy colors (orange glow, wood, iron), soft top-down lighting, square composition centered, transparent background, soft shadow, weathered look, 256x256, no text, no border"
    "CommemorativeToken|A medieval commemorative coin: gold with a king profile on obverse, castle on reverse, ornate border, hand-painted look, top-down 45-degree perspective, warm earthy colors (gold, bronze), soft top-down lighting, square composition centered, transparent background, soft shadow, weathered look, 256x256, no text, no border"
)

echo "Found ${#SPRITES[@]} sprite definitions"
echo ""

# ============================================================
# Process each sprite
# ============================================================

for sprite_def in "${SPRITES[@]}"; do
    # Parse name and prompt
    NAME="${sprite_def%%|*}"
    PROMPT="${sprite_def#*|}"
    OUTPUT="${TIER1_DIR}/${NAME}.png"

    # Check if already exists
    if [ -f "${OUTPUT}" ]; then
        # Check if it's already a proper PNG (not JPEG)
        HEADER=$(head -c 4 "${OUTPUT}" 2>/dev/null | xxd -p 2>/dev/null | head -c 8)
        if [ "${HEADER}" = "89504e47" ]; then
            echo "  SKIP ${NAME}.png (already exists as PNG)"
            SKIPPED=$((SKIPPED + 1))
            continue
        fi
    fi

    # Check if we've reached max count
    if [ ${GENERATED} -ge ${MAX_COUNT} ]; then
        echo "  Reached max count (${MAX_COUNT}), stopping"
        break
    fi

    echo "  Generating ${NAME}.png..."

    # Step 1: AI generate
    if z-ai image -p "${PROMPT}" -o "${OUTPUT}" -s 1024x1024 > /dev/null 2>&1; then
        # Step 2: Convert JPEG → PNG with alpha
        python3 "${SCRIPTS_DIR}/convert_sprites_to_png.py" > /dev/null 2>&1

        # Verify it's now a proper PNG
        HEADER=$(head -c 4 "${OUTPUT}" 2>/dev/null | xxd -p 2>/dev/null | head -c 8)
        if [ "${HEADER}" = "89504e47" ]; then
            SIZE=$(du -h "${OUTPUT}" | cut -f1)
            echo "    ✓ ${NAME}.png (${SIZE})"
            GENERATED=$((GENERATED + 1))
        else
            echo "    ✗ Conversion failed for ${NAME}.png"
            FAILED=$((FAILED + 1))
        fi
    else
        echo "    ✗ AI generation failed for ${NAME}.png"
        FAILED=$((FAILED + 1))
        # Remove failed file
        rm -f "${OUTPUT}"
    fi

    # Small delay to avoid rate limiting
    sleep 1
done

# ============================================================
# Summary
# ============================================================

echo ""
echo "=========================================="
echo "  SPRITE GENERATION COMPLETE"
echo "=========================================="
echo "  Generated: ${GENERATED}"
echo "  Skipped (already existed): ${SKIPPED}"
echo "  Failed: ${FAILED}"
echo "  Total Tier 1 sprites: $(ls ${TIER1_DIR}/*.png 2>/dev/null | wc -l)"
echo "=========================================="

if [ ${GENERATED} -gt 0 ]; then
    echo ""
    echo "Next steps:"
    echo "  1. Review generated sprites visually"
    echo "  2. git add -A && git commit -m 'feat: Tier 1 sprite batch (${GENERATED} sprites)'"
    echo "  3. git push origin main"
fi
