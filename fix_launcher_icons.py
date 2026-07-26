from pathlib import Path
from PIL import Image

paths = list(Path('D:/Flutter/ai_women_safety/android/app/src/main/res').glob('mipmap-*/ic_launcher.png'))
print('Found', len(paths), 'launcher icons')
for p in paths:
    print('Processing', p)
    with Image.open(p) as img:
        img.convert('RGBA').save(p, format='PNG')
    print('Saved PNG', p)
