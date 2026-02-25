#!/bin/bash

# herenow.sh - here.now deployment wrapper
# Usage: herenow deploy [file|directory|options]

set -e

# Configuration
HERE_NOW_API="https://here.now"
HERE_NOW_ENDPOINT="/api/v1/deploy"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Variables
CONTENT=""
NAME=""
PATH_TO_DEPLOY=""

# Usage
usage() {
  cat << EOF
here.now - Instant Web Hosting

Usage:
  herenow <command> [options]

Commands:
  deploy [path]    Deploy file or directory
  deploy --content   Deploy content string
  status           Check service status
  list             List your deployments

Options:
  --name <name>    Custom name for deployment
  --content <str>   Deploy content string instead of file
  --help, -h       Show this help

Examples:
  herenow deploy index.html
  herenow deploy ./docs/
  herenow deploy --content "<html>Hello</html>"
  herenow deploy report.html --name "my-report"

Get instant URL: velvet-soul-6sy2.here.now

EOF
  exit 0
}

# Check if jq is installed
check_dependencies() {
  if ! command -v jq &> /dev/null; then
    echo -e "${YELLOW}Warning: jq not found. Install with: brew install jq${NC}"
    echo "Will parse JSON response manually."
  fi
}

# Parse response (with or without jq)
parse_url() {
  local response="$1"
  
  if command -v jq &> /dev/null; then
    local url=$(echo "$response" | jq -r '.url // empty' 2>/dev/null)
    local expires=$(echo "$response" | jq -r '.expires // empty' 2>/dev/null)
    local size=$(echo "$response" | jq -r '.size // empty' 2>/dev/null)
    
    if [[ -n "$url" ]]; then
      echo "$url|$expires|$size"
      return 0
    fi
  fi
  
  # Fallback: try to extract URL with grep
  local url=$(echo "$response" | grep -oP 'http://[a-zA-Z0-9\-]+\.here\.now' | head -1)
  
  if [[ -n "$url" ]]; then
    echo "$url||"
    return 0
  fi
  
  return 1
}

# Deploy file
deploy_file() {
  local file="$1"
  
  if [[ ! -f "$file" ]]; then
    echo -e "${RED}Error: File not found: $file${NC}"
    exit 1
  fi
  
  echo -e "${BLUE}Deploying file: $file${NC}"
  
  local data="file=@$file"
  if [[ -n "$NAME" ]]; then
    data="$data;name=$NAME"
  fi
  
  # Try different API endpoints (since exact endpoint is unknown)
  local response=""
  
  # Try endpoint 1: /deploy
  response=$(curl -s -X POST \
    -H "Accept: application/json" \
    -F "file=@$file" \
    "$HERE_NOW_API/deploy" 2>&1)
  
  # Check if we got a valid response
  if [[ "$response" == *"http://"*"here.now"* ]] || [[ "$response" == *"{"* ]]; then
    # Got a response, try to parse
    local result=$(parse_url "$response")
    
    if [[ $? -eq 0 ]]; then
      local url=$(echo "$result" | cut -d'|' -f1)
      local expires=$(echo "$result" | cut -d'|' -f2)
      local size=$(echo "$result" | cut -d'|' -f3)
      
      echo -e "${GREEN}✓ Deployed successfully!${NC}"
      echo -e "  ${BLUE}URL:$NC $url"
      
      if [[ -n "$expires" ]]; then
        echo -e "  Expires: $expires"
      fi
      
      if [[ -n "$size" && "$size" != "null" ]]; then
        echo -e "  Size: $size bytes"
      fi
      
      echo ""
      echo -e "${YELLOW}Share this URL:${NC} $url"
      return 0
    fi
  fi
  
  # Try endpoint 2: /api/v1/deploy
  response=$(curl -s -X POST \
    -H "Accept: application/json" \
    -F "file=@$file" \
    "$HERE_NOW_API$HERE_NOW_ENDPOINT" 2>&1)
  
  if [[ "$response" == *"http://"*"here.now"* ]] || [[ "$response" == *"{"* ]]; then
    local result=$(parse_url "$response")
    
    if [[ $? -eq 0 ]]; then
      local url=$(echo "$result" | cut -d'|' -f1)
      echo -e "${GREEN}✓ Deployed successfully!${NC}"
      echo -e "  ${BLUE}URL:$NC $url"
      echo ""
      echo -e "${YELLOW}Share this URL:${NC} $url"
      return 0
    fi
  fi
  
  # If we got here, deployment failed
  echo -e "${RED}Deployment failed${NC}"
  echo ""
  echo "Response from server:"
  echo "$response"
  echo ""
  echo -e "${YELLOW}Note: here.now API endpoint may be different than expected.${NC}"
  echo -e "${YELLOW}Please check: https://here.now for current API documentation${NC}"
  return 1
}

# Deploy directory
deploy_directory() {
  local dir="$1"
  
  if [[ ! -d "$dir" ]]; then
    echo -e "${RED}Error: Directory not found: $dir${NC}"
    exit 1
  fi
  
  echo -e "${BLUE}Deploying directory: $dir${NC}"
  
  # Create tarball
  local tarball="/tmp/herenow-$(date +%s).tar.gz"
  echo -e "${BLUE}Creating tarball...${NC}"
  tar -czf "$tarball" -C "$dir" . 2>/dev/null
  
  local size=$(ls -lh "$tarball" | awk '{print $5}')
  echo -e "${BLUE}Tarball size: $size${NC}"
  
  # Deploy
  local response=$(curl -s -X POST \
    -H "Accept: application/json" \
    -H "Content-Type: application/octet-stream" \
    --data-binary "@$tarball" \
    "$HERE_NOW_API/deploy" 2>&1)
  
  # Cleanup
  rm -f "$tarball"
  
  # Parse response
  local result=$(parse_url "$response")
  
  if [[ $? -eq 0 ]]; then
    local url=$(echo "$result" | cut -d'|' -f1)
    echo -e "${GREEN}✓ Deployed successfully!${NC}"
    echo -e "  ${BLUE}URL:$NC $url"
    echo ""
    echo -e "${YELLOW}Share this URL:${NC} $url"
    return 0
  fi
  
  echo -e "${RED}Deployment failed${NC}"
  echo ""
  echo "Response from server:"
  echo "$response"
  return 1
}

# Deploy content string
deploy_content() {
  local content="$1"
  
  echo -e "${BLUE}Deploying content string...${NC}"
  
  # Create JSON payload
  local json_payload="{\"content\":\"$content\"}"
  if [[ -n "$NAME" ]]; then
    json_payload=$(echo "$json_payload" | jq -c --arg n "$NAME" '. + {name: $n}')
  fi
  
  # Deploy
  local response=$(curl -s -X POST \
    -H "Accept: application/json" \
    -H "Content-Type: application/json" \
    -d "$json_payload" \
    "$HERE_NOW_API/deploy" 2>&1)
  
  # Parse response
  local result=$(parse_url "$response")
  
  if [[ $? -eq 0 ]]; then
    local url=$(echo "$result" | cut -d'|' -f1)
    echo -e "${GREEN}✓ Deployed successfully!${NC}"
    echo -e "  ${BLUE}URL:$NC $url"
    echo ""
    echo -e "${YELLOW}Share this URL:${NC} $url"
    return 0
  fi
  
  echo -e "${RED}Deployment failed${NC}"
  echo ""
  echo "Response from server:"
  echo "$response"
  return 1
}

# Check service status
check_status() {
  echo -e "${BLUE}Checking here.now service status...${NC}"
  
  local response=$(curl -s "$HERE_NOW_API/status" 2>&1 || curl -s "$HERE_NOW_API" 2>&1)
  
  echo "$response"
}

# List deployments
list_deployments() {
  echo -e "${BLUE}Listing deployments...${NC}"
  
  local response=$(curl -s "$HERE_NOW_API/list" 2>&1 || curl -s "$HERE_NOW_API" 2>&1)
  
  if command -v jq &> /dev/null && [[ "$response" == *"{"* ]]; then
    echo "$response" | jq .
  else
    echo "$response"
  fi
}

# Parse arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --name)
      NAME="$2"
      shift 2
      ;;
    --content)
      CONTENT="$2"
      shift 2
      ;;
    --help|-h)
      usage
      ;;
    deploy|status|list)
      COMMAND="$1"
      shift
      ;;
    *)
      if [[ -z "$PATH_TO_DEPLOY" ]]; then
        PATH_TO_DEPLOY="$1"
      fi
      shift
      ;;
  esac
done

# Check dependencies
check_dependencies

# Execute command
case "$COMMAND" in
  deploy)
    if [[ -n "$CONTENT" ]]; then
      deploy_content "$CONTENT"
    elif [[ -n "$PATH_TO_DEPLOY" ]]; then
      if [[ -f "$PATH_TO_DEPLOY" ]]; then
        deploy_file "$PATH_TO_DEPLOY"
      elif [[ -d "$PATH_TO_DEPLOY" ]]; then
        deploy_directory "$PATH_TO_DEPLOY"
      else
        echo -e "${RED}Error: $PATH_TO_DEPLOY is not a valid file or directory${NC}"
        exit 1
      fi
    else
      echo -e "${RED}Error: No path or content specified${NC}"
      echo ""
      usage
    fi
    ;;
  status)
    check_status
    ;;
  list)
    list_deployments
    ;;
  *)
    echo -e "${RED}Unknown command: $COMMAND${NC}"
    echo ""
    usage
    ;;
esac
