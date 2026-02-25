#!/usr/bin/env bash
set -euo pipefail

WS="/Users/anton/.openclaw/workspace"
OUT="$WS/inbox/ask-gap-report-$(date +%F).md"

python3 "$WS/skills/ask-gap-auditor/scripts/ask_gap_auditor.py" \
  --since last \
  --limit 60 \
  --output "$OUT"

echo "$OUT"
