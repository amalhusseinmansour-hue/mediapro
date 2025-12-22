from PIL import Image, ImageDraw, ImageFont, ImageFilter
import os

base_path = r"C:\Users\HP\social_media_manager"
logo_path = os.path.join(base_path, "assets", "logo.jpeg")
output_path = os.path.join(base_path, "store_assets")

logo = Image.open(logo_path)

def create_gradient_bg(width, height, color1, color2):
    """Create a gradient background"""
    img = Image.new('RGB', (width, height))
    for y in range(height):
        ratio = y / height
        r = int(color1[0] * (1 - ratio) + color2[0] * ratio)
        g = int(color1[1] * (1 - ratio) + color2[1] * ratio)
        b = int(color1[2] * (1 - ratio) + color2[2] * ratio)
        for x in range(width):
            img.putpixel((x, y), (r, g, b))
    return img

def draw_rounded_rect(draw, coords, radius, fill):
    """Draw a rounded rectangle"""
    x1, y1, x2, y2 = coords
    draw.rectangle([x1 + radius, y1, x2 - radius, y2], fill=fill)
    draw.rectangle([x1, y1 + radius, x2, y2 - radius], fill=fill)
    draw.ellipse([x1, y1, x1 + radius * 2, y1 + radius * 2], fill=fill)
    draw.ellipse([x2 - radius * 2, y1, x2, y1 + radius * 2], fill=fill)
    draw.ellipse([x1, y2 - radius * 2, x1 + radius * 2, y2], fill=fill)
    draw.ellipse([x2 - radius * 2, y2 - radius * 2, x2, y2], fill=fill)

def create_screenshot(title, subtitle, features, filename, accent_color):
    """Create a promotional screenshot"""
    width, height = 1080, 1920

    # Create gradient background
    img = create_gradient_bg(width, height, (20, 20, 40), (40, 20, 60))
    draw = ImageDraw.Draw(img)

    try:
        font_title = ImageFont.truetype("arial.ttf", 56)
        font_subtitle = ImageFont.truetype("arial.ttf", 32)
        font_feature = ImageFont.truetype("arial.ttf", 36)
        font_small = ImageFont.truetype("arial.ttf", 28)
    except:
        font_title = ImageFont.load_default()
        font_subtitle = font_title
        font_feature = font_title
        font_small = font_title

    # Add logo at top
    logo_small = logo.resize((180, 180), Image.Resampling.LANCZOS)
    img.paste(logo_small, ((width - 180) // 2, 80))

    # Title
    bbox = draw.textbbox((0, 0), title, font=font_title)
    title_width = bbox[2] - bbox[0]
    draw.text(((width - title_width) // 2, 300), title, fill=(255, 255, 255), font=font_title)

    # Subtitle
    bbox = draw.textbbox((0, 0), subtitle, font=font_subtitle)
    subtitle_width = bbox[2] - bbox[0]
    draw.text(((width - subtitle_width) // 2, 380), subtitle, fill=accent_color, font=font_subtitle)

    # Feature cards
    card_y = 500
    for i, feature in enumerate(features):
        # Card background
        card_x = 60
        card_width = width - 120
        card_height = 160

        draw_rounded_rect(draw, (card_x, card_y, card_x + card_width, card_y + card_height), 20, (30, 30, 50))

        # Feature icon circle
        circle_x = card_x + 40
        circle_y = card_y + (card_height - 80) // 2
        draw.ellipse([circle_x, circle_y, circle_x + 80, circle_y + 80], fill=accent_color)

        # Feature number
        num_text = str(i + 1)
        bbox = draw.textbbox((0, 0), num_text, font=font_title)
        num_width = bbox[2] - bbox[0]
        draw.text((circle_x + (80 - num_width) // 2, circle_y + 10), num_text, fill=(255, 255, 255), font=font_title)

        # Feature text
        text_x = circle_x + 110
        text_y = card_y + (card_height - 60) // 2
        draw.text((text_x, text_y), feature["title"], fill=(255, 255, 255), font=font_feature)
        draw.text((text_x, text_y + 45), feature["desc"], fill=(150, 150, 170), font=font_small)

        card_y += card_height + 30

    # Bottom tagline
    tagline = "Download Now - Free!"
    bbox = draw.textbbox((0, 0), tagline, font=font_subtitle)
    tagline_width = bbox[2] - bbox[0]
    draw.text(((width - tagline_width) // 2, height - 150), tagline, fill=accent_color, font=font_subtitle)

    img.save(os.path.join(output_path, filename), "PNG")
    print(f"Created: {filename}")

# Screenshot 1: AI Content Generation
create_screenshot(
    "AI Content Creation",
    "Generate amazing content instantly",
    [
        {"title": "Smart Text Generation", "desc": "AI-powered captions & posts"},
        {"title": "Image Generation", "desc": "Create stunning visuals with AI"},
        {"title": "Video Creation", "desc": "Generate engaging video content"},
        {"title": "Multi-Language Support", "desc": "Content in any language"},
        {"title": "Tone Optimization", "desc": "Professional, casual, or fun"},
    ],
    "screenshot_01_ai_content.png",
    (100, 180, 255)
)

# Screenshot 2: Social Media Management
create_screenshot(
    "Manage All Accounts",
    "One app for all platforms",
    [
        {"title": "Facebook & Instagram", "desc": "Post to Meta platforms"},
        {"title": "Twitter / X", "desc": "Tweet and engage"},
        {"title": "LinkedIn", "desc": "Professional networking"},
        {"title": "TikTok", "desc": "Short-form video content"},
        {"title": "YouTube", "desc": "Video publishing"},
    ],
    "screenshot_02_platforms.png",
    (255, 100, 180)
)

# Screenshot 3: Analytics
create_screenshot(
    "Powerful Analytics",
    "Track your growth",
    [
        {"title": "Real-time Stats", "desc": "Live engagement metrics"},
        {"title": "Audience Insights", "desc": "Know your followers"},
        {"title": "Performance Reports", "desc": "Detailed analytics"},
        {"title": "Growth Tracking", "desc": "Monitor your progress"},
        {"title": "Export Reports", "desc": "PDF & Excel exports"},
    ],
    "screenshot_03_analytics.png",
    (100, 255, 180)
)

# Screenshot 4: Scheduling
create_screenshot(
    "Smart Scheduling",
    "Post at the perfect time",
    [
        {"title": "Calendar View", "desc": "Visual content calendar"},
        {"title": "Best Time to Post", "desc": "AI-optimized timing"},
        {"title": "Bulk Scheduling", "desc": "Schedule weeks ahead"},
        {"title": "Auto-Publishing", "desc": "Set it and forget it"},
        {"title": "Time Zone Support", "desc": "Global audience reach"},
    ],
    "screenshot_04_scheduling.png",
    (255, 180, 100)
)

# Screenshot 5: Pro Features
create_screenshot(
    "Pro Features",
    "Unlock your potential",
    [
        {"title": "Team Collaboration", "desc": "Work with your team"},
        {"title": "White Label", "desc": "Your brand, your app"},
        {"title": "API Access", "desc": "Developer integrations"},
        {"title": "Priority Support", "desc": "24/7 assistance"},
        {"title": "Unlimited Usage", "desc": "No restrictions"},
    ],
    "screenshot_05_pro.png",
    (180, 100, 255)
)

print("\n=== All Screenshots Created! ===")
print(f"Location: {output_path}")
