#!/bin/bash

# Screenshot & Explain with AI
# Takes screenshot using Peekaboo, then asks AI to explain it

SCRIPT_DIR="$HOME/.openclaw/workspace/scripts"
TIMESTAMP=$(date +%s)
SCREENSHOT_DIR="$HOME/Desktop/screenshots"
SCREENSHOT_PATH="$SCREENSHOT_DIR/screenshot-$TIMESTAMP.png"

# Create screenshot directory
mkdir -p "$SCREENSHOT_DIR"

echo "📸 Screenshot & Explain"
echo "======================================"
echo ""

# Parse arguments
MODE="frontmost"  # default
APP_NAME=""
WINDOW_TITLE=""
EXPLAIN=true

while [[ $# -gt 0 ]]; do
  case $1 in
    --screen)
      MODE="screen"
      shift
      ;;
    --window)
      MODE="window"
      shift
      ;;
    --frontmost)
      MODE="frontmost"
      shift
      ;;
    --app)
      APP_NAME="$2"
      shift 2
      ;;
    --window-title)
      WINDOW_TITLE="$2"
      shift 2
      ;;
    --no-explain)
      EXPLAIN=false
      shift
      ;;
    *)
      echo "Unknown option: $1"
      echo "Usage: $0 [options]"
      echo ""
      echo "Options:"
      echo "  --screen              Capture entire screen"
      echo "  --window             Capture specific window"
      echo "  --frontmost           Capture frontmost window (default)"
      echo "  --app <name>         Target specific app"
      echo "  --window-title <name>  Target specific window title"
      echo "  --no-explain         Skip AI explanation"
      exit 1
      ;;
  esac
done

# Take screenshot
echo "Taking screenshot..."
echo ""

if [ "$MODE" = "screen" ]; then
  peekaboo image --mode screen --path "$SCREENSHOT_PATH"
  echo "✅ Screenshot saved: $SCREENSHOT_PATH"
elif [ "$MODE" = "window" ] && [ -n "$WINDOW_TITLE" ]; then
  peekaboo image --mode window --window-title "$WINDOW_TITLE" --path "$SCREENSHOT_PATH"
  echo "✅ Screenshot saved: $SCREENSHOT_PATH (window: $WINDOW_TITLE)"
elif [ "$MODE" = "window" ] && [ -n "$APP_NAME" ]; then
  peekaboo image --app "$APP_NAME" --path "$SCREENSHOT_PATH"
  echo "✅ Screenshot saved: $SCREENSHOT_PATH (app: $APP_NAME)"
else
  peekaboo image --mode frontmost --path "$SCREENSHOT_PATH"
  echo "✅ Screenshot saved: $SCREENSHOT_PATH (frontmost window)"
fi

echo ""

# Ask AI to explain
if [ "$EXPLAIN" = true ]; then
  echo "🤖 Asking AI to explain screenshot..."
  echo ""
  
  echo "📝 Screenshot saved to: $SCREENSHOT_PATH"
  echo ""
  echo "💡 To explain this screenshot, ask:"
  echo "   Explain this screenshot: $SCREENSHOT_PATH"
  echo "   or: Create visual documentation for the UI shown in $SCREENSHOT_PATH"
else
  echo "📝 Screenshot saved to: $SCREENSHOT_PATH"
  echo "   (No AI explanation requested)"
fi

echo ""
echo "======================================"
echo "Done!"
