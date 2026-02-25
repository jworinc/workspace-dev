#!/bin/bash

# Simon Willison's "Linear Walkthrough" Generator
# Uses LLM to map a project structure

set -e

PROJECT_PATH="$1"
MODEL="claude-3-5-sonnet" # Default to Sonnet for high quality walkthroughs

if [ -z "$PROJECT_PATH" ]; then
  echo "Usage: walkthrough.sh [project-path] [model]"
  exit 1
fi

if [ -n "$2" ]; then
  MODEL="$2"
fi

cd "$PROJECT_PATH"

echo "🧠 Generating linear walkthrough for: $(basename "$PWD")"
echo "🤖 Using model: $MODEL"

# 1. Collect file list and content (excluding large/binary files)
FILES=$(find . -maxdepth 3 -not -path '*/.*' -not -path '*/node_modules/*' -not -path '*/build/*' -not -path '*/dist/*' -type f | grep -E '\.(swift|py|js|ts|tsx|md|json|sh|html|css|txt)$')

echo "📂 Analyzing $(echo "$FILES" | wc -l) files..."

{
  echo "You are an expert software architect. Present a linear walkthrough of this entire codebase."
  echo "Include all files, their purposes, key functions, data structures, and how they connect."
  echo ""
  echo "CODEBASE CONTEXT:"
  echo "-----------------"
  
  for f in $FILES; do
    echo "FILE: $f"
    echo "---"
    cat "$f"
    echo ""
    echo "---"
  done
} | llm -m "$MODEL" > WALKTHROUGH.md

echo "✅ Walkthrough generated: $(pwd)/WALKTHROUGH.md"

# 🧠 NEW: Index into Viking
ARTIFACTS_DIR="/Users/anton/.openclaw/workspace/semantica/artifacts"
if [ -d "$ARTIFACTS_DIR" ]; then
  PROJECT_NAME=$(basename "$PROJECT_PATH")
  cp WALKTHROUGH.md "$ARTIFACTS_DIR/WALKTHROUGH-$PROJECT_NAME.md"
  echo "✅ Viking: Walkthrough added to artifacts for indexing"
  
  # Trigger indexer
  cd /Users/anton/.openclaw/workspace/semantica
  bash index.sh > /dev/null 2>&1 || true
fi
