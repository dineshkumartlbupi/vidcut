import os, sys, math
from PIL import Image, ImageDraw, ImageFilter, ImageFont, ImageEnhance

BRAIN_DIR = '/Users/pritamsharma/.gemini/antigravity/brain/1924d82f-8c85-4f77-96d0-28de4bd5bc32'
ASSETS_DIR = '/Users/pritamsharma/Downloads/video_editor_app/play_store_assets'
DOWNLOADS_DIR = '/Users/pritamsharma/Downloads/VidCut_PlayStore_Assets'

FONT_TITLE = '/System/Library/Fonts/Supplemental/DIN Alternate Bold.ttf'
FONT_SUB = '/System/Library/Fonts/Supplemental/Arial Bold.ttf'
FONT_BADGE = '/System/Library/Fonts/Supplemental/Arial Bold.ttf'

w, h = 1024, 500

# 1. Background from real device editor screen
real_screen = Image.open(os.path.join(BRAIN_DIR, 'real_device_editor.png')).convert('RGBA')
bg = real_screen.resize((w, h), Image.Resampling.LANCZOS)
bg = bg.filter(ImageFilter.GaussianBlur(85))
bg = ImageEnhance.Brightness(bg).enhance(0.28)
bg = ImageEnhance.Color(bg).enhance(1.4)

dark_overlay = Image.new('RGBA', (w, h), (10, 12, 18, 160))
bg = Image.alpha_composite(bg, dark_overlay)

def add_spotlight(canvas, cx, cy, radius, color):
    layer = Image.new('RGBA', (w, h), (0, 0, 0, 0))
    d = ImageDraw.Draw(layer)
    for i in range(30, 0, -1):
        cur_r = int(radius * (i / 30))
        alpha = int(color[3] * (1.0 - (i / 30))**1.7)
        d.ellipse([cx - cur_r, cy - cur_r, cx + cur_r, cy + cur_r], fill=(color[0], color[1], color[2], alpha))
    layer = layer.filter(ImageFilter.GaussianBlur(30))
    return Image.alpha_composite(canvas, layer)

bg = add_spotlight(bg, 800, 250, 400, (124, 58, 237, 140)) # Violet
bg = add_spotlight(bg, 960, 100, 280, (6, 182, 212, 100))   # Cyan
bg = add_spotlight(bg, 250, 250, 360, (124, 58, 237, 60))   # Ambient left

# 2. Right Phone Mockup with Real Screen
pw, ph = 390, 750
phone_screen = real_screen.resize((pw, ph), Image.Resampling.LANCZOS)

# Create phone body
p_frame = Image.new('RGBA', (pw + 24, ph + 24), (0, 0, 0, 0))
pf_mask = Image.new('L', ((pw + 24)*2, (ph + 24)*2), 0)
pf_draw = ImageDraw.Draw(pf_mask)
pf_draw.rounded_rectangle([0, 0, (pw + 24)*2, (ph + 24)*2], radius=48, fill=255)
pf_mask = pf_mask.resize((pw + 24, ph + 24), Image.Resampling.LANCZOS)

pf_bg = Image.new('RGBA', (pw + 24, ph + 24), (20, 22, 28, 255))
pf_bg.putalpha(pf_mask)

# Screen rounded
ps_mask = Image.new('L', (pw*2, ph*2), 0)
ps_draw = ImageDraw.Draw(ps_mask)
ps_draw.rounded_rectangle([0, 0, pw*2, ph*2], radius=36, fill=255)
ps_mask = ps_mask.resize((pw, ph), Image.Resampling.LANCZOS)
phone_screen.putalpha(ps_mask)

p_frame = Image.alpha_composite(p_frame, pf_bg)
p_frame.paste(phone_screen, (12, 12), phone_screen)

# Metallic rim border
pb_draw = ImageDraw.Draw(p_frame)
pb_draw.rounded_rectangle([1, 1, pw + 22, ph + 22], radius=24, outline=(85, 95, 115, 230), width=2)
# Punch hole
pb_draw.rounded_rectangle([(pw+24)//2 - 38, 18, (pw+24)//2 + 38, 34], radius=8, fill=(10, 10, 14, 255))

# Rotate 3D (6 degrees)
rotated_phone = p_frame.rotate(6, expand=True, resample=Image.Resampling.BICUBIC)

# Drop shadow
shadow_canvas = Image.new('RGBA', (w, h), (0, 0, 0, 0))
s_alpha = rotated_phone.split()[-1]
s_fill = Image.new('RGBA', rotated_phone.size, (0, 0, 0, 220))
s_fill.putalpha(s_alpha)
shadow_pos = (610, -50)
shadow_canvas.paste(s_fill, shadow_pos, s_fill)
shadow_canvas = shadow_canvas.filter(ImageFilter.GaussianBlur(35))

bg = Image.alpha_composite(bg, shadow_canvas)
bg.paste(rotated_phone, (610, -50), rotated_phone)

# 3. Left Branding & Bullet Points
draw = ImageDraw.Draw(bg)

# App Logo Squircle Icon
draw.rounded_rectangle([60, 52, 138, 130], radius=20, fill=(124, 58, 237, 255), outline=(192, 132, 252, 230), width=2)
draw.polygon([(88, 74), (88, 110), (116, 92)], fill=(255, 255, 255))

# App Title
f_brand = ImageFont.truetype(FONT_TITLE, 70)
draw.text((158, 56), "VidCut", font=f_brand, fill=(255, 255, 255))

# Subtitle
f_sub = ImageFont.truetype(FONT_SUB, 24)
draw.text((62, 160), "PRO VIDEO EDITOR & REELS MAKER", font=f_sub, fill=(56, 189, 248))

# Value Proposition line
f_desc = ImageFont.truetype(FONT_SUB, 18)
desc_lines = [
    "• 1-Tap Cinematic Transitions & Velocity Curves",
    "• Extract Audio from Any Video & 1-Tap Mute",
    "• Photos to Video Reels with Trending Music",
    "• Crystal Clear 4K 60FPS Ultra HD Export"
]
for idx, line in enumerate(desc_lines):
    draw.text((62, 215 + idx * 34), line, font=f_desc, fill=(226, 232, 240))

# Badges at bottom
def render_feat_badge(d, text, x, y, bg_col, border_col):
    f_b = ImageFont.truetype(FONT_BADGE, 18)
    bb = f_b.getbbox(text)
    bw = (bb[2] - bb[0]) + 32
    bh = (bb[3] - bb[1]) + 16
    d.rounded_rectangle([x, y, x + bw, y + bh], radius=bh//2, fill=bg_col, outline=border_col, width=2)
    d.text((x + 16, y + 8 - bb[1]), text, font=f_b, fill=(255, 255, 255))
    return bw

b1_w = render_feat_badge(draw, "⚡ 100% FREE VIP", 62, 385, (124, 58, 237, 180), (192, 132, 252, 240))
b2_w = render_feat_badge(draw, "🚫 NO WATERMARK", 62 + b1_w + 14, 385, (239, 68, 68, 180), (248, 113, 113, 240))
b3_w = render_feat_badge(draw, "💎 4K 60FPS", 62 + b1_w + 14 + b2_w + 14, 385, (5, 150, 105, 180), (52, 211, 153, 240))

out_path = os.path.join(ASSETS_DIR, 'feature_graphic_1024x500.png')
bg.convert('RGB').save(out_path, quality=96)
bg.convert('RGB').save(os.path.join(DOWNLOADS_DIR, 'feature_graphic_1024x500.png'), quality=96)
bg.convert('RGB').save(os.path.join(BRAIN_DIR, 'feature_graphic_1024x500.png'), quality=96)
print("Feature Graphic with real device screenshot generated successfully!")
