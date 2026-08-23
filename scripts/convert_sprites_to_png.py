#!/usr/bin/env python3
"""
Convert AI-generated JPEG sprites to PNG with alpha channel.
Removes near-white background and makes it transparent.
Resizes to tier-appropriate size:
  - tier1: 256x256 (high-quality artist sprites)
  - tier2: 128x128 (AI-generated, lower detail)
"""
import sys
from pathlib import Path
from PIL import Image

PROJECT_ROOT = Path("/home/z/my-project/castlekingdoms2027")
TIERS = {
    "tier1": {
        "dir": PROJECT_ROOT / "assets" / "royal_systems" / "tier1",
        "size": 256,
    },
    "tier2": {
        "dir": PROJECT_ROOT / "assets" / "royal_systems" / "tier2",
        "size": 128,
    },
}
WHITE_THRESHOLD = 245  # Pixels brighter than this are considered background

def convert_to_png_alpha(input_path: Path, target_size: int, output_path: Path = None):
    """Convert JPEG to PNG with transparent background at specified size."""
    if output_path is None:
        output_path = input_path  # overwrite

    # Open JPEG
    img = Image.open(input_path).convert("RGBA")

    # Resize to target size
    if img.size != (target_size, target_size):
        img = img.resize((target_size, target_size), Image.LANCZOS)

    # Get pixel data
    pixels = img.load()
    width, height = img.size

    # Make near-white pixels transparent (background removal)
    for y in range(height):
        for x in range(width):
            r, g, b, a = pixels[x, y]
            if r >= WHITE_THRESHOLD and g >= WHITE_THRESHOLD and b >= WHITE_THRESHOLD:
                pixels[x, y] = (r, g, b, 0)

    img.save(output_path, "PNG")
    print(f"  ✓ Converted {input_path.name}: {target_size}x{target_size}, alpha channel added")
    return output_path

def process_tier(tier_name: str, tier_config: dict):
    """Process all PNG files in a tier directory."""
    tier_dir = tier_config["dir"]
    target_size = tier_config["size"]

    print(f"\n--- {tier_name.upper()} ({target_size}x{target_size}) ---")

    if not tier_dir.exists():
        print(f"  Directory not found: {tier_dir}")
        return

    png_files = list(tier_dir.glob("*.png"))
    if not png_files:
        print(f"  No .png files found")
        return

    print(f"  Found {len(png_files)} files")

    for png_file in png_files:
        try:
            with open(png_file, 'rb') as f:
                header = f.read(8)
            if header[:3] == b'\xff\xd8\xff':
                print(f"\n  Processing {png_file.name} (JPEG detected)...")
                convert_to_png_alpha(png_file, target_size)
            elif header[:4] == b'\x89PNG':
                # Already PNG — check size and resize if needed
                try:
                    check_img = Image.open(png_file)
                    if check_img.size != (target_size, target_size):
                        print(f"\n  Resizing {png_file.name} ({check_img.size[0]}x{check_img.size[1]} → {target_size}x{target_size})...")
                        check_img.close()
                        convert_to_png_alpha(png_file, target_size)
                    else:
                        check_img.close()
                        # already correct, skip silently
                except Exception as e:
                    print(f"  ✗ Error checking size {png_file.name}: {e}")
            else:
                print(f"\n  Unknown format: {png_file.name} (header: {header.hex()})")
        except Exception as e:
            print(f"  ✗ Error processing {png_file.name}: {e}")

def main():
    print("=== JPEG → PNG with alpha conversion (multi-tier) ===")

    # Process all tiers
    for tier_name, tier_config in TIERS.items():
        process_tier(tier_name, tier_config)

    print("\n=== Done ===")

if __name__ == '__main__':
    main()
