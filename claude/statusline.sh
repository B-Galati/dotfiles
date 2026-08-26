#!/bin/bash
# Claude Code status line. Reads the hook payload on stdin, prints one or two lines.
#
# This runs on every frame, so the script avoids forks: a single jq pass, helpers
# that return through globals rather than $(...), and no calls to date or git.

RST=$'\033[0m'
DIM=$'\033[2m'
GRN=$'\033[32m'
RED=$'\033[31m'

# Every field comes from the one jq pass below. Without jq there is nothing to
# report, and falling through would print plausible-looking zeroes instead.
command -v jq >/dev/null || { printf 'statusline: jq not found\n'; exit 0; }

# One jq pass, one value per line. Newline-separated (not tab-separated) because
# bash treats tabs in IFS as whitespace and would collapse consecutive empty
# fields, silently shifting every value after a missing one.
mapfile -t F < <(jq -r '
  [ .model.display_name,
    .output_style.name,
    .context_window.used_percentage,
    .context_window.context_window_size,
    .context_window.total_input_tokens,
    .context_window.current_usage.input_tokens,
    .context_window.current_usage.cache_read_input_tokens,
    .context_window.current_usage.cache_creation_input_tokens,
    .cost.total_cost_usd,
    .effort.level,
    .rate_limits.five_hour.used_percentage,
    .rate_limits.five_hour.resets_at,
    .rate_limits.seven_day.used_percentage,
    .rate_limits.seven_day.resets_at,
    .workspace.current_dir,
    .workspace.project_dir,
    .cost.total_lines_added,
    .cost.total_lines_removed
  ] | .[] | if . == null then "" else tostring end' 2>/dev/null)

# Truncate a possibly-fractional value to a non-negative integer, into NUM.
# The payload types are not guaranteed: percentages and epochs both show up as
# floats, and bash arithmetic chokes on those.
NUM=0
to_num() {
  NUM=${1%%.*}
  case $NUM in '' | *[!0-9]*) NUM=0 ;; esac
}

# Compact model label, into MODEL_SHORT: "Claude Opus 5 (1M context)" -> "O5·1M".
# Family initial + version, with the parenthesised context variant kept as a tag.
MODEL_SHORT=""
short_model() {
  local m=${1#Claude } ctx=""
  case $m in *1M* | *1m*) ctx="·1M" ;; esac
  m=${m%%(*}
  m=${m% }
  case $m in
    [A-Za-z]*" "[0-9]*) MODEL_SHORT="${m:0:1}${m#* }${ctx}" ;;
    *) MODEL_SHORT="${m}${ctx}" ;;
  esac
}

short_model "${F[0]}"; MODEL=$MODEL_SHORT
STYLE=${F[1]}
to_num "${F[2]}"; PCT=$NUM
to_num "${F[3]}"; CTX_SIZE=$NUM
to_num "${F[4]}"; USED_TOK=$NUM
to_num "${F[5]}"; LAST_INPUT=$NUM
to_num "${F[6]}"; CACHE_READ=$NUM
to_num "${F[7]}"; CACHE_CREATE=$NUM
COST=${F[8]}
EFFORT=${F[9]}
RATE_5H=${F[10]}
RATE_5H_RESET=${F[11]}
RATE_7D=${F[12]}
RATE_7D_RESET=${F[13]}
CURRENT_DIR=${F[14]}
PROJECT_DIR=${F[15]}
to_num "${F[16]}"; LINES_ADD=$NUM
to_num "${F[17]}"; LINES_DEL=$NUM

((CTX_SIZE)) || CTX_SIZE=200000
((PCT > 100)) && PCT=100

# Colour for a percentage, into CFG (bright) and CDIM (dim, for the empty track).
CFG=""
CDIM=""
pct_color() {
  if (($1 >= 80)); then
    CFG=$'\033[31m'; CDIM=$'\033[2;31m'   # red
  elif (($1 >= 50)); then
    CFG=$'\033[33m'; CDIM=$'\033[2;33m'   # yellow
  else
    CFG=$'\033[32m'; CDIM=$'\033[2;32m'   # green
  fi
}

# Gradient progress bar (█ → ▓ → ▒) over a dim ░ track, into BAR.
BAR=""
render_bar() {
  local pct=$1 width=${2:-15} filled rem empty part solid track
  filled=$((pct * width / 100))
  rem=$((pct * width % 100))

  # Only two partial glyphs: a third one would be ░, the same glyph as the empty
  # track, making a barely-filled cell indistinguishable from an empty one.
  part=""
  if ((rem >= 66)); then part="▓"
  elif ((rem >= 33)); then part="▒"
  fi

  empty=$((width - filled))
  [ -n "$part" ] && empty=$((empty - 1))
  ((empty < 0)) && empty=0

  printf -v solid '%*s' "$filled" ''; solid=${solid// /█}
  printf -v track '%*s' "$empty" ''; track=${track// /░}

  pct_color "$pct"
  BAR="${CFG}${solid}${part}${RST}${CDIM}${track}${RST}"
}

# Current branch, into BRANCH. Read straight from .git rather than shelling out
# to git, which would cost more than the rest of the script put together.
BRANCH=""
git_branch() {
  local dir=$1 gd head
  BRANCH=""
  while [ -n "$dir" ] && [ "$dir" != "/" ]; do
    [ -e "$dir/.git" ] && break
    # A relative path has no leading slash left to consume, so ${dir%/*} would
    # return it unchanged and spin here forever.
    [ "${dir%/*}" = "$dir" ] && return
    dir=${dir%/*}
  done
  [ -n "$dir" ] && [ -e "$dir/.git" ] || return
  gd=$dir/.git
  # A linked worktree has .git as a file holding "gitdir: <path>".
  [ -f "$gd" ] && { read -r _ gd <"$gd" || return; }
  [ -r "$gd/HEAD" ] || return
  read -r head <"$gd/HEAD" || return
  case $head in
    "ref: refs/heads/"*) BRANCH=${head#ref: refs/heads/} ;;
    "ref: "*) BRANCH=${head#ref: } ;;
    *) BRANCH=${head:0:7} ;;   # detached HEAD
  esac
}

# Where we are, into DIRLBL: the project's own name, plus any path below it.
DIRLBL=""
dir_label() {
  local cur=${1%/} proj=${2%/}
  [ -n "$cur" ] || cur=$proj
  DIRLBL=""
  [ -n "$cur" ] || return
  if [ -n "$proj" ] && [ "$cur" = "$proj" ]; then
    DIRLBL=${proj##*/}
  elif [ -n "$proj" ] && [ "${cur#"$proj"/}" != "$cur" ]; then
    DIRLBL="${proj##*/}/${cur#"$proj"/}"
  else
    DIRLBL=${cur/#"$HOME"/'~'}
  fi
}

# Seconds until a unix epoch as "3d4h" / "2h15m" / "45m", into CD.
CD=""
fmt_countdown() {
  local secs days hours mins
  to_num "$1"
  CD=""
  ((NUM)) || return
  secs=$((NUM - EPOCHSECONDS))
  if ((secs <= 0)); then CD="0m"; return; fi
  days=$((secs / 86400))
  hours=$((secs % 86400 / 3600))
  mins=$((secs % 3600 / 60))
  if ((days > 0)); then CD="${days}d${hours}h"
  elif ((hours > 0)); then CD="${hours}h${mins}m"
  else CD="${mins}m"
  fi
}

# Context tokens: prefer the exact count, fall back to the (already truncated)
# percentage only when the payload omits it.
CTX_K=$((CTX_SIZE / 1000))
if ((USED_TOK)); then
  USED_K=$(((USED_TOK + 500) / 1000))
else
  USED_K=$((PCT * CTX_K / 100))
fi

# Cache hit rate over the last request's total input.
LAST_TOTAL_IN=$((LAST_INPUT + CACHE_READ + CACHE_CREATE))
CACHE_PCT=0
((LAST_TOTAL_IN)) && CACHE_PCT=$((CACHE_READ * 100 / LAST_TOTAL_IN))

[[ $COST =~ ^[0-9]+(\.[0-9]+)?$ ]] || COST=0
printf -v COST_FMT '$%.2f' "$COST"

MODE=""
[ -n "$STYLE" ] && [ "$STYLE" != "default" ] && MODE=" [${STYLE}]"

# Pad the shorter of the two leading labels so both lines' first bar (and the
# " | " before it) start at the same column.
LABEL1_PLAIN="${MODEL}${MODE}"
LABEL2_PLAIN=""
LABEL2_COLORED=""
if [ -n "$EFFORT" ]; then
  LABEL2_PLAIN="effort:${EFFORT}"
  LABEL2_COLORED="${DIM}effort:${RST}${EFFORT}"
fi
PAD1=""
PAD2=""
if ((${#LABEL1_PLAIN} > ${#LABEL2_PLAIN})); then
  printf -v PAD2 '%*s' $((${#LABEL1_PLAIN} - ${#LABEL2_PLAIN})) ''
else
  printf -v PAD1 '%*s' $((${#LABEL2_PLAIN} - ${#LABEL1_PLAIN})) ''
fi

# Line 1: model | context | cache | cost | location
render_bar "$PCT"
LINE1="${LABEL1_PLAIN}${PAD1} | ${BAR} ${CFG}${PCT}%${RST} ${USED_K}k/${CTX_K}k"
LINE1+=" | ${DIM}cache:${RST}${CACHE_PCT}% | ${COST_FMT}"
((LINES_ADD || LINES_DEL)) &&
  LINE1+=" | ${GRN}+${LINES_ADD}${RST}/${RED}-${LINES_DEL}${RST}"

dir_label "$CURRENT_DIR" "$PROJECT_DIR"
if [ -n "$DIRLBL" ]; then
  LINE1+=" | ${DIRLBL}"
  git_branch "$CURRENT_DIR"
  [ -n "$BRANCH" ] && LINE1+=" ${DIM}⎇${RST} ${BRANCH}"
fi

# Line 2: effort | rate limits. Each segment reads <bar> <pct>% <label> (reset <in>)
rate_segment() { # $1 percentage, $2 epoch, $3 label
  local pct
  to_num "$1"; pct=$NUM
  ((pct > 100)) && pct=100
  render_bar "$pct"
  [ -n "$RATE_STR" ] && RATE_STR+=" | "
  RATE_STR+="${BAR} ${pct}% ${DIM}${3}${RST}"
  fmt_countdown "$2"
  [ -n "$CD" ] && RATE_STR+=" ${DIM}(reset ${RST}${CD}${DIM})${RST}"
}

RATE_STR=""
[ -n "$RATE_5H" ] && rate_segment "$RATE_5H" "$RATE_5H_RESET" "5h"
[ -n "$RATE_7D" ] && rate_segment "$RATE_7D" "$RATE_7D_RESET" "7d"

printf '%s\n' "$LINE1"
if [ -n "$RATE_STR" ]; then
  printf '%s\n' "${LABEL2_COLORED}${PAD2} | ${RATE_STR}"
elif [ -n "$LABEL2_COLORED" ]; then
  printf '%s\n' "$LABEL2_COLORED"
fi
