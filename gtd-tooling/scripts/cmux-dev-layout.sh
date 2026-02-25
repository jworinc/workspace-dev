#!/usr/bin/env bash
set -euo pipefail

# Run this INSIDE a cmux terminal.
# (cmux denies socket access to processes not started inside cmux.)

CMUX_BIN="cmux"

# Quick sanity checks
if [[ -z "${CMUX_SURFACE_ID:-}" ]]; then
  echo "Error: not running inside cmux (CMUX_SURFACE_ID not set)." >&2
  echo "Open cmux, open a terminal pane, then run this script again." >&2
  exit 1
fi

# Ensure we can talk to cmux
$CMUX_BIN ping >/dev/null

# Create a new workspace
WS_JSON="$($CMUX_BIN --json new-workspace)"

# Create a browser pane to the right (defaults to current workspace)
# Pass a URL as $1, else open about:blank.
URL="${1:-about:blank}"
$CMUX_BIN new-pane --type browser --direction right --url "$URL" >/dev/null

# Optional: add a second terminal split down (uncomment if you want it by default)
# $CMUX_BIN new-split down >/dev/null

# Focus stays where cmux decides; you can use shortcuts to jump/focus.

echo "cmux dev layout created. Browser URL: $URL"
