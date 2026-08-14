from PIL import Image, ImageDraw
from pathlib import Path
import random

ROOT = Path(__file__).resolve().parents[1]
BG = ROOT / "assets/backgrounds/demo_room"
NPC = ROOT / "assets/sprites/cartographer/world"
CHEST = ROOT / "assets/sprites/chest"
for p in (BG, NPC, CHEST):
    p.mkdir(parents=True, exist_ok=True)

W, H = 680, 116

def save(im, path):
    im.save(path, "PNG", optimize=True)
    check = Image.open(path)
    check.load()

# Árboles lejanos: sombras oscuras sobre el cielo nocturno existente.
far = Image.new("RGBA", (W, H), (0, 0, 0, 0))
d = ImageDraw.Draw(far)
random.seed(48)
for x in range(-20, W + 30, 30):
    height = random.randint(28, 52)
    base = 92 + random.randint(-1, 2)
    cx = x + random.randint(-6, 6)
    col = random.choice([(11, 20, 45, 230), (13, 24, 51, 235), (10, 18, 42, 225)])
    d.rectangle((cx - 1, base - int(height * 0.50), cx + 1, base), fill=(8, 14, 31, 220))
    top = base - height
    for j in range(5):
        yy = top + j * int(height * 0.14)
        half = 4 + j * 3
        d.polygon(((cx, yy), (cx - half, yy + 10), (cx + half, yy + 10)), fill=col)
save(far, BG / "trees_far.png")

# Árboles intermedios.
mid = Image.new("RGBA", (W, H), (0, 0, 0, 0))
d = ImageDraw.Draw(mid)
random.seed(49)
for x in range(-10, W + 40, 48):
    height = random.randint(36, 62)
    base = 96 + random.randint(-1, 2)
    cx = x + random.randint(-7, 7)
    col = random.choice([(18, 40, 59, 245), (21, 46, 64, 245), (24, 50, 66, 245)])
    d.rectangle((cx - 2, base - int(height * 0.48), cx + 1, base), fill=(31, 29, 35, 240))
    top = base - height
    for j in range(5):
        yy = top + j * int(height * 0.15)
        half = 5 + j * 4
        d.polygon(((cx, yy), (cx - half, yy + 12), (cx + half, yy + 12)), fill=col)
save(mid, BG / "trees_mid.png")

# Árboles cercanos con algo más de detalle.
near = Image.new("RGBA", (W, H), (0, 0, 0, 0))
d = ImageDraw.Draw(near)
random.seed(50)
for x in range(-5, W + 50, 76):
    height = random.randint(46, 72)
    base = 92
    cx = x + random.randint(-8, 8)
    d.rectangle((cx - 2, base - int(height * 0.48), cx + 2, base), fill=(49, 39, 38, 255))
    top = base - height
    for j in range(5):
        yy = top + j * int(height * 0.15)
        half = 6 + j * 5
        d.polygon(((cx, yy), (cx - half, yy + 13), (cx + half, yy + 13)), fill=(20, 43, 55, 255))
        if j >= 2:
            d.line(((cx - half + 3, yy + 11), (cx + half - 3, yy + 11)), fill=(30, 57, 64, 255), width=1)
for x in range(0, W, 34):
    y = 84 + ((x // 34) % 3)
    d.ellipse((x - 8, y - 8, x + 13, y + 5), fill=(23, 47, 48, 255))
    d.rectangle((x - 5, y, x + 12, 92), fill=(23, 47, 48, 255))
save(near, BG / "trees_near.png")

# Suelo independiente, 1:1 con la cámara.
ground = Image.new("RGBA", (680, 28), (59, 43, 38, 255))
d = ImageDraw.Draw(ground)
d.rectangle((0, 0, 679, 3), fill=(43, 65, 49, 255))
d.rectangle((0, 4, 679, 6), fill=(73, 61, 47, 255))
d.rectangle((0, 7, 679, 18), fill=(75, 54, 45, 255))
d.rectangle((0, 19, 679, 27), fill=(45, 35, 35, 255))
random.seed(51)
for i in range(100):
    x = random.randrange(680)
    y = random.randrange(5, 25)
    if i % 3 == 0:
        d.rectangle((x, y, x + random.randint(1, 4), y + 1), fill=(91, 74, 61, 255))
    elif i % 3 == 1:
        d.rectangle((x, y, x + 2, y + 1), fill=(44, 39, 42, 255))
    elif y < 10:
        d.line(((x, y), (x, y - 2)), fill=(67, 91, 62, 255))
save(ground, BG / "ground.png")

# NPC pequeño recuperando el aspecto sencillo anterior.
def npc_frame(breathe=0, mouth_open=False, blink=False):
    im = Image.new("RGBA", (24, 48), (0, 0, 0, 0))
    d = ImageDraw.Draw(im)
    d.rectangle((4, 45, 20, 47), fill=(12, 14, 19, 150))
    y = breathe
    skin, hair, beard = (215, 169, 132, 255), (35, 31, 38, 255), (65, 43, 36, 255)
    shirt, pants, shoe = (82, 99, 122, 255), (43, 52, 69, 255), (18, 20, 27, 255)
    d.rectangle((7, 31+y, 10, 44+y), fill=pants); d.rectangle((13, 31+y, 16, 44+y), fill=pants)
    d.rectangle((6, 43+y, 10, 45+y), fill=shoe); d.rectangle((13, 43+y, 17, 45+y), fill=shoe)
    d.rectangle((5, 19+y, 18, 32+y), fill=shirt)
    d.rectangle((4, 22+y, 6, 30+y), fill=skin); d.rectangle((18, 22+y, 20, 30+y), fill=skin)
    d.rectangle((10, 16+y, 13, 20+y), fill=skin); d.rectangle((8, 7+y, 16, 17+y), fill=skin)
    d.rectangle((7, 5+y, 17, 8+y), fill=(25,22,28,255)); d.rectangle((6, 7+y, 18, 9+y), fill=(25,22,28,255))
    d.rectangle((7, 9+y, 8, 15+y), fill=hair); d.rectangle((16, 9+y, 17, 15+y), fill=hair)
    d.rectangle((9, 14+y, 15, 17+y), fill=beard); d.rectangle((10, 17+y, 14, 18+y), fill=beard)
    eye = (25,25,29,255)
    if blink:
        d.line(((9,11+y),(10,11+y)), fill=eye); d.line(((14,11+y),(15,11+y)), fill=eye)
    else:
        d.point((10,11+y), fill=eye); d.point((14,11+y), fill=eye)
    if mouth_open:
        d.rectangle((11,15+y,13,16+y), fill=(30,18,20,255))
    else:
        d.line(((11,15+y),(13,15+y)), fill=(30,18,20,255))
    return im

for name, im in {
    "idle_0": npc_frame(),
    "idle_1": npc_frame(1, False, True),
    "talk_0": npc_frame(),
    "talk_1": npc_frame(0, True, False),
}.items():
    save(im, NPC / f"{name}.png")

# Cofre como estados independientes.
def chest_frame(state):
    im = Image.new("RGBA", (56, 32), (0,0,0,0))
    d = ImageDraw.Draw(im)
    metal, dark, wood, hi, gold = (54,52,58,255), (67,38,31,255), (121,70,43,255), (166,99,55,255), (202,157,72,255)
    d.ellipse((3,24,52,31), fill=(10,10,14,120))
    d.rectangle((4,13,51,28), fill=dark); d.rectangle((6,15,49,26), fill=wood)
    d.line(((7,18),(48,18)), fill=hi); d.line(((7,23),(48,23)), fill=dark)
    d.rectangle((9,14,12,27), fill=metal); d.rectangle((43,14,46,27), fill=metal)
    d.rectangle((25,17,31,24), fill=gold); d.rectangle((27,19,29,23), fill=(83,62,37,255))
    if state == "closed":
        d.rectangle((5,6,50,14), fill=dark); d.rectangle((7,7,48,12), fill=wood)
        d.line(((9,8),(46,8)), fill=hi); d.rectangle((9,11,46,14), fill=metal)
    elif state == "opening":
        d.polygon(((5,9),(49,4),(50,11),(6,15)), fill=dark); d.polygon(((8,9),(47,5),(48,10),(8,13)), fill=wood)
        d.line(((10,9),(45,6)), fill=hi); d.rectangle((8,12,47,14), fill=metal); d.rectangle((8,11,47,13), fill=(15,14,17,255))
    else:
        d.rectangle((6,1,49,7), fill=dark); d.rectangle((8,2,47,5), fill=wood)
        d.line(((10,2),(45,2)), fill=hi); d.rectangle((8,7,47,10), fill=metal); d.rectangle((8,10,47,14), fill=(15,14,17,255))
    return im

for state in ("closed", "opening", "open"):
    save(chest_frame(state), CHEST / f"chest_{state}.png")

print("Assets 0.4.8 generados y validados.")
