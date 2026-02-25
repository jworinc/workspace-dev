#!/usr/bin/env bash
set -euo pipefail

# openclaw-websearch-switch.sh
# Easy toggle for OpenClaw web_search backend between Perplexity direct and OpenRouter.
#
# Why a script?
# - If Perplexity rate-limits or times out, you can switch to OpenRouter quickly.
# - Keeps your current defaults unless you explicitly change them.
#
# Notes:
# - This script changes ~/.openclaw/openclaw.json via `openclaw config set`.
# - It does NOT print API keys.

cmd="${1:-status}"
shift || true

OPENCLAW_BIN="openclaw"

get() { "$OPENCLAW_BIN" config get "$1"; }
setv() { "$OPENCLAW_BIN" config set "$1" "$2" >/dev/null; }

perplexity_key() {
  get tools.web.search.perplexity.apiKey
}

openrouter_key() {
  # Reuse the OpenRouter provider key already stored in OpenClaw config.
  get models.providers.openrouter.apiKey
}

status() {
  echo "web_search provider:   $(get tools.web.search.provider)"
  echo "web_search enabled:    $(get tools.web.search.enabled)"
  echo "perplexity baseUrl:    $(get tools.web.search.perplexity.baseUrl)"
  echo "perplexity model:      $(get tools.web.search.perplexity.model)"
  echo "perplexity apiKey:     (hidden)"
}

use_perplexity() {
  setv tools.web.search.provider perplexity
  setv tools.web.search.perplexity.baseUrl https://api.perplexity.ai
  # keep existing pplx key
  local k
  k="$(perplexity_key)"
  setv tools.web.search.perplexity.apiKey "$k"
  echo "Switched web_search to Perplexity direct (api.perplexity.ai)."
}

use_openrouter() {
  setv tools.web.search.provider perplexity
  setv tools.web.search.perplexity.baseUrl https://openrouter.ai/api/v1
  local k
  k="$(openrouter_key)"
  setv tools.web.search.perplexity.apiKey "$k"
  echo "Switched web_search to OpenRouter (openrouter.ai) for Perplexity search models."
}

model_sonar() {
  setv tools.web.search.perplexity.model perplexity/sonar
  echo "Set web_search model to perplexity/sonar"
}

model_pro() {
  setv tools.web.search.perplexity.model perplexity/sonar-pro
  echo "Set web_search model to perplexity/sonar-pro"
}

model_deep() {
  # OpenClaw docs list this as the deep research option.
  setv tools.web.search.perplexity.model perplexity/sonar-reasoning-pro
  echo "Set web_search model to perplexity/sonar-reasoning-pro"
}

case "$cmd" in
  status)
    status
    ;;
  perplexity)
    use_perplexity
    ;;
  openrouter)
    use_openrouter
    ;;
  sonar)
    model_sonar
    ;;
  pro)
    model_pro
    ;;
  deep)
    model_deep
    ;;
  *)
    cat <<'EOF'
Usage:
  openclaw-websearch-switch.sh status
  openclaw-websearch-switch.sh perplexity     # Perplexity direct (pplx key + api.perplexity.ai)
  openclaw-websearch-switch.sh openrouter     # OpenRouter (sk-or key + openrouter.ai)
  openclaw-websearch-switch.sh sonar          # perplexity/sonar
  openclaw-websearch-switch.sh pro            # perplexity/sonar-pro (default)
  openclaw-websearch-switch.sh deep           # perplexity/sonar-reasoning-pro

Tip:
  If you hit rate limits/timeouts:
    ./openclaw-websearch-switch.sh openrouter
  When stable again:
    ./openclaw-websearch-switch.sh perplexity
EOF
    exit 2
    ;;
esac
