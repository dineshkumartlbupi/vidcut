import os, sys, math
from PIL import Image, ImageDraw, ImageFilter, ImageFont, ImageEnhance

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

# Load sample footage images
img_sunset = Image.open(os.path.join(FOOTAGE_DIR, 'footage_hero_sunset.jpg')).convert('RGBA')
img_skater = Image.open(os.path.join(FOOTAGE_DIR, 'footage_action_skater.jpg')).convert('RGBA')
img_coastal = Image.open(os.path.join(FOOTAGE_DIR, 'footage_fashion_coastal.jpg')).convert('RGBA')

print("Assets loaded successfully!")

def fit_crop(img, tw, th):
    sw, sh = img.size
    scale = max(tw / float(sw), th / float(sh))
    nw, nh = int(sw * scale), int(sh * scale)
    scaled = img.resize((nw, nh), Image.Resampling.LANCZOS)
    cx = (nw - tw) // 2
    cy = (nh - th) // 2
    return scaled.crop((cx, cy, cx + tw, cy + th))

def build_flagship_device(screen_img, target_w=870, target_h=1600, radius=50, bezel=12):
    phone_w = target_w
    phone_h = target_h
    inner_w = phone_w - (bezel * 2)
    inner_h = phone_h - (bezel * 2)
    inner_r = radius - (bezel // 2)
    
    # Scale and crop inner screen
    scaled_screen = fit_crop(screen_img, inner_w, inner_h)
    
    # Rounded mask for screen
    screen_mask = Image.new('L', (inner_w * 2, inner_h * 2), 0)
    m_draw = ImageDraw.Draw(screen_mask)
    m_draw.rounded_rectangle([0, 0, inner_w * 2, inner_h * 2], radius=inner_r * 2, fill=255)
    screen_mask = screen_mask.resize((inner_w, inner_h), Image.Resampling.LANCZOS)
    
    rounded_screen = Image.new('RGBA', (inner_w, inner_h), (0, 0, 0, 0))
    rounded_screen.paste(scaled_screen, (0, 0))
    rounded_screen.putalpha(screen_mask)
    
    # Subtle glass reflection across top right
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
    
    # Phone body with side buttons
    button_w = 6
    total_w = phone_w + button_w * 2
    total_h = phone_h
    
    body = Image.new('RGBA', (total_w, total_h), (0, 0, 0, 0))
    b_draw = ImageDraw.Draw(body)
    
    # Hardware buttons
    b_draw.rounded_rectangle([0, 220, button_w + 3, 300], radius=3, fill=(55, 60, 75, 255)) # Vol Up
    b_draw.rounded_rectangle([0, 320, button_w + 3, 400], radius=3, fill=(55, 60, 75, 255)) # Vol Down
    b_draw.rounded_rectangle([total_w - button_w - 3, 260, total_w, 370], radius=3, fill=(55, 60, 75, 255)) # Power
    
    # Chassis mask
    c_mask = Image.new('L', (phone_w * 2, phone_h * 2), 0)
    cm_draw = ImageDraw.Draw(c_mask)
    cm_draw.rounded_rectangle([0, 0, phone_w * 2, phone_h * 2], radius=radius * 2, fill=255)
    c_mask = c_mask.resize((phone_w, phone_h), Image.Resampling.LANCZOS)
    
    chassis = Image.new('RGBA', (phone_w, phone_h), (22, 24, 30, 255))
    chassis.putalpha(c_mask)
    
    # Metallic specular edge border
    rim_layer = Image.new('RGBA', (phone_w, phone_h), (0, 0, 0, 0))
    r_draw = ImageDraw.Draw(rim_layer)
    r_draw.rounded_rectangle([1, 1, phone_w - 2, phone_h - 2], radius=radius, outline=(90, 100, 120, 230), width=2)
    r_draw.rounded_rectangle([3, 3, phone_w - 4, phone_h - 4], radius=radius - 2, outline=(18, 19, 24, 255), width=bezel - 3)
    # Specular light arc on top-left curve
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

print("Flagship device builder ready")

def create_ambient_poster_bg(footage_img, glow1, glow2):
    bg = footage_img.resize((CANVAS_W, CANVAS_H), Image.Resampling.LANCZOS)
    bg = bg.filter(ImageFilter.GaussianBlur(90))
    bg = ImageEnhance.Brightness(bg).enhance(0.35)
    bg = ImageEnhance.Color(bg).enhance(1.4)
    
    # Overlay dark studio navy
    dark = Image.new('RGBA', (CANVAS_W, CANVAS_H), (10, 13, 20, 150))
    bg = Image.alpha_composite(bg, dark)
    
    # Add colored spotlights
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
    
    # Top gradient fade for crystal clear text legibility
    fade = Image.new('RGBA', (CANVAS_W, CANVAS_H), (0, 0, 0, 0))
    f_draw = ImageDraw.Draw(fade)
    for y in range(460):
        a = int(240 * (1.0 - (y / 460.0)**1.3))
        f_draw.line([(0, y), (CANVAS_W, y)], fill=(8, 10, 16, a))
    bg = Image.alpha_composite(bg, fade)
    return bg

def create_floating_popout_card(icon_str, title_str, sub_str, bg_color, border_color):
    cw, ch = 340, 105
    card = Image.new('RGBA', (cw, ch), (0, 0, 0, 0))
    c_mask = Image.new('L', (cw * 2, ch * 2), 0)
    cm_draw = ImageDraw.Draw(c_mask)
    cm_draw.rounded_rectangle([0, 0, cw * 2, ch * 2], radius=36, fill=255)
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

def render_poster_card(bg, screen_img, popout_card, popout_pos,
                       hook_text, hook_color,
                       main_title, sub_text, sub_color):
    phone = build_flagship_device(screen_img, target_w=870, target_h=1590, radius=50, bezel=12)
    phone_x, phone_y = 100, 330
    
    # Drop shadows
    # Contact shadow
    c_shadow = Image.new('RGBA', (CANVAS_W, CANVAS_H), (0, 0, 0, 0))
    p_alpha = phone.split()[-1]
    c_fill = Image.new('RGBA', phone.size, (0, 0, 0, 220))
    c_fill.putalpha(p_alpha)
    c_shadow.paste(c_fill, (phone_x, phone_y + 14), c_fill)
    c_shadow = c_shadow.filter(ImageFilter.GaussianBlur(22))
    bg = Image.alpha_composite(bg, c_shadow)
    
    # Diffuse shadow
    d_shadow = Image.new('RGBA', (CANVAS_W, CANVAS_H), (0, 0, 0, 0))
    d_fill = Image.new('RGBA', phone.size, (0, 0, 0, 150))
    d_fill.putalpha(p_alpha)
    d_shadow.paste(d_fill, (phone_x, phone_y + 38), d_fill)
    d_shadow = d_shadow.filter(ImageFilter.GaussianBlur(50))
    bg = Image.alpha_composite(bg, d_shadow)
    
    # Paste Phone
    bg.paste(phone, (phone_x, phone_y), phone)
    
    # Floating Popout Card
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
        
    # Typography: InShot / YouCut Signature Layout
    draw = ImageDraw.Draw(bg)
    f_hook = ImageFont.truetype(FONT_BADGE, 28)
    f_main = ImageFont.truetype(FONT_TITLE, 82)
    f_sub = ImageFont.truetype(FONT_SUB, 32)
    
    # 1. Hook Kicker (Centered at y = 75)
    h_bb = f_hook.getbbox(hook_text)
    hw = h_bb[2] - h_bb[0]
    # Pill background for hook
    pill_w = hw + 44
    pill_h = (h_bb[3] - h_bb[1]) + 20
    px = (CANVAS_W - pill_w) // 2
    draw.rounded_rectangle([px, 60, px + pill_w, 60 + pill_h], radius=pill_h//2,
                           fill=(20, 24, 38, 220), outline=hook_color, width=2)
    draw.text((px + 22, 68), hook_text, font=f_hook, fill=hook_color)
    
    # 2. Huge Main Headline (Centered at y = 135)
    m_bb = f_main.getbbox(main_title)
    mw = m_bb[2] - m_bb[0]
    mx = (CANVAS_W - mw) // 2
    # Drop shadow on title
    for ox, oy in [(-2,2), (2,2), (0,3), (0,4)]:
        draw.text((mx + ox, 135 + oy), main_title, font=f_main, fill=(0, 0, 0, 230))
    draw.text((mx, 135), main_title, font=f_main, fill=(255, 255, 255))
    
    # 3. Subtitle (Centered at y = 238)
    s_bb = f_sub.getbbox(sub_text)
    sw = s_bb[2] - s_bb[0]
    sx = (CANVAS_W - sw) // 2
    draw.text((sx, 238), sub_text, font=f_sub, fill=sub_color)
    
    return bg

print("Poster card rendering framework ready")

def create_native_editor_ui(footage_img, viral_caption, active_tool='trim'):
    screen = Image.new('RGBA', (1080, 2400), (18, 22, 34, 255))
    draw = ImageDraw.Draw(screen)
    
    f_bar_title = ImageFont.truetype('/System/Library/Fonts/Supplemental/Arial Bold.ttf', 32)
    f_bar_sub = ImageFont.truetype('/System/Library/Fonts/Supplemental/Arial Bold.ttf', 22)
    f_btn = ImageFont.truetype('/System/Library/Fonts/Supplemental/Arial Bold.ttf', 24)
    f_badge = ImageFont.truetype('/System/Library/Fonts/Supplemental/Arial Bold.ttf', 20)
    f_caption = ImageFont.truetype('/System/Library/Fonts/Supplemental/DIN Alternate Bold.ttf', 52)
    f_tool = ImageFont.truetype('/System/Library/Fonts/Supplemental/Arial Bold.ttf', 20)
    
    # 1. Top App Bar (y: 70 to 170)
    # Back button
    draw.text((45, 105), "←", font=f_bar_title, fill=(255, 255, 255))
    # Project Title
    draw.text((115, 95), "Travel Reel 2026", font=f_bar_title, fill=(255, 255, 255))
    draw.text((115, 135), "00:15.00 • 4K UHD", font=f_bar_sub, fill=(148, 163, 184))
    
    # Undo / Redo
    draw.text((630, 105), "↩", font=f_bar_title, fill=(203, 213, 225))
    draw.text((710, 105), "↪", font=f_bar_title, fill=(203, 213, 225))
    
    # Export Button (Glowing Purple Pill)
    draw.rounded_rectangle([790, 90, 1035, 155], radius=32, fill=(124, 58, 237, 255), outline=(192, 132, 252, 220), width=2)
    draw.text((820, 105), "💎 Export 4K", font=f_btn, fill=(255, 255, 255))
    
    # 2. Centered Video Player Preview (y: 200 to 1160)
    pw, ph = 680, 960
    px = (1080 - pw) // 2
    py = 200
    
    # Outer frame border for player
    draw.rounded_rectangle([px - 4, py - 4, px + pw + 4, py + ph + 4], radius=24, outline=(45, 55, 78, 200), width=3)
    
    video_crop = fit_crop(footage_img, pw, ph)
    v_mask = Image.new('L', (pw * 2, ph * 2), 0)
    ImageDraw.Draw(v_mask).rounded_rectangle([0, 0, pw * 2, ph * 2], radius=44, fill=255)
    v_mask = v_mask.resize((pw, ph), Image.Resampling.LANCZOS)
    video_crop.putalpha(v_mask)
    
    # HUD Overlays on video
    v_draw = ImageDraw.Draw(video_crop)
    # 4K 60FPS
    v_draw.rounded_rectangle([20, 20, 140, 56], radius=8, fill=(0, 0, 0, 160), outline=(255, 255, 255, 160), width=1)
    v_draw.text((32, 27), "4K 60FPS", font=f_badge, fill=(255, 255, 255))
    # 9:16 REEL
    v_draw.rounded_rectangle([pw - 130, 20, pw - 20, 56], radius=8, fill=(0, 0, 0, 160), outline=(56, 189, 248, 200), width=1)
    v_draw.text((pw - 118, 27), "9:16 REEL", font=f_badge, fill=(56, 189, 248))
    
    # Viral Caption on Video
    if viral_caption:
        c_bb = f_caption.getbbox(viral_caption)
        cw = c_bb[2] - c_bb[0]
        cx_pos = (pw - cw) // 2
        cy_pos = ph - 150
        for ox, oy in [(-3,0),(3,0),(0,-3),(0,3),(-3,-3),(3,3)]:
            v_draw.text((cx_pos + ox, cy_pos + oy), viral_caption, font=f_caption, fill=(0, 0, 0, 250))
        v_draw.text((cx_pos, cy_pos), viral_caption, font=f_caption, fill=(255, 230, 0))
        
    # Timecode
    v_draw.rounded_rectangle([20, ph - 60, 200, ph - 18], radius=8, fill=(0, 0, 0, 170))
    v_draw.text((32, ph - 52), "00:03.14 / 00:15", font=f_badge, fill=(255, 255, 255))
    
    screen.paste(video_crop, (px, py), video_crop)
    
    # 3. Action Controls (y: 1180 to 1270)
    # Current time
    draw.text((80, 1205), "00:03.14", font=f_bar_title, fill=(255, 255, 255))
    # Circular Play Button at center
    draw.ellipse([540 - 36, 1215 - 36, 540 + 36, 1215 + 36], fill=(124, 58, 237, 255), outline=(192, 132, 252, 220), width=2)
    draw.polygon([(532, 1200), (532, 1230), (556, 1215)], fill=(255, 255, 255))
    # Quick Split icon
    draw.text((360, 1205), "✂️ Split", font=f_btn, fill=(203, 213, 225))
    # Duration
    draw.text((900, 1205), "00:15.00", font=f_bar_sub, fill=(148, 163, 184))
    
    # 4. Multi-Track Timeline (y: 1270 to 1690)
    # Background timeline container
    draw.rounded_rectangle([30, 1270, 1050, 1690], radius=20, fill=(12, 15, 24, 255), outline=(35, 42, 60, 200), width=2)
    
    # Time ruler ticks
    r_font = ImageFont.truetype('/System/Library/Fonts/Supplemental/Arial Bold.ttf', 16)
    ticks = ["00:00", "00:02", "00:04", "00:06", "00:08", "00:10", "00:12"]
    for idx, t in enumerate(ticks):
        tx = 70 + idx * 150
        draw.line([(tx, 1280), (tx, 1295)], fill=(100, 116, 139, 200), width=2)
        draw.text((tx - 18, 1300), t, font=r_font, fill=(148, 163, 184))
        
    # Main Video Track (y: 1330 to 1470, height 140)
    # 6 video thumbnail blocks
    tw = 150
    thumb = fit_crop(footage_img, tw, 140)
    for idx in range(6):
        screen.paste(thumb, (70 + idx * tw, 1330))
        # Draw frame separator
        draw.line([(70 + idx * tw, 1330), (70 + idx * tw, 1470)], fill=(0, 0, 0, 180), width=2)
        
    # Yellow selection outline on selected clip (from x=220 to x=670)
    draw.rounded_rectangle([220, 1326, 670, 1474], radius=10, outline=(250, 204, 21, 255), width=4)
    # Clip trim handles at left and right
    draw.rounded_rectangle([212, 1350, 222, 1450], radius=4, fill=(250, 204, 21, 255))
    draw.rounded_rectangle([668, 1350, 678, 1450], radius=4, fill=(250, 204, 21, 255))
    
    # Audio Track (y: 1485 to 1575, height 90)
    draw.rounded_rectangle([70, 1485, 970, 1575], radius=14, fill=(49, 26, 85, 230), outline=(139, 92, 246, 200), width=2)
    f_aud = ImageFont.truetype('/System/Library/Fonts/Supplemental/Arial Bold.ttf', 20)
    draw.text((90, 1495), "🎵 Summer Vibes • Chill Lo-Fi Beats (02:45)", font=f_aud, fill=(255, 255, 255))
    # Waveform visualizer bars
    for bx in range(90, 950, 12):
        bar_h = 10 + int(35 * abs(math.sin(bx * 0.08)))
        draw.line([(bx, 1560 - bar_h), (bx, 1560)], fill=(56, 189, 248, 230), width=4)
        
    # Text Track (y: 1590 to 1660, height 70)
    draw.rounded_rectangle([220, 1590, 670, 1660], radius=12, fill=(120, 53, 15, 230), outline=(245, 158, 11, 200), width=2)
    f_txt = ImageFont.truetype('/System/Library/Fonts/Supplemental/Arial Bold.ttf', 20)
    draw.text((245, 1608), "💬 Title: " + (viral_caption or "Video Title"), font=f_txt, fill=(255, 255, 255))
    
    # Vertical Playhead Line traversing through all tracks at x=540
    draw.line([(540, 1300), (540, 1680)], fill=(255, 255, 255, 255), width=4)
    draw.polygon([(530, 1290), (550, 1290), (540, 1310)], fill=(255, 255, 255))
    
    # 5. Bottom Toolbar (y: 1710 to 1980)
    tools = [
        ("✂️", "Trim", "trim"),
        ("🔀", "Transitions", "trans"),
        ("🏎️", "Speed", "speed"),
        ("🎵", "Music", "music"),
        ("🎨", "Filters", "filter"),
        ("💬", "Text", "text"),
        ("🖼️", "PIP", "pip"),
        ("🔄", "Reverse", "rev")
    ]
    for idx, (t_icon, t_name, t_id) in enumerate(tools):
        tx = 50 + idx * 125
        is_active = (t_id == active_tool)
        if is_active:
            draw.rounded_rectangle([tx - 6, 1720, tx + 94, 1840], radius=16, fill=(124, 58, 237, 80), outline=(192, 132, 252, 220), width=2)
        f_ti = ImageFont.truetype('/System/Library/Fonts/Supplemental/Arial Bold.ttf', 36)
        draw.text((tx + 22, 1735), t_icon, font=f_ti, fill=(255, 255, 255))
        draw.text((tx + 10, 1795), t_name, font=f_tool, fill=(255, 255, 255) if is_active else (148, 163, 184))
        
    return screen

print("Native editor UI generator ready")

print("Rendering all 7 InShot/YouCut Tier-1 Play Store Posters...")

# ==============================================================================
# 1. SLIDE 1: Hero Video Editor
# ==============================================================================
print("Generating Poster 1: Pro Video Editor & No Watermark...")
bg1 = create_ambient_poster_bg(img_sunset, (124, 58, 237, 120), (6, 182, 212, 80))
ui1 = create_native_editor_ui(img_sunset, "GOLDEN HOUR 🌅", active_tool='trim')
card1 = create_floating_popout_card("✂️", "Millisecond Cut", "1-Tap Split & Trim Video",
                                   (18, 24, 38, 235), (96, 165, 250, 230))
p1 = render_poster_card(bg1, ui1, card1, (660, 880),
                        "⚡ 100% FREE VIP", (250, 204, 21), # Neon Yellow
                        "NO WATERMARK",
                        "Pro Video Editor & Reels Maker",
                        (56, 189, 248))
p1.convert('RGB').save(os.path.join(OUT_DIR, 'screenshot_1_hero_editor.png'), quality=96)
p1.convert('RGB').save(os.path.join(DOWNLOADS_OUT, 'screenshot_1_hero_editor.png'), quality=96)
p1.convert('RGB').save(os.path.join(BRAIN_DIR, 'screenshot_1_hero_editor.png'), quality=96)

# ==============================================================================
# 2. SLIDE 2: Cinematic Transitions Suite
# ==============================================================================
print("Generating Poster 2: Cinematic Transitions...")
bg2 = create_ambient_poster_bg(img_coastal, (37, 99, 235, 120), (6, 182, 212, 90))
base2 = Image.open(os.path.join(BRAIN_DIR, 'novacut_transitions_drawer.png')).convert('RGBA')

# In player area (x: 200 to 880, y: 220 to 1100), composite transition split
pw, ph = 680, 880
px, py = (1080 - pw) // 2, 220
f_left = fit_crop(img_sunset, pw, ph)
f_right = fit_crop(img_coastal, pw, ph)

trans_player = Image.new('RGBA', (pw, ph), (0, 0, 0, 0))
trans_player.paste(f_left, (0, 0))
trans_player.paste(f_right.crop((pw//2, 0, pw, ph)), (pw//2, 0))

# Split glow line & diamond
t_draw = ImageDraw.Draw(trans_player)
t_draw.line([(pw//2, 0), (pw//2, ph)], fill=(255, 255, 255, 240), width=4)
t_draw.rounded_rectangle([pw//2 - 32, ph//2 - 32, pw//2 + 32, ph//2 + 32], radius=10, fill=(37, 99, 235, 245), outline=(255, 255, 255, 255), width=2)
f_icon = ImageFont.truetype('/System/Library/Fonts/Supplemental/Arial Bold.ttf', 28)
t_draw.text((pw//2 - 16, ph//2 - 16), "🔀", font=f_icon, fill=(255, 255, 255))

base2.paste(trans_player, (px, py))

card2 = create_floating_popout_card("🔀", "1-Tap Apply to All", "10+ Cinematic FX Styles",
                                   (15, 28, 48, 235), (56, 189, 248, 230))
p2 = render_poster_card(bg2, base2, card2, (660, 820),
                        "✨ 1-TAP APPLY ALL", (56, 189, 248), # Electric Cyan
                        "SMOOTH TRANSITIONS",
                        "Glitch, Zoom, Dissolve & Flash FX",
                        (147, 197, 253))
p2.convert('RGB').save(os.path.join(OUT_DIR, 'screenshot_2_transitions.png'), quality=96)
p2.convert('RGB').save(os.path.join(DOWNLOADS_OUT, 'screenshot_2_transitions.png'), quality=96)
p2.convert('RGB').save(os.path.join(BRAIN_DIR, 'screenshot_2_transitions.png'), quality=96)

# ==============================================================================
# 3. SLIDE 3: Velocity Speed Curves (Speed Ramping)
# ==============================================================================
print("Generating Poster 3: Velocity Speed Curves...")
bg3 = create_ambient_poster_bg(img_skater, (234, 88, 12, 120), (234, 179, 8, 80))
base3 = Image.open(os.path.join(BRAIN_DIR, 'novacut_curves_active.png')).convert('RGBA')

# Mid-air action skater in player area
skater_v = fit_crop(img_skater, pw, ph)
sk_draw = ImageDraw.Draw(skater_v)
# Speed tag
sk_draw.rounded_rectangle([25, 25, 220, 75], radius=10, fill=(234, 88, 12, 230), outline=(255, 255, 255, 240), width=2)
f_spd = ImageFont.truetype('/System/Library/Fonts/Supplemental/DIN Alternate Bold.ttf', 30)
sk_draw.text((38, 32), "🏎️ 0.2x SLOW-MO", font=f_spd, fill=(255, 255, 255))

# Dynamic bezier curve graph overlaid at bottom
curve_pts = [(30, ph - 50), (160, ph - 50), (280, ph - 160), (420, ph - 40), (560, ph - 40), (650, ph - 120)]
sk_draw.line(curve_pts, fill=(251, 146, 60, 240), width=6)
for pt in curve_pts:
    sk_draw.ellipse([pt[0]-8, pt[1]-8, pt[0]+8, pt[1]+8], fill=(255, 255, 255), outline=(234, 88, 12), width=3)

base3.paste(skater_v, (px, py))

card3 = create_floating_popout_card("🏎️", "Bullet Time 0.2x", "Montage & Hero Speed Curves",
                                   (38, 22, 14, 235), (251, 146, 60, 230))
p3 = render_poster_card(bg3, base3, card3, (660, 820),
                        "🏎️ 0.25x - 4.0x SPEED", (251, 146, 60), # Sunset Orange
                        "VELOCITY SLOW-MO",
                        "Hero Climax, Bullet Time & Montage Curves",
                        (253, 186, 116))
p3.convert('RGB').save(os.path.join(OUT_DIR, 'screenshot_3_velocity_curves.png'), quality=96)
p3.convert('RGB').save(os.path.join(DOWNLOADS_OUT, 'screenshot_3_velocity_curves.png'), quality=96)
p3.convert('RGB').save(os.path.join(BRAIN_DIR, 'screenshot_3_velocity_curves.png'), quality=96)

# ==============================================================================
# 4. SLIDE 4: Audio Extraction & Studio
# ==============================================================================
print("Generating Poster 4: Audio Extraction & Studio...")
bg4 = create_ambient_poster_bg(img_coastal, (225, 29, 72, 120), (168, 85, 247, 85))
base4 = Image.open(os.path.join(BRAIN_DIR, 'novacut_audio_sheet.png')).convert('RGBA')

# Coastal clip with music waveform
audio_v = fit_crop(img_coastal, pw, ph)
av_draw = ImageDraw.Draw(audio_v)
# Music pill
av_draw.rounded_rectangle([25, ph - 95, pw - 25, ph - 25], radius=14, fill=(0, 0, 0, 210), outline=(244, 114, 182, 220), width=2)
f_m = ImageFont.truetype('/System/Library/Fonts/Supplemental/Arial Bold.ttf', 24)
av_draw.text((45, ph - 80), "🎵 Trending Audio: Summer Chill Beats (02:45)", font=f_m, fill=(255, 255, 255))

# 1-Tap Muted video tag
av_draw.rounded_rectangle([pw - 190, 25, pw - 25, 75], radius=10, fill=(225, 29, 72, 230), outline=(255, 255, 255, 240), width=2)
f_mu = ImageFont.truetype('/System/Library/Fonts/Supplemental/Arial Bold.ttf', 20)
av_draw.text((pw - 175, 38), "🔇 Video Muted", font=f_mu, fill=(255, 255, 255))

base4.paste(audio_v, (px, py))

card4 = create_floating_popout_card("🎙️", "Video Audio Ripper", "Extract Sound Directly from Video",
                                   (40, 16, 28, 235), (244, 114, 182, 230))
p4 = render_poster_card(bg4, base4, card4, (660, 820),
                        "🎙️ FROM ANY VIDEO", (244, 114, 182), # Hot Rose
                        "EXTRACT AUDIO",
                        "Rip Trending Music & 1-Tap Mute Sound",
                        (251, 164, 206))
p4.convert('RGB').save(os.path.join(OUT_DIR, 'screenshot_4_audio_extractor.png'), quality=96)
p4.convert('RGB').save(os.path.join(DOWNLOADS_OUT, 'screenshot_4_audio_extractor.png'), quality=96)
p4.convert('RGB').save(os.path.join(BRAIN_DIR, 'screenshot_4_audio_extractor.png'), quality=96)

# ==============================================================================
# 5. SLIDE 5: Hollywood LUT Filters
# ==============================================================================
print("Generating Poster 5: Hollywood LUT Filters...")
bg5 = create_ambient_poster_bg(img_sunset, (217, 119, 6, 120), (139, 92, 246, 80))
base5 = Image.open(os.path.join(BRAIN_DIR, 'novacut_filters.png')).convert('RGBA')

# Split Before/After in player
lut_base = fit_crop(img_sunset, pw, ph)
raw_side = ImageEnhance.Color(lut_base).enhance(0.35)
raw_side = ImageEnhance.Contrast(raw_side).enhance(0.8)
graded_side = ImageEnhance.Color(lut_base).enhance(1.65)
graded_side = ImageEnhance.Contrast(graded_side).enhance(1.25)

split_filter = Image.new('RGBA', (pw, ph), (0, 0, 0, 0))
split_filter.paste(raw_side, (0, 0))
split_filter.paste(graded_side.crop((pw//2, 0, pw, ph)), (pw//2, 0))

sf_draw = ImageDraw.Draw(split_filter)
sf_draw.line([(pw//2, 0), (pw//2, ph)], fill=(255, 255, 255, 240), width=4)

f_lbl = ImageFont.truetype('/System/Library/Fonts/Supplemental/Arial Bold.ttf', 20)
# RAW LOG tag
sf_draw.rounded_rectangle([25, 25, 150, 70], radius=8, fill=(0, 0, 0, 190), outline=(200, 200, 200, 200), width=1)
sf_draw.text((40, 35), "RAW LOG", font=f_lbl, fill=(200, 200, 200))
# TEAL & ORANGE tag
sf_draw.rounded_rectangle([pw - 180, 25, pw - 25, 70], radius=8, fill=(217, 119, 6, 230), outline=(255, 255, 255, 220), width=1)
sf_draw.text((pw - 165, 35), "TEAL & ORANGE", font=f_lbl, fill=(255, 255, 255))

# Center slider badge
sf_draw.rounded_rectangle([pw//2 - 75, ph//2 - 20, pw//2 + 75, ph//2 + 20], radius=20, fill=(0, 0, 0, 230), outline=(255, 255, 255, 240), width=2)
f_cmp = ImageFont.truetype('/System/Library/Fonts/Supplemental/Arial Bold.ttf', 17)
sf_draw.text((pw//2 - 62, ph//2 - 11), "◀ BEFORE | AFTER ▶", font=f_cmp, fill=(255, 255, 255))

base5.paste(split_filter, (px, py))

card5 = create_floating_popout_card("🎨", "Cinema Color LUT", "Hollywood Teal & Orange 90s",
                                   (40, 26, 14, 235), (251, 191, 36, 230))
p5 = render_poster_card(bg5, base5, card5, (660, 820),
                        "🎨 CINEMA COLOR GRADE", (251, 191, 36), # Warm Amber
                        "HOLLYWOOD FILTERS",
                        "Teal & Orange, Cyberpunk & 90s Vintage",
                        (253, 224, 71))
p5.convert('RGB').save(os.path.join(OUT_DIR, 'screenshot_5_lut_filters.png'), quality=96)
p5.convert('RGB').save(os.path.join(DOWNLOADS_OUT, 'screenshot_5_lut_filters.png'), quality=96)
p5.convert('RGB').save(os.path.join(BRAIN_DIR, 'screenshot_5_lut_filters.png'), quality=96)

# ==============================================================================
# 6. SLIDE 6: 4K 60FPS Ultra HD Export
# ==============================================================================
print("Generating Poster 6: 4K 60FPS Ultra HD Export...")
bg6 = create_ambient_poster_bg(img_sunset, (5, 150, 105, 120), (6, 182, 212, 80))
base6 = Image.open(os.path.join(BRAIN_DIR, 'novacut_export_pro_free.png')).convert('RGBA')

# Export thumbnail of real footage
export_th = fit_crop(img_sunset, 340, 440)
t_mask = Image.new('L', (340*2, 440*2), 0)
ImageDraw.Draw(t_mask).rounded_rectangle([0, 0, 340*2, 440*2], radius=36, fill=255)
t_mask = t_mask.resize((340, 440), Image.Resampling.LANCZOS)
export_th.putalpha(t_mask)
base6.paste(export_th, (370, 340), export_th)

card6 = create_floating_popout_card("💎", "4K 60FPS Ultra HD", "Hardware Encoded • Zero Watermark",
                                   (14, 38, 30, 235), (52, 211, 153, 230))
p6 = render_poster_card(bg6, base6, card6, (660, 820),
                        "💎 ULTRA HD AT 60 FPS", (52, 211, 153), # Emerald Green
                        "4K EXPORT FREE",
                        "100% Free Forever • Zero Watermark",
                        (110, 231, 183))
p6.convert('RGB').save(os.path.join(OUT_DIR, 'screenshot_6_4k_export.png'), quality=96)
p6.convert('RGB').save(os.path.join(DOWNLOADS_OUT, 'screenshot_6_4k_export.png'), quality=96)
p6.convert('RGB').save(os.path.join(BRAIN_DIR, 'screenshot_6_4k_export.png'), quality=96)

# ==============================================================================
# 7. SLIDE 7: Viral Reels & Photo Slideshow
# ==============================================================================
print("Generating Poster 7: Viral Reels & Photo Slideshow...")
bg7 = create_ambient_poster_bg(img_sunset, (147, 51, 234, 120), (236, 72, 153, 80))
base7 = Image.open(os.path.join(BRAIN_DIR, 'novacut_home_pro.png')).convert('RGBA')

# Patch VidCut branding on top header
p7_draw = ImageDraw.Draw(base7)
p7_draw.rectangle([(110, 160), (460, 215)], fill=(20, 24, 36))
logo_f = ImageFont.truetype(FONT_LOGO, 48, index=0)
p7_draw.text((113, 165), 'VidCut', font=logo_f, fill=(255, 255, 255))

# Patch real image previews into Photo Reel card
card_photo = fit_crop(img_coastal, 480, 250)
cp_mask = Image.new('L', (480*2, 250*2), 0)
ImageDraw.Draw(cp_mask).rounded_rectangle([0, 0, 480*2, 250*2], radius=28, fill=255)
cp_mask = cp_mask.resize((480, 250), Image.Resampling.LANCZOS)
card_photo.putalpha(cp_mask)
cp_grad = Image.new('RGBA', (480, 250), (0, 0, 0, 0))
for gx in range(480):
    a = int(180 * (gx / 480.0)**1.2)
    ImageDraw.Draw(cp_grad).line([(gx, 0), (gx, 250)], fill=(20, 24, 36, a))
card_photo = Image.alpha_composite(card_photo, cp_grad)
base7.paste(card_photo, (550, 480), card_photo)

card7 = create_floating_popout_card("🚀", "1-Tap Viral Presets", "Turn Photos into Trending Reels",
                                   (32, 18, 45, 235), (216, 180, 254, 230))
p7 = render_poster_card(bg7, base7, card7, (660, 820),
                        "📸 PHOTOS TO VIDEO", (236, 72, 153), # Vibrant Magenta
                        "VIRAL REEL MAKER",
                        "Auto Beat Sync & Trending Presets",
                        (216, 180, 254))
p7.convert('RGB').save(os.path.join(OUT_DIR, 'screenshot_7_reels_slideshow.png'), quality=96)
p7.convert('RGB').save(os.path.join(DOWNLOADS_OUT, 'screenshot_7_reels_slideshow.png'), quality=96)
p7.convert('RGB').save(os.path.join(BRAIN_DIR, 'screenshot_7_reels_slideshow.png'), quality=96)

print("ALL 7 TIER-1 INSHOT/YOUCUT POSTERS GENERATED SUCCESSFULLY!")
