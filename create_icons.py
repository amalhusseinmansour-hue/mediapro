#!/usr/bin/env python3
"""Create web app icons from logo"""

from PIL import Image
import os

# Input logo path
logo_path = "assets/logo.jpeg"

# Output directory
output_dir = "web/icons"

# Ensure output directory exists
os.makedirs(output_dir, exist_ok=True)

# Icon sizes needed for web app
icon_sizes = {
    "Icon-192.png": 192,
    "Icon-512.png": 512,
    "Icon-maskable-192.png": 192,
    "Icon-maskable-512.png": 512,
}

# Load the logo
try:
    logo = Image.open(logo_path)
    print(f"[OK] Loaded logo: {logo.size}")

    # Convert to RGBA if needed
    if logo.mode != 'RGBA':
        logo = logo.convert('RGBA')

    # Create each icon size
    for filename, size in icon_sizes.items():
        # Resize the logo
        resized = logo.resize((size, size), Image.Resampling.LANCZOS)

        # Save as PNG
        output_path = os.path.join(output_dir, filename)
        resized.save(output_path, 'PNG', optimize=True)
        print(f"[OK] Created: {filename} ({size}x{size})")

    # Also create favicon
    favicon = logo.resize((32, 32), Image.Resampling.LANCZOS)
    favicon.save("web/favicon.png", 'PNG', optimize=True)
    print(f"[OK] Created: favicon.png (32x32)")

    print("\n[SUCCESS] All icons created successfully!")

except Exception as e:
    print(f"[ERROR] Error: {e}")
