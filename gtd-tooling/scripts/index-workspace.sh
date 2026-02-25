#!/bin/bash

# Workspace Semantic Indexer (using Simon Willison's llm-embed)
# Creates a vector database of all your Markdown notes

WORKSPACE="/Users/anton/.openclaw/workspace"
COLLECTION="workspace"
MODEL="sentence-transformers/all-MiniLM-L6-v2"

echo "🧠 Indexing workspace for Semantic Search..."
echo "🤖 Using embedding model: $MODEL"

# 1. Initialize/Reset collection
llm embed-multi "$COLLECTION" --model "$MODEL" --reset

# 2. Add all Markdown files
echo "📂 Processing Markdown files..."
find "$WORKSPACE" -name "*.md" -not -path "*/node_modules/*" -type f | while read -r f; do
  ID=$(echo "$f" | sed "s|$WORKSPACE/||")
  echo "📄 Indexing: $ID"
  llm embed "$COLLECTION" "$ID" --model "$MODEL" --content "$(cat "$f")" --metadata "{\"path\": \"$f\"}"
done

echo "✅ Indexing complete!"
echo "🚀 Run 'find.sh \"your query\"' to search."
