#!/usr/bin/env bash
set -euo pipefail

WS="/Users/anton/.openclaw/workspace"
OUT="$WS/inbox/ask-gap-report-$(date +%F).md"

if [ -f "$OUT" ]; then
  echo "Ask Gap Report ready: $OUT"
else
  echo "Ask Gap Report missing for today: $OUT"
  echo "Tip: run $WS/scripts/ask-gap-auditor.sh"
fi
