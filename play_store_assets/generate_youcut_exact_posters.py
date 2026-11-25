import os, sys, math
from PIL import Image, ImageDraw, ImageFilter, ImageFont, ImageEnhance

BRAIN_DIR = '/Users/pritamsharma/.gemini/antigravity/brain/1924d82f-8c85-4f77-96d0-28de4bd5bc32'
OUT_DIR = '/Users/pritamsharma/Downloads/video_editor_app/play_store_assets/screenshots'
DOWNLOADS_OUT = '/Users/pritamsharma/Downloads/VidCut_PlayStore_Assets/screenshots'
ASSETS_DIR = '/Users/pritamsharma/Downloads/video_editor_app/play_store_assets'
DOWNLOADS_ROOT = '/Users/pritamsharma/Downloads/VidCut_PlayStore_Assets'

os.makedirs(OUT_DIR, exist_ok=True)
os.makedirs(DOWNLOADS_OUT, exist_ok=True)

FONT_TITLE = '/System/Library/Fonts/Supplemental/DIN Alternate Bold.ttf'
FONT_SUB = '/System/Library/Fonts/Supplemental/Arial Bold.ttf'
FONT_BADGE = '/System/Library/Fonts/Supplemental/Arial Bold.ttf'

CANVAS_W, CANVAS_H = 1080, 1920

def fit_crop(img, tw, th):
    sw, sh = img.size
    scale = max(tw / float(sw), th / float(sh))
    nw, nh = int(sw * scale), int(sh * scale)
    scaled = img.resize((nw, nh), Image.Resampling.LANCZOS)
    cx = (nw - tw) // 2
    cy = (nh - th) // 2
    return scaled.crop((cx, cy, cx + tw, cy + th))

def create_youcut_bg(accent_glow_color):
    # Dark charcoal / obsidian background (Signature YouCut dark theme)
    bg = Image.new('RGBA', (CANVAS_W, CANVAS_H), (13, 15, 23, 255))
    
    # Smooth vertical mesh gradient
    for y in range(CANVAS_H):
        r = int(12 + (20 - 12) * (y / CANVAS_H))
        g = int(14 + (24 - 14) * (y / CANVAS_H))
        b = int(22 + (36 - 22) * (y / CANVAS_H))
        ImageDraw.Draw(bg).line([(0, y), (CANVAS_W, y)], fill=(r, g, b, 255))
        
    # Volumetric ambient backlight glow behind phone
    glow_layer = Image.new('RGBA', (CANVAS_W, CANVAS_H), (0, 0, 0, 0))
    d = ImageDraw.Draw(glow_layer)
    cx, cy = 540, 1050
    radius = 680
    r_val, g_val, b_val, a_max = accent_glow_color
    for i in range(35, 0, -1):
        cur_r = int(radius * (i / 35.0))
        alpha = int(a_max * (1.0 - (i / 35.0))**1.7)
        d.ellipse([cx - cur_r, cy - cur_r, cx + cur_r, cy + cur_r], fill=(r_val, g_val, b_val, alpha))
    glow_layer = glow_layer.filter(ImageFilter.GaussianBlur(40))
    bg = Image.alpha_composite(bg, glow_layer)
    
    # Secondary ambient fill at top
    top_glow = Image.new('RGBA', (CANVAS_W, CANVAS_H), (0, 0, 0, 0))
    td = ImageDraw.Draw(top_glow)
    td.ellipse([200 - 300, 100 - 300, 200 + 300, 100 + 300], fill=(r_val, g_val, b_val, int(a_max * 0.25)))
    top_glow = top_glow.filter(ImageFilter.GaussianBlur(50))
    bg = Image.alpha_composite(bg, top_glow)
    
    # Gradient fade at top for punchy text legibility
    fade = Image.new('RGBA', (CANVAS_W, CANVAS_H), (0, 0, 0, 0))
    f_draw = ImageDraw.Draw(fade)
    for y in range(420):
        a = int(230 * (1.0 - (y / 420.0)**1.3))
        f_draw.line([(0, y), (CANVAS_W, y)], fill=(10, 12, 18, a))
    bg = Image.alpha_composite(bg, fade)
    return bg

def build_youcut_phone(screen_img, target_w=870, target_h=1590, radius=50, bezel=12):
    phone_w = target_w
    phone_h = target_h
    inner_w = phone_w - (bezel * 2)
    inner_h = phone_h - (bezel * 2)
    inner_r = radius - (bezel // 2)
    
    # Scale real device screenshot to inner screen
    scaled_screen = fit_crop(screen_img, inner_w, inner_h)
    
    # Mask
    screen_mask = Image.new('L', (inner_w * 2, inner_h * 2), 0)
    ImageDraw.Draw(screen_mask).rounded_rectangle([0, 0, inner_w * 2, inner_h * 2], radius=inner_r * 2, fill=255)
    screen_mask = screen_mask.resize((inner_w, inner_h), Image.Resampling.LANCZOS)
    
    rounded_screen = Image.new('RGBA', (inner_w, inner_h), (0, 0, 0, 0))
    rounded_screen.paste(scaled_screen, (0, 0))
    rounded_screen.putalpha(screen_mask)
    
    # Glass sheen reflection
    glass_sheen = Image.new('RGBA', (inner_w, inner_h), (0, 0, 0, 0))
    g_draw = ImageDraw.Draw(glass_sheen)
    sheen_poly = [
        (int(inner_w * 0.45), 0),
        (inner_w, 0),
        (inner_w, int(inner_h * 0.3)),
        (int(inner_w * 0.1), int(inner_h * 0.7)),
        (0, int(inner_h * 0.6)),
        (0, int(inner_h * 0.25))
    ]
    g_draw.polygon(sheen_poly, fill=(255, 255, 255, 12))
    glass_sheen = glass_sheen.filter(ImageFilter.GaussianBlur(14))
    glass_sheen.putalpha(screen_mask)
    rounded_screen = Image.alpha_composite(rounded_screen, glass_sheen)
    
    # Phone chassis with side buttons
    button_w = 6
    total_w = phone_w + button_w * 2
    total_h = phone_h
    
    body = Image.new('RGBA', (total_w, total_h), (0, 0, 0, 0))
    b_draw = ImageDraw.Draw(body)
    b_draw.rounded_rectangle([0, 220, button_w + 3, 300], radius=3, fill=(55, 60, 75, 255))
    b_draw.rounded_rectangle([0, 320, button_w + 3, 400], radius=3, fill=(55, 60, 75, 255))
    b_draw.rounded_rectangle([total_w - button_w - 3, 260, total_w, 370], radius=3, fill=(55, 60, 75, 255))
    
    c_mask = Image.new('L', (phone_w * 2, phone_h * 2), 0)
    ImageDraw.Draw(c_mask).rounded_rectangle([0, 0, phone_w * 2, phone_h * 2], radius=radius * 2, fill=255)
    c_mask = c_mask.resize((phone_w, phone_h), Image.Resampling.LANCZOS)
    
    chassis = Image.new('RGBA', (phone_w, phone_h), (22, 24, 30, 255))
    chassis.putalpha(c_mask)
    
    rim_layer = Image.new('RGBA', (phone_w, phone_h), (0, 0, 0, 0))
    r_draw = ImageDraw.Draw(rim_layer)
    r_draw.rounded_rectangle([1, 1, phone_w - 2, phone_h - 2], radius=radius, outline=(90, 100, 120, 230), width=2)
    r_draw.rounded_rectangle([3, 3, phone_w - 4, phone_h - 4], radius=radius - 2, outline=(18, 19, 24, 255), width=bezel - 3)
    r_draw.arc([2, 2, radius * 3, radius * 3], start=180, end=270, fill=(210, 225, 250, 180), width=3)
    
    chassis = Image.alpha_composite(chassis, rim_layer)
    chassis.paste(rounded_screen, (bezel, bezel), rounded_screen)
    
    # Dynamic Island
    island_w, island_h = 114, 28
    island_x = (phone_w - island_w) // 2
    island_y = bezel + 12
    i_draw = ImageDraw.Draw(chassis)
    i_draw.rounded_rectangle([island_x, island_y, island_x + island_w, island_y + island_h], radius=14, fill=(10, 10, 14, 255))
    i_draw.ellipse([island_x + 22, island_y + 7, island_x + 36, island_y + 21], fill=(18, 22, 32, 255))
    i_draw.ellipse([island_x + 26, island_y + 11, island_x + 31, island_y + 16], fill=(50, 70, 110, 255))
    i_draw.ellipse([island_x + 78, island_y + 9, island_x + 90, island_y + 21], fill=(16, 20, 28, 255))
    i_draw.ellipse([island_x + 82, island_y + 13, island_x + 86, island_y + 17], fill=(40, 60, 95, 255))
    
    body.paste(chassis, (button_w, 0), chassis)
    return body

def create_floating_callout(icon_str, title_str, sub_str, bg_color, border_color):
    cw, ch = 340, 105
    card = Image.new('RGBA', (cw, ch), (0, 0, 0, 0))
    c_mask = Image.new('L', (cw * 2, ch * 2), 0)
    ImageDraw.Draw(c_mask).rounded_rectangle([0, 0, cw * 2, ch * 2], radius=36, fill=255)
    c_mask = c_mask.resize((cw, ch), Image.Resampling.LANCZOS)
    
    c_bg = Image.new('RGBA', (cw, ch), bg_color)
    c_bg.putalpha(c_mask)
    card = Image.alpha_composite(card, c_bg)
    
    cb_draw = ImageDraw.Draw(card)
    cb_draw.rounded_rectangle([1, 1, cw - 2, ch - 2], radius=18, outline=border_color, width=2)
    
    f_icon = ImageFont.truetype('/System/Library/Fonts/Supplemental/Arial Bold.ttf', 38)
    f_title = ImageFont.truetype('/System/Library/Fonts/Supplemental/Arial Bold.ttf', 24)
    f_sub = ImageFont.truetype('/System/Library/Fonts/Supplemental/Arial Bold.ttf', 17)
    
    cb_draw.text((22, 34), icon_str, font=f_icon, fill=(255, 255, 255))
    cb_draw.text((78, 26), title_str, font=f_title, fill=(255, 255, 255))
    cb_draw.text((78, 58), sub_str, font=f_sub, fill=(200, 225, 255))
    return card

def render_youcut_style_slide(real_screen_path, callout_card, callout_pos,
                              line1_text, line1_color,
                              line2_text,
                              subtitle_text,
                              glow_color, out_name):
    real_screen = Image.open(real_screen_path).convert('RGBA')
    bg = create_youcut_bg(glow_color)
    phone = build_youcut_phone(real_screen, target_w=870, target_h=1590, radius=50, bezel=12)
    phone_x, phone_y = 100, 330
    
    # Shadows
    c_shadow = Image.new('RGBA', (CANVAS_W, CANVAS_H), (0, 0, 0, 0))
    p_alpha = phone.split()[-1]
    c_fill = Image.new('RGBA', phone.size, (0, 0, 0, 220))
    c_fill.putalpha(p_alpha)
    c_shadow.paste(c_fill, (phone_x, phone_y + 14), c_fill)
    c_shadow = c_shadow.filter(ImageFilter.GaussianBlur(22))
    bg = Image.alpha_composite(bg, c_shadow)
    
    d_shadow = Image.new('RGBA', (CANVAS_W, CANVAS_H), (0, 0, 0, 0))
    d_fill = Image.new('RGBA', phone.size, (0, 0, 0, 150))
    d_fill.putalpha(p_alpha)
    d_shadow.paste(d_fill, (phone_x, phone_y + 38), d_fill)
    d_shadow = d_shadow.filter(ImageFilter.GaussianBlur(50))
    bg = Image.alpha_composite(bg, d_shadow)
    
    bg.paste(phone, (phone_x, phone_y), phone)
    
    # Popout card
    if callout_card and callout_pos:
        cx, cy = callout_pos
        b_shadow = Image.new('RGBA', (CANVAS_W, CANVAS_H), (0, 0, 0, 0))
        b_alpha = callout_card.split()[-1]
        b_fill = Image.new('RGBA', callout_card.size, (0, 0, 0, 170))
        b_fill.putalpha(b_alpha)
        b_shadow.paste(b_fill, (cx, cy + 12), b_fill)
        b_shadow = b_shadow.filter(ImageFilter.GaussianBlur(18))
        bg = Image.alpha_composite(bg, b_shadow)
        bg.paste(callout_card, (cx, cy), callout_card)
        
    # Typography: Signature YouCut Google Play Style
    draw = ImageDraw.Draw(bg)
    f_line1 = ImageFont.truetype(FONT_TITLE, 62)
    f_line2 = ImageFont.truetype(FONT_TITLE, 86)
    f_sub = ImageFont.truetype(FONT_SUB, 30)
    
    # Line 1: Accent Color (Centered at y = 65)
    bb1 = f_line1.getbbox(line1_text)
    w1 = bb1[2] - bb1[0]
    x1 = (CANVAS_W - w1) // 2
    for ox, oy in [(-1,1), (1,1), (0,2)]:
        draw.text((x1 + ox, 65 + oy), line1_text, font=f_line1, fill=(0, 0, 0, 200))
    draw.text((x1, 65), line1_text, font=f_line1, fill=line1_color)
    
    # Line 2: Huge Bold White (Centered at y = 135)
    bb2 = f_line2.getbbox(line2_text)
    w2 = bb2[2] - bb2[0]
    x2 = (CANVAS_W - w2) // 2
    for ox, oy in [(-2,2), (2,2), (0,3), (0,4)]:
        draw.text((x2 + ox, 135 + oy), line2_text, font=f_line2, fill=(0, 0, 0, 240))
    draw.text((x2, 135), line2_text, font=f_line2, fill=(255, 255, 255))
    
    # Line 3: Clean Subtitle (Centered at y = 238)
    bb3 = f_sub.getbbox(subtitle_text)
    w3 = bb3[2] - bb3[0]
    x3 = (CANVAS_W - w3) // 2
    draw.text((x3, 238), subtitle_text, font=f_sub, fill=(203, 213, 225))
    
    # Save outputs
    bg_rgb = bg.convert('RGB')
    bg_rgb.save(os.path.join(OUT_DIR, out_name), quality=96)
    bg_rgb.save(os.path.join(DOWNLOADS_OUT, out_name), quality=96)
    bg_rgb.save(os.path.join(BRAIN_DIR, out_name), quality=96)
    print("Saved YouCut style slide:", out_name)

print("Starting generation of YouCut style Google Play screenshot cards...")

# ==============================================================================
# Slide 1: FREE & NO WATERMARK
# ==============================================================================
c1 = create_floating_callout("✂️", "Precision Trimmer", "Millisecond Split & Cut", (18, 24, 38, 235), (96, 165, 250, 230))
render_youcut_style_slide(os.path.join(BRAIN_DIR, 'fresh_editor.png'), c1, (660, 880),
                          "FREE &", (255, 230, 0), # YouCut Signature Bright Yellow
                          "NO WATERMARK",
                          "Pro Video Editor & Reels Maker",
                          (124, 58, 237, 130), 'screenshot_1_hero_editor.png')

# ==============================================================================
# Slide 2: 50+ DYNAMIC TRANSITION EFFECTS
# ==============================================================================
c2 = create_floating_callout("🔀", "1-Tap Apply to All", "Cross Dissolve, Glitch & Zoom", (15, 28, 48, 235), (56, 189, 248, 230))
render_youcut_style_slide(os.path.join(BRAIN_DIR, 'fresh_transitions.png'), c2, (660, 820),
                          "50+ DYNAMIC", (0, 229, 255), # Vivid Cyan
                          "TRANSITION EFFECTS",
                          "Glitch, Zoom, Dissolve & 1-Tap Apply All",
                          (37, 99, 235, 130), 'screenshot_2_transitions.png')

# ==============================================================================
# Slide 3: SMOOTH SLOW MOTION & SPEED
# ==============================================================================
c3 = create_floating_callout("🏎️", "Bullet Time 0.2x", "Montage & Hero Speed Curves", (38, 22, 14, 235), (251, 146, 60, 230))
render_youcut_style_slide(os.path.join(BRAIN_DIR, 'fresh_velocity.png'), c3, (660, 820),
                          "SMOOTH", (255, 87, 34), # YouCut Vivid Orange
                          "SLOW MOTION & SPEED",
                          "Velocity Curve Ramping 0.2x – 4.0x",
                          (234, 88, 12, 130), 'screenshot_3_velocity_curves.png')

# ==============================================================================
# Slide 4: EXTRACT & ADD MUSIC & SOUND FX
# ==============================================================================
c4 = create_floating_callout("🎙️", "Video Audio Ripper", "Extract Sound Directly from Video", (40, 16, 28, 235), (244, 114, 182, 230))
render_youcut_style_slide(os.path.join(BRAIN_DIR, 'fresh_audio.png'), c4, (660, 820),
                          "EXTRACT & ADD", (255, 64, 129), # Vivid Pink
                          "MUSIC & SOUND FX",
                          "Rip Audio from Video • 1-Tap Mute Sound",
                          (225, 29, 72, 130), 'screenshot_4_audio_extractor.png')

# ==============================================================================
# Slide 5: PRO GRADE CINEMATIC FILTERS & FX
# ==============================================================================
c5 = create_floating_callout("🎨", "Cinema Color LUT", "Hollywood Teal & Orange 90s", (40, 26, 14, 235), (251, 191, 36, 230))
render_youcut_style_slide(os.path.join(BRAIN_DIR, 'fresh_filters.png'), c5, (660, 820),
                          "PRO GRADE", (255, 193, 7), # Vivid Amber Gold
                          "CINEMATIC FILTERS & FX",
                          "Teal & Orange, Cyberpunk & 90s Vintage",
                          (217, 119, 6, 130), 'screenshot_5_lut_filters.png')

# ==============================================================================
# Slide 6: ULTRA HD 4K 60FPS EXPORT
# ==============================================================================
c6 = create_floating_callout("💎", "4K 60FPS Ultra HD", "Hardware Encoded • Zero Watermark", (14, 38, 30, 235), (52, 211, 153, 230))
render_youcut_style_slide(os.path.join(BRAIN_DIR, 'fresh_export.png'), c6, (660, 820),
                          "ULTRA HD", (0, 230, 118), # Vivid Emerald Green
                          "4K 60FPS EXPORT",
                          "High Bitrate • 100% Free Forever",
                          (5, 150, 105, 130), 'screenshot_6_4k_export.png')

# ==============================================================================
# Slide 7: PHOTOS TO VIDEO SLIDESHOW & REELS
# ==============================================================================
c7 = create_floating_callout("🚀", "1-Tap Viral Presets", "Turn Photos into Trending Reels", (32, 18, 45, 235), (216, 180, 254, 230))
render_youcut_style_slide(os.path.join(BRAIN_DIR, 'fresh_home.png'), c7, (660, 820),
                          "PHOTOS TO VIDEO", (190, 80, 255), # Vivid Purple
                          "SLIDESHOW & REELS",
                          "1-Tap Viral Themes & Beat Sync",
                          (147, 51, 234, 130), 'screenshot_7_reels_slideshow.png')

print("ALL 7 YOUCUT-STYLE GOOGLE PLAY STORE SCREENSHOTS GENERATED SUCCESSFULLY!")
