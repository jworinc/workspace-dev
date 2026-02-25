#!/bin/bash

# Semantic Search Tool (v2 - Integrated with Semantica + OpenViking)
# Uses the existing viking-find.sh to search the curated corpus

QUERY="$1"
VIKING_FIND="/Users/anton/.openclaw/workspace-ai/skills/viking-find/viking-find.sh"

if [ -z "$QUERY" ]; then
  echo "Usage: find.sh \"your search query\""
  exit 1
fi

if [[ ! -f "$VIKING_FIND" ]]; then
  echo "⚠️ viking-find.sh not found at: $VIKING_FIND"
  exit 1
fi

echo "🔍 Searching curated corpus via OpenViking..."
echo "-" * 30

bash "$VIKING_FIND" "$QUERY"
