from PIL import Image
import os

# Paths
logo_path = "assets/logo.jpeg"
output_dir = "website_icons"

# Create output directory
os.makedirs(output_dir, exist_ok=True)

# Load logo
print("[INFO] Loading logo...")
logo = Image.open(logo_path)
logo = logo.convert('RGBA')

# Icon sizes for website
icon_sizes = {
    "favicon-16x16.png": 16,
    "favicon-32x32.png": 32,
    "favicon-48x48.png": 48,
    "apple-touch-icon.png": 180,
    "android-chrome-192x192.png": 192,
    "android-chrome-512x512.png": 512,
}

print("[INFO] Generating website icons...")
for filename, size in icon_sizes.items():
    resized = logo.resize((size, size), Image.Resampling.LANCZOS)
    output_path = os.path.join(output_dir, filename)
    resized.save(output_path, 'PNG', optimize=True)
    print(f"[SUCCESS] Created {filename} ({size}x{size})")

# Create favicon.ico (multi-resolution)
print("[INFO] Creating favicon.ico...")
favicon_sizes = [16, 32, 48]
favicon_images = []
for size in favicon_sizes:
    resized = logo.resize((size, size), Image.Resampling.LANCZOS)
    favicon_images.append(resized)

favicon_path = os.path.join(output_dir, "favicon.ico")
favicon_images[0].save(
    favicon_path,
    format='ICO',
    sizes=[(s, s) for s in favicon_sizes],
    append_images=favicon_images[1:]
)
print(f"[SUCCESS] Created favicon.ico")

# Copy original logo for use in website
logo_copy = os.path.join(output_dir, "logo.png")
logo.save(logo_copy, 'PNG', optimize=True)
print(f"[SUCCESS] Created logo.png")

print("\n[COMPLETE] All website icons created successfully!")
print(f"[INFO] Output directory: {output_dir}")
print(f"[INFO] Total files created: {len(icon_sizes) + 2}")
