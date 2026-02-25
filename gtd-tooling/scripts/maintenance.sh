#!/bin/bash

# OpenClaw GTD Maintenance Script
# Performs daily/weekly checks

WORKSPACE="/Users/anton/.openclaw/workspace"
SCRIPTS="$WORKSPACE/scripts"
TIL_FILE="$WORKSPACE/memory/TIL.md"

# Colors
BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log() { echo -e "${BLUE}$1${NC}"; }
success() { echo -e "${GREEN}✅ $1${NC}"; }
warn() { echo -e "${YELLOW}⚠️  $1${NC}"; }

# 1. Daily Maintenance
daily() {
  log "--- Daily Maintenance ---"
  
  # Ensure Memory Log
  python3 "$SCRIPTS/gtd_commands.py" gtd
  
  # TIL Scan
  if [ -f "$TIL_FILE" ]; then
    log "Recent TILs:"
    tail -n 10 "$TIL_FILE"
  fi
  
  success "Daily checks complete"
}

# 2. Weekly Maintenance
weekly() {
  log "--- Weekly Maintenance ---"
  
  # Registry Sync
  # ...
  
  # TIL Summary
  if [ -f "$TIL_FILE" ]; then
    log "Weekly TIL Summary (Last 7 days):"
    # Filter by date... (simple tail for now)
    grep -A 5 "$(date -v-7d +%Y-%m-%d)" "$TIL_FILE" || tail -n 20 "$TIL_FILE"
  fi
  
  success "Weekly review complete"
}

case "$1" in
  daily) daily ;;
  weekly) weekly ;;
  *) echo "Usage: maintenance.sh [daily|weekly]" ;;
esac
