#!/bin/bash
# diff-lanes.sh - Compare implementations between AS-IS and TO-BE lanes

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(dirname "$SCRIPT_DIR")"
LANES_DIR="$WORKSPACE_DIR/lanes"
ASIS_DIR="$LANES_DIR/asis"
TOBE_DIR="$LANES_DIR/tobe"

# Function to show usage
show_usage() {
    echo "Usage: $0 <filename> [--stats] [--summary]"
    echo ""
    echo "Compare implementations between AS-IS and TO-BE lanes."
    echo ""
    echo "Arguments:"
    echo "  filename    File to compare (relative to lane root)"
    echo "  --stats     Show diff statistics"
    echo "  --summary   Show summary of differences"
    echo ""
    echo "Examples:"
    echo "  $0 my_module.py"
    echo "  $0 src/calculator.py --stats"
    echo "  $0 tests/test_contract.py --summary"
}

# Function to check if file exists in both lanes
check_files() {
    local file=$1

    if [ ! -f "$ASIS_DIR/$file" ]; then
        echo -e "${RED}❌ File not found in AS-IS lane: $file${NC}"
        return 1
    fi

    if [ ! -f "$TOBE_DIR/$file" ]; then
        echo -e "${RED}❌ File not found in TO-BE lane: $file${NC}"
        return 1
    fi

    return 0
}

# Function to count lines of code
count_lines() {
    local file=$1
    # Count non-empty, non-comment lines
    grep -v '^\s*$' "$file" | grep -v '^\s*#' | wc -l | tr -d ' '
}

# Function to show diff statistics
show_stats() {
    local file=$1
    local asis_lines=$(count_lines "$ASIS_DIR/$file")
    local tobe_lines=$(count_lines "$TOBE_DIR/$file")
    local diff_lines=$(git diff --numstat "$ASIS_DIR/$file" "$TOBE_DIR/$file" 2>/dev/null | awk '{print $1 + $2}')

    echo -e "${BLUE}📊 Statistics for: $file${NC}"
    echo "   AS-IS lines: $asis_lines"
    echo "   TO-BE lines: $tobe_lines"
    echo "   Diff size: ${diff_lines:-0} lines"
}

# Function to show summary of changes
show_summary() {
    local file=$1

    echo -e "${BLUE}📝 Summary of changes: $file${NC}"

    # Count additions
    local additions=$(diff -u "$ASIS_DIR/$file" "$TOBE_DIR/$file" 2>/dev/null | grep "^+" | grep -v "^+++" | wc -l | tr -d ' ')

    # Count deletions
    local deletions=$(diff -u "$ASIS_DIR/$file" "$TOBE_DIR/$file" 2>/dev/null | grep "^-" | grep -v "^---" | wc -l | tr -d ' ')

    echo "   Lines added: ${additions:-0}"
    echo "   Lines removed: ${deletions:-0}"

    # Show if file grew or shrank
    if [ "${additions:-0}" -gt "${deletions:-0}" ]; then
        echo -e "   ${GREEN}File grew${NC}"
    elif [ "${deletions:-0}" -gt "${additions:-0}" ]; then
        echo -e "   ${YELLOW}File shrank${NC}"
    else
        echo -e "   ${BLUE}File size unchanged${NC}"
    fi
}

# Main function
main() {
    if [ $# -eq 0 ] || [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
        show_usage
        return 0
    fi

    local file=$1
    local show_stats_flag=0
    local show_summary_flag=0

    # Parse options
    shift
    while [ $# -gt 0 ]; do
        case "$1" in
            --stats)
                show_stats_flag=1
                ;;
            --summary)
                show_summary_flag=1
                ;;
            *)
                echo -e "${RED}Unknown option: $1${NC}"
                show_usage
                return 1
                ;;
        esac
        shift
    done

    # Check if files exist
    if ! check_files "$file"; then
        return 1
    fi

    echo ""
    echo -e "${BLUE}🔄 Comparing: AS-IS vs TO-BE${NC}"
    echo -e "${BLUE}   File: $file${NC}"
    echo ""

    # Show statistics if requested
    if [ $show_stats_flag -eq 1 ]; then
        show_stats "$file"
        echo ""
    fi

    # Show summary if requested
    if [ $show_summary_flag -eq 1 ]; then
        show_summary "$file"
        echo ""
    fi

    # Show diff
    echo -e "${BLUE}📄 Diff Output:${NC}"
    echo ""
    diff -u "$ASIS_DIR/$file" "$TOBE_DIR/$file" || true

    echo ""
    echo -e "${GREEN}✅ Comparison complete${NC}"
}

cd "$WORKSPACE_DIR"
main "$@"
