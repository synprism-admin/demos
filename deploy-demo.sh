#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════
#  Synprism Demo Deploy Script
#  Usage: ./deploy-demo.sh <slug> <name> <category> <icon> <tags>
#
#  Example:
#    ./deploy-demo.sh diamondwelldrilling \
#      "Diamond Well Drilling" \
#      "Well Drilling · Auburn, CA" \
#      "💧" \
#      "Well Drilling,Pumps,Lab Testing"
#
#  The HTML file must already exist at:
#    /home/adam/<slug>/index.html
#
#  What this script does:
#    1. Copies the built HTML into this repo under /<slug>/
#    2. Updates demos.json with the new entry
#    3. Commits and pushes to GitHub
#    4. Cloudflare Pages auto-deploys in ~60 seconds
# ═══════════════════════════════════════════════════════════════

set -e

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
SLUG="${1}"
NAME="${2}"
CATEGORY="${3:-}"
ICON="${4:-🌐}"
TAGS_RAW="${5:-}"
SOURCE_DIR="/home/adam/${SLUG}"

# ── Validate ──────────────────────────────────────────────────
if [[ -z "$SLUG" || -z "$NAME" ]]; then
  echo "Usage: $0 <slug> <name> [category] [icon] [tags]"
  echo "Example: $0 jtinteriors \"JT Interiors\" \"Remodeling · WA\" \"🏠\" \"Kitchen,Bathroom\""
  exit 1
fi

if [[ ! -f "$SOURCE_DIR/index.html" ]]; then
  echo "❌  No file found at $SOURCE_DIR/index.html"
  echo "    Build the demo first, then run this script."
  exit 1
fi

echo ""
echo "🚀  Deploying: $NAME ($SLUG)"
echo "────────────────────────────────────"

# ── 1. Copy HTML into repo ────────────────────────────────────
mkdir -p "$REPO_DIR/$SLUG"
cp "$SOURCE_DIR/index.html" "$REPO_DIR/$SLUG/index.html"
echo "✓   Copied index.html → $SLUG/"

# ── 2. Update demos.json ──────────────────────────────────────
DEMOS_FILE="$REPO_DIR/demos.json"

# Parse tags into JSON array
IFS=',' read -ra TAGS_ARR <<< "$TAGS_RAW"
TAGS_JSON="["
for i in "${!TAGS_ARR[@]}"; do
  tag=$(echo "${TAGS_ARR[$i]}" | xargs)  # trim whitespace
  TAGS_JSON+="\"$tag\""
  [[ $i -lt $((${#TAGS_ARR[@]}-1)) ]] && TAGS_JSON+=","
done
TAGS_JSON+="]"

# Use python to safely update the JSON (handles existing entries)
python3 - "$DEMOS_FILE" "$SLUG" "$NAME" "$CATEGORY" "$ICON" "$TAGS_JSON" <<'PYEOF'
import sys, json, os
from datetime import datetime

filepath, slug, name, category, icon, tags_json = sys.argv[1:]

demos = []
if os.path.exists(filepath):
    with open(filepath) as f:
        demos = json.load(f)

import json as _json
tags = _json.loads(tags_json)

# Update existing or append new
entry = {
    "slug":     slug,
    "name":     name,
    "category": category,
    "icon":     icon,
    "path":     f"/{slug}/",
    "status":   "live",
    "tags":     tags,
    "added":    datetime.utcnow().strftime("%Y-%m-%d")
}

existing = next((i for i,d in enumerate(demos) if d["slug"] == slug), None)
if existing is not None:
    demos[existing] = entry
    print(f"✓   Updated existing entry for {slug}")
else:
    demos.append(entry)
    print(f"✓   Added new entry for {slug}")

with open(filepath, 'w') as f:
    json.dump(demos, f, indent=2)
PYEOF

# ── 3. Git commit & push ──────────────────────────────────────
cd "$REPO_DIR"
git add "$SLUG/index.html" demos.json
git commit -m "Deploy demo: $NAME ($SLUG)"
git push origin main

echo ""
echo "✅  Done! Cloudflare Pages is deploying now."
echo "    Live in ~60 seconds at:"
echo "    https://demos.synprism.io/$SLUG/"
echo ""
