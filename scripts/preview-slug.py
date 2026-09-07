#!/usr/bin/env python3
"""Derive the unlisted owner-preview path slug from a passphrase."""

from __future__ import annotations

import hashlib
import json
import os
import sys
from pathlib import Path


def slug_for_key(key: str) -> str:
    normalized = key.strip()
    if not normalized:
        raise ValueError("preview key is empty")
    return hashlib.sha256(normalized.encode("utf-8")).hexdigest()[:16]


def resolve_preview_key(root: Path) -> str:
    env_key = os.environ.get("HOMEPAGE_PREVIEW_KEY", "").strip()
    if env_key:
        return env_key
    config_path = root / "site-config.json"
    data = json.loads(config_path.read_text(encoding="utf-8"))
    config_key = str(data.get("previewKey") or "").strip()
    if config_key:
        return config_key
    raise SystemExit(
        "Missing preview key. Set site-config.json previewKey or HOMEPAGE_PREVIEW_KEY."
    )


def main() -> None:
    root = Path(sys.argv[1]) if len(sys.argv) > 1 else Path.cwd()
    print(slug_for_key(resolve_preview_key(root)))


if __name__ == "__main__":
    main()
