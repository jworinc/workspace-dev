#!/bin/bash

# Karakeep CLI - OpenClaw Integration
# Usage: karakeep <command> [options]

set -e

# Configuration
KARAKEEP_URL="${KARAKEEP_URL:-http://localhost:3000}"
KARAKEEP_API_KEY="${KARAKEEP_API_KEY:-}"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Help message
usage() {
  cat << EOF
Karakeep CLI - Self-Hosted Bookmark Manager

Usage:
  karakeep <command> [options]

Commands:
  list              List recent bookmarks
  search <query>    Search bookmarks
  add <url>         Create new bookmark
  get <id>          Get bookmark details
  update <id>       Update bookmark
  delete <id>       Delete bookmark
  tags              List all tags
  help              Show this help

Options:
  --title <title>   Set bookmark title
  --tags <tags>     Set bookmark tags (comma-separated)
  --note <note>     Set bookmark note
  --limit <n>       Limit results
  --type <type>     Filter by type (link, note, text)
  --archived        Include archived bookmarks
  --favourited      Only favourited bookmarks
  --json            Output as JSON
  --raw             Raw curl output (debug)

Environment:
  KARAKEEP_URL      Karakeep URL (default: http://localhost:3000)
  KARAKEEP_API_KEY  API key (required)

Examples:
  karakeep list
  karakeep search "rust programming"
  karakeep add "https://example.com" --title "Example Site" --tags "tech"
  karakeep get "abc123"
  karakeep update "abc123" --tags "tech,research"
  karakeep delete "abc123"

Setup:
  1. Generate API key: http://localhost:3000/settings/api-keys
  2. Set env var: export KARAKEEP_API_KEY="your-key"
  3. Add to .zshrc: echo 'export KARAKEEP_API_KEY="your-key"' >> ~/.zshrc

EOF
  exit 0
}

# Check API key
check_api_key() {
  if [[ -z "$KARAKEEP_API_KEY" ]]; then
    echo -e "${RED}Error: KARAKEEP_API_KEY not set${NC}"
    echo ""
    echo "Generate an API key at: http://localhost:3000/settings/api-keys"
    echo ""
    echo "Then set it:"
    echo '  export KARAKEEP_API_KEY="your-key"'
    echo '  echo '"'"'export KARAKEEP_API_KEY="your-key'"'"' >> ~/.zshrc'
    exit 1
  fi
}

# API request helper
api_request() {
  local endpoint="$1"
  local method="${2:-GET}"
  local data="${3:-}"
  
  local url="$KARAKEEP_URL/api/$endpoint"
  
  if [[ "$method" == "GET" ]]; then
    curl -s -H "Authorization: Bearer $KARAKEEP_API_KEY" "$url"
  else
    curl -s -X "$method" \
      -H "Authorization: Bearer $KARAKEEP_API_KEY" \
      -H "Content-Type: application/json" \
      -d "$data" \
      "$url"
  fi
}

# Format output
format_bookmark() {
  local bookmark="$1"
  
  if [[ "$OUTPUT_JSON" == "true" ]]; then
    echo "$bookmark"
    return
  fi
  
  local id=$(echo "$bookmark" | jq -r '.id // empty')
  local title=$(echo "$bookmark" | jq -r '.title // empty')
  local url=$(echo "$bookmark" | jq -r '.url // empty')
  local tags=$(echo "$bookmark" | jq -r '.tags | map(.name) | join(", ") // empty')
  local created=$(echo "$bookmark" | jq -r '.createdAt // empty' | sed 's/T/ /' | cut -d'.' -f1)
  local type=$(echo "$bookmark" | jq -r '.type // empty')
  
  echo -e "${GREEN}[$type] $title${NC}"
  if [[ -n "$url" ]]; then
    echo "  URL: $url"
  fi
  if [[ -n "$tags" ]]; then
    echo "  Tags: $tags"
  fi
  echo "  ID: $id | Created: $created"
  echo ""
}

# List bookmarks
cmd_list() {
  local url="bookmarks?limit=${LIMIT:-10}"
  
  if [[ -n "$TYPE" ]]; then
    url="$url&filterType=$TYPE"
  fi
  
  if [[ -n "$TAGS" ]]; then
    url="$url&filterTags=$TAGS"
  fi
  
  if [[ "$ARCHIVED" == "true" ]]; then
    url="$url&archived=true"
  fi
  
  if [[ "$FAVOURITED" == "true" ]]; then
    url="$url&favourited=true"
  fi
  
  local response=$(api_request "$url")
  
  if [[ "$OUTPUT_JSON" == "true" ]] || [[ "$OUTPUT_RAW" == "true" ]]; then
    echo "$response"
  else
    local count=$(echo "$response" | jq '.items | length')
    echo "Found $count bookmarks"
    echo ""
    
    echo "$response" | jq -c '.items[]' | while read -r bookmark; do
      format_bookmark "$bookmark"
    done
  fi
}

# Search bookmarks
cmd_search() {
  local query="$1"
  
  if [[ -z "$query" ]]; then
    echo -e "${RED}Error: Search query required${NC}"
    usage
  fi
  
  local url="bookmarks/search?q=$(echo "$query" | jq -sRr @uri)"
  
  if [[ -n "$LIMIT" ]]; then
    url="$url&limit=$LIMIT"
  fi
  
  local response=$(api_request "$url")
  
  if [[ "$OUTPUT_JSON" == "true" ]] || [[ "$OUTPUT_RAW" == "true" ]]; then
    echo "$response"
  else
    local count=$(echo "$response" | jq '.bookmarks | length')
    echo "Found $count bookmarks for '$query'"
    echo ""
    
    echo "$response" | jq -c '.bookmarks[]' | while read -r bookmark; do
      format_bookmark "$bookmark"
    done
  fi
}

# Add bookmark
cmd_add() {
  local url="$1"
  
  if [[ -z "$url" ]]; then
    echo -e "${RED}Error: URL required${NC}"
    usage
  fi
  
  local data='{
    "type": "link",
    "url": "'"$url"'"
  }'
  
  if [[ -n "$TITLE" ]]; then
    data=$(echo "$data" | jq --arg t "$TITLE" '. + {title: $t}')
  fi
  
  if [[ -n "$TAGS" ]]; then
    local tags_array=$(echo "$TAGS" | jq -R 'split(",") | map(. | ltrimstr(" ") | rtrimstr(" "))')
    data=$(echo "$data" | jq --argjson t "$tags_array" '. + {tags: t}')
  fi
  
  if [[ -n "$NOTE" ]]; then
    data=$(echo "$data" | jq --arg n "$NOTE" '. + {note: $n}')
  fi
  
  local response=$(api_request "bookmarks" "POST" "$data")
  
  if [[ "$OUTPUT_JSON" == "true" ]] || [[ "$OUTPUT_RAW" == "true" ]]; then
    echo "$response"
  else
    local id=$(echo "$response" | jq -r '.id')
    local title=$(echo "$response" | jq -r '.title')
    
    if [[ -n "$id" ]] && [[ "$id" != "null" ]]; then
      echo -e "${GREEN}✓ Bookmark created${NC}"
      echo "  Title: $title"
      echo "  URL: $url"
      echo "  ID: $id"
      echo "  View: $KARAKEEP_URL/bookmarks/$id"
    else
      echo -e "${RED}Error creating bookmark${NC}"
      echo "$response"
      exit 1
    fi
  fi
}

# Get bookmark
cmd_get() {
  local id="$1"
  
  if [[ -z "$id" ]]; then
    echo -e "${RED}Error: Bookmark ID required${NC}"
    usage
  fi
  
  local response=$(api_request "bookmarks/$id")
  
  if [[ "$OUTPUT_JSON" == "true" ]] || [[ "$OUTPUT_RAW" == "true" ]]; then
    echo "$response"
  else
    format_bookmark "$response"
  fi
}

# Update bookmark
cmd_update() {
  local id="$1"
  
  if [[ -z "$id" ]]; then
    echo -e "${RED}Error: Bookmark ID required${NC}"
    usage
  fi
  
  local data='{}'
  
  if [[ -n "$TITLE" ]]; then
    data=$(echo "$data" | jq --arg t "$TITLE" '. + {title: $t}')
  fi
  
  if [[ -n "$TAGS" ]]; then
    local tags_array=$(echo "$TAGS" | jq -R 'split(",") | map(. | ltrimstr(" ") | rtrimstr(" "))')
    data=$(echo "$data" | jq --argjson t "$tags_array" '. + {tags: t}')
  fi
  
  if [[ -n "$NOTE" ]]; then
    data=$(echo "$data" | jq --arg n "$NOTE" '. + {note: $n}')
  fi
  
  local response=$(api_request "bookmarks/$id" "PATCH" "$data")
  
  if [[ "$OUTPUT_JSON" == "true" ]] || [[ "$OUTPUT_RAW" == "true" ]]; then
    echo "$response"
  else
    local id=$(echo "$response" | jq -r '.id')
    local title=$(echo "$response" | jq -r '.title')
    
    if [[ -n "$id" ]] && [[ "$id" != "null" ]]; then
      echo -e "${GREEN}✓ Bookmark updated${NC}"
      echo "  Title: $title"
      echo "  ID: $id"
    else
      echo -e "${RED}Error updating bookmark${NC}"
      echo "$response"
      exit 1
    fi
  fi
}

# Delete bookmark
cmd_delete() {
  local id="$1"
  
  if [[ -z "$id" ]]; then
    echo -e "${RED}Error: Bookmark ID required${NC}"
    usage
  fi
  
  local response=$(api_request "bookmarks/$id" "DELETE")
  
  if [[ "$OUTPUT_JSON" == "true" ]] || [[ "$OUTPUT_RAW" == "true" ]]; then
    echo "$response"
  else
    echo -e "${GREEN}✓ Bookmark deleted${NC}"
    echo "  ID: $id"
  fi
}

# List tags
cmd_tags() {
  local response=$(api_request "tags")
  
  if [[ "$OUTPUT_JSON" == "true" ]] || [[ "$OUTPUT_RAW" == "true" ]]; then
    echo "$response"
  else
    echo "Tags:"
    echo "$response" | jq -r '.[] | "  • \(.name) (\(.count))"' | sort
  fi
}

# Main
check_api_key

COMMAND="$1"
shift || true

case "$COMMAND" in
  list)
    cmd_list
    ;;
  search)
    cmd_search "$@"
    ;;
  add)
    cmd_add "$@"
    ;;
  get)
    cmd_get "$@"
    ;;
  update)
    cmd_update "$@"
    ;;
  delete)
    cmd_delete "$@"
    ;;
  tags)
    cmd_tags
    ;;
  help|--help|-h)
    usage
    ;;
  *)
    echo -e "${RED}Unknown command: $COMMAND${NC}"
    echo ""
    usage
    ;;
esac
