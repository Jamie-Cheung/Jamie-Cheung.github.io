#!/usr/bin/env python3
"""Merge GitHub repository traffic views into data/traffic.json."""

from __future__ import annotations

import json
import os
import sys
import urllib.error
import urllib.request
from datetime import datetime, timezone
from pathlib import Path

DATA_PATH = Path("data/traffic.json")
API_VERSION = "2022-11-28"


def load_state() -> dict:
    if DATA_PATH.exists():
        with DATA_PATH.open(encoding="utf-8") as handle:
            return json.load(handle)

    return {
        "daily_views": {},
        "daily_uniques": {},
        "tracking_since": None,
    }


def fetch_traffic(token: str, repository: str) -> dict:
    url = f"https://api.github.com/repos/{repository}/traffic/views"
    request = urllib.request.Request(
        url,
        headers={
            "Authorization": f"Bearer {token}",
            "Accept": "application/vnd.github+json",
            "X-GitHub-Api-Version": API_VERSION,
            "User-Agent": "homepage-traffic-sync",
        },
    )

    with urllib.request.urlopen(request) as response:
        return json.load(response)


def day_key(timestamp: str) -> str:
    return timestamp[:10]


def merge_daily(state: dict, api_data: dict) -> None:
    daily_views = state.setdefault("daily_views", {})
    daily_uniques = state.setdefault("daily_uniques", {})
    seen_days: list[str] = []

    for entry in api_data.get("views", []):
        day = day_key(entry["timestamp"])
        seen_days.append(day)
        daily_views[day] = int(entry["count"])
        daily_uniques[day] = int(entry["uniques"])

    if not seen_days:
        return

    earliest = min(seen_days)
    current = state.get("tracking_since")
    state["tracking_since"] = earliest if not current else min(current, earliest)


def build_output(state: dict, api_data: dict) -> dict:
    daily_views = state.get("daily_views", {})
    total_views = sum(int(value) for value in daily_views.values())

    return {
        "total_views": total_views,
        "last_14_days_views": int(api_data.get("count", 0)),
        "last_14_days_uniques": int(api_data.get("uniques", 0)),
        "tracking_since": state.get("tracking_since"),
        "updated_at": datetime.now(timezone.utc).replace(microsecond=0).isoformat(),
        "daily_views": daily_views,
        "daily_uniques": state.get("daily_uniques", {}),
        "source": "github-traffic-api",
    }


def write_output(payload: dict) -> None:
    DATA_PATH.parent.mkdir(parents=True, exist_ok=True)
    with DATA_PATH.open("w", encoding="utf-8") as handle:
        json.dump(payload, handle, ensure_ascii=False, indent=2)
        handle.write("\n")


def main() -> int:
    token = os.environ.get("GITHUB_TOKEN")
    repository = os.environ.get("GITHUB_REPOSITORY")

    if not token or not repository:
        print("GITHUB_TOKEN and GITHUB_REPOSITORY are required.", file=sys.stderr)
        return 1

    try:
        api_data = fetch_traffic(token, repository)
    except urllib.error.HTTPError as error:
        body = error.read().decode("utf-8", errors="replace")
        print(f"GitHub traffic API failed: {error.code} {body}", file=sys.stderr)
        return 1
    except urllib.error.URLError as error:
        print(f"GitHub traffic API request failed: {error}", file=sys.stderr)
        return 1

    state = load_state()
    merge_daily(state, api_data)
    payload = build_output(state, api_data)
    write_output(payload)

    print(
        "Traffic synced:",
        f"total_views={payload['total_views']},",
        f"last_14_days_views={payload['last_14_days_views']}",
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
