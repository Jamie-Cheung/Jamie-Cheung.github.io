#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"
dest="${1:-"$root/_site"}"
mode="publish"
if [ "${2:-}" = "--hidden" ]; then
  mode="hidden"
fi

site_dest="$dest"
if [ "$mode" = "hidden" ]; then
  slug="$(python3 "$root/scripts/preview-slug.py" "$root")"
  site_dest="$dest/p/$slug"
fi

rm -rf "$dest"
mkdir -p "$site_dest"

tar -C "$root" \
  --exclude='.git' \
  --exclude='.github' \
  --exclude='offline' \
  --exclude='scripts' \
  --exclude='_site' \
  --exclude='site-config.json' \
  --exclude='README.md' \
  -cf - . | tar -C "$site_dest" -xf -

iso="$(
  TZ=Asia/Shanghai git -C "$root" log -1 --format='%cd' --date=format-local:'%Y-%m-%d' -- \
    index.html stylesheet.css images
)"
if [ -z "$iso" ]; then
  iso="$(TZ=Asia/Shanghai git -C "$root" log -1 --format='%cd' --date=format-local:'%Y-%m-%d')"
fi
dot="${iso//-/.}"

python3 - "$site_dest/index.html" "$iso" "$dot" <<'PY'
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

if [ "$mode" = "hidden" ]; then
  python3 - "$site_dest/index.html" "$slug" <<'PY'
from pathlib import Path
import json
import re
import sys

path = Path(sys.argv[1])
slug = sys.argv[2]
html = path.read_text(encoding="utf-8")
if "noindex" not in html.lower():
    html = html.replace(
        "<head>",
        '<head>\n    <meta name="robots" content="noindex, nofollow">',
        1,
    )

slug_js = json.dumps(slug, ensure_ascii=False)
banner = f"""
    <div class="owner-preview-banner" role="status">
      <span>当前主页未公开，这是仅你可见的预览。访客打开网站只能看到「暂未公开」。</span>
      <button type="button" class="owner-preview-banner__exit" id="owner-preview-exit">退出预览</button>
    </div>
    <script>
      try {{ localStorage.setItem("zhang-homepage-preview-slug", {slug_js}); }} catch (e) {{}}
      document.getElementById("owner-preview-exit")?.addEventListener("click", function () {{
        try {{ localStorage.removeItem("zhang-homepage-preview-slug"); }} catch (e) {{}}
        location.href = "/";
      }});
    </script>
"""
updated, count = re.subn(r"<body[^>]*>", lambda match: match.group(0) + banner, html, count=1)
if count != 1:
    raise SystemExit(f"expected to inject owner-preview banner once in {path}, found {count}")
path.write_text(updated, encoding="utf-8")
PY

  cp "$root/offline/index.html" "$dest/index.html"
  cp "$root/offline/stylesheet.css" "$dest/stylesheet.css"
  cp "$root/offline/owner-preview.js" "$dest/owner-preview.js"
  cp "$root/offline/404.html" "$dest/404.html"
  printf 'User-agent: *\nDisallow: /\n' > "$dest/robots.txt"
  touch "$dest/.nojekyll"

  echo "Built hidden homepage with owner-only preview."
  if [ "${PRINT_PREVIEW_SLUG:-}" = "1" ]; then
    echo "Preview path: /p/${slug}/"
  fi
else
  echo "Built public homepage."
fi
