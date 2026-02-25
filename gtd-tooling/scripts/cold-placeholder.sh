#!/bin/bash

# cold-placeholder.sh - Create transient placeholder scripts for cold storage
# Usage: ./cold-placeholder.sh create <file> --remote <remote-path>

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Configuration
COLD_STORAGE_REMOTE="${COLD_STORAGE_REMOTE:-b2:videos}"
RETRIEVE_DIR="${RETRIEVE_DIR:-~/Downloads}"

# Usage
usage() {
  cat << EOF
Cold Storage Placeholder Generator

Usage:
  cold-placeholder.sh <command> [options]

Commands:
  create <file> [--remote <path>]    Create placeholder script for file
  list                                 List all placeholder scripts
  clean                                Clean up downloaded files

Options:
  --remote <path>      Remote storage path (default: b2:videos/filename)
  --description <text>  Description of placeholder
  --size <size>        File size for display

Examples:
  cold-placeholder.sh create video.mp4
  cold-placeholder.sh create video.mp4 --remote "b2:archive/video.mp4"
  cold-placeholder.sh create video.mp4 --description "Family vacation 2024"
  cold-placeholder.sh list
  cold-placeholder.sh clean

EOF
  exit 0
}

# Get file size from remote
get_remote_size() {
  local remote="$1"
  local size=$(rclone size "$remote" --json 2>/dev/null | jq -r '.count' || echo "Unknown")
  echo "$size"
}

# Create placeholder script
create_placeholder() {
  local file="$1"
  local remote="$2"
  local description="$3"
  local size_display="$4"
  
  # Default remote path
  if [[ -z "$remote" ]]; then
    remote="$COLD_STORAGE_REMOTE/$file"
  fi
  
  # Get size if not provided
  if [[ -z "$size_display" ]]; then
    local size=$(get_remote_size "$remote")
    size_display="$size"
  fi
  
  # Create script path
  local dir=$(dirname "$file")
  local filename=$(basename "$file" .${file##*.})
  local script_path="${dir}/${filename}.cold.sh"
  
  echo -e "${BLUE}Creating placeholder: $script_path${NC}"
  
  # Generate script
  cat > "$script_path" << EOF
#!/bin/bash

# Cold Storage Placeholder: $filename
# Size: $size_display
# Remote: $remote
# Description: ${description:-Cold storage file}

set -e

REMOTE="$remote"
LOCAL="\$RETRIEVE_DIR/${filename}-\$(date +%s).${file##*.}"
CACHED_FILE="${dir}/${filename}"

echo -e "\${GREEN}📥 Retrieving from cold storage...${NC}"
echo "Remote: \$REMOTE"
echo "Size: $size_display"
echo ""

# Check for local cache first
if [[ -f "\$CACHED_FILE" ]]; then
  echo -e "\${BLUE}✓ Found cached copy: \$CACHED_FILE${NC}"
  echo ""
  read -p "Use cached copy? (y/n): " -n 1 -r
  if [[ "\$REPLY" == "y" ]]; then
    open "\$CACHED_FILE"
    exit 0
  fi
  echo ""
fi

# Download from cold storage
echo "Downloading from \$REMOTE..."
rclone copy "\$REMOTE" "\$RETRIEVE_DIR"

echo -e "\${GREEN}✓ Downloaded: \$LOCAL${NC}"
echo ""

# Ask to open or cache
echo -e "\${YELLOW}Choose action:${NC}"
echo "  1. Open file"
echo "  2. Save as cache (\$CACHED_FILE)"
echo "  3. Just keep in Downloads"
echo ""
read -p "Choice (1/2/3): " -n 1 -r

case "\$REPLY" in
  1)
    open "\$LOCAL"
    ;;
  2)
    cp "\$LOCAL" "\$CACHED_FILE"
    echo -e "\${GREEN}✓ Cached: \$CACHED_FILE${NC}"
    ;;
  3)
    echo "File kept in: \$LOCAL"
    ;;
  *)
    echo -e "\${YELLOW}Cancelled${NC}"
    ;;
esac
EOF

  chmod +x "$script_path"
  
  # Create empty placeholder (for Finder)
  touch "${dir}/${filename}.placeholder"
  
  echo -e "${GREEN}✓ Created placeholder script${NC}"
  echo "  Script: $script_path"
  echo "  Run to retrieve: bash $script_path"
  echo "  Remote: $remote"
  echo "  Size: $size_display"
}

# List all placeholders
list_placeholders() {
  echo -e "${BLUE}Cold storage placeholders:${NC}"
  echo ""
  
  find . -name "*.cold.sh" -type f | while read -r script; do
    local filename=$(basename "$script" .cold.sh)
    local dir=$(dirname "$script")
    
    # Extract info from script
    local remote=$(grep "^REMOTE=" "$script" | cut -d= -f2 | tr -d '"')
    local size=$(grep "# Size:" "$script" | awk '{print $3}')
    local desc=$(grep "# Description:" "$script" | cut -d: -f2- | xargs)
    
    echo "  • $filename"
    echo "    Remote: $remote"
    echo "    Size: $size"
    if [[ -n "$desc" ]]; then
      echo "    Description: $desc"
    fi
    echo ""
  done
}

# Clean downloaded files
clean_downloads() {
  echo -e "${BLUE}Cleaning downloaded files from $RETRIEVE_DIR...${NC}"
  
  local count=$(find "$RETRIEVE_DIR" -type f -name "*-*" 2>/dev/null | wc -l)
  
  if [[ "$count" -eq 0 ]]; then
    echo -e "${YELLOW}No downloaded files found${NC}"
    return 0
  fi
  
  read -p "Delete $count downloaded files? (y/n): " -n 1 -r
  
  if [[ "$REPLY" == "y" ]]; then
    find "$RETRIEVE_DIR" -type f -name "*-*" -delete
    echo -e "${GREEN}✓ Cleaned $count files${NC}"
  else
    echo -e "${YELLOW}Cancelled${NC}"
  fi
}

# Parse arguments
COMMAND="$1"
shift || true

REMOTE=""
DESCRIPTION=""
SIZE=""

while [[ $# -gt 0 ]]; do
  case $1 in
    --remote)
      REMOTE="$2"
      shift 2
      ;;
    --description)
      DESCRIPTION="$2"
      shift 2
      ;;
    --size)
      SIZE="$2"
      shift 2
      ;;
    *)
      shift
      ;;
  esac
done

case "$COMMAND" in
  create)
    if [[ -z "$1" ]]; then
      echo -e "${YELLOW}Error: File required${NC}"
      usage
    fi
    create_placeholder "$1" "$REMOTE" "$DESCRIPTION" "$SIZE"
    ;;
  list)
    list_placeholders
    ;;
  clean)
    clean_downloads
    ;;
  help|--help|-h)
    usage
    ;;
  *)
    echo -e "${YELLOW}Unknown command: $COMMAND${NC}"
    usage
    ;;
esac
