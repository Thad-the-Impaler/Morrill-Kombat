#!/usr/bin/env python3
"""Build script: concatenates template.html + all.js into index.html."""
import os

SRC_DIR = os.path.dirname(os.path.abspath(__file__))
ROOT_DIR = os.path.dirname(SRC_DIR)
OUTPUT = os.path.join(ROOT_DIR, 'index.html')

with open(os.path.join(SRC_DIR, 'template.html'), 'r', encoding='utf-8') as f:
    html = f.read()
with open(os.path.join(SRC_DIR, 'all.js'), 'r', encoding='utf-8') as f:
    html += f.read()
html += '</script>\n</body>\n</html>\n'

with open(OUTPUT, 'w', encoding='utf-8') as f:
    f.write(html)
print(f'Built {OUTPUT} ({len(html):,} bytes)')
