import os, sys, math
from PIL import Image, ImageDraw, ImageFilter, ImageFont

BRAIN_DIR = '/Users/pritamsharma/.gemini/antigravity/brain/1924d82f-8c85-4f77-96d0-28de4bd5bc32'
ASSETS_DIR = '/Users/pritamsharma/Downloads/video_editor_app/play_store_assets'

FONT_TITLE = '/System/Library/Fonts/Supplemental/DIN Alternate Bold.ttf'
FONT_SUB = '/System/Library/Fonts/Supplemental/Arial Bold.ttf'
FONT_BADGE = '/System/Library/Fonts/Supplemental/Arial Bold.ttf'
FONT_LOGO = '/System/Library/Fonts/HelveticaNeue.ttc'

w, h = 1024, 500
base = Image.new('RGBA', (w, h), (11, 14, 23, 255))

# Top-to-bottom subtle gradient
for y in range(h):
    ratio = y / float(h)
    r = int(11 + (22 - 11) * ratio)
    g = int(14 + (27 - 14) * ratio)
    b = int(23 + (45 - 23) * ratio)
    line = Image.new('RGBA', (w, 1), (r, g, b, 255))
    base.paste(line, (0, y))

# Add radial spotlights
def add_spotlight(canvas, cx, cy, radius, color):
    layer = Image.new('RGBA', (w, h), (0, 0, 0, 0))
    d = ImageDraw.Draw(layer)
    for i in range(30, 0, -1):
        cur_r = int(radius * (i / 30))
        alpha = int(color[3] * (1.0 - (i / 30))**1.7)
        d.ellipse([cx - cur_r, cy - cur_r, cx + cur_r, cy + cur_r], fill=(color[0], color[1], color[2], alpha))
    layer = layer.filter(ImageFilter.GaussianBlur(30))
    return Image.alpha_composite(canvas, layer)

base = add_spotlight(base, 780, 250, 360, (124, 58, 237, 120))  # Purple behind phone
base = add_spotlight(base, 920, 120, 260, (6, 182, 212, 90))   # Cyan top right
base = add_spotlight(base, 250, 250, 320, (124, 58, 237, 45))  # Left purple ambient

# Render Right Phone Mockup (Tilted / Angled)
editor_src = Image.open(os.path.join(BRAIN_DIR, 'novacut_editor_active_pro.png')).convert('RGBA')
ew, eh = editor_src.size

# Scale phone down for right half
pw, ph = 380, 720
phone_screen = editor_src.resize((pw, ph), Image.Resampling.LANCZOS)

# Create phone body
p_frame = Image.new('RGBA', (pw + 24, ph + 24), (0, 0, 0, 0))
pf_mask = Image.new('L', ((pw + 24)*2, (ph + 24)*2), 0)
pf_draw = ImageDraw.Draw(pf_mask)
pf_draw.rounded_rectangle([0, 0, (pw + 24)*2, (ph + 24)*2], radius=44, fill=255)
pf_mask = pf_mask.resize((pw + 24, ph + 24), Image.Resampling.LANCZOS)

pf_bg = Image.new('RGBA', (pw + 24, ph + 24), (20, 22, 28, 255))
pf_bg.putalpha(pf_mask)

# Screen rounded
ps_mask = Image.new('L', (pw*2, ph*2), 0)
ps_draw = ImageDraw.Draw(ps_mask)
ps_draw.rounded_rectangle([0, 0, pw*2, ph*2], radius=32, fill=255)
ps_mask = ps_mask.resize((pw, ph), Image.Resampling.LANCZOS)
phone_screen.putalpha(ps_mask)

p_frame = Image.alpha_composite(p_frame, pf_bg)
p_frame.paste(phone_screen, (12, 12), phone_screen)

# Border
pb_draw = ImageDraw.Draw(p_frame)
pb_draw.rounded_rectangle([1, 1, pw + 22, ph + 22], radius=22, outline=(70, 80, 105, 200), width=2)

# Punch hole
pb_draw.rounded_rectangle([(pw+24)//2 - 35, 18, (pw+24)//2 + 35, 34], radius=8, fill=(10, 10, 14, 255))

# Rotate phone slightly for 3D dynamic look (-7 degrees)
rotated_phone = p_frame.rotate(6, expand=True, resample=Image.Resampling.BICUBIC)

# Add heavy drop shadow for the phone
ps_w, ps_h = rotated_phone.size
shadow_canvas = Image.new('RGBA', (w, h), (0, 0, 0, 0))
s_alpha = rotated_phone.split()[-1]
s_fill = Image.new('RGBA', rotated_phone.size, (0, 0, 0, 200))
s_fill.putalpha(s_alpha)
shadow_pos = (610, -50)
shadow_canvas.paste(s_fill, shadow_pos, s_fill)
shadow_canvas = shadow_canvas.filter(ImageFilter.GaussianBlur(35))

base = Image.alpha_composite(base, shadow_canvas)
base.paste(rotated_phone, (610, -50), rotated_phone)

# Draw Left Branding
draw = ImageDraw.Draw(base)

# App Logo Squircle Icon
logo_box = [60, 55, 135, 130]
draw.rounded_rectangle(logo_box, radius=18, fill=(124, 58, 237, 255), outline=(192, 132, 252, 220), width=2)
# Draw play/scissor triangle inside icon
draw.polygon([(88, 75), (88, 110), (115, 92)], fill=(255, 255, 255))

# App Title
f_brand = ImageFont.truetype(FONT_TITLE, 64)
draw.text((155, 62), "VidCut", font=f_brand, fill=(255, 255, 255))

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

b1_w = render_feat_badge(draw, "⚡ 100% FREE VIP", 62, 385, (124, 58, 237, 90), (192, 132, 252, 220))
b2_w = render_feat_badge(draw, "🚫 NO WATERMARK", 62 + b1_w + 14, 385, (239, 68, 68, 90), (248, 113, 113, 220))
b3_w = render_feat_badge(draw, "💎 4K 60FPS", 62 + b1_w + 14 + b2_w + 14, 385, (5, 150, 105, 90), (52, 211, 153, 220))

out_path = os.path.join(ASSETS_DIR, 'feature_graphic_1024x500.png')
base.convert('RGB').save(out_path, quality=95)
print("Feature graphic generated successfully:", out_path)
