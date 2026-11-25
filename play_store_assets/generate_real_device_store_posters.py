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

def create_ambient_bg(screen_img, glow1, glow2):
    bg = screen_img.resize((CANVAS_W, CANVAS_H), Image.Resampling.LANCZOS)
    bg = bg.filter(ImageFilter.GaussianBlur(95))
    bg = ImageEnhance.Brightness(bg).enhance(0.32)
    bg = ImageEnhance.Color(bg).enhance(1.4)
    
    # Overlay dark studio base
    dark = Image.new('RGBA', (CANVAS_W, CANVAS_H), (10, 12, 18, 150))
    bg = Image.alpha_composite(bg, dark)
    
    def add_glow(base, cx, cy, rad, col):
        g_layer = Image.new('RGBA', (CANVAS_W, CANVAS_H), (0, 0, 0, 0))
        d = ImageDraw.Draw(g_layer)
        for i in range(30, 0, -1):
            r = int(rad * (i / 30))
            a = int(col[3] * (1.0 - (i / 30))**1.7)
            d.ellipse([cx - r, cy - r, cx + r, cy + r], fill=(col[0], col[1], col[2], a))
        g_layer = g_layer.filter(ImageFilter.GaussianBlur(40))
        return Image.alpha_composite(base, g_layer)
        
    bg = add_glow(bg, 540, 950, 680, glow1)
    bg = add_glow(bg, 220, 320, 380, glow2)
    
    # Top fade for legibility
    fade = Image.new('RGBA', (CANVAS_W, CANVAS_H), (0, 0, 0, 0))
    f_draw = ImageDraw.Draw(fade)
    for y in range(460):
        a = int(245 * (1.0 - (y / 460.0)**1.3))
        f_draw.line([(0, y), (CANVAS_W, y)], fill=(8, 10, 16, a))
    bg = Image.alpha_composite(bg, fade)
    return bg

def build_flagship_device(screen_img, target_w=870, target_h=1590, radius=50, bezel=12):
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
    
    # Glass sheen
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
    
    # Chassis
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

def create_floating_card(icon_str, title_str, sub_str, bg_color, border_color):
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

def render_real_device_poster(real_screen_path, popout_card, popout_pos,
                              hook_text, hook_color,
                              main_title, sub_text, sub_color,
                              glow1, glow2, out_name):
    real_screen = Image.open(real_screen_path).convert('RGBA')
    bg = create_ambient_bg(real_screen, glow1, glow2)
    phone = build_flagship_device(real_screen, target_w=870, target_h=1590, radius=50, bezel=12)
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
    if popout_card and popout_pos:
        cx, cy = popout_pos
        b_shadow = Image.new('RGBA', (CANVAS_W, CANVAS_H), (0, 0, 0, 0))
        b_alpha = popout_card.split()[-1]
        b_fill = Image.new('RGBA', popout_card.size, (0, 0, 0, 170))
        b_fill.putalpha(b_alpha)
        b_shadow.paste(b_fill, (cx, cy + 12), b_fill)
        b_shadow = b_shadow.filter(ImageFilter.GaussianBlur(18))
        bg = Image.alpha_composite(bg, b_shadow)
        bg.paste(popout_card, (cx, cy), popout_card)
        
    # InShot/YouCut Signature Typography
    draw = ImageDraw.Draw(bg)
    f_hook = ImageFont.truetype(FONT_BADGE, 28)
    f_main = ImageFont.truetype(FONT_TITLE, 82)
    f_sub = ImageFont.truetype(FONT_SUB, 32)
    
    # Hook pill
    h_bb = f_hook.getbbox(hook_text)
    hw = h_bb[2] - h_bb[0]
    pill_w = hw + 44
    pill_h = (h_bb[3] - h_bb[1]) + 20
    px = (CANVAS_W - pill_w) // 2
    draw.rounded_rectangle([px, 60, px + pill_w, 60 + pill_h], radius=pill_h//2,
                           fill=(20, 24, 38, 220), outline=hook_color, width=2)
    draw.text((px + 22, 68), hook_text, font=f_hook, fill=hook_color)
    
    # Main Headline
    m_bb = f_main.getbbox(main_title)
    mw = m_bb[2] - m_bb[0]
    mx = (CANVAS_W - mw) // 2
    for ox, oy in [(-2,2), (2,2), (0,3), (0,4)]:
        draw.text((mx + ox, 135 + oy), main_title, font=f_main, fill=(0, 0, 0, 230))
    draw.text((mx, 135), main_title, font=f_main, fill=(255, 255, 255))
    
    # Subtitle
    s_bb = f_sub.getbbox(sub_text)
    sw = s_bb[2] - s_bb[0]
    sx = (CANVAS_W - sw) // 2
    draw.text((sx, 238), sub_text, font=f_sub, fill=sub_color)
    
    # Save outputs
    bg_rgb = bg.convert('RGB')
    bg_rgb.save(os.path.join(OUT_DIR, out_name), quality=96)
    bg_rgb.save(os.path.join(DOWNLOADS_OUT, out_name), quality=96)
    bg_rgb.save(os.path.join(BRAIN_DIR, out_name), quality=96)
    print("Saved:", out_name)

# 1. Slide 1: Hero Editor
c1 = create_floating_card("✂️", "Millisecond Cut", "1-Tap Split & Trim Video", (18, 24, 38, 235), (96, 165, 250, 230))
render_real_device_poster(os.path.join(BRAIN_DIR, 'real_device_editor.png'), c1, (660, 880),
                          "⚡ 100% FREE VIP", (250, 204, 21),
                          "NO WATERMARK", "Pro Video Editor & Reels Maker", (56, 189, 248),
                          (124, 58, 237, 120), (6, 182, 212, 80), 'screenshot_1_hero_editor.png')

# 2. Slide 2: Transitions
c2 = create_floating_card("🔀", "1-Tap Apply to All", "10+ Cinematic FX Styles", (15, 28, 48, 235), (56, 189, 248, 230))
render_real_device_poster(os.path.join(BRAIN_DIR, 'real_device_transitions.png'), c2, (660, 820),
                          "✨ 1-TAP APPLY ALL", (56, 189, 248),
                          "SMOOTH TRANSITIONS", "Glitch, Zoom, Dissolve & Flash FX", (147, 197, 253),
                          (37, 99, 235, 120), (6, 182, 212, 90), 'screenshot_2_transitions.png')

# 3. Slide 3: Velocity Curves
c3 = create_floating_card("🏎️", "Bullet Time 0.2x", "Montage & Hero Speed Curves", (38, 22, 14, 235), (251, 146, 60, 230))
render_real_device_poster(os.path.join(BRAIN_DIR, 'real_device_velocity.png'), c3, (660, 820),
                          "🏎️ 0.25x - 4.0x SPEED", (251, 146, 60),
                          "VELOCITY SLOW-MO", "Hero Climax, Bullet Time & Montage Curves", (253, 186, 116),
                          (234, 88, 12, 120), (234, 179, 8, 80), 'screenshot_3_velocity_curves.png')

# 4. Slide 4: Audio Extractor
c4 = create_floating_card("🎙️", "Video Audio Ripper", "Extract Sound Directly from Video", (40, 16, 28, 235), (244, 114, 182, 230))
render_real_device_poster(os.path.join(BRAIN_DIR, 'real_device_audio.png'), c4, (660, 820),
                          "🎙️ FROM ANY VIDEO", (244, 114, 182),
                          "EXTRACT AUDIO", "Rip Trending Music & 1-Tap Mute Sound", (251, 164, 206),
                          (225, 29, 72, 120), (168, 85, 247, 85), 'screenshot_4_audio_extractor.png')

# 5. Slide 5: LUT Filters
c5 = create_floating_card("🎨", "Cinema Color LUT", "Hollywood Teal & Orange 90s", (40, 26, 14, 235), (251, 191, 36, 230))
render_real_device_poster(os.path.join(BRAIN_DIR, 'real_device_filters.png'), c5, (660, 820),
                          "🎨 CINEMA COLOR GRADE", (251, 191, 36),
                          "HOLLYWOOD FILTERS", "Teal & Orange, Cyberpunk & 90s Vintage", (253, 224, 71),
                          (217, 119, 6, 120), (139, 92, 246, 80), 'screenshot_5_lut_filters.png')

# 6. Slide 6: 4K Export
c6 = create_floating_card("💎", "4K 60FPS Ultra HD", "Hardware Encoded • Zero Watermark", (14, 38, 30, 235), (52, 211, 153, 230))
render_real_device_poster(os.path.join(BRAIN_DIR, 'real_device_export.png'), c6, (660, 820),
                          "💎 ULTRA HD AT 60 FPS", (52, 211, 153),
                          "4K EXPORT FREE", "100% Free Forever • Zero Watermark", (110, 231, 183),
                          (5, 150, 105, 120), (6, 182, 212, 80), 'screenshot_6_4k_export.png')

# 7. Slide 7: Viral Reels & Home
c7 = create_floating_card("🚀", "1-Tap Viral Presets", "Turn Photos into Trending Reels", (32, 18, 45, 235), (216, 180, 254, 230))
render_real_device_poster(os.path.join(BRAIN_DIR, 'real_live_screen_1.png'), c7, (660, 820),
                          "📸 PHOTOS TO VIDEO", (236, 72, 153),
                          "VIRAL REEL MAKER", "Auto Beat Sync & Trending Presets", (216, 180, 254),
                          (147, 51, 234, 120), (236, 72, 153, 80), 'screenshot_7_reels_slideshow.png')

print("ALL 7 REAL DEVICE POSTERS SUCCESSFULLY GENERATED AND SAVED!")
