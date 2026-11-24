import os, sys, math
from PIL import Image, ImageDraw, ImageFilter, ImageFont

BRAIN_DIR = '/Users/pritamsharma/.gemini/antigravity/brain/1924d82f-8c85-4f77-96d0-28de4bd5bc32'
OUT_DIR = '/Users/pritamsharma/Downloads/video_editor_app/play_store_assets/screenshots'
ASSETS_DIR = '/Users/pritamsharma/Downloads/video_editor_app/play_store_assets'
os.makedirs(OUT_DIR, exist_ok=True)

# Fonts
FONT_TITLE = '/System/Library/Fonts/Supplemental/DIN Alternate Bold.ttf'
FONT_SUB = '/System/Library/Fonts/Supplemental/Arial Bold.ttf'
FONT_BADGE = '/System/Library/Fonts/Supplemental/Arial Bold.ttf'
FONT_LOGO = '/System/Library/Fonts/HelveticaNeue.ttc'

def make_gradient(width, height, top_color, bottom_color):
    base = Image.new('RGBA', (width, height), top_color)
    top_r, top_g, top_b = top_color[:3]
    bot_r, bot_g, bot_b = bottom_color[:3]
    for y in range(height):
        ratio = y / float(height)
        r = int(top_r + (bot_r - top_r) * ratio)
        g = int(top_g + (bot_g - top_g) * ratio)
        b = int(top_b + (bot_b - top_b) * ratio)
        line = Image.new('RGBA', (width, 1), (r, g, b, 255))
        base.paste(line, (0, y))
    return base

def add_radial_glow(canvas, center_x, center_y, radius, glow_color):
    glow_layer = Image.new('RGBA', canvas.size, (0, 0, 0, 0))
    draw = ImageDraw.Draw(glow_layer)
    r_val, g_val, b_val = glow_color[:3]
    steps = 35
    for i in range(steps, 0, -1):
        cur_r = int(radius * (i / steps))
        alpha = int(glow_color[3] * (1.0 - (i / steps))**1.7)
        bbox = [center_x - cur_r, center_y - cur_r, center_x + cur_r, center_y + cur_r]
        draw.ellipse(bbox, fill=(r_val, g_val, b_val, alpha))
    glow_layer = glow_layer.filter(ImageFilter.GaussianBlur(35))
    return Image.alpha_composite(canvas, glow_layer)

def create_phone_mockup(screen_img, target_w=870, target_h=1620, radius=52, bezel=14):
    frame_w = target_w
    frame_h = target_h
    inner_w = frame_w - (bezel * 2)
    inner_h = frame_h - (bezel * 2)
    inner_r = radius - (bezel // 2)
    
    sw, sh = screen_img.size
    scale = max(inner_w / float(sw), inner_h / float(sh))
    new_sw = int(sw * scale)
    new_sh = int(sh * scale)
    scaled_screen = screen_img.resize((new_sw, new_sh), Image.Resampling.LANCZOS)
    
    crop_x = (new_sw - inner_w) // 2
    crop_y = 0
    cropped_screen = scaled_screen.crop((crop_x, crop_y, crop_x + inner_w, crop_y + inner_h))
    
    screen_mask = Image.new('L', (inner_w * 2, inner_h * 2), 0)
    m_draw = ImageDraw.Draw(screen_mask)
    m_draw.rounded_rectangle([0, 0, inner_w * 2, inner_h * 2], radius=inner_r * 2, fill=255)
    screen_mask = screen_mask.resize((inner_w, inner_h), Image.Resampling.LANCZOS)
    
    rounded_screen = Image.new('RGBA', (inner_w, inner_h), (0, 0, 0, 0))
    rounded_screen.paste(cropped_screen, (0, 0))
    rounded_screen.putalpha(screen_mask)
    
    phone = Image.new('RGBA', (frame_w, frame_h), (0, 0, 0, 0))
    frame_mask = Image.new('L', (frame_w * 2, frame_h * 2), 0)
    f_draw = ImageDraw.Draw(frame_mask)
    f_draw.rounded_rectangle([0, 0, frame_w * 2, frame_h * 2], radius=radius * 2, fill=255)
    frame_mask = frame_mask.resize((frame_w, frame_h), Image.Resampling.LANCZOS)
    
    frame_bg = Image.new('RGBA', (frame_w, frame_h), (20, 22, 28, 255))
    frame_bg.putalpha(frame_mask)
    
    border_layer = Image.new('RGBA', (frame_w, frame_h), (0, 0, 0, 0))
    b_draw = ImageDraw.Draw(border_layer)
    b_draw.rounded_rectangle([1, 1, frame_w - 2, frame_h - 2], radius=radius, outline=(65, 72, 88, 220), width=2)
    b_draw.rounded_rectangle([3, 3, frame_w - 4, frame_h - 4], radius=radius - 2, outline=(25, 27, 34, 255), width=bezel - 3)
    
    phone = Image.alpha_composite(phone, frame_bg)
    phone = Image.alpha_composite(phone, border_layer)
    phone.paste(rounded_screen, (bezel, bezel), rounded_screen)
    
    # Island punch-hole
    island_w, island_h = 110, 28
    island_x = (frame_w - island_w) // 2
    island_y = bezel + 12
    p_draw = ImageDraw.Draw(phone)
    p_draw.rounded_rectangle([island_x, island_y, island_x + island_w, island_y + island_h], radius=14, fill=(10, 10, 14, 255))
    p_draw.ellipse([island_x + 22, island_y + 8, island_x + 34, island_y + 20], fill=(20, 25, 38, 255))
    p_draw.ellipse([island_x + 25, island_y + 11, island_x + 29, island_y + 15], fill=(45, 55, 80, 255))
    
    return phone

def add_drop_shadow(canvas, element, pos, offset=(0, 28), blur_radius=42, shadow_color=(0, 0, 0, 175)):
    shadow = Image.new('RGBA', canvas.size, (0, 0, 0, 0))
    alpha = element.split()[-1]
    s_elem = Image.new('RGBA', element.size, shadow_color)
    s_elem.putalpha(alpha)
    sx = pos[0] + offset[0]
    sy = pos[1] + offset[1]
    shadow.paste(s_elem, (sx, sy), s_elem)
    shadow = shadow.filter(ImageFilter.GaussianBlur(blur_radius))
    canvas = Image.alpha_composite(canvas, shadow)
    canvas.paste(element, pos, element)
    return canvas

def render_pill_badge(draw, text, x_center, y, font, bg_color, border_color, text_color=(255, 255, 255, 255)):
    bbox = font.getbbox(text)
    text_w = bbox[2] - bbox[0]
    text_h = bbox[3] - bbox[1]
    pad_x = 24
    pad_y = 10
    pill_w = text_w + pad_x * 2
    pill_h = text_h + pad_y * 2
    pill_x = x_center - pill_w // 2
    draw.rounded_rectangle([pill_x, y, pill_x + pill_w, y + pill_h], radius=pill_h//2, fill=bg_color, outline=border_color, width=2)
    draw.text((pill_x + pad_x, y + pad_y - bbox[1]), text, font=font, fill=text_color)
    return pill_w, pill_h

def build_screenshot_card(cfg):
    canvas_w, canvas_h = 1080, 1920
    bg = make_gradient(canvas_w, canvas_h, cfg['bg_top'], cfg['bg_bot'])
    
    for glow in cfg['glows']:
        bg = add_radial_glow(bg, glow['x'], glow['y'], glow['r'], glow['color'])
        
    src_img = Image.open(cfg['source_path']).convert('RGBA')
    
    # Custom patch for home screen if branding needs to be VidCut
    if cfg.get('patch_vidcut_logo'):
        p_draw = ImageDraw.Draw(src_img)
        p_draw.rectangle([(110, 160), (460, 215)], fill=(20, 24, 36))
        logo_f = ImageFont.truetype(FONT_LOGO, 48, index=0)
        p_draw.text((113, 165), 'VidCut', font=logo_f, fill=(255, 255, 255))
        
    phone = create_phone_mockup(src_img, target_w=870, target_h=1620, radius=52, bezel=14)
    bg = add_drop_shadow(bg, phone, pos=(105, 305), offset=(0, 28), blur_radius=42, shadow_color=(0, 0, 0, 180))
    
    draw = ImageDraw.Draw(bg)
    title_font = ImageFont.truetype(FONT_TITLE, cfg.get('title_size', 68))
    sub_font = ImageFont.truetype(FONT_SUB, 32)
    badge_font = ImageFont.truetype(FONT_BADGE, 24)
    
    # Draw badges
    b1_text = cfg['badge1']['text']
    b2_text = cfg['badge2']['text']
    b1_bbox = badge_font.getbbox(b1_text)
    b2_bbox = badge_font.getbbox(b2_text)
    p1_w = (b1_bbox[2] - b1_bbox[0]) + 48
    p2_w = (b2_bbox[2] - b2_bbox[0]) + 48
    gap = 20
    total_w = p1_w + gap + p2_w
    start_x = (canvas_w - total_w) // 2
    
    render_pill_badge(draw, b1_text, start_x + p1_w//2, 60, badge_font,
                      bg_color=cfg['badge1']['bg'], border_color=cfg['badge1']['border'])
    render_pill_badge(draw, b2_text, start_x + p1_w + gap + p2_w//2, 60, badge_font,
                      bg_color=cfg['badge2']['bg'], border_color=cfg['badge2']['border'])
                      
    # Title
    title = cfg['title']
    t_bbox = title_font.getbbox(title)
    t_w = t_bbox[2] - t_bbox[0]
    draw.text(((canvas_w - t_w)//2, 130), title, font=title_font, fill=(255, 255, 255))
    
    # Subtitle
    subtitle = cfg['subtitle']
    s_bbox = sub_font.getbbox(subtitle)
    s_w = s_bbox[2] - s_bbox[0]
    draw.text(((canvas_w - s_w)//2, 218), subtitle, font=sub_font, fill=cfg['sub_color'])
    
    out_path = os.path.join(OUT_DIR, cfg['filename'])
    bg.convert('RGB').save(out_path, quality=95)
    print("Generated:", out_path)
    return out_path

slides = [
    {
        'filename': 'screenshot_1_hero_editor.png',
        'title': 'PRO VIDEO EDITOR & MAKER',
        'subtitle': 'Multi-Track Timeline • Millisecond Precision Trimming',
        'sub_color': (56, 189, 248),
        'bg_top': (12, 14, 22),
        'bg_bot': (19, 23, 36),
        'source_path': os.path.join(BRAIN_DIR, 'novacut_editor_active_pro.png'),
        'badge1': {'text': '⚡ 100% FREE VIP', 'bg': (124, 58, 237, 70), 'border': (192, 132, 252, 220)},
        'badge2': {'text': '🚫 NO WATERMARK', 'bg': (239, 68, 68, 70), 'border': (248, 113, 113, 220)},
        'glows': [
            {'x': 540, 'y': 950, 'r': 650, 'color': (124, 58, 237, 75)},
            {'x': 250, 'y': 300, 'r': 350, 'color': (6, 182, 212, 45)}
        ]
    },
    {
        'filename': 'screenshot_2_transitions.png',
        'title': 'CINEMATIC TRANSITIONS',
        'subtitle': 'Glitch, Zoom, Dissolve & Flash FX • 1-Tap Apply to All',
        'sub_color': (147, 197, 253),
        'bg_top': (10, 15, 28),
        'bg_bot': (16, 25, 46),
        'source_path': os.path.join(BRAIN_DIR, 'novacut_transitions_drawer.png'),
        'badge1': {'text': '🔀 10+ PRO TRANSITIONS', 'bg': (37, 99, 235, 70), 'border': (96, 165, 250, 220)},
        'badge2': {'text': '✨ 1-TAP APPLY ALL', 'bg': (6, 182, 212, 70), 'border': (103, 232, 249, 220)},
        'glows': [
            {'x': 540, 'y': 1100, 'r': 650, 'color': (37, 99, 235, 80)},
            {'x': 800, 'y': 400, 'r': 400, 'color': (6, 182, 212, 50)}
        ]
    },
    {
        'filename': 'screenshot_3_velocity_curves.png',
        'title': 'VELOCITY SPEED CURVES',
        'subtitle': 'Smooth Slow-Mo & Hero Ramping • Montage & Bullet Time',
        'sub_color': (253, 186, 116),
        'bg_top': (18, 14, 12),
        'bg_bot': (32, 22, 18),
        'source_path': os.path.join(BRAIN_DIR, 'novacut_curves_active.png'),
        'badge1': {'text': '🏎️ 0.25x - 4.0x SPEED', 'bg': (234, 88, 12, 70), 'border': (251, 146, 60, 220)},
        'badge2': {'text': '🎵 BEAT SYNC CURVES', 'bg': (202, 138, 4, 70), 'border': (250, 204, 21, 220)},
        'glows': [
            {'x': 540, 'y': 1050, 'r': 650, 'color': (234, 88, 12, 75)},
            {'x': 250, 'y': 350, 'r': 380, 'color': (234, 179, 8, 45)}
        ]
    },
    {
        'filename': 'screenshot_4_audio_extractor.png',
        'title': 'EXTRACT AUDIO FROM ANY VIDEO',
        'title_size': 62,
        'subtitle': 'Rip Trending Reel Audio • 1-Tap Mute Original Sound',
        'sub_color': (244, 114, 182),
        'bg_top': (18, 10, 22),
        'bg_bot': (30, 16, 38),
        'source_path': os.path.join(BRAIN_DIR, 'novacut_audio_sheet.png'),
        'badge1': {'text': '🎙️ VIDEO AUDIO RIPPER', 'bg': (225, 29, 72, 70), 'border': (251, 113, 133, 220)},
        'badge2': {'text': '🔇 1-TAP MUTE SOUND', 'bg': (168, 85, 247, 70), 'border': (216, 180, 254, 220)},
        'glows': [
            {'x': 540, 'y': 1050, 'r': 650, 'color': (225, 29, 72, 75)},
            {'x': 750, 'y': 380, 'r': 380, 'color': (168, 85, 247, 50)}
        ]
    },
    {
        'filename': 'screenshot_5_lut_filters.png',
        'title': 'HOLLYWOOD LUT FILTERS',
        'subtitle': 'Teal & Orange, Cyberpunk Neon, 90s Vintage & Noir',
        'sub_color': (251, 191, 36),
        'bg_top': (16, 12, 24),
        'bg_bot': (28, 18, 40),
        'source_path': os.path.join(BRAIN_DIR, 'novacut_filters.png'),
        'badge1': {'text': '🎨 PRO COLOR GRADES', 'bg': (217, 119, 6, 70), 'border': (251, 191, 36, 220)},
        'badge2': {'text': '⚡ REALTIME PREVIEWS', 'bg': (139, 92, 246, 70), 'border': (196, 181, 253, 220)},
        'glows': [
            {'x': 540, 'y': 1100, 'r': 650, 'color': (217, 119, 6, 75)},
            {'x': 250, 'y': 350, 'r': 380, 'color': (139, 92, 246, 50)}
        ]
    },
    {
        'filename': 'screenshot_6_4k_export.png',
        'title': '4K 60FPS ULTRA HD EXPORT',
        'subtitle': '100% Free Forever • Zero Watermark • Ultra Bitrate',
        'sub_color': (52, 211, 153),
        'bg_top': (8, 20, 18),
        'bg_bot': (14, 34, 30),
        'source_path': os.path.join(BRAIN_DIR, 'novacut_export_pro_free.png'),
        'badge1': {'text': '💎 4K 60FPS ULTRA HD', 'bg': (5, 150, 105, 70), 'border': (52, 211, 153, 220)},
        'badge2': {'text': '🚫 ZERO WATERMARK', 'bg': (239, 68, 68, 70), 'border': (248, 113, 113, 220)},
        'glows': [
            {'x': 540, 'y': 1050, 'r': 650, 'color': (5, 150, 105, 75)},
            {'x': 780, 'y': 350, 'r': 380, 'color': (6, 182, 212, 50)}
        ]
    },
    {
        'filename': 'screenshot_7_reels_slideshow.png',
        'title': 'VIRAL REELS & PHOTO SLIDESHOW',
        'title_size': 62,
        'subtitle': 'Turn Photos into Trending Reels with Music in Seconds',
        'sub_color': (192, 132, 252),
        'bg_top': (14, 12, 26),
        'bg_bot': (24, 20, 44),
        'source_path': os.path.join(BRAIN_DIR, 'novacut_home_pro.png'),
        'patch_vidcut_logo': True,
        'badge1': {'text': '🚀 1-TAP REEL MAKER', 'bg': (147, 51, 234, 70), 'border': (216, 180, 254, 220)},
        'badge2': {'text': '📸 PHOTO TO VIDEO', 'bg': (236, 72, 153, 70), 'border': (244, 114, 182, 220)},
        'glows': [
            {'x': 540, 'y': 950, 'r': 650, 'color': (147, 51, 234, 75)},
            {'x': 250, 'y': 350, 'r': 380, 'color': (236, 72, 153, 50)}
        ]
    }
]

print("Generating all 7 Play Store screenshot cards...")
for slide in slides:
    build_screenshot_card(slide)

print("All 7 screenshots created successfully!")
