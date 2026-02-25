#!/bin/bash

# Cleanup script for OpenClaw stack sessions
# Removes duplicate sessions directories from stack traces

STACKS_DIR="$HOME/.openclaw/stacks"

echo "🔍 Scanning for sessions directories..."
echo ""

# Count sessions
SESSION_COUNT=$(find "$STACKS_DIR" -name "sessions" -type d | wc -l | tr -d ' ')

# Calculate size
TOTAL_SIZE_KB=$(find "$STACKS_DIR" -name "sessions" -type d -exec du -sk {} \; 2>/dev/null | awk '{sum+=$1} END {print sum}')
TOTAL_SIZE_MB=$((TOTAL_SIZE_KB / 1024))

echo "📊 Found $SESSION_COUNT sessions directories"
echo "💾 Total size: ${TOTAL_SIZE_MB} MB"
echo ""

# Show top 10 stacks by sessions size
echo "🗂 Top 10 stacks with sessions:"
find "$STACKS_DIR" -name "sessions" -type d | while read -r d; do
    size=$(du -sk "$d" 2>/dev/null | awk '{print $1}')
    parent=$(basename "$(dirname "$d")")
    printf "%8s KB  %s\n" "$size" "$parent"
done | sort -rn | head -10 | nl
echo ""

echo "⚠️  These are duplicate session copies saved in stack traces."
echo "⚠️  Original sessions are saved elsewhere (main sessions store)."
echo ""

# Show examples
echo "📋 Example sessions:"
find "$STACKS_DIR" -name "sessions" -type d -maxdepth 2 | head -3 | sed "s|$STACKS_DIR/||"
echo ""

echo "🤔 Remove all $SESSION_COUNT sessions directories?"
echo "   This will free: ${TOTAL_SIZE_MB} MB"
echo ""
read -p "Type 'yes' to continue, anything else to cancel: " CONFIRM

if [ "$CONFIRM" != "yes" ]; then
    echo "❌ Cancelled. No changes made."
    exit 0
fi

# Remove sessions
echo ""
echo "🧹 Removing sessions directories..."
REMOVED=0
for d in $(find "$STACKS_DIR" -name "sessions" -type d); do
    rm -rf "$d"
    REMOVED=$((REMOVED + 1))
    if [ $((REMOVED % 50)) -eq 0 ]; then
        echo "   Progress: $REMOVED/$SESSION_COUNT..."
    fi
done

echo ""
echo "✅ Removed $REMOVED sessions directories"
echo "💾 Freed: ${TOTAL_SIZE_MB} MB"
echo ""

echo "📊 Current disk space:"
df -h / | grep "/"
