#!/bin/bash
# SRE Modification Workflow
# Usage: ./scripts/CRI-ACTION.sh <mode>
#
# Run from a subfolder containing the target file (e.g., changes/config/)
# The script automatically detects the target file in the current directory.
#
# Modes:
#   apply       - Apply change with delta, test, and confirm
#   rollback    - Rollback to last backup
#   rollback <id> - Rollback to specific backup
#   list        - List available backups
#   test        - Validate syntax only (no changes)
#   status      - Show file status and recent backups

set -e

MODE="$1"
ARG3="$2"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

BACKUP_DIR="/tmp/sre-mod-backups"

# Find target file in current directory (skip the script itself)
find_target_file() {
    for f in *; do
        if [ -f "$f" ] && [[ ! "$f" =~ \.sh$ ]] && [[ ! "$f" =~ \.md$ ]]; then
            echo "$f"
            return
        fi
    done
    return 1
}

FILE=$(find_target_file)

# Show usage
usage() {
    echo "SRE Modification Workflow"
    echo ""
    echo "Usage: ./scripts/CRI-ACTION.sh <mode>"
    echo ""
    echo "Run this script from a subfolder containing the target file."
    echo "Example: cd changes/config && ../../scripts/CRI-ACTION.sh apply"
    echo ""
    echo "Modes:"
    echo "  apply           - Apply change with delta, test, and confirm"
    echo "  rollback        - Rollback to last backup"
    echo "  rollback <id>   - Rollback to specific backup"
    echo "  list            - List available backups"
    echo "  test            - Validate syntax only (no changes)"
    echo "  status          - Show file status and recent backups"
    echo ""
    echo "Examples:"
    echo "  cd changes/config && ../../scripts/CRI-ACTION.sh apply"
    echo "  cd changes/config && ../../scripts/CRI-ACTION.sh rollback"
    echo "  cd changes/config && ../../scripts/CRI-ACTION.sh rollback 20250212-154500"
    echo "  cd changes/config && ../../scripts/CRI-ACTION.sh list"
    echo "  cd changes/config && ../../scripts/CRI-ACTION.sh test"
    echo "  cd changes/config && ../../scripts/CRI-ACTION.sh status"
}

# Get backups for a file
get_backups() {
    local basefile=$(basename "$1")
    ls -t "$BACKUP_DIR/${basefile}".* 2>/dev/null || true
}

# Apply mode
apply_mode() {
    if [ -z "$FILE" ]; then
        echo -e "${RED}Error: No target file found in current directory${NC}"
        echo "Create a subfolder with your config file (e.g., changes/config/openclaw.json)"
        exit 1
    fi

    # Create backup
    mkdir -p "$BACKUP_DIR"
    TIMESTAMP=$(date +%Y%m%d-%H%M%S)
    BACKUP="$BACKUP_DIR/$(basename "$FILE").$TIMESTAMP"
    cp "$FILE" "$BACKUP"

    echo -e "${BLUE}=== SRE Modification: Apply ===${NC}"
    echo -e "File: $FILE"
    echo -e "Backup: $BACKUP (${TIMESTAMP})"
    echo ""

    # Show current state
    echo -e "${YELLOW}1. Current State${NC}"
    echo "----------------------------------------"
    head -20 "$FILE"
    if [ $(wc -l < "$FILE") -gt 20 ]; then
        echo "... ($(wc -l < "$FILE") total lines)"
    fi
    echo ""

    # Get new content
    echo -e "${YELLOW}2. Proposed Change${NC}"
    echo "----------------------------------------"
    echo "Paste the new content (Ctrl+D to finish, or Ctrl+C to cancel):"
    echo ""
    NEW_CONTENT=$(cat)
    if [ -z "$NEW_CONTENT" ]; then
        echo -e "${RED}Error: No content provided${NC}"
        exit 1
    fi

    # Show delta
    echo ""
    echo -e "${YELLOW}3. DELTA${NC}"
    echo "----------------------------------------"
    diff -u "$FILE" <(echo "$NEW_CONTENT") || true
    echo ""

    # Test syntax
    echo -e "${YELLOW}4. Test${NC}"
    echo "----------------------------------------"
    TEST_RESULT=0
    case "$FILE" in
        *.json)
            echo "Validating JSON syntax..."
            echo "$NEW_CONTENT" | jq . > /dev/null 2>&1 || TEST_RESULT=1
            ;;
        *.yaml|*.yml)
            echo "Validating YAML syntax..."
            echo "$NEW_CONTENT" | python3 -c "import yaml, sys; yaml.safe_load(sys.stdin)" 2>/dev/null || TEST_RESULT=1
            ;;
        *.sh)
            echo "Validating shell syntax..."
            echo "$NEW_CONTENT" | bash -n || TEST_RESULT=1
            ;;
        *)
            echo "No syntax test available for this file type"
            ;;
    esac

    if [ $TEST_RESULT -eq 0 ]; then
        echo -e "${GREEN}✓ Syntax validation passed${NC}"
    else
        echo -e "${RED}✗ Syntax validation failed${NC}"
        echo ""
        read -p "Proceed anyway? (y/N): " proceed_anyway
        if [[ ! "$proceed_anyway" =~ ^[Yy]$ ]]; then
            echo "Aborted. Backup kept at: $BACKUP"
            exit 1
        fi
    fi
    echo ""

    # Recovery info
    echo -e "${YELLOW}5. Recovery${NC}"
    echo "----------------------------------------"
    echo "If something goes wrong, run:"
    echo "  ./scripts/CRI-ACTION.sh rollback"
    echo "  # or specific backup:"
    echo "  ./scripts/CRI-ACTION.sh rollback $TIMESTAMP"
    echo ""

    # Confirm
    echo -e "${YELLOW}6. Confirm${NC}"
    echo "----------------------------------------"
    read -p "Apply this change? (yes/y): " confirm

    if [[ "$confirm" =~ ^[Yy][Ee][Ss]$ || "$confirm" =~ ^[Yy]$ ]]; then
        echo "$NEW_CONTENT" > "$FILE"
        echo -e "${GREEN}✓ Change applied successfully${NC}"
        echo "Backup: $BACKUP"
    else
        echo "Change cancelled."
        echo "Backup kept at: $BACKUP"
        exit 1
    fi
}

# Rollback mode
rollback_mode() {
    local backups=($(get_backups "$FILE"))

    if [ ${#backups[@]} -eq 0 ]; then
        echo -e "${RED}No backups found for: $FILE${NC}"
        exit 1
    fi

    if [ -n "$ARG3" ]; then
        # Specific backup
        BACKUP="$BACKUP_DIR/$(basename "$FILE").$ARG3"
        if [ ! -f "$BACKUP" ]; then
            echo -e "${RED}Backup not found: $BACKUP${NC}"
            exit 1
        fi
    else
        # Latest backup
        BACKUP="${backups[0]}"
    fi

    echo -e "${BLUE}=== SRE Modification: Rollback ===${NC}"
    echo -e "File: $FILE"
    echo -e "Backup: $BACKUP"
    echo ""

    # Show what will change
    echo -e "${YELLOW}DELTA (Current → Backup)${NC}"
    echo "----------------------------------------"
    diff -u "$FILE" "$BACKUP" || true
    echo ""

    # Confirm
    read -p "Restore this backup? (yes/y): " confirm
    if [[ "$confirm" =~ ^[Yy][Ee][Ss]$ || "$confirm" =~ ^[Yy]$ ]]; then
        cp "$BACKUP" "$FILE"
        echo -e "${GREEN}✓ Rollback completed${NC}"
        echo "Restored from: $BACKUP"
    else
        echo "Rollback cancelled."
        exit 1
    fi
}

# List mode
list_mode() {
    local backups=($(get_backups "$FILE"))

    if [ ${#backups[@]} -eq 0 ]; then
        echo "No backups found for: $FILE"
        exit 0
    fi

    echo -e "${BLUE}=== Backups for: $FILE ===${NC}"
    echo ""

    for i in "${!backups[@]}"; do
        local backup="${backups[$i]}"
        local base=$(basename "$backup")
        local timestamp=${base##*.}
        local info=$(ls -lh "$backup" | awk '{print $5, $6, $7, $8}')

        if [ $i -eq 0 ]; then
            echo -e "${CYAN}[LATEST]${NC} $timestamp  ($info)"
        else
            echo "         $timestamp  ($info)"
        fi
    done
    echo ""
    echo "Rollback commands:"
    echo "  ./scripts/CRI-ACTION.sh rollback        # Latest"
    echo "  ./scripts/CRI-ACTION.sh rollback <id>   # Specific"
}

# Test mode
test_mode() {
    echo -e "${BLUE}=== SRE Modification: Test ===${NC}"
    echo -e "File: $FILE"
    echo ""

    TEST_RESULT=0
    case "$FILE" in
        *.json)
            echo "Validating JSON syntax..."
            jq . "$FILE" > /dev/null 2>&1 || TEST_RESULT=1
            ;;
        *.yaml|*.yml)
            echo "Validating YAML syntax..."
            python3 -c "import yaml; yaml.safe_load(open('$FILE'))" 2>/dev/null || TEST_RESULT=1
            ;;
        *.sh)
            echo "Validating shell syntax..."
            bash -n "$FILE" || TEST_RESULT=1
            ;;
        *)
            echo "No syntax test available for this file type"
            TEST_RESULT=2
            ;;
    esac

    if [ $TEST_RESULT -eq 0 ]; then
        echo -e "${GREEN}✓ Valid${NC}"
    elif [ $TEST_RESULT -eq 2 ]; then
        echo -e "${YELLOW}⚠ Skipped (no validator)${NC}"
    else
        echo -e "${RED}✗ Invalid${NC}"
        exit 1
    fi
}

# Status mode
status_mode() {
    echo -e "${BLUE}=== SRE Status: $FILE ===${NC}"
    echo ""

    # File info
    if [ -f "$FILE" ]; then
        echo -e "${CYAN}File:${NC} $FILE"
        echo -e "${CYAN}Size:${NC} $(ls -lh "$FILE" | awk '{print $5}')"
        echo -e "${CYAN}Modified:${NC} $(ls -l "$FILE" | awk '{print $6, $7, $8}')"
        echo ""
    else
        echo -e "${RED}File not found: $FILE${NC}"
        echo ""
    fi

    # Backups
    local backups=($(get_backups "$FILE"))
    if [ ${#backups[@]} -gt 0 ]; then
        echo -e "${CYAN}Recent backups:${NC}"
        for i in "${!backups[@]}"; do
            local backup="${backups[$i]}"
            local base=$(basename "$backup")
            local timestamp=${base##*.}
            local info=$(ls -lh "$backup" | awk '{print $5, $6, $7, $8}')

            if [ $i -eq 0 ]; then
                echo "  ${CYAN}[LATEST]${NC} $timestamp  ($info)"
            elif [ $i -lt 3 ]; then
                echo "          $timestamp  ($info)"
            fi
        done
        echo ""
    else
        echo -e "${CYAN}No backups found${NC}"
        echo ""
    fi

    # Test
    echo -e "${CYAN}Validation:${NC}"
    test_mode
}

# Main
case "$MODE" in
    apply)
        apply_mode
        ;;
    rollback)
        rollback_mode
        ;;
    list)
        list_mode
        ;;
    test)
        test_mode
        ;;
    status)
        status_mode
        ;;
    help|--help|-h)
        usage
        ;;
    *)
        echo -e "${RED}Error: Unknown mode '$MODE'${NC}"
        echo ""
        usage
        exit 1
        ;;
esac
