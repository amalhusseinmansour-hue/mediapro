from PIL import Image, ImageDraw, ImageFont, ImageFilter
import os

# Paths
base_path = r"C:\Users\HP\social_media_manager"
logo_path = os.path.join(base_path, "assets", "logo.jpeg")
output_path = os.path.join(base_path, "store_assets")

# Ensure output directory exists
os.makedirs(output_path, exist_ok=True)

# Load original logo
logo = Image.open(logo_path)
print(f"Original logo size: {logo.size}")

# 1. Create App Icon 512x512
print("Creating app icon 512x512...")
icon = logo.copy()
icon = icon.resize((512, 512), Image.Resampling.LANCZOS)
icon_path = os.path.join(output_path, "app_icon_512x512.png")
icon.save(icon_path, "PNG")
print(f"Saved: {icon_path}")

# 2. Create Feature Graphic 1024x500
print("Creating feature graphic 1024x500...")
feature = Image.new('RGB', (1024, 500), color=(15, 15, 25))

# Create gradient background
for y in range(500):
    for x in range(1024):
        # Gradient from dark blue to purple
        r = int(20 + (x / 1024) * 40)
        g = int(10 + (y / 500) * 20)
        b = int(40 + (x / 1024) * 60 + (y / 500) * 30)
        feature.putpixel((x, y), (r, g, b))

# Add logo to center
logo_small = logo.resize((300, 300), Image.Resampling.LANCZOS)
logo_x = (1024 - 300) // 2
logo_y = (500 - 300) // 2 - 30
feature.paste(logo_small, (logo_x, logo_y))

# Add text
draw = ImageDraw.Draw(feature)
try:
    # Try to use a nice font
    font_large = ImageFont.truetype("arial.ttf", 36)
    font_small = ImageFont.truetype("arial.ttf", 20)
except:
    font_large = ImageFont.load_default()
    font_small = ImageFont.load_default()

# App name
text = "Media Pro Social"
bbox = draw.textbbox((0, 0), text, font=font_large)
text_width = bbox[2] - bbox[0]
draw.text(((1024 - text_width) // 2, 380), text, fill=(255, 255, 255), font=font_large)

# Tagline
tagline = "AI-Powered Social Media Management"
bbox = draw.textbbox((0, 0), tagline, font=font_small)
tagline_width = bbox[2] - bbox[0]
draw.text(((1024 - tagline_width) // 2, 430), tagline, fill=(150, 180, 255), font=font_small)

feature_path = os.path.join(output_path, "feature_graphic_1024x500.png")
feature.save(feature_path, "PNG")
print(f"Saved: {feature_path}")

# 3. Create Phone Screenshot Mockup Background (1080x1920)
print("Creating screenshot background 1080x1920...")
screenshot_bg = Image.new('RGB', (1080, 1920), color=(15, 15, 25))

# Create gradient
for y in range(1920):
    for x in range(1080):
        r = int(15 + (y / 1920) * 25)
        g = int(10 + (x / 1080) * 15)
        b = int(35 + (y / 1920) * 45)
        screenshot_bg.putpixel((x, y), (r, g, b))

# Add logo at top
logo_header = logo.resize((200, 200), Image.Resampling.LANCZOS)
screenshot_bg.paste(logo_header, ((1080 - 200) // 2, 100))

screenshot_path = os.path.join(output_path, "screenshot_background_1080x1920.png")
screenshot_bg.save(screenshot_path, "PNG")
print(f"Saved: {screenshot_path}")

# 4. Create Hi-Res Icon 1024x1024 (for iOS/other stores)
print("Creating hi-res icon 1024x1024...")
icon_hires = logo.resize((1024, 1024), Image.Resampling.LANCZOS)
icon_hires_path = os.path.join(output_path, "app_icon_1024x1024.png")
icon_hires.save(icon_hires_path, "PNG")
print(f"Saved: {icon_hires_path}")

print("\n=== Store Assets Created Successfully! ===")
print(f"Location: {output_path}")
print("\nFiles created:")
print("1. app_icon_512x512.png - For Google Play Store")
print("2. app_icon_1024x1024.png - Hi-res icon")
print("3. feature_graphic_1024x500.png - Feature graphic for store")
print("4. screenshot_background_1080x1920.png - Background for screenshots")
