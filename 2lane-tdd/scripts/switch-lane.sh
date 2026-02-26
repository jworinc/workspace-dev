#!/bin/bash
# switch-lane.sh - Toggle active lane for development

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(dirname "$SCRIPT_DIR")"
LANES_DIR="$WORKSPACE_DIR/lanes"
ACTIVE_LANE_FILE="$WORKSPACE_DIR/.active-lane"

# Function to show current active lane
show_current_lane() {
    if [ -f "$ACTIVE_LANE_FILE" ]; then
        local current_lane=$(cat "$ACTIVE_LANE_FILE")
        echo -e "${BLUE}📍 Current active lane: ${GREEN}$current_lane${NC}"
        return 0
    else
        echo -e "${YELLOW}⚠️  No active lane set${NC}"
        return 1
    fi
}

# Function to set active lane
set_lane() {
    local lane=$1

    if [ "$lane" != "asis" ] && [ "$lane" != "tobe" ]; then
        echo -e "${RED}❌ Invalid lane: $lane${NC}"
        echo "   Valid lanes: asis, tobe"
        return 1
    fi

    # Check if lane exists
    if [ ! -d "$LANES_DIR/$lane" ]; then
        echo -e "${RED}❌ Lane directory not found: $lane${NC}"
        return 1
    fi

    # Set active lane
    echo "$lane" > "$ACTIVE_LANE_FILE"

    echo -e "${GREEN}✅ Active lane set to: $lane${NC}"
    echo ""
    echo -e "${BLUE}Next steps:${NC}"
    echo "   1. cd $LANES_DIR/$lane"
    echo "   2. Start working: vim <file> or pytest -x --watch"
    echo "   3. Run tests: cd $WORKSPACE_DIR && ./scripts/verify-both.sh"
}

# Function to show usage
show_usage() {
    echo "Usage: $0 [asis|tobe|current]"
    echo ""
    echo "Switch or show the active development lane."
    echo ""
    echo "Commands:"
    echo "  asis      Set AS-IS lane as active"
    echo "  tobe      Set TO-BE lane as active"
    echo "  current   Show current active lane"
    echo ""
    echo "Examples:"
    echo "  $0 tobe          # Switch to TO-BE lane"
    echo "  $0 asis          # Switch to AS-IS lane"
    echo "  $0 current       # Show current lane"
    echo ""
    echo "Quick Start:"
    echo "  cd \$($0 --path)  # Jump to active lane"
}

# Function to get path of active lane
get_lane_path() {
    if [ -f "$ACTIVE_LANE_FILE" ]; then
        local lane=$(cat "$ACTIVE_LANE_FILE")
        echo "$LANES_DIR/$lane"
        return 0
    else
        return 1
    fi
}

# Main function
main() {
    if [ $# -eq 0 ]; then
        show_current_lane
        return $?
    fi

    case "$1" in
        asis|tobe)
            set_lane "$1"
            ;;
        current)
            show_current_lane
            ;;
        --path)
            get_lane_path
            ;;
        -h|--help|help)
            show_usage
            ;;
        *)
            echo -e "${RED}Unknown command: $1${NC}"
            echo ""
            show_usage
            return 1
            ;;
    esac
}

cd "$WORKSPACE_DIR"
main "$@"
