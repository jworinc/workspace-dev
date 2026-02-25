#!/bin/bash

# Datasette Bridge: Turn GTD Markdown into a Searchable Database
# Uses Simon Willison's sqlite-utils

WORKSPACE="/Users/anton/.openclaw/workspace"
DB_PATH="$WORKSPACE/gtd.db"
PROJECTS_DIR="$WORKSPACE/projects"

echo "📊 Syncing GTD Workspace to SQLite..."

# 1. Clean up old DB
rm -f "$DB_PATH"

# 2. Extract Task data (using a simple grep/sed parser for frontmatter)
echo "📋 Processing tasks..."
find "$PROJECTS_DIR" -name "K*.md" | while read -r f; do
  ID=$(grep "id: " "$f" | head -1 | cut -d' ' -f2)
  TITLE=$(grep "title: " "$f" | head -1 | cut -d' ' -f2- | tr -d '"')
  STATUS=$(grep "status: " "$f" | head -1 | cut -d' ' -f2)
  PROJECT=$(grep "project: " "$f" | head -1 | cut -d' ' -f2)
  DUE=$(grep "due: " "$f" | head -1 | cut -d' ' -f2)
  
  # Insert into SQLite as JSON
  echo "{\"id\": \"$ID\", \"title\": \"$TITLE\", \"status\": \"$STATUS\", \"project\": \"$PROJECT\", \"due\": \"$DUE\", \"path\": \"$f\"}" | \
    sqlite-utils insert "$DB_PATH" tasks - --pk id
done

# 3. Extract Memory log entries
echo "📝 Processing memory logs..."
find "$WORKSPACE/memory" -name "*.md" | while read -r f; do
  DATE=$(basename "$f" .md)
  CONTENT=$(cat "$f")
  
  echo "{\"date\": \"$DATE\", \"content\": $(echo "$CONTENT" | jq -R .), \"path\": \"$f\"}" | \
    sqlite-utils insert "$DB_PATH" memory -
done

echo "✅ Sync complete: $DB_PATH"
echo "🚀 Run 'datasette $DB_PATH' to view!"
