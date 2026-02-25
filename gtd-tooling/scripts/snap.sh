#!/bin/bash

# Visual Documentation Tool (using Simon Willison's shot-scraper)
# Captures a screenshot of a URL/App and commits it to Git

URL="$1"
NAME="$2"
WORKSPACE="/Users/anton/.openclaw/workspace"

if [ -z "$URL" ]; then
  echo "Usage: snap.sh [url] [filename-prefix]"
  exit 1
fi

if [ -z "$NAME" ]; then
  NAME="snap-$(date +%Y-%m-%d-%H%M)"
fi

OUTPUT_DIR="$WORKSPACE/assets/snaps"
mkdir -p "$OUTPUT_DIR"

echo "📸 Capturing: $URL"
shot-scraper "$URL" -o "$OUTPUT_DIR/$NAME.png"

echo "✅ Saved to: $OUTPUT_DIR/$NAME.png"

# Commit to Git
cd "$WORKSPACE"
git add "assets/snaps/$NAME.png"
git commit -m "Snap: Captured screenshot of $URL"
echo "🔀 Git: Committed snap"
