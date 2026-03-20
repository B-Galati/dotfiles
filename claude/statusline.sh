#!/bin/bash
input=$(cat)

MODEL=$(echo "$input" | jq -r '.model.display_name')
PCT=$(echo "$input" | jq -r '.context_window.used_percentage // 0' | cut -d. -f1)
CTX_SIZE=$(echo "$input" | jq -r '.context_window.context_window_size // 200000')
STYLE=$(echo "$input" | jq -r '.output_style.name // empty')
LAST_INPUT=$(echo "$input" | jq -r '.context_window.current_usage.input_tokens // 0')
LAST_OUTPUT=$(echo "$input" | jq -r '.context_window.current_usage.output_tokens // 0')
CACHE_READ=$(echo "$input" | jq -r '.context_window.current_usage.cache_read_input_tokens // 0')
CACHE_CREATE=$(echo "$input" | jq -r '.context_window.current_usage.cache_creation_input_tokens // 0')

# Defensive defaults
PCT=${PCT:-0}
CTX_SIZE=${CTX_SIZE:-200000}
LAST_INPUT=${LAST_INPUT:-0}
LAST_OUTPUT=${LAST_OUTPUT:-0}
CACHE_READ=${CACHE_READ:-0}
CACHE_CREATE=${CACHE_CREATE:-0}

# Context bar with gradient shading (█ → ▓ → ▒ → ░)
WIDTH=15
FILLED=$((PCT * WIDTH / 100))
REMAINDER=$((PCT * WIDTH % 100))
EMPTY=$((WIDTH - FILLED - (REMAINDER > 0 ? 1 : 0)))
BAR=""
for ((i = 0; i < FILLED; i++)); do BAR+="█"; done
if [ "$REMAINDER" -gt 0 ]; then
  if [ "$REMAINDER" -ge 66 ]; then BAR+="▓"
  elif [ "$REMAINDER" -ge 33 ]; then BAR+="▒"
  else BAR+="░"
  fi
fi
RST="\033[0m"
DIM="\033[2m"

# Context color: bright for filled, dim for empty
if [ "$PCT" -ge 80 ]; then
  FG="\033[31m"       # red
  EMPTY_FG="\033[2;31m"  # dim red
elif [ "$PCT" -ge 50 ]; then
  FG="\033[33m"       # yellow
  EMPTY_FG="\033[2;33m"  # dim yellow
else
  FG="\033[32m"       # green
  EMPTY_FG="\033[2;32m"  # dim green
fi

BAR_FILLED="${FG}${BAR}${RST}"
BAR_EMPTY=""
for ((i = 0; i < EMPTY; i++)); do BAR_EMPTY+="░"; done
CTX_BAR="${BAR_FILLED}${EMPTY_FG}${BAR_EMPTY}${RST}"

# Cost
COST=$(echo "$input" | jq -r '.cost.total_cost_usd // 0')
COST_FMT=$(printf '$%.2f' "$COST")

# Token usage (in k) — derive from used_percentage to stay consistent with the bar
CTX_K=$((CTX_SIZE / 1000))
USED_K=$((PCT * CTX_K / 100))

# Format token count: raw if <1000, otherwise Nk
fmt_tokens() {
  if [ "$1" -lt 1000 ]; then echo "$1"
  else echo "$(($1 / 1000))k"
  fi
}
LAST_IN_FMT=$(fmt_tokens "$LAST_INPUT")
LAST_OUT_FMT=$(fmt_tokens "$LAST_OUTPUT")

# Cache hit percentage (cache_read / total input of last request)
LAST_TOTAL_IN=$((LAST_INPUT + CACHE_READ + CACHE_CREATE))
if [ "$LAST_TOTAL_IN" -gt 0 ]; then
  CACHE_PCT=$((CACHE_READ * 100 / LAST_TOTAL_IN))
else
  CACHE_PCT=0
fi

# Mode indicator
MODE=""
if [ -n "$STYLE" ] && [ "$STYLE" != "default" ]; then
  MODE=" [${STYLE}]"
fi

# Rate limits (Claude.ai subscription)
RATE_5H=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
RATE_7D=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')
RATE_STR=""
if [ -n "$RATE_5H" ]; then
  RATE_STR+=" | ${DIM}5h:${RST}$(printf '%.0f' "$RATE_5H")%"
fi
if [ -n "$RATE_7D" ]; then
  RATE_STR+=" ${DIM}7d:${RST}$(printf '%.0f' "$RATE_7D")%"
fi

printf "%s%s | ${CTX_BAR} ${FG}%s%%${RST} %sk/%sk | ${DIM}in:${RST}%s ${DIM}out:${RST}%s | ${DIM}cache:${RST}%s%% | %s%b\n" \
  "$MODEL" "$MODE" "$PCT" "$USED_K" "$CTX_K" \
  "$LAST_IN_FMT" "$LAST_OUT_FMT" "$CACHE_PCT" "$COST_FMT" "$RATE_STR"
