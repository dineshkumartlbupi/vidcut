import os, sys, math
from PIL import Image, ImageDraw, ImageFilter, ImageFont

def create_flagship_phone(screen_img, target_w=870, target_h=1620, radius=52, bezel=14):
    phone_w = target_w
    phone_h = target_h
    inner_w = phone_w - (bezel * 2)
    inner_h = phone_h - (bezel * 2)
    inner_r = radius - (bezel // 2)
    
    # Scale and crop inner screen
    sw, sh = screen_img.size
    scale = max(inner_w / float(sw), inner_h / float(sh))
    new_sw = int(sw * scale)
    new_sh = int(sh * scale)
    scaled_screen = screen_img.resize((new_sw, new_sh), Image.Resampling.LANCZOS)
    
    crop_x = (new_sw - inner_w) // 2
    crop_y = 0
    cropped_screen = scaled_screen.crop((crop_x, crop_y, crop_x + inner_w, crop_y + inner_h))
    
    # Rounded mask for screen
    screen_mask = Image.new('L', (inner_w * 2, inner_h * 2), 0)
    m_draw = ImageDraw.Draw(screen_mask)
    m_draw.rounded_rectangle([0, 0, inner_w * 2, inner_h * 2], radius=inner_r * 2, fill=255)
    screen_mask = screen_mask.resize((inner_w, inner_h), Image.Resampling.LANCZOS)
    
    rounded_screen = Image.new('RGBA', (inner_w, inner_h), (0, 0, 0, 0))
    rounded_screen.paste(cropped_screen, (0, 0))
    rounded_screen.putalpha(screen_mask)
    
    # Add subtle glass reflection across screen (top-right diagonal light sheen)
    glass_sheen = Image.new('RGBA', (inner_w, inner_h), (0, 0, 0, 0))
    g_draw = ImageDraw.Draw(glass_sheen)
    # Diagonal polygon for realistic window/studio light reflection
    sheen_poly = [
        (int(inner_w * 0.4), 0),
        (inner_w, 0),
        (inner_w, int(inner_h * 0.35)),
        (int(inner_w * 0.1), int(inner_h * 0.75)),
        (0, int(inner_h * 0.65)),
        (0, int(inner_h * 0.25))
    ]
    g_draw.polygon(sheen_poly, fill=(255, 255, 255, 14))
    glass_sheen = glass_sheen.filter(ImageFilter.GaussianBlur(15))
    glass_sheen.putalpha(screen_mask)
    rounded_screen = Image.alpha_composite(rounded_screen, glass_sheen)
    
    # Canvas with phone body plus side buttons
    # Side buttons: power on right (width 6px), volume on left (width 6px)
    button_w = 6
    total_w = phone_w + button_w * 2
    total_h = phone_h
    
    body = Image.new('RGBA', (total_w, total_h), (0, 0, 0, 0))
    b_draw = ImageDraw.Draw(body)
    
    # Left buttons (Volume up & down)
    vol_up_y = 220
    b_draw.rounded_rectangle([0, vol_up_y, button_w + 4, vol_up_y + 80], radius=3, fill=(50, 54, 68, 255))
    vol_dn_y = 330
    b_draw.rounded_rectangle([0, vol_dn_y, button_w + 4, vol_dn_y + 80], radius=3, fill=(50, 54, 68, 255))
    
    # Right button (Power)
    pwr_y = 260
    b_draw.rounded_rectangle([total_w - button_w - 4, pwr_y, total_w, pwr_y + 110], radius=3, fill=(50, 54, 68, 255))
    
    # Phone main chassis
    chassis = Image.new('RGBA', (phone_w, phone_h), (0, 0, 0, 0))
    c_mask = Image.new('L', (phone_w * 2, phone_h * 2), 0)
    cm_draw = ImageDraw.Draw(c_mask)
    cm_draw.rounded_rectangle([0, 0, phone_w * 2, phone_h * 2], radius=radius * 2, fill=255)
    c_mask = c_mask.resize((phone_w, phone_h), Image.Resampling.LANCZOS)
    
    # Titanium gradient chassis background
    chassis_bg = Image.new('RGBA', (phone_w, phone_h), (22, 24, 30, 255))
    chassis_bg.putalpha(c_mask)
    chassis = Image.alpha_composite(chassis, chassis_bg)
    
    # Metallic specular edge border (Realistic titanium chamfer)
    rim_layer = Image.new('RGBA', (phone_w, phone_h), (0, 0, 0, 0))
    r_draw = ImageDraw.Draw(rim_layer)
    # Outer specular rim
    r_draw.rounded_rectangle([1, 1, phone_w - 2, phone_h - 2], radius=radius, outline=(85, 95, 115, 230), width=2)
    # Inner dark bezel
    r_draw.rounded_rectangle([3, 3, phone_w - 4, phone_h - 4], radius=radius - 2, outline=(18, 19, 24, 255), width=bezel - 3)
    # Top-left specular highlight gleam
    gleam_layer = Image.new('RGBA', (phone_w, phone_h), (0, 0, 0, 0))
    g_draw2 = ImageDraw.Draw(gleam_layer)
    g_draw2.arc([2, 2, radius * 3, radius * 3], start=180, end=270, fill=(200, 215, 240, 160), width=3)
    rim_layer = Image.alpha_composite(rim_layer, gleam_layer)
    
    chassis = Image.alpha_composite(chassis, rim_layer)
    
    # Paste screen inside chassis
    chassis.paste(rounded_screen, (bezel, bezel), rounded_screen)
    
    # Dynamic Island / Camera pill at top center
    island_w, island_h = 114, 28
    island_x = (phone_w - island_w) // 2
    island_y = bezel + 12
    i_draw = ImageDraw.Draw(chassis)
    i_draw.rounded_rectangle([island_x, island_y, island_x + island_w, island_y + island_h], radius=14, fill=(10, 10, 14, 255))
    # Dual camera lenses with subtle reflections
    i_draw.ellipse([island_x + 22, island_y + 7, island_x + 36, island_y + 21], fill=(18, 22, 32, 255))
    i_draw.ellipse([island_x + 26, island_y + 11, island_x + 31, island_y + 16], fill=(50, 70, 110, 255))
    i_draw.ellipse([island_x + 78, island_y + 9, island_x + 90, island_y + 21], fill=(16, 20, 28, 255))
    i_draw.ellipse([island_x + 82, island_y + 13, island_x + 86, island_y + 17], fill=(40, 60, 95, 255))
    
    # Paste chassis onto body (offset by button_w)
    body.paste(chassis, (button_w, 0), chassis)
    return body

print("Flagship phone generator ready")
