import os, sys, math
from PIL import Image, ImageDraw, ImageFilter, ImageFont, ImageEnhance
from test_phone_mockup import create_flagship_phone

BRAIN_DIR = '/Users/pritamsharma/.gemini/antigravity/brain/1924d82f-8c85-4f77-96d0-28de4bd5bc32'
FOOTAGE_DIR = '/Users/pritamsharma/Downloads/video_editor_app/play_store_assets/sample_footage'
OUT_DIR = '/Users/pritamsharma/Downloads/video_editor_app/play_store_assets/screenshots'
DOWNLOADS_OUT = '/Users/pritamsharma/Downloads/VidCut_PlayStore_Assets/screenshots'
os.makedirs(OUT_DIR, exist_ok=True)
os.makedirs(DOWNLOADS_OUT, exist_ok=True)

FONT_TITLE = '/System/Library/Fonts/Supplemental/DIN Alternate Bold.ttf'
FONT_SUB = '/System/Library/Fonts/Supplemental/Arial Bold.ttf'
FONT_BADGE = '/System/Library/Fonts/Supplemental/Arial Bold.ttf'
FONT_LOGO = '/System/Library/Fonts/HelveticaNeue.ttc'

CANVAS_W, CANVAS_H = 1080, 1920

def create_ambient_bg(footage_path, glow_color1, glow_color2, brightness=0.35, saturation=1.4):
    footage = Image.open(footage_path).convert('RGBA')
    bg = footage.resize((CANVAS_W, CANVAS_H), Image.Resampling.LANCZOS)
    bg = bg.filter(ImageFilter.GaussianBlur(100))
    bg = ImageEnhance.Brightness(bg).enhance(brightness)
    bg = ImageEnhance.Color(bg).enhance(saturation)
    
    # Blend with studio dark overlay
    dark_overlay = Image.new('RGBA', (CANVAS_W, CANVAS_H), (10, 12, 18, 140))
    bg = Image.alpha_composite(bg, dark_overlay)
    
    # Add radial colored spotlights
    def add_glow(base, cx, cy, rad, col):
        g_layer = Image.new('RGBA', (CANVAS_W, CANVAS_H), (0, 0, 0, 0))
        d = ImageDraw.Draw(g_layer)
        for i in range(30, 0, -1):
            r = int(rad * (i / 30))
            a = int(col[3] * (1.0 - (i / 30))**1.7)
            d.ellipse([cx - r, cy - r, cx + r, cy + r], fill=(col[0], col[1], col[2], a))
        g_layer = g_layer.filter(ImageFilter.GaussianBlur(40))
        return Image.alpha_composite(base, g_layer)
        
    bg = add_glow(bg, 540, 950, 650, glow_color1)
    bg = add_glow(bg, 250, 350, 350, glow_color2)
    
    # Top gradient fade for clear text legibility
    grad_fade = Image.new('RGBA', (CANVAS_W, CANVAS_H), (0, 0, 0, 0))
    g_draw = ImageDraw.Draw(grad_fade)
    for y in range(420):
        a = int(230 * (1.0 - (y / 420.0)**1.2))
        g_draw.line([(0, y), (CANVAS_W, y)], fill=(10, 12, 18, a))
    bg = Image.alpha_composite(bg, grad_fade)
    return bg

def fit_crop(img, tw, th):
    sw, sh = img.size
    scale = max(tw / float(sw), th / float(sh))
    nw, nh = int(sw * scale), int(sh * scale)
    scaled = img.resize((nw, nh), Image.Resampling.LANCZOS)
    cx = (nw - tw) // 2
    cy = (nh - th) // 2
    return scaled.crop((cx, cy, cx + tw, cy + th))

def create_floating_badge(icon_text, title_text, sub_text, bg_col, border_col):
    bw, bh = 330, 100
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

def assemble_screenshot_card(bg, screen_img, badge_card, badge_pos,
                             badge1_text, badge1_bg, badge1_border,
                             badge2_text, badge2_bg, badge2_border,
                             title, subtitle, sub_color, title_size=68):
    phone = create_flagship_phone(screen_img, target_w=870, target_h=1620, radius=52, bezel=14)
    phone_x, phone_y = 100, 310
    
    # Contact shadow
    c_shadow = Image.new('RGBA', (CANVAS_W, CANVAS_H), (0, 0, 0, 0))
    p_alpha = phone.split()[-1]
    c_fill = Image.new('RGBA', phone.size, (0, 0, 0, 210))
    c_fill.putalpha(p_alpha)
    c_shadow.paste(c_fill, (phone_x, phone_y + 15), c_fill)
    c_shadow = c_shadow.filter(ImageFilter.GaussianBlur(25))
    bg = Image.alpha_composite(bg, c_shadow)
    
    # Diffuse shadow
    d_shadow = Image.new('RGBA', (CANVAS_W, CANVAS_H), (0, 0, 0, 0))
    d_fill = Image.new('RGBA', phone.size, (0, 0, 0, 140))
    d_fill.putalpha(p_alpha)
    d_shadow.paste(d_fill, (phone_x, phone_y + 40), d_fill)
    d_shadow = d_shadow.filter(ImageFilter.GaussianBlur(55))
    bg = Image.alpha_composite(bg, d_shadow)
    
    # Paste Phone
    bg.paste(phone, (phone_x, phone_y), phone)
    
    # Paste Floating 3D Badge
    if badge_card and badge_pos:
        card_x, card_y = badge_pos
        b_shadow = Image.new('RGBA', (CANVAS_W, CANVAS_H), (0, 0, 0, 0))
        b_alpha = badge_card.split()[-1]
        b_fill = Image.new('RGBA', badge_card.size, (0, 0, 0, 160))
        b_fill.putalpha(b_alpha)
        b_shadow.paste(b_fill, (card_x, card_y + 12), b_fill)
        b_shadow = b_shadow.filter(ImageFilter.GaussianBlur(18))
        bg = Image.alpha_composite(bg, b_shadow)
        bg.paste(badge_card, (card_x, card_y), badge_card)
        
    # Typography
    draw = ImageDraw.Draw(bg)
    f_title = ImageFont.truetype(FONT_TITLE, title_size)
    f_sub = ImageFont.truetype(FONT_SUB, 32)
    f_badge = ImageFont.truetype(FONT_BADGE, 24)
    
    # Header pills
    bb1 = f_badge.getbbox(badge1_text)
    bb2 = f_badge.getbbox(badge2_text)
    p1_w = (bb1[2] - bb1[0]) + 48
    p2_w = (bb2[2] - bb2[0]) + 48
    gap = 20
    total_w = p1_w + gap + p2_w
    start_x = (CANVAS_W - total_w) // 2
    
    # Pill 1
    draw.rounded_rectangle([start_x, 60, start_x + p1_w, 108], radius=24, fill=badge1_bg, outline=badge1_border, width=2)
    draw.text((start_x + 24, 68), badge1_text, font=f_badge, fill=(255, 255, 255))
    
    # Pill 2
    x2 = start_x + p1_w + gap
    draw.rounded_rectangle([x2, 60, x2 + p2_w, 108], radius=24, fill=badge2_bg, outline=badge2_border, width=2)
    draw.text((x2 + 24, 68), badge2_text, font=f_badge, fill=(255, 255, 255))
    
    # Title
    t_bb = f_title.getbbox(title)
    tw = t_bb[2] - t_bb[0]
    draw.text(((CANVAS_W - tw)//2, 135), title, font=f_title, fill=(255, 255, 255))
    
    # Subtitle
    s_bb = f_sub.getbbox(subtitle)
    sw = s_bb[2] - s_bb[0]
    draw.text(((CANVAS_W - sw)//2, 222), subtitle, font=f_sub, fill=sub_color)
    
    return bg

print("Compositing framework ready!")

print("Starting generation of all 7 hyper-realistic screenshots...")

# ==============================================================================
# SLIDE 1: Hero Editor
# ==============================================================================
print("Generating Slide 1: Hero Editor...")
bg1 = create_ambient_bg(os.path.join(FOOTAGE_DIR, 'footage_hero_sunset.jpg'),
                        (124, 58, 237, 90), (6, 182, 212, 60))
editor1 = Image.open(os.path.join(BRAIN_DIR, 'enhanced_editor_test.png')).convert('RGBA')
badge1 = create_floating_badge("✂️", "Millisecond Split", "Precise Clip Trimming",
                              (18, 22, 36, 235), (96, 165, 250, 220))
s1 = assemble_screenshot_card(bg1, editor1, badge1, (670, 840),
                              "⚡ 100% FREE VIP", (124, 58, 237, 180), (192, 132, 252, 240),
                              "🚫 NO WATERMARK", (239, 68, 68, 180), (248, 113, 113, 240),
                              "PRO VIDEO EDITOR & MAKER",
                              "Multi-Track Timeline • Millisecond Precision Trimming",
                              (56, 189, 248))
s1.convert('RGB').save(os.path.join(OUT_DIR, 'screenshot_1_hero_editor.png'), quality=96)
s1.convert('RGB').save(os.path.join(DOWNLOADS_OUT, 'screenshot_1_hero_editor.png'), quality=96)
s1.convert('RGB').save(os.path.join(BRAIN_DIR, 'screenshot_1_hero_editor.png'), quality=96)

# ==============================================================================
# SLIDE 2: Transitions
# ==============================================================================
print("Generating Slide 2: Cinematic Transitions...")
bg2 = create_ambient_bg(os.path.join(FOOTAGE_DIR, 'footage_fashion_coastal.jpg'),
                        (37, 99, 235, 100), (6, 182, 212, 70))
screen2 = Image.open(os.path.join(BRAIN_DIR, 'novacut_transitions_drawer.png')).convert('RGBA')

# Compose transition split in player area: x: 225 to 854, y: 280 to 810
pw, ph = 629, 530
px, py = 225, 280
f_left = fit_crop(Image.open(os.path.join(FOOTAGE_DIR, 'footage_hero_sunset.jpg')).convert('RGBA'), pw, ph)
f_right = fit_crop(Image.open(os.path.join(FOOTAGE_DIR, 'footage_fashion_coastal.jpg')).convert('RGBA'), pw, ph)

trans_player = Image.new('RGBA', (pw, ph), (0, 0, 0, 0))
trans_player.paste(f_left, (0, 0))
# Right half
trans_player.paste(f_right.crop((pw//2, 0, pw, ph)), (pw//2, 0))

# Transition split glow line & diamond
t_draw = ImageDraw.Draw(trans_player)
t_draw.line([(pw//2, 0), (pw//2, ph)], fill=(255, 255, 255, 240), width=4)
# Transition icon box
t_box = [pw//2 - 28, ph//2 - 28, pw//2 + 28, ph//2 + 28]
t_draw.rounded_rectangle(t_box, radius=8, fill=(37, 99, 235, 240), outline=(255, 255, 255, 255), width=2)
f_icon = ImageFont.truetype('/System/Library/Fonts/Supplemental/Arial Bold.ttf', 24)
t_draw.text((pw//2 - 14, ph//2 - 14), "🔀", font=f_icon, fill=(255, 255, 255))

screen2.paste(trans_player, (px, py))

badge2 = create_floating_badge("🔀", "1-Tap Apply to All", "10+ Cinematic Transitions",
                              (14, 25, 45, 235), (56, 189, 248, 220))
s2 = assemble_screenshot_card(bg2, screen2, badge2, (670, 780),
                              "🔀 10+ PRO TRANSITIONS", (37, 99, 235, 180), (96, 165, 250, 240),
                              "✨ 1-TAP APPLY ALL", (6, 182, 212, 180), (103, 232, 249, 240),
                              "CINEMATIC TRANSITIONS",
                              "Glitch, Zoom, Dissolve & Flash FX • 1-Tap Apply to All",
                              (147, 197, 253))
s2.convert('RGB').save(os.path.join(OUT_DIR, 'screenshot_2_transitions.png'), quality=96)
s2.convert('RGB').save(os.path.join(DOWNLOADS_OUT, 'screenshot_2_transitions.png'), quality=96)
s2.convert('RGB').save(os.path.join(BRAIN_DIR, 'screenshot_2_transitions.png'), quality=96)

# ==============================================================================
# SLIDE 3: Velocity Curves
# ==============================================================================
print("Generating Slide 3: Velocity Speed Curves...")
bg3 = create_ambient_bg(os.path.join(FOOTAGE_DIR, 'footage_action_skater.jpg'),
                        (234, 88, 12, 95), (234, 179, 8, 60))
screen3 = Image.open(os.path.join(BRAIN_DIR, 'novacut_curves_active.png')).convert('RGBA')

# Player area with mid-air action skater
skater_video = fit_crop(Image.open(os.path.join(FOOTAGE_DIR, 'footage_action_skater.jpg')).convert('RGBA'), pw, ph)
sk_draw = ImageDraw.Draw(skater_video)

# 0.2x SLOW-MO badge
sk_draw.rounded_rectangle([20, 20, 190, 60], radius=8, fill=(234, 88, 12, 220), outline=(255, 255, 255, 240), width=2)
f_speed = ImageFont.truetype('/System/Library/Fonts/Supplemental/DIN Alternate Bold.ttf', 24)
sk_draw.text((32, 26), "🏎️ 0.2x SLOW-MO", font=f_speed, fill=(255, 255, 255))

# Dynamic bezier speed curve visual on player bottom
curve_pts = [(30, ph - 40), (150, ph - 40), (250, ph - 120), (380, ph - 30), (520, ph - 30), (600, ph - 90)]
sk_draw.line(curve_pts, fill=(251, 146, 60, 240), width=5)
for pt in curve_pts:
    sk_draw.ellipse([pt[0]-6, pt[1]-6, pt[0]+6, pt[1]+6], fill=(255, 255, 255), outline=(234, 88, 12), width=2)

screen3.paste(skater_video, (px, py))

badge3 = create_floating_badge("🏎️", "Bullet Time Curve", "Montage & Hero Speed Ramping",
                              (35, 20, 15, 235), (251, 146, 60, 220))
s3 = assemble_screenshot_card(bg3, screen3, badge3, (670, 780),
                              "🏎️ 0.25x - 4.0x SPEED", (234, 88, 12, 180), (251, 146, 60, 240),
                              "🎵 BEAT SYNC CURVES", (202, 138, 4, 180), (250, 204, 21, 240),
                              "VELOCITY SPEED CURVES",
                              "Smooth Slow-Mo & Hero Ramping • Montage & Bullet Time",
                              (253, 186, 116))
s3.convert('RGB').save(os.path.join(OUT_DIR, 'screenshot_3_velocity_curves.png'), quality=96)
s3.convert('RGB').save(os.path.join(DOWNLOADS_OUT, 'screenshot_3_velocity_curves.png'), quality=96)
s3.convert('RGB').save(os.path.join(BRAIN_DIR, 'screenshot_3_velocity_curves.png'), quality=96)

# ==============================================================================
# SLIDE 4: Audio Extraction
# ==============================================================================
print("Generating Slide 4: Audio Extraction...")
bg4 = create_ambient_bg(os.path.join(FOOTAGE_DIR, 'footage_fashion_coastal.jpg'),
                        (225, 29, 72, 95), (168, 85, 247, 65))
screen4 = Image.open(os.path.join(BRAIN_DIR, 'novacut_audio_sheet.png')).convert('RGBA')

# Player with music waveform
audio_video = fit_crop(Image.open(os.path.join(FOOTAGE_DIR, 'footage_fashion_coastal.jpg')).convert('RGBA'), pw, ph)
av_draw = ImageDraw.Draw(audio_video)

# Music pill overlay
av_draw.rounded_rectangle([20, ph - 80, pw - 20, ph - 20], radius=10, fill=(0, 0, 0, 200), outline=(244, 114, 182, 200), width=2)
f_m = ImageFont.truetype('/System/Library/Fonts/Supplemental/Arial Bold.ttf', 20)
av_draw.text((35, ph - 70), "🎵 Trending Audio: Chill Lo-Fi Beats (02:45)", font=f_m, fill=(255, 255, 255))

# 1-Tap Muted video tag top right
av_draw.rounded_rectangle([pw - 170, 20, pw - 20, 58], radius=8, fill=(225, 29, 72, 220), outline=(255, 255, 255, 240), width=1)
f_mute = ImageFont.truetype('/System/Library/Fonts/Supplemental/Arial Bold.ttf', 18)
av_draw.text((pw - 158, 28), "🔇 Video Muted", font=f_mute, fill=(255, 255, 255))

screen4.paste(audio_video, (px, py))

badge4 = create_floating_badge("🎙️", "Audio Extractor", "Rip Sound Directly from Gallery",
                              (35, 15, 25, 235), (244, 114, 182, 220))
s4 = assemble_screenshot_card(bg4, screen4, badge4, (670, 780),
                              "🎙️ VIDEO AUDIO RIPPER", (225, 29, 72, 180), (251, 113, 133, 240),
                              "🔇 1-TAP MUTE SOUND", (168, 85, 247, 180), (216, 180, 254, 240),
                              "EXTRACT AUDIO FROM ANY VIDEO",
                              "Rip Trending Reel Audio • 1-Tap Mute Original Sound",
                              (244, 114, 182), title_size=62)
s4.convert('RGB').save(os.path.join(OUT_DIR, 'screenshot_4_audio_extractor.png'), quality=96)
s4.convert('RGB').save(os.path.join(DOWNLOADS_OUT, 'screenshot_4_audio_extractor.png'), quality=96)
s4.convert('RGB').save(os.path.join(BRAIN_DIR, 'screenshot_4_audio_extractor.png'), quality=96)

# ==============================================================================
# SLIDE 5: Hollywood LUT Filters
# ==============================================================================
print("Generating Slide 5: Hollywood LUT Filters...")
bg5 = create_ambient_bg(os.path.join(FOOTAGE_DIR, 'footage_hero_sunset.jpg'),
                        (217, 119, 6, 95), (139, 92, 246, 60))
screen5 = Image.open(os.path.join(BRAIN_DIR, 'novacut_filters.png')).convert('RGBA')

# Create Split Before / After player
lut_base = fit_crop(Image.open(os.path.join(FOOTAGE_DIR, 'footage_hero_sunset.jpg')).convert('RGBA'), pw, ph)
# Desaturate left half for "RAW LOG"
raw_side = ImageEnhance.Color(lut_base).enhance(0.4)
raw_side = ImageEnhance.Contrast(raw_side).enhance(0.8)

# Boost right half for "LUT GRADE" (Teal & Orange)
graded_side = ImageEnhance.Color(lut_base).enhance(1.6)
graded_side = ImageEnhance.Contrast(graded_side).enhance(1.2)

split_filter_player = Image.new('RGBA', (pw, ph), (0, 0, 0, 0))
split_filter_player.paste(raw_side, (0, 0))
split_filter_player.paste(graded_side.crop((pw//2, 0, pw, ph)), (pw//2, 0))

sf_draw = ImageDraw.Draw(split_filter_player)
sf_draw.line([(pw//2, 0), (pw//2, ph)], fill=(255, 255, 255, 240), width=4)

# Labels
f_lbl = ImageFont.truetype('/System/Library/Fonts/Supplemental/Arial Bold.ttf', 18)
# RAW LOG tag
sf_draw.rounded_rectangle([20, 20, 130, 55], radius=6, fill=(0, 0, 0, 180), outline=(200, 200, 200, 200), width=1)
sf_draw.text((32, 26), "RAW LOG", font=f_lbl, fill=(200, 200, 200))
# LUT GRADE tag
sf_draw.rounded_rectangle([pw - 150, 20, pw - 20, 55], radius=6, fill=(217, 119, 6, 220), outline=(255, 255, 255, 220), width=1)
sf_draw.text((pw - 138, 26), "TEAL & ORANGE", font=f_lbl, fill=(255, 255, 255))

# Center comparison badge
c_box = [pw//2 - 65, ph//2 - 18, pw//2 + 65, ph//2 + 18]
sf_draw.rounded_rectangle(c_box, radius=18, fill=(0, 0, 0, 220), outline=(255, 255, 255, 240), width=2)
f_cmp = ImageFont.truetype('/System/Library/Fonts/Supplemental/Arial Bold.ttf', 16)
sf_draw.text((pw//2 - 52, ph//2 - 10), "◀ BEFORE | AFTER ▶", font=f_cmp, fill=(255, 255, 255))

screen5.paste(split_filter_player, (px, py))

badge5 = create_floating_badge("🎨", "Cinema Color LUT", "Hollywood Teal & Orange 90s",
                              (35, 24, 15, 235), (251, 191, 36, 220))
s5 = assemble_screenshot_card(bg5, screen5, badge5, (670, 780),
                              "🎨 PRO COLOR GRADES", (217, 119, 6, 180), (251, 191, 36, 240),
                              "⚡ REALTIME PREVIEWS", (139, 92, 246, 180), (196, 181, 253, 240),
                              "HOLLYWOOD LUT FILTERS",
                              "Teal & Orange, Cyberpunk Neon, 90s Vintage & Noir",
                              (251, 191, 36))
s5.convert('RGB').save(os.path.join(OUT_DIR, 'screenshot_5_lut_filters.png'), quality=96)
s5.convert('RGB').save(os.path.join(DOWNLOADS_OUT, 'screenshot_5_lut_filters.png'), quality=96)
s5.convert('RGB').save(os.path.join(BRAIN_DIR, 'screenshot_5_lut_filters.png'), quality=96)

# ==============================================================================
# SLIDE 6: 4K 60FPS Export
# ==============================================================================
print("Generating Slide 6: 4K 60FPS Export...")
bg6 = create_ambient_bg(os.path.join(FOOTAGE_DIR, 'footage_hero_sunset.jpg'),
                        (5, 150, 105, 95), (6, 182, 212, 60))
screen6 = Image.open(os.path.join(BRAIN_DIR, 'novacut_export_pro_free.png')).convert('RGBA')

# In the video thumbnail area of export screen, paste real footage thumbnail
export_thumb = fit_crop(Image.open(os.path.join(FOOTAGE_DIR, 'footage_hero_sunset.jpg')).convert('RGBA'), 320, 420)
# Export thumbnail is around center-top (x: 380, y: 350)
t_mask = Image.new('L', (320*2, 420*2), 0)
ImageDraw.Draw(t_mask).rounded_rectangle([0, 0, 320*2, 420*2], radius=32, fill=255)
t_mask = t_mask.resize((320, 420), Image.Resampling.LANCZOS)
export_thumb.putalpha(t_mask)
screen6.paste(export_thumb, (380, 350), export_thumb)

badge6 = create_floating_badge("💎", "Ultra 4K 60FPS", "Hardware Encoded • Zero Watermark",
                              (12, 35, 28, 235), (52, 211, 153, 220))
s6 = assemble_screenshot_card(bg6, screen6, badge6, (670, 780),
                              "💎 4K 60FPS ULTRA HD", (5, 150, 105, 180), (52, 211, 153, 240),
                              "🚫 ZERO WATERMARK", (239, 68, 68, 180), (248, 113, 113, 240),
                              "4K 60FPS ULTRA HD EXPORT",
                              "100% Free Forever • Zero Watermark • Ultra Bitrate",
                              (52, 211, 153))
s6.convert('RGB').save(os.path.join(OUT_DIR, 'screenshot_6_4k_export.png'), quality=96)
s6.convert('RGB').save(os.path.join(DOWNLOADS_OUT, 'screenshot_6_4k_export.png'), quality=96)
s6.convert('RGB').save(os.path.join(BRAIN_DIR, 'screenshot_6_4k_export.png'), quality=96)

# ==============================================================================
# SLIDE 7: Viral Reels & Photo Slideshow
# ==============================================================================
print("Generating Slide 7: Viral Reels & Photo Slideshow...")
bg7 = create_ambient_bg(os.path.join(FOOTAGE_DIR, 'footage_hero_sunset.jpg'),
                        (147, 51, 234, 95), (236, 72, 153, 60))
screen7 = Image.open(os.path.join(BRAIN_DIR, 'novacut_home_pro.png')).convert('RGBA')

# Patch VidCut branding on top header
p_draw7 = ImageDraw.Draw(screen7)
p_draw7.rectangle([(110, 160), (460, 215)], fill=(20, 24, 36))
logo_f = ImageFont.truetype(FONT_LOGO, 48, index=0)
p_draw7.text((113, 165), 'VidCut', font=logo_f, fill=(255, 255, 255))

# Patch real image previews into Recent Projects and Photo Reel cards
# Photo Reel card is in y: 450 to 720
card_photo = fit_crop(Image.open(os.path.join(FOOTAGE_DIR, 'footage_fashion_coastal.jpg')).convert('RGBA'), 480, 250)
cp_mask = Image.new('L', (480*2, 250*2), 0)
ImageDraw.Draw(cp_mask).rounded_rectangle([0, 0, 480*2, 250*2], radius=28, fill=255)
cp_mask = cp_mask.resize((480, 250), Image.Resampling.LANCZOS)
card_photo.putalpha(cp_mask)
# Add gradient darkening on right
cp_grad = Image.new('RGBA', (480, 250), (0, 0, 0, 0))
for gx in range(480):
    a = int(180 * (gx / 480.0)**1.2)
    ImageDraw.Draw(cp_grad).line([(gx, 0), (gx, 250)], fill=(20, 24, 36, a))
card_photo = Image.alpha_composite(card_photo, cp_grad)
screen7.paste(card_photo, (550, 480), card_photo)

badge7 = create_floating_badge("🚀", "1-Tap Viral Presets", "Turn Photos into Trending Reels",
                              (30, 18, 42, 235), (216, 180, 254, 220))
s7 = assemble_screenshot_card(bg7, screen7, badge7, (670, 780),
                              "🚀 1-TAP REEL MAKER", (147, 51, 234, 180), (216, 180, 254, 240),
                              "📸 PHOTO TO VIDEO", (236, 72, 153, 180), (244, 114, 182, 240),
                              "VIRAL REELS & PHOTO SLIDESHOW",
                              "Turn Photos into Trending Reels with Music in Seconds",
                              (192, 132, 252), title_size=62)
s7.convert('RGB').save(os.path.join(OUT_DIR, 'screenshot_7_reels_slideshow.png'), quality=96)
s7.convert('RGB').save(os.path.join(DOWNLOADS_OUT, 'screenshot_7_reels_slideshow.png'), quality=96)
s7.convert('RGB').save(os.path.join(BRAIN_DIR, 'screenshot_7_reels_slideshow.png'), quality=96)

print("All 7 hyper-realistic screenshots successfully generated and saved!")
