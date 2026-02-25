#!/usr/bin/env bash
set -euo pipefail

# Usage:
#   cmux-notify.sh "Title" ["Body"]
# Runs ONLY inside cmux (socket access restriction).

TITLE="${1:-Agent needs input}"
BODY="${2:-}"

if [[ -z "${CMUX_SURFACE_ID:-}" ]]; then
  echo "Not in cmux; skipping notification: $TITLE" >&2
  exit 0
fi

# Ensure cmux CLI is available (we also add it to PATH in ~/.zshrc when in cmux)
if ! command -v cmux >/dev/null 2>&1; then
  export PATH="/Applications/cmux.app/Contents/Resources/bin:$PATH"
fi

cmux ping >/dev/null
cmux notify --title "$TITLE" --body "$BODY" >/dev/null
