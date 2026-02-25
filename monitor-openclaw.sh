#!/bin/bash

# OpenClaw Monitoring Script
# Uses Clog to monitor gateway logs in real-time

CLOG_BIN="$HOME/.openclaw/workspace-dev/clog-bin"
GATEWAY_LOG="$HOME/.openclaw/logs/gateway.log"
GATEWAY_ERR="$HOME/.openclaw/logs/gateway.err.log"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log() { echo -e "${BLUE}$1${NC}"; }
success() { echo -e "${GREEN}✅ $1${NC}"; }

# Check if Clog exists
if [[ ! -f "$CLOG_BIN" ]]; then
  log "Clog not found. Please build it first:"
  echo "  cd ~/.openclaw/workspace-dev/clog"
  echo "  go build -o clog"
  exit 1
fi

# Check if logs exist
if [[ ! -f "$GATEWAY_LOG" ]]; then
  warn "Gateway log not found: $GATEWAY_LOG"
fi

# Start monitoring
log "OpenClaw monitoring started with Clog"
log "Press Ctrl+C to stop"
echo ""

# Monitor main gateway log
$CLOG_BIN -d "$GATEWAY_LOG" &

# Monitor gateway error log (errors only)
if [[ -f "$GATEWAY_ERR" ]]; then
  $CLOG_BIN -e "$GATEWAY_ERR" &
fi

# Wait for Ctrl+C
success "Monitoring active - viewing logs in Clog dashboard"
wait

echo ""
log "Monitoring stopped"
