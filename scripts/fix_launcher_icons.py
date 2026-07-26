from pathlib import Path
from PIL import Image

res_dir = Path('D:/Flutter/ai_women_safety/android/app/src/main/res')
paths = list(res_dir.glob('mipmap-*/ic_launcher.png'))
print('Found', len(paths), 'launcher icons')

for p in paths:
    print('Processing', p)
    try:
        with Image.open(p) as img:
            img.convert('RGBA').save(p, format='PNG')
        print('Saved PNG', p)
    except Exception as e:
        print('Failed', p, e)

# record signatures
out_lines = []
for p in paths:
    b = p.read_bytes()[:8]
    out_lines.append(f"{p.name} {p.parent.name} {b.hex()}")

out_file = Path('D:/Flutter/ai_women_safety/icon_signatures.txt')
out_file.write_text('\n'.join(out_lines))
print('Signature file written to', out_file)
