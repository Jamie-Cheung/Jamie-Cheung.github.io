#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"
dest="${1:-"$root/_site"}"

mkdir -p "$dest"
rsync -a \
  --exclude='.git/' \
  --exclude='.github/' \
  --exclude='offline/' \
  --exclude='scripts/' \
  --exclude='_site/' \
  --exclude='site-config.json' \
  --exclude='README.md' \
  "$root/" "$dest/"

iso="$(
  TZ=Asia/Shanghai git -C "$root" log -1 --format='%cd' --date=format-local:'%Y-%m-%d' -- \
    index.html stylesheet.css images
)"
if [ -z "$iso" ]; then
  iso="$(TZ=Asia/Shanghai git -C "$root" log -1 --format='%cd' --date=format-local:'%Y-%m-%d')"
fi
dot="${iso//-/.}"

python3 - "$dest/index.html" "$iso" "$dot" <<'PY'
from pathlib import Path
import re
import sys

path = Path(sys.argv[1])
iso, dot = sys.argv[2], sys.argv[3]
html = path.read_text(encoding="utf-8")
pattern = re.compile(
    r'(<time datetime=")[^"]*("[^>]*data-last-updated[^>]*>\s*<strong>)[^<]*(</strong>\s*</time>)',
    re.IGNORECASE,
)
updated, count = pattern.subn(rf"\g<1>{iso}\g<2>{dot}\g<3>", html, count=1)
if count != 1:
    raise SystemExit(f"expected to stamp last-updated once in {path}, found {count}")
path.write_text(updated, encoding="utf-8")
print(f"Stamped last updated: {dot}")
PY
