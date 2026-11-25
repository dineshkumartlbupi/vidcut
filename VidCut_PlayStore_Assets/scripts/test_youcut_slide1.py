import os, sys
from PIL import Image, ImageDraw, ImageFilter, ImageFont

BRAIN_DIR = '/Users/pritamsharma/.gemini/antigravity/brain/1924d82f-8c85-4f77-96d0-28de4bd5bc32'
RAW_DIR = '/Users/pritamsharma/Downloads/VidCut_PlayStore_Assets/raw_device_screenshots'
OUT_DIR = '/Users/pritamsharma/Downloads/VidCut_PlayStore_Assets/screenshots'

FONT_TITLE = '/System/Library/Fonts/Supplemental/DIN Alternate Bold.ttf'
FONT_SUB = '/System/Library/Fonts/Supplemental/Arial Bold.ttf'

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
    bg = Image.new('RGBA', (CANVAS_W, CANVAS_H), (13, 15, 23, 255))
    
    # Smooth vertical mesh gradient
    for y in range(CANVAS_H):
        r = int(12 + (19 - 12) * (y / CANVAS_H))
        g = int(14 + (23 - 14) * (y / CANVAS_H))
        b = int(22 + (34 - 22) * (y / CANVAS_H))
        ImageDraw.Draw(bg).line([(0, y), (CANVAS_W, y)], fill=(r, g, b, 255))
        
    # Volumetric ambient backlight glow behind phone
    glow_layer = Image.new('RGBA', (CANVAS_W, CANVAS_H), (0, 0, 0, 0))
    d = ImageDraw.Draw(glow_layer)
    cx, cy = 540, 1080
    radius = 650
    r_val, g_val, b_val, a_max = accent_glow_color
    for i in range(35, 0, -1):
        cur_r = int(radius * (i / 35.0))
        alpha = int(a_max * (1.0 - (i / 35.0))**1.7)
        d.ellipse([cx - cur_r, cy - cur_r, cx + cur_r, cy + cur_r], fill=(r_val, g_val, b_val, alpha))
    glow_layer = glow_layer.filter(ImageFilter.GaussianBlur(40))
    bg = Image.alpha_composite(bg, glow_layer)
    
    # Gradient fade at top for punchy text legibility
    fade = Image.new('RGBA', (CANVAS_W, CANVAS_H), (0, 0, 0, 0))
    f_draw = ImageDraw.Draw(fade)
    for y in range(400):
        a = int(220 * (1.0 - (y / 400.0)**1.2))
        f_draw.line([(0, y), (CANVAS_W, y)], fill=(10, 12, 18, a))
    bg = Image.alpha_composite(bg, fade)
    return bg

def build_youcut_phone(screen_img, target_w=864, target_h=1560, radius=48, bezel=12):
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

def render_poster(screen_path, line1, line1_color, line2, sub, glow, out_name):
    real_screen = Image.open(screen_path).convert('RGBA')
    bg = create_youcut_bg(glow)
    phone = build_youcut_phone(real_screen, target_w=864, target_h=1560, radius=48, bezel=12)
    phone_x, phone_y = (CANVAS_W - phone.size[0]) // 2, 335
    
    # Shadows
    c_shadow = Image.new('RGBA', (CANVAS_W, CANVAS_H), (0, 0, 0, 0))
    p_alpha = phone.split()[-1]
    c_fill = Image.new('RGBA', phone.size, (0, 0, 0, 220))
    c_fill.putalpha(p_alpha)
    c_shadow.paste(c_fill, (phone_x, phone_y + 16), c_fill)
    c_shadow = c_shadow.filter(ImageFilter.GaussianBlur(24))
    bg = Image.alpha_composite(bg, c_shadow)
    
    d_shadow = Image.new('RGBA', (CANVAS_W, CANVAS_H), (0, 0, 0, 0))
    d_fill = Image.new('RGBA', phone.size, (0, 0, 0, 150))
    d_fill.putalpha(p_alpha)
    d_shadow.paste(d_fill, (phone_x, phone_y + 44), d_fill)
    d_shadow = d_shadow.filter(ImageFilter.GaussianBlur(52))
    bg = Image.alpha_composite(bg, d_shadow)
    
    bg.paste(phone, (phone_x, phone_y), phone)
    
    # Typography: Exactly matching YouCut Google Play Store layout
    draw = ImageDraw.Draw(bg)
    f_line1 = ImageFont.truetype(FONT_TITLE, 60)
    f_line2 = ImageFont.truetype(FONT_TITLE, 86)
    f_sub = ImageFont.truetype(FONT_SUB, 28)
    
    # Line 1: Accent Color (Centered at y = 62)
    bb1 = f_line1.getbbox(line1)
    w1 = bb1[2] - bb1[0]
    x1 = (CANVAS_W - w1) // 2
    for ox, oy in [(-1,1), (1,1), (0,2)]:
        draw.text((x1 + ox, 62 + oy), line1, font=f_line1, fill=(0, 0, 0, 200))
    draw.text((x1, 62), line1, font=f_line1, fill=line1_color)
    
    # Line 2: Huge Bold White (Centered at y = 132)
    bb2 = f_line2.getbbox(line2)
    w2 = bb2[2] - bb2[0]
    x2 = (CANVAS_W - w2) // 2
    for ox, oy in [(-2,2), (2,2), (0,3), (0,4)]:
        draw.text((x2 + ox, 132 + oy), line2, font=f_line2, fill=(0, 0, 0, 240))
    draw.text((x2, 132), line2, font=f_line2, fill=(255, 255, 255))
    
    # Line 3: Clean Subtitle (Centered at y = 236)
    bb3 = f_sub.getbbox(sub)
    w3 = bb3[2] - bb3[0]
    x3 = (CANVAS_W - w3) // 2
    draw.text((x3, 236), sub, font=f_sub, fill=(203, 213, 225))
    
    out_p = os.path.join(OUT_DIR, out_name)
    bg.convert('RGB').save(out_p, quality=96)
    bg.convert('RGB').save(os.path.join(BRAIN_DIR, out_name), quality=96)
    print("Saved test poster:", out_p)

render_poster(os.path.join(RAW_DIR, 'raw_1_editor.png'),
              "FREE &", (255, 230, 0),
              "NO WATERMARK",
              "Pro Video Editor & Reels Maker • 100% Free",
              (124, 58, 237, 130), 'test_slide_1.png')
