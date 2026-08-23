#!/usr/bin/env python3
"""
Convert AI-generated JPEG sprites to PNG with alpha channel.
Removes near-white background and makes it transparent.
Also resizes to 256x256 if needed.
"""
import sys
from pathlib import Path
from PIL import Image

TILE_DIR = Path("/home/z/my-project/castlekingdoms2027/assets/royal_systems/tier1")
TARGET_SIZE = 256  # Final sprite size
WHITE_THRESHOLD = 245  # Pixels brighter than this are considered background

def convert_to_png_alpha(input_path: Path, output_path: Path = None):
    """Convert JPEG to PNG with transparent background."""
    if output_path is None:
        output_path = input_path  # overwrite
    
    # Open JPEG
    img = Image.open(input_path).convert("RGBA")
    
    # Resize to 256x256 if needed
    if img.size != (TARGET_SIZE, TARGET_SIZE):
        img = img.resize((TARGET_SIZE, TARGET_SIZE), Image.LANCZOS)
    
    # Get pixel data
    pixels = img.load()
    width, height = img.size
    
    # Make near-white pixels transparent (background removal)
    for y in range(height):
        for x in range(width):
            r, g, b, a = pixels[x, y]
            # If pixel is near-white (all channels above threshold), make transparent
            if r >= WHITE_THRESHOLD and g >= WHITE_THRESHOLD and b >= WHITE_THRESHOLD:
                pixels[x, y] = (r, g, b, 0)  # Set alpha to 0
    
    # Save as PNG (overwrites the JPEG file with PNG)
    img.save(output_path, "PNG")
    print(f"  ✓ Converted {input_path.name}: {TARGET_SIZE}x{TARGET_SIZE}, alpha channel added")
    return output_path

def main():
    print("=== JPEG → PNG with alpha conversion ===")
    
    png_files = list(TILE_DIR.glob("*.png"))
    if not png_files:
        print("No .png files found in tier1 directory")
        return
    
    print(f"Found {len(png_files)} files to process")
    
    for png_file in png_files:
        # Check if it's actually a JPEG
        try:
            with open(png_file, 'rb') as f:
                header = f.read(4)
            if header[:3] == b'\xff\xd8\xff':
                # It's a JPEG, convert
                print(f"\nProcessing {png_file.name} (JPEG detected)...")
                convert_to_png_alpha(png_file)
            elif header[:8] == b'\x89PNG\r\n\x1a\n':
                print(f"\nSkipping {png_file.name} (already PNG)")
            else:
                print(f"\nUnknown format: {png_file.name}")
        except Exception as e:
            print(f"  ✗ Error processing {png_file.name}: {e}")
    
    print(f"\n=== Done. Verify with: file {TILE_DIR}/*.png ===")

if __name__ == '__main__':
    main()
