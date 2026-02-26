#!/bin/bash
# verify-both.sh - Run tests in both AS-IS and TO-BE lanes

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(dirname "$SCRIPT_DIR")"
LANES_DIR="$WORKSPACE_DIR/lanes"
SHARED_TESTS_DIR="$WORKSPACE_DIR/shared-tests"

# Options
VERBOSE=${1:-""}

echo "🧪 2-Lane TDD Verification"
echo "================================"
echo ""

# Function to run tests in a lane
test_lane() {
    local lane=$1
    local lane_dir="$LANES_DIR/$lane"

    if [ ! -d "$lane_dir" ]; then
        echo -e "${RED}❌ $lane: Lane directory not found${NC}"
        return 1
    fi

    echo -e "${YELLOW}Testing $lane lane...${NC}"

    # Create temporary pytest config for this lane
    cd "$lane_dir"

    # Export PYTHONPATH to include lane + shared tests
    export PYTHONPATH="$lane_dir:$SHARED_TESTS_DIR"

    if [ -n "$VERBOSE" ]; then
        python3 -m pytest "$SHARED_TESTS_DIR" -v --tb=short
    else
        python3 -m pytest "$SHARED_TESTS_DIR" -q --tb=line
    fi

    local exit_code=$?

    if [ $exit_code -eq 0 ]; then
        echo -e "${GREEN}✅ $lane: All tests passed${NC}"
        return 0
    else
        echo -e "${RED}❌ $lane: Tests failed (exit code: $exit_code)${NC}"
        return 1
    fi
}

# Function to check if lane has tests
check_tests_exist() {
    local lane=$1
    local lane_dir="$LANES_DIR/$lane"

    if [ ! -d "$lane_dir" ]; then
        return 1
    fi

    # Check if there are any Python files in shared-tests
    if [ -z "$(find "$SHARED_TESTS_DIR" -name "test_*.py" -o -name "*_test.py" 2>/dev/null)" ]; then
        echo -e "${YELLOW}⚠️  No test files found in shared-tests/${NC}"
        return 1
    fi

    return 0
}

# Main verification
main() {
    local asis_passed=0
    local tobe_passed=0

    # Check if tests exist
    if ! check_tests_exist "asis" && ! check_tests_exist "tobe"; then
        echo -e "${YELLOW}No tests found. Create tests in shared-tests/ first.${NC}"
        return 1
    fi

    # Test AS-IS lane
    if check_tests_exist "asis"; then
        test_lane "asis"
        asis_passed=$?
    else
        echo -e "${YELLOW}⚠️  AS-IS lane: Skipped (no tests or lane not found)${NC}"
    fi

    echo ""

    # Test TO-BE lane
    if check_tests_exist "tobe"; then
        test_lane "tobe"
        tobe_passed=$?
    else
        echo -e "${YELLOW}⚠️  TO-BE lane: Skipped (no tests or lane not found)${NC}"
    fi

    echo ""
    echo "================================"

    # Summary
    if [ $asis_passed -eq 0 ] && [ $tobe_passed -eq 0 ]; then
        echo -e "${GREEN}✅ Both lanes verified successfully!${NC}"
        return 0
    elif [ $asis_passed -eq 0 ] && [ $tobe_passed -ne 0 ]; then
        echo -e "${RED}❌ AS-IS passed, but TO-BE failed${NC}"
        echo -e "${YELLOW}Fix TO-BE to match AS-IS behavior${NC}"
        return 1
    elif [ $asis_passed -ne 0 ] && [ $tobe_passed -eq 0 ]; then
        echo -e "${RED}❌ TO-BE passed, but AS-IS failed${NC}"
        echo -e "${YELLOW}AS-IS should be stable. Fix AS-IS first.${NC}"
        return 1
    else
        echo -e "${RED}❌ Both lanes failed${NC}"
        echo -e "${YELLOW}Check test failures and fix implementations${NC}"
        return 1
    fi
}

cd "$WORKSPACE_DIR"
main
