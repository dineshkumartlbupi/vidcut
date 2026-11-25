import os, sys
from PIL import Image, ImageDraw, ImageFilter, ImageFont

RAW_DIR = '/Users/pritamsharma/Downloads/VidCut_PlayStore_Assets/raw_device_screenshots'
MAIN_OUT = '/Users/pritamsharma/Downloads/VidCut_PlayStore_Assets/screenshots'
APP_MAIN_OUT = '/Users/pritamsharma/Downloads/video_editor_app/play_store_assets/screenshots'
FRAMED_OUT = '/Users/pritamsharma/Downloads/VidCut_PlayStore_Assets/screenshots_framed_youcut'
APP_ONLY_OUT = '/Users/pritamsharma/Downloads/VidCut_PlayStore_Assets/screenshots_raw_app_only'
BRAIN_DIR = '/Users/pritamsharma/.gemini/antigravity/brain/1924d82f-8c85-4f77-96d0-28de4bd5bc32'

os.makedirs(MAIN_OUT, exist_ok=True)
os.makedirs(APP_MAIN_OUT, exist_ok=True)
os.makedirs(FRAMED_OUT, exist_ok=True)
os.makedirs(APP_ONLY_OUT, exist_ok=True)

# Clean existing files in MAIN_OUT
for f in os.listdir(MAIN_OUT):
    if f.endswith('.png') or f.endswith('.jpg'):
        os.remove(os.path.join(MAIN_OUT, f))

for f in os.listdir(APP_MAIN_OUT):
    if f.endswith('.png') or f.endswith('.jpg'):
        os.remove(os.path.join(APP_MAIN_OUT, f))

FONT_TITLE = '/System/Library/Fonts/Supplemental/DIN Alternate Bold.ttf'
FONT_SUB = '/System/Library/Fonts/Supplemental/Arial Bold.ttf'

CANVAS_W, CANVAS_H = 1080, 1920

print("=== 1. Generating Pure Raw Play Console Screenshots (1080x1920) ===")
# Generate pure raw screenshots directly from 1.jpeg through 8.jpeg
for i in range(1, 9):
    raw_p = os.path.join(RAW_DIR, f"{i}.jpeg")
    if not os.path.exists(raw_p):
        continue
    im = Image.open(raw_p).convert('RGB')
    
    # Direct high-fidelity resize to exactly 1080x1920
    im_1080x1920 = im.resize((CANVAS_W, CANVAS_H), Image.Resampling.LANCZOS)
    
    out_name = f"screenshot_{i}.png"
    im_1080x1920.save(os.path.join(MAIN_OUT, out_name), quality=100)
    im_1080x1920.save(os.path.join(APP_MAIN_OUT, out_name), quality=100)
    im_1080x1920.save(os.path.join(BRAIN_DIR, f"raw_1080x1920_{i}.png"), quality=100)
    print(f"Saved {out_name} (1080x1920) directly from {i}.jpeg")

print("\n=== 2. Generating App-Only (Clean Status Bar) Screenshots (1080x1920) ===")
for i in range(1, 9):
    raw_p = os.path.join(RAW_DIR, f"{i}.jpeg")
    if not os.path.exists(raw_p):
        continue
    im = Image.open(raw_p).convert('RGB')
    sw, sh = im.size
    
    # Trim Android system status bar (top ~3.8%) and navigation bar (bottom ~3.8%)
    top_trim = int(sh * 0.038)
    bot_trim = int(sh * 0.038)
    app_crop = im.crop((0, top_trim, sw, sh - bot_trim))
    app_1080x1920 = app_crop.resize((CANVAS_W, CANVAS_H), Image.Resampling.LANCZOS)
    
    app_1080x1920.save(os.path.join(APP_ONLY_OUT, f"screenshot_{i}_clean.png"), quality=100)
    print(f"Saved screenshot_{i}_clean.png in screenshots_raw_app_only/")

print("\n=== 3. Generating YouCut-Style Framed Posters in Exact 1-to-8 Order ===")

def fit_crop(img, tw, th):
    sw, sh = img.size
    scale = max(tw / float(sw), th / float(sh))
    nw, nh = int(sw * scale), int(sh * scale)
    scaled = img.resize((nw, nh), Image.Resampling.LANCZOS)
    cx = (nw - tw) // 2
    cy = (nh - th) // 2
    return scaled.crop((cx, cy, cx + tw, cy + th))

def create_youcut_bg(accent_glow_color):
    bg = Image.new('RGBA', (CANVAS_W, CANVAS_H), (14, 16, 24, 255))
    for y in range(CANVAS_H):
        r = int(13 + (20 - 13) * (y / CANVAS_H))
        g = int(15 + (24 - 15) * (y / CANVAS_H))
        b = int(22 + (36 - 22) * (y / CANVAS_H))
        ImageDraw.Draw(bg).line([(0, y), (CANVAS_W, y)], fill=(r, g, b, 255))
        
    glow_layer = Image.new('RGBA', (CANVAS_W, CANVAS_H), (0, 0, 0, 0))
    d = ImageDraw.Draw(glow_layer)
    cx, cy = 540, 1100
    radius = 660
    r_val, g_val, b_val, a_max = accent_glow_color
    for i in range(35, 0, -1):
        cur_r = int(radius * (i / 35.0))
        alpha = int(a_max * (1.0 - (i / 35.0))**1.7)
        d.ellipse([cx - cur_r, cy - cur_r, cx + cur_r, cy + cur_r], fill=(r_val, g_val, b_val, alpha))
    glow_layer = glow_layer.filter(ImageFilter.GaussianBlur(40))
    bg = Image.alpha_composite(bg, glow_layer)
    
    fade = Image.new('RGBA', (CANVAS_W, CANVAS_H), (0, 0, 0, 0))
    f_draw = ImageDraw.Draw(fade)
    for y in range(410):
        a = int(230 * (1.0 - (y / 410.0)**1.2))
        f_draw.line([(0, y), (CANVAS_W, y)], fill=(10, 12, 18, a))
    bg = Image.alpha_composite(bg, fade)
    return bg

def build_youcut_phone(screen_img, target_w=760, target_h=1575, radius=46, bezel=12):
    phone_w = target_w
    phone_h = target_h
    inner_w = phone_w - (bezel * 2)
    inner_h = phone_h - (bezel * 2)
    inner_r = radius - (bezel // 2)
    
    scaled_screen = fit_crop(screen_img, inner_w, inner_h)
    
    screen_mask = Image.new('L', (inner_w * 2, inner_h * 2), 0)
    ImageDraw.Draw(screen_mask).rounded_rectangle([0, 0, inner_w * 2, inner_h * 2], radius=inner_r * 2, fill=255)
    screen_mask = screen_mask.resize((inner_w, inner_h), Image.Resampling.LANCZOS)
    
    rounded_screen = Image.new('RGBA', (inner_w, inner_h), (0, 0, 0, 0))
    rounded_screen.paste(scaled_screen, (0, 0))
    rounded_screen.putalpha(screen_mask)
    
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
    
    chassis = Image.alpha_composite(chassis, rim_layer)
    chassis.paste(rounded_screen, (bezel, bezel), rounded_screen)
    
    body.paste(chassis, (button_w, 0), chassis)
    return body

def render_poster(screen_filename, line1, line1_color, line2, sub, glow, out_name):
    raw_path = os.path.join(RAW_DIR, screen_filename)
    if not os.path.exists(raw_path):
        return
        
    real_screen = Image.open(raw_path).convert('RGBA')
    bg = create_youcut_bg(glow)
    phone = build_youcut_phone(real_screen, target_w=760, target_h=1575, radius=46, bezel=12)
    phone_x = (CANVAS_W - phone.size[0]) // 2
    phone_y = 310
    
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
    
    draw = ImageDraw.Draw(bg)
    f_line1 = ImageFont.truetype(FONT_TITLE, 58)
    f_line2 = ImageFont.truetype(FONT_TITLE, 86)
    f_sub = ImageFont.truetype(FONT_SUB, 28)
    
    bb1 = f_line1.getbbox(line1)
    w1 = bb1[2] - bb1[0]
    x1 = (CANVAS_W - w1) // 2
    for ox, oy in [(-1,1), (1,1), (0,2)]:
        draw.text((x1 + ox, 62 + oy), line1, font=f_line1, fill=(0, 0, 0, 200))
    draw.text((x1, 62), line1, font=f_line1, fill=line1_color)
    
    bb2 = f_line2.getbbox(line2)
    w2 = bb2[2] - bb2[0]
    x2 = (CANVAS_W - w2) // 2
    for ox, oy in [(-2,2), (2,2), (0,3), (0,4)]:
        draw.text((x2 + ox, 132 + oy), line2, font=f_line2, fill=(0, 0, 0, 240))
    draw.text((x2, 132), line2, font=f_line2, fill=(255, 255, 255))
    
    bb3 = f_sub.getbbox(sub)
    w3 = bb3[2] - bb3[0]
    x3 = (CANVAS_W - w3) // 2
    draw.text((x3, 236), sub, font=f_sub, fill=(203, 213, 225))
    
    out_rgb = bg.convert('RGB')
    out_rgb.save(os.path.join(FRAMED_OUT, out_name), quality=96)
    out_rgb.save(os.path.join(BRAIN_DIR, f"framed_{out_name}"), quality=96)
    print(f"Saved framed poster: {out_name} (from {screen_filename})")

# Exactly in 1 to 8 order:
# 1.jpeg: VidCut Home
render_poster('1.jpeg', "PHOTOS TO VIDEO", (192, 132, 252), "SLIDESHOW & REELS", "1-Tap Viral Presets • Beat Sync & Easy 3-Step Guide", (147, 51, 234, 130), 'framed_1_home_reels.png')
# 2.jpeg: Stock 4K Library
render_poster('2.jpeg', "STOCK 4K LIBRARY &", (0, 229, 255), "CANVAS RATIOS", "9:16 TikTok & Reels • 16:9 YouTube • 1:1 Instagram", (37, 99, 235, 130), 'framed_2_stock_canvas.png')
# 3.jpeg: Gallery Import
render_poster('3.jpeg', "EASY IMPORT &", (56, 189, 248), "CAMERA RECORDER", "Import Any MP4, MOV or Camera Video to Edit", (2, 132, 199, 130), 'framed_3_import_gallery.png')
# 4.jpeg: Editor Timeline
render_poster('4.jpeg', "FREE &", (255, 230, 0), "NO WATERMARK", "Multi-Track Timeline • Video, Music & Text Overlays", (124, 58, 237, 130), 'framed_4_hero_editor.png')
# 5.jpeg: Speed Ramping
render_poster('5.jpeg', "SMOOTH", (255, 109, 0), "SLOW MOTION & SPEED", "Velocity Curve Ramping 0.25x Slow – 4.0x Fast", (234, 88, 12, 130), 'framed_5_velocity_curves.png')
# 6.jpeg: 4K Export Settings
render_poster('6.jpeg', "ULTRA HD", (0, 230, 118), "4K 60FPS EXPORT", "Full 4K UHD 60FPS • Zero Watermark • High Bitrate", (5, 150, 105, 130), 'framed_6_4k_export.png')
# 7.jpeg: Fast Rendering
render_poster('7.jpeg', "BLAZING FAST", (245, 158, 11), "HARDWARE RENDER", "GPU Accelerated Cinema LUT Grading & Zero Loss", (217, 119, 6, 130), 'framed_7_fast_rendering.png')
# 8.jpeg: Social Share
render_poster('8.jpeg', "INSTANT SAVE &", (236, 72, 153), "SHARE TO REELS", "1-Tap Share to Instagram, TikTok, WhatsApp & YouTube", (225, 29, 72, 130), 'framed_8_share_social.png')

print("\n=== ALL FORMATS GENERATED SUCCESSFULLY! ===")
