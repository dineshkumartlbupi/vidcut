import os, sys
from PIL import Image, ImageDraw, ImageFilter, ImageFont

BRAIN_DIR = '/Users/pritamsharma/.gemini/antigravity/brain/1924d82f-8c85-4f77-96d0-28de4bd5bc32'
FOOTAGE_DIR = '/Users/pritamsharma/Downloads/video_editor_app/play_store_assets/sample_footage'

editor_base = Image.open(os.path.join(BRAIN_DIR, 'novacut_editor_active_pro.png')).convert('RGBA')
footage = Image.open(os.path.join(FOOTAGE_DIR, 'footage_hero_sunset.jpg')).convert('RGBA')

# Player bounds: x: 225 to 854 (w=629), y: 280 to 810 (h=530)
pw, ph = 629, 530
px, py = 225, 280

# Crop and scale footage to fit player
fw, fh = footage.size
scale = max(pw / float(fw), ph / float(fh))
scaled_f = footage.resize((int(fw * scale), int(fh * scale)), Image.Resampling.LANCZOS)
cx = (scaled_f.width - pw) // 2
cy = (scaled_f.height - ph) // 2
player_video = scaled_f.crop((cx, cy, cx + pw, cy + ph))

# Add video HUD overlays
hud_draw = ImageDraw.Draw(player_video)
font_badge = ImageFont.truetype('/System/Library/Fonts/Supplemental/Arial Bold.ttf', 20)
font_caption = ImageFont.truetype('/System/Library/Fonts/Supplemental/DIN Alternate Bold.ttf', 44)

# 4K 60FPS badge
hud_draw.rounded_rectangle([15, 15, 125, 45], radius=6, fill=(0, 0, 0, 160), outline=(255, 255, 255, 140), width=1)
hud_draw.text((25, 20), "4K 60FPS", font=font_badge, fill=(255, 255, 255))

# 9:16 Canvas badge
hud_draw.rounded_rectangle([pw - 105, 15, pw - 15, 45], radius=6, fill=(0, 0, 0, 160), outline=(255, 255, 255, 140), width=1)
hud_draw.text((pw - 95, 20), "9:16 REEL", font=font_badge, fill=(56, 189, 248))

# Viral animated subtitle in lower-middle
caption = "GOLDEN HOUR 🌅"
c_bb = font_caption.getbbox(caption)
cw = c_bb[2] - c_bb[0]
cx_pos = (pw - cw) // 2
cy_pos = ph - 110

# Draw text shadow & glow
for ox, oy in [(-2,0),(2,0),(0,-2),(0,2),(-2,-2),(2,2)]:
    hud_draw.text((cx_pos + ox, cy_pos + oy), caption, font=font_caption, fill=(0, 0, 0, 240))
hud_draw.text((cx_pos, cy_pos), caption, font=font_caption, fill=(255, 230, 0))

# Timecode
hud_draw.rounded_rectangle([15, ph - 45, 175, ph - 15], radius=6, fill=(0, 0, 0, 160))
hud_draw.text((25, ph - 40), "00:03.18 / 00:15", font=font_badge, fill=(255, 255, 255))

# Paste video into editor
editor_base.paste(player_video, (px, py))

# Enhance timeline video track with real filmstrip thumbnails
# Timeline video track is roughly y: 1100 to 1230, x: 200 to 1080
thumb_w, thumb_h = 100, 125
mini_thumb = scaled_f.resize((thumb_w, thumb_h), Image.Resampling.LANCZOS)
for tx in range(210, 1050, thumb_w):
    editor_base.paste(mini_thumb, (tx, 1110))

# Redraw playhead line over timeline (bright cyan / purple line at x=540)
p_draw = ImageDraw.Draw(editor_base)
p_draw.line([(540, 1070), (540, 1380)], fill=(255, 255, 255, 255), width=4)
# Playhead pointer head
p_draw.polygon([(530, 1060), (550, 1060), (540, 1075)], fill=(255, 255, 255))

editor_base.save('/Users/pritamsharma/.gemini/antigravity/brain/1924d82f-8c85-4f77-96d0-28de4bd5bc32/enhanced_editor_test.png')
print("enhanced_editor_test.png saved successfully!")
