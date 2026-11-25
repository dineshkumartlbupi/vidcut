import os
import math
from PIL import Image, ImageDraw, ImageFilter, ImageFont

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
    steps = 40
    for i in range(steps, 0, -1):
        cur_r = int(radius * (i / steps))
        alpha = int(glow_color[3] * (1.0 - (i / steps))**1.8)
        bbox = [center_x - cur_r, center_y - cur_r, center_x + cur_r, center_y + cur_r]
        draw.ellipse(bbox, fill=(r_val, g_val, b_val, alpha))
    glow_layer = glow_layer.filter(ImageFilter.GaussianBlur(35))
    return Image.alpha_composite(canvas, glow_layer)

def create_phone_mockup(screen_img, target_w=860, target_h=1580, radius=50, bezel=14):
    # Outer frame
    frame_w = target_w
    frame_h = target_h
    
    # Inner screen dimensions
    inner_w = frame_w - (bezel * 2)
    inner_h = frame_h - (bezel * 2)
    inner_r = radius - (bezel // 2)
    
    # Scale and crop screenshot to inner dimensions
    sw, sh = screen_img.size
    scale = max(inner_w / float(sw), inner_h / float(sh))
    new_sw = int(sw * scale)
    new_sh = int(sh * scale)
    scaled_screen = screen_img.resize((new_sw, new_sh), Image.Resampling.LANCZOS)
    
    # Center crop
    crop_x = (new_sw - inner_w) // 2
    crop_y = 0  # start from top so status bar / top header is visible
    cropped_screen = scaled_screen.crop((crop_x, crop_y, crop_x + inner_w, crop_y + inner_h))
    
    # Mask inner screen with rounded corners
    screen_mask = Image.new('L', (inner_w * 2, inner_h * 2), 0)
    m_draw = ImageDraw.Draw(screen_mask)
    m_draw.rounded_rectangle([0, 0, inner_w * 2, inner_h * 2], radius=inner_r * 2, fill=255)
    screen_mask = screen_mask.resize((inner_w, inner_h), Image.Resampling.LANCZOS)
    
    rounded_screen = Image.new('RGBA', (inner_w, inner_h), (0, 0, 0, 0))
    rounded_screen.paste(cropped_screen, (0, 0))
    rounded_screen.putalpha(screen_mask)
    
    # Create Phone Frame
    phone = Image.new('RGBA', (frame_w, frame_h), (0, 0, 0, 0))
    
    # Outer bezel mask
    frame_mask = Image.new('L', (frame_w * 2, frame_h * 2), 0)
    f_draw = ImageDraw.Draw(frame_mask)
    f_draw.rounded_rectangle([0, 0, frame_w * 2, frame_h * 2], radius=radius * 2, fill=255)
    frame_mask = frame_mask.resize((frame_w, frame_h), Image.Resampling.LANCZOS)
    
    frame_bg = Image.new('RGBA', (frame_w, frame_h), (24, 26, 32, 255))
    frame_bg.putalpha(frame_mask)
    
    # Draw subtle metallic edge border
    border_layer = Image.new('RGBA', (frame_w, frame_h), (0, 0, 0, 0))
    b_draw = ImageDraw.Draw(border_layer)
    b_draw.rounded_rectangle([1, 1, frame_w - 2, frame_h - 2], radius=radius, outline=(60, 65, 80, 220), width=2)
    b_draw.rounded_rectangle([3, 3, frame_w - 4, frame_h - 4], radius=radius - 2, outline=(30, 32, 40, 255), width=bezel - 3)
    
    phone = Image.alpha_composite(phone, frame_bg)
    phone = Image.alpha_composite(phone, border_layer)
    
    # Paste the rounded screen into phone
    phone.paste(rounded_screen, (bezel, bezel), rounded_screen)
    
    # Add modern camera punch-hole island at top center
    island_w, island_h = 110, 28
    island_x = (frame_w - island_w) // 2
    island_y = bezel + 12
    p_draw = ImageDraw.Draw(phone)
    p_draw.rounded_rectangle([island_x, island_y, island_x + island_w, island_y + island_h], radius=14, fill=(10, 10, 14, 255))
    
    # Camera lens reflection dot
    p_draw.ellipse([island_x + 22, island_y + 8, island_x + 34, island_y + 20], fill=(20, 25, 38, 255))
    p_draw.ellipse([island_x + 25, island_y + 11, island_x + 29, island_y + 15], fill=(40, 50, 75, 255))
    
    return phone

print("Mockup generator code defined")

def add_drop_shadow(canvas, element, pos, offset=(0, 25), blur_radius=40, shadow_color=(0, 0, 0, 160)):
    shadow = Image.new('RGBA', canvas.size, (0, 0, 0, 0))
    # Extract alpha mask of element
    alpha = element.split()[-1]
    
    # Create shadow shape
    s_elem = Image.new('RGBA', element.size, shadow_color)
    s_elem.putalpha(alpha)
    
    # Paste onto shadow canvas with offset
    sx = pos[0] + offset[0]
    sy = pos[1] + offset[1]
    shadow.paste(s_elem, (sx, sy), s_elem)
    
    # Blur
    shadow = shadow.filter(ImageFilter.GaussianBlur(blur_radius))
    
    # Composite shadow then element
    canvas = Image.alpha_composite(canvas, shadow)
    canvas.paste(element, pos, element)
    return canvas

def render_pill_badge(draw, text, x_center, y, font, bg_color=(124, 58, 237, 60), border_color=(167, 139, 250, 180), text_color=(255, 255, 255, 255)):
    bbox = font.getbbox(text)
    text_w = bbox[2] - bbox[0]
    text_h = bbox[3] - bbox[1]
    
    pad_x = 24
    pad_y = 10
    pill_w = text_w + pad_x * 2
    pill_h = text_h + pad_y * 2
    pill_x = x_center - pill_w // 2
    
    # draw rounded rect
    draw.rounded_rectangle([pill_x, y, pill_x + pill_w, y + pill_h], radius=pill_h//2, fill=bg_color, outline=border_color, width=2)
    # text
    draw.text((pill_x + pad_x, y + pad_y - bbox[1]), text, font=font, fill=text_color)
    return pill_w, pill_h

# Let's test generating Slide 1
canvas_w, canvas_h = 1080, 1920
bg = make_gradient(canvas_w, canvas_h, (12, 14, 22), (20, 24, 38))

# Ambient radial glow in center
bg = add_radial_glow(bg, 540, 950, 650, (124, 58, 237, 75))
bg = add_radial_glow(bg, 250, 300, 350, (6, 182, 212, 45))

# Open source screenshot
src_path = '/Users/pritamsharma/.gemini/antigravity/brain/1924d82f-8c85-4f77-96d0-28de4bd5bc32/novacut_editor_active_pro.png'
screen_img = Image.open(src_path).convert('RGBA')

phone = create_phone_mockup(screen_img, target_w=870, target_h=1620, radius=52, bezel=14)

# Add phone with drop shadow
bg = add_drop_shadow(bg, phone, pos=(105, 300), offset=(0, 30), blur_radius=45, shadow_color=(0, 0, 0, 180))

# Now draw text overlay
draw = ImageDraw.Draw(bg)

title_font = ImageFont.truetype('/System/Library/Fonts/Supplemental/DIN Alternate Bold.ttf', 68)
sub_font = ImageFont.truetype('/System/Library/Fonts/Supplemental/Arial Bold.ttf', 32)
badge_font = ImageFont.truetype('/System/Library/Fonts/Supplemental/Arial Bold.ttf', 24)

# Draw Pill Badges
# Draw two pills side by side
b1_text = "⚡ 100% FREE VIP"
b2_text = "🚫 NO WATERMARK"
pill1_bbox = badge_font.getbbox(b1_text)
pill2_bbox = badge_font.getbbox(b2_text)
p1_w = (pill1_bbox[2] - pill1_bbox[0]) + 44
p2_w = (pill2_bbox[2] - pill2_bbox[0]) + 44
gap = 20
total_pills_w = p1_w + gap + p2_w
start_x = (canvas_w - total_pills_w) // 2

# Draw pill 1
render_pill_badge(draw, b1_text, start_x + p1_w//2, 60, badge_font, bg_color=(124, 58, 237, 70), border_color=(192, 132, 252, 200), text_color=(255, 255, 255))
# Draw pill 2
render_pill_badge(draw, b2_text, start_x + p1_w + gap + p2_w//2, 60, badge_font, bg_color=(239, 68, 68, 70), border_color=(248, 113, 113, 200), text_color=(255, 255, 255))

# Draw Title
title = "PRO VIDEO EDITOR & MAKER"
t_bbox = title_font.getbbox(title)
t_w = t_bbox[2] - t_bbox[0]
draw.text(((canvas_w - t_w)//2, 130), title, font=title_font, fill=(255, 255, 255))

# Draw Subtitle
subtitle = "Multi-Track Timeline • Millisecond Precision Trimming"
s_bbox = sub_font.getbbox(subtitle)
s_w = s_bbox[2] - s_bbox[0]
draw.text(((canvas_w - s_w)//2, 218), subtitle, font=sub_font, fill=(56, 189, 248))

# Save output
out_dir = '/Users/pritamsharma/Downloads/video_editor_app/play_store_assets/screenshots'
os.makedirs(out_dir, exist_ok=True)
out_file = os.path.join(out_dir, 'screenshot_1_hero_editor.png')
bg.convert('RGB').save(out_file, quality=95)
print("Slide 1 generated successfully:", out_file)

