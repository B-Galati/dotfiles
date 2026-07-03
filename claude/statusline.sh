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

RST="\033[0m"
DIM="\033[2m"

# Build a gradient progress bar (█ → ▓ → ▒ → ░) for a given percentage,
# colored green/yellow/red by the same thresholds used across all bars.
render_bar() {
  local pct="$1" width="${2:-15}"
  local filled remainder empty bar bar_empty fg empty_fg i
  filled=$((pct * width / 100))
  remainder=$((pct * width % 100))
  empty=$((width - filled - (remainder > 0 ? 1 : 0)))

  bar=""
  for ((i = 0; i < filled; i++)); do bar+="█"; done
  if [ "$remainder" -gt 0 ]; then
    if [ "$remainder" -ge 66 ]; then bar+="▓"
    elif [ "$remainder" -ge 33 ]; then bar+="▒"
    else bar+="░"
    fi
  fi

  if [ "$pct" -ge 80 ]; then
    fg="\033[31m"       # red
    empty_fg="\033[2;31m"  # dim red
  elif [ "$pct" -ge 50 ]; then
    fg="\033[33m"       # yellow
    empty_fg="\033[2;33m"  # dim yellow
  else
    fg="\033[32m"       # green
    empty_fg="\033[2;32m"  # dim green
  fi

  bar_empty=""
  for ((i = 0; i < empty; i++)); do bar_empty+="░"; done

  echo "${fg}${bar}${RST}${empty_fg}${bar_empty}${RST}"
}

# Context bar
CTX_BAR=$(render_bar "$PCT")

# Context color (used for the %  next to the bar)
if [ "$PCT" -ge 80 ]; then
  FG="\033[31m"
elif [ "$PCT" -ge 50 ]; then
  FG="\033[33m"
else
  FG="\033[32m"
fi

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

# Reasoning effort level (only present when the current model supports it)
EFFORT=$(echo "$input" | jq -r '.effort.level // empty')

# Rate limits (Claude.ai subscription)
RATE_5H=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
RATE_5H_RESET=$(echo "$input" | jq -r '.rate_limits.five_hour.resets_at // empty')
RATE_7D=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')
RATE_7D_RESET=$(echo "$input" | jq -r '.rate_limits.seven_day.resets_at // empty')

# Format seconds until a unix epoch as e.g. "2h15m" / "45m" / "3d4h"
fmt_countdown() {
  local target="$1" now secs
  now=$(date +%s)
  secs=$((target - now))
  if [ "$secs" -le 0 ]; then echo "0m"; return; fi
  local days=$((secs / 86400))
  local hours=$(((secs % 86400) / 3600))
  local mins=$(((secs % 3600) / 60))
  if [ "$days" -gt 0 ]; then
    echo "${days}d${hours}h"
  elif [ "$hours" -gt 0 ]; then
    echo "${hours}h${mins}m"
  else
    echo "${mins}m"
  fi
}

# Build the leading (pre-first-bar) label for line 2: just "effort:<level>"
# when present, otherwise empty (the first bar then starts right after the
# aligned " | ").
LABEL2_PLAIN=""
if [ -n "$EFFORT" ]; then
  LABEL2_PLAIN="effort:${EFFORT}"
fi

LABEL2_COLORED=""
if [ -n "$EFFORT" ]; then
  LABEL2_COLORED="${DIM}effort:${RST}${EFFORT}"
fi

# Line 1's label (plain, for width measurement only — no ANSI codes).
LABEL1_PLAIN="${MODEL}${MODE}"

# Pad the shorter label with trailing spaces so both lines' first bar
# (and the " | " before it) start at the same column.
LEN1=${#LABEL1_PLAIN}
LEN2=${#LABEL2_PLAIN}
if [ "$LEN1" -gt "$LEN2" ]; then
  PAD2=$(printf '%*s' "$((LEN1 - LEN2))" "")
  PAD1=""
else
  PAD1=$(printf '%*s' "$((LEN2 - LEN1))" "")
  PAD2=""
fi

# Build the remainder of line 2 (first bar segment, then optional 7d segment).
# Each segment reads: <bar> <pct>% <label> (reset <countdown>)
RATE_STR=""
if [ -n "$RATE_5H" ]; then
  RATE_5H_INT=$(printf '%.0f' "$RATE_5H")
  RATE_5H_BAR=$(render_bar "$RATE_5H_INT")
  RATE_STR+="${RATE_5H_BAR} ${RATE_5H_INT}% ${DIM}5h${RST}"
  if [ -n "$RATE_5H_RESET" ]; then
    RATE_STR+=" ${DIM}(reset ${RST}$(fmt_countdown "$RATE_5H_RESET")${DIM})${RST}"
  fi
  if [ -n "$RATE_7D" ]; then
    RATE_7D_INT=$(printf '%.0f' "$RATE_7D")
    RATE_7D_BAR=$(render_bar "$RATE_7D_INT")
    RATE_STR+=" | ${RATE_7D_BAR} ${RATE_7D_INT}% ${DIM}7d${RST}"
    if [ -n "$RATE_7D_RESET" ]; then
      RATE_STR+=" ${DIM}(reset ${RST}$(fmt_countdown "$RATE_7D_RESET")${DIM})${RST}"
    fi
  fi
elif [ -n "$RATE_7D" ]; then
  RATE_7D_INT=$(printf '%.0f' "$RATE_7D")
  RATE_7D_BAR=$(render_bar "$RATE_7D_INT")
  RATE_STR+="${RATE_7D_BAR} ${RATE_7D_INT}% ${DIM}7d${RST}"
  if [ -n "$RATE_7D_RESET" ]; then
    RATE_STR+=" ${DIM}(reset ${RST}$(fmt_countdown "$RATE_7D_RESET")${DIM})${RST}"
  fi
fi

printf "%s%s%s | ${CTX_BAR} ${FG}%s%%${RST} %sk/%sk | ${DIM}in:${RST}%s ${DIM}out:${RST}%s | ${DIM}cache:${RST}%s%% | %s\n" \
  "$MODEL" "$MODE" "$PAD1" "$PCT" "$USED_K" "$CTX_K" \
  "$LAST_IN_FMT" "$LAST_OUT_FMT" "$CACHE_PCT" "$COST_FMT"

if [ -n "$RATE_STR" ]; then
  printf "%b\n" "${LABEL2_COLORED}${PAD2} | ${RATE_STR}"
fi
