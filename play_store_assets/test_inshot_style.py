import os, sys, math
from PIL import Image, ImageDraw, ImageFilter, ImageFont, ImageEnhance

BRAIN_DIR = '/Users/pritamsharma/.gemini/antigravity/brain/1924d82f-8c85-4f77-96d0-28de4bd5bc32'
FOOTAGE_DIR = '/Users/pritamsharma/Downloads/video_editor_app/play_store_assets/sample_footage'

FONT_TITLE = '/System/Library/Fonts/Supplemental/DIN Alternate Bold.ttf'
FONT_SUB = '/System/Library/Fonts/Supplemental/Arial Bold.ttf'
FONT_BADGE = '/System/Library/Fonts/Supplemental/Arial Bold.ttf'

w, h = 1080, 1920

# 1. Background: High-contrast InShot/YouCut mesh gradient with ambient glow
bg = Image.new('RGBA', (w, h), (11, 14, 22, 255))
for y in range(h):
    r = int(10 + (22 - 10) * (y / h))
    g = int(12 + (24 - 12) * (y / h))
    b = int(18 + (38 - 18) * (y / h))
    ImageDraw.Draw(bg).line([(0, y), (w, y)], fill=(r, g, b, 255))

# Ambient glow spotlights
def add_radial_glow(canvas, cx, cy, rad, color):
    layer = Image.new('RGBA', canvas.size, (0, 0, 0, 0))
    d = ImageDraw.Draw(layer)
    for i in range(35, 0, -1):
        r = int(rad * (i / 35))
        a = int(color[3] * (1.0 - (i / 35))**1.7)
        d.ellipse([cx - r, cy - r, cx + r, cy + r], fill=(color[0], color[1], color[2], a))
    layer = layer.filter(ImageFilter.GaussianBlur(35))
    return Image.alpha_composite(canvas, layer)

bg = add_radial_glow(bg, 540, 1000, 700, (124, 58, 237, 110)) # Purple
bg = add_radial_glow(bg, 200, 320, 400, (6, 182, 212, 80))    # Cyan
bg = add_radial_glow(bg, 880, 450, 450, (236, 72, 153, 75))   # Magenta

print("Background ready")
