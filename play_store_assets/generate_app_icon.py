import os, sys, math
from PIL import Image, ImageDraw, ImageFilter

size = 512
img = Image.new('RGBA', (size, size), (0, 0, 0, 0))

# Create rounded squircle mask (Play Store standard: radius ~ 110px on 512px)
mask = Image.new('L', (size * 2, size * 2), 0)
m_draw = ImageDraw.Draw(mask)
m_draw.rounded_rectangle([0, 0, size * 2, size * 2], radius=210, fill=255)
mask = mask.resize((size, size), Image.Resampling.LANCZOS)

# Create background gradient (Diagonal from top-left #7C3AED to bottom-right #EC4899)
bg = Image.new('RGBA', (size, size), (0, 0, 0, 0))
for y in range(size):
    for x in range(size):
        ratio = (x + y) / (float(size * 2))
        r = int(109 + (236 - 109) * ratio)
        g = int(40 + (72 - 40) * ratio)
        b = int(217 + (153 - 217) * ratio)
        bg.putpixel((x, y), (r, g, b, 255))

# Top-left specular glow
specular = Image.new('RGBA', (size, size), (0, 0, 0, 0))
s_draw = ImageDraw.Draw(specular)
s_draw.ellipse([-50, -50, 320, 320], fill=(255, 255, 255, 60))
specular = specular.filter(ImageFilter.GaussianBlur(50))
bg = Image.alpha_composite(bg, specular)

# Subtle inner shadow / border
border = Image.new('RGBA', (size, size), (0, 0, 0, 0))
b_draw = ImageDraw.Draw(border)
b_draw.rounded_rectangle([4, 4, size - 5, size - 5], radius=102, outline=(255, 255, 255, 100), width=4)
bg = Image.alpha_composite(bg, border)

bg.putalpha(mask)

# Now render icon glyph (Modern Cinema Film Clapper & Play Triangle with Cut Accent)
glyph_layer = Image.new('RGBA', (size, size), (0, 0, 0, 0))
g_draw = ImageDraw.Draw(glyph_layer)

# Central Cinema Frame & Cutout
center_x, center_y = size // 2, size // 2

# Draw sleek overlapping scissor/film blades in pure white with soft drop shadow
# Left wing / film strip
g_draw.rounded_rectangle([115, 150, 205, 362], radius=20, fill=(255, 255, 255, 240))
# Sprocket holes
for sp_y in [175, 235, 295]:
    g_draw.rounded_rectangle([135, sp_y, 185, sp_y + 36], radius=8, fill=(124, 58, 237, 255))

# Large Play Triangle in center-right
play_points = [
    (235, 160),
    (235, 352),
    (395, 256)
]
g_draw.polygon(play_points, fill=(255, 255, 255, 255))

# Diagonal dynamic cut line through the triangle (Giving the "Cut" / VidCut brand feel)
# Draw an angled slash line
cut_angle = math.radians(25)
slash_layer = Image.new('RGBA', (size, size), (0, 0, 0, 0))
sl_draw = ImageDraw.Draw(slash_layer)
sl_draw.line([(180, 370), (410, 140)], fill=(124, 58, 237, 255), width=16)

# Composite glyph with cut
glyph_layer.paste(slash_layer, (0, 0), slash_layer)

# Add drop shadow to glyph
glyph_shadow = Image.new('RGBA', (size, size), (0, 0, 0, 0))
g_alpha = glyph_layer.split()[-1]
g_fill = Image.new('RGBA', (size, size), (0, 0, 0, 120))
g_fill.putalpha(g_alpha)
glyph_shadow.paste(g_fill, (0, 16), g_fill)
glyph_shadow = glyph_shadow.filter(ImageFilter.GaussianBlur(14))

# Final composite
final_icon = Image.alpha_composite(bg, glyph_shadow)
final_icon = Image.alpha_composite(final_icon, glyph_layer)

out_file = '/Users/pritamsharma/Downloads/video_editor_app/play_store_assets/app_icon_512x512.png'
final_icon.save(out_file, 'PNG')
print("App icon generated successfully:", out_file)
