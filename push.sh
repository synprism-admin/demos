#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════
#  Quick-push any single file or the whole repo
#  Usage:
#    ./push.sh                     → commit & push everything
#    ./push.sh dashboard           → push only index.html (dashboard)
#    ./push.sh questionnaire       → push only questionnaire/
# ═══════════════════════════════════════════════════════════════

set -e
REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$REPO_DIR"

TARGET="${1:-all}"

if [[ "$TARGET" == "all" ]]; then
  git add -A
  git commit -m "Update: $(date '+%Y-%m-%d %H:%M')" || echo "Nothing to commit."
elif [[ "$TARGET" == "dashboard" ]]; then
  git add index.html demos.json
  git commit -m "Update dashboard" || echo "Nothing to commit."
else
  git add "$TARGET/"
  git commit -m "Update: $TARGET" || echo "Nothing to commit."
fi

git push origin main
echo "✅  Pushed. Live in ~60 seconds."
