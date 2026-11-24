import os, sys
from PIL import Image, ImageDraw, ImageFilter, ImageFont, ImageEnhance
from test_phone_mockup import create_flagship_phone

BRAIN_DIR = '/Users/pritamsharma/.gemini/antigravity/brain/1924d82f-8c85-4f77-96d0-28de4bd5bc32'
FOOTAGE_DIR = '/Users/pritamsharma/Downloads/video_editor_app/play_store_assets/sample_footage'

canvas_w, canvas_h = 1080, 1920

# 1. Background: Ambient blurred footage
footage = Image.open(os.path.join(FOOTAGE_DIR, 'footage_hero_sunset.jpg')).convert('RGBA')
bg_ambient = footage.resize((canvas_w, canvas_h), Image.Resampling.LANCZOS)
bg_ambient = bg_ambient.filter(ImageFilter.GaussianBlur(100))

# Darken ambient
enhancer = ImageEnhance.Brightness(bg_ambient)
bg_ambient = enhancer.enhance(0.38)
sat_enhancer = ImageEnhance.Color(bg_ambient)
bg_ambient = sat_enhancer.enhance(1.4)

# Blend with deep navy studio base
dark_overlay = Image.new('RGBA', (canvas_w, canvas_h), (10, 12, 18, 140))
bg = Image.alpha_composite(bg_ambient, dark_overlay)

# Top gradient fade for header legibility
grad_fade = Image.new('RGBA', (canvas_w, canvas_h), (0, 0, 0, 0))
g_draw = ImageDraw.Draw(grad_fade)
for y in range(400):
    a = int(220 * (1.0 - (y / 400.0)**1.2))
    g_draw.line([(0, y), (canvas_w, y)], fill=(10, 12, 18, a))
bg = Image.alpha_composite(bg, grad_fade)

# 2. Get enhanced editor screen
screen_img = Image.open(os.path.join(BRAIN_DIR, 'enhanced_editor_test.png')).convert('RGBA')

# 3. Create 3D Flagship Phone Mockup
phone = create_flagship_phone(screen_img, target_w=870, target_h=1620, radius=52, bezel=14)

# 4. Multi-Layer Drop Shadow
phone_x, phone_y = 100, 310

# Contact shadow
c_shadow = Image.new('RGBA', (canvas_w, canvas_h), (0, 0, 0, 0))
p_alpha = phone.split()[-1]
c_fill = Image.new('RGBA', phone.size, (0, 0, 0, 210))
c_fill.putalpha(p_alpha)
c_shadow.paste(c_fill, (phone_x, phone_y + 15), c_fill)
c_shadow = c_shadow.filter(ImageFilter.GaussianBlur(25))
bg = Image.alpha_composite(bg, c_shadow)

# Diffuse ambient shadow
d_shadow = Image.new('RGBA', (canvas_w, canvas_h), (0, 0, 0, 0))
d_fill = Image.new('RGBA', phone.size, (0, 0, 0, 140))
d_fill.putalpha(p_alpha)
d_shadow.paste(d_fill, (phone_x, phone_y + 40), d_fill)
d_shadow = d_shadow.filter(ImageFilter.GaussianBlur(55))
bg = Image.alpha_composite(bg, d_shadow)

# Paste Phone
bg.paste(phone, (phone_x, phone_y), phone)

# 5. Floating Glassmorphism 3D Badge (popping out on right side of phone)
def create_floating_badge(icon_text, title_text, sub_text, bg_col, border_col):
    bw, bh = 320, 100
    card = Image.new('RGBA', (bw, bh), (0, 0, 0, 0))
    c_mask = Image.new('L', (bw * 2, bh * 2), 0)
    cm_draw = ImageDraw.Draw(c_mask)
    cm_draw.rounded_rectangle([0, 0, bw * 2, bh * 2], radius=32, fill=255)
    c_mask = c_mask.resize((bw, bh), Image.Resampling.LANCZOS)
    
    c_bg = Image.new('RGBA', (bw, bh), bg_col)
    c_bg.putalpha(c_mask)
    card = Image.alpha_composite(card, c_bg)
    
    cb_draw = ImageDraw.Draw(card)
    cb_draw.rounded_rectangle([1, 1, bw - 2, bh - 2], radius=16, outline=border_col, width=2)
    
    f_icon = ImageFont.truetype('/System/Library/Fonts/Supplemental/Arial Bold.ttf', 36)
    f_title = ImageFont.truetype('/System/Library/Fonts/Supplemental/Arial Bold.ttf', 24)
    f_sub = ImageFont.truetype('/System/Library/Fonts/Supplemental/Arial Bold.ttf', 18)
    
    cb_draw.text((22, 32), icon_text, font=f_icon, fill=(255, 255, 255))
    cb_draw.text((75, 26), title_text, font=f_title, fill=(255, 255, 255))
    cb_draw.text((75, 56), sub_text, font=f_sub, fill=(147, 197, 253))
    return card

badge_card = create_floating_badge("✂️", "Millisecond Split", "Precise Clip Trimming",
                                  (18, 22, 36, 235), (96, 165, 250, 220))

# Add shadow to badge
card_x, card_y = 690, 840
b_shadow = Image.new('RGBA', (canvas_w, canvas_h), (0, 0, 0, 0))
b_alpha = badge_card.split()[-1]
b_fill = Image.new('RGBA', badge_card.size, (0, 0, 0, 160))
b_fill.putalpha(b_alpha)
b_shadow.paste(b_fill, (card_x, card_y + 12), b_fill)
b_shadow = b_shadow.filter(ImageFilter.GaussianBlur(18))

bg = Image.alpha_composite(bg, b_shadow)
bg.paste(badge_card, (card_x, card_y), badge_card)

# 6. Top Typography & Pill Badges
draw = ImageDraw.Draw(bg)
f_title = ImageFont.truetype('/System/Library/Fonts/Supplemental/DIN Alternate Bold.ttf', 68)
f_sub = ImageFont.truetype('/System/Library/Fonts/Supplemental/Arial Bold.ttf', 32)
f_badge = ImageFont.truetype('/System/Library/Fonts/Supplemental/Arial Bold.ttf', 24)

# Pill badges
def render_pill(d, text, cx, y, bg_c, bd_c):
    bb = f_badge.getbbox(text)
    pw = (bb[2] - bb[0]) + 48
    ph = (bb[3] - bb[1]) + 20
    x = cx - pw // 2
    d.rounded_rectangle([x, y, x + pw, y + ph], radius=ph//2, fill=bg_c, outline=bd_c, width=2)
    d.text((x + 24, y + 10 - bb[1]), text, font=f_badge, fill=(255, 255, 255))
    return pw

p1_w = render_pill(draw, "⚡ 100% FREE VIP", 370, 60, (124, 58, 237, 180), (192, 132, 252, 240))
p2_w = render_pill(draw, "🚫 NO WATERMARK", 710, 60, (239, 68, 68, 180), (248, 113, 113, 240))

# Title
title = "PRO VIDEO EDITOR & MAKER"
t_bb = f_title.getbbox(title)
tw = t_bb[2] - t_bb[0]
draw.text(((canvas_w - tw)//2, 135), title, font=f_title, fill=(255, 255, 255))

# Subtitle
sub = "Multi-Track Timeline • Millisecond Precision Trimming"
s_bb = f_sub.getbbox(sub)
sw = s_bb[2] - s_bb[0]
draw.text(((canvas_w - sw)//2, 222), sub, font=f_sub, fill=(56, 189, 248))

out_path = '/Users/pritamsharma/.gemini/antigravity/brain/1924d82f-8c85-4f77-96d0-28de4bd5bc32/perfect_slide_1_test.png'
bg.convert('RGB').save(out_path, quality=95)
print("perfect_slide_1_test.png generated successfully!")
