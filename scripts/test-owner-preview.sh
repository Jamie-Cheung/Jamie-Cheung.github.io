#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

python3 - "$root" <<'PY'
import hashlib
import subprocess
import sys
from pathlib import Path

root = Path(sys.argv[1])
slug = subprocess.check_output(
    [sys.executable, str(root / "scripts" / "preview-slug.py"), str(root)],
    text=True,
).strip()
assert slug == hashlib.sha256(b"zhanjie-preview").hexdigest()[:16]
print("preview slug helper ok")
PY

bash "$root/scripts/build-homepage.sh" "$tmp/public"
if grep -q "owner-preview-banner" "$tmp/public/index.html"; then
  echo "public build should not include the private banner" >&2
  exit 1
fi
test -f "$tmp/public/images/Google.jpg"
test ! -d "$tmp/public/p"
test ! -f "$tmp/public/owner-preview.js"
grep -q "Publications" "$tmp/public/index.html"

PRINT_PREVIEW_SLUG=1 bash "$root/scripts/build-homepage.sh" "$tmp/hidden" --hidden
slug="$(python3 "$root/scripts/preview-slug.py" "$root")"
preview="$tmp/hidden/p/$slug/index.html"

test -f "$tmp/hidden/index.html"
test -f "$tmp/hidden/owner-preview.js"
test -f "$tmp/hidden/404.html"
test -f "$tmp/hidden/robots.txt"
test -f "$preview"
test -f "$tmp/hidden/p/$slug/images/Google.jpg"
test ! -e "$tmp/hidden/images"

grep -q "主页暂未公开" "$tmp/hidden/index.html"
if grep -q "Publications" "$tmp/hidden/index.html"; then
  echo "offline root page must not include homepage content" >&2
  exit 1
fi
if grep -q "zhanjie-preview" "$tmp/hidden/index.html" "$tmp/hidden/owner-preview.js"; then
  echo "preview key must not be embedded in the public gate" >&2
  exit 1
fi
if grep -q "$slug" "$tmp/hidden/index.html" "$tmp/hidden/owner-preview.js"; then
  echo "preview slug must not be embedded in the public gate" >&2
  exit 1
fi

grep -q "Publications" "$preview"
grep -q "owner-preview-banner" "$preview"
grep -q "noindex" "$preview"
grep -q "Disallow: /" "$tmp/hidden/robots.txt"

echo "owner-preview build checks passed"
