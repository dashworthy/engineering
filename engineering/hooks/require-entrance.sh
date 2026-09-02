#!/bin/sh
# PreToolUse guard: no building without an entrance.
#
# The pipeline's entrances (/signal, /triage, /receiving-code-review) exist so a request
# is shaped before code is touched. That instruction was advisory — a SessionStart reminder
# and the `using-skills` skill — and advisory guidance is bypassable: "this is too small",
# "let me explore first", "just one question". This hook makes it structural. It blocks the
# build move (Edit/Write/MultiEdit/NotebookEdit on a real file) until this session has engaged
# the pipeline, so the silent self-justified skip is no longer possible: the edit tool is
# denied, not merely discouraged.
#
# The gate lifts for the session the moment the model runs `run-context.sh` (which every
# entrance and every downstream phase calls to establish/join its run) or `entrance-ack.sh`
# (an explicit, reason-logged acknowledgement — the only sanctioned bypass, for continuing
# already-approved work or recording a human's authorization; never for self-certifying a skip).
# A companion SessionStart hook clears the marker at each startup, so a fresh session — even in
# a worktree whose run was already entered — starts gated and must engage the pipeline itself.
#
# Reads the PreToolUse event JSON on stdin; emits a PreToolUse permission decision on stdout.
# Never touches git. Parses with grep/sed only (no jq, no python dependency). Fails open on any
# parse error rather than bricking the edit tool — the guard is a floor, not a tripwire.

set -e

root="${CLAUDE_PROJECT_DIR:-.}"
state_dir="$root/.engineering/.state"
marker="$state_dir/entered"

input=$(cat)

# tool_name is a top-level string field; take the first match on its own line.
tool=$(printf '%s\n' "$input" \
  | grep -o '"tool_name"[[:space:]]*:[[:space:]]*"[^"]*"' \
  | head -1 | sed 's/.*"\([^"]*\)"$/\1/')

allow() { exit 0; }   # no stdout => default allow

deny() {
  # $1 is a single-line, JSON-safe reason.
  printf '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"%s"}}\n' "$1"
  exit 0
}

# --- Pipeline engagement lifts the gate for the rest of the session ---------------------
# Only a Bash invocation counts, so that editing run-context.sh itself (its path would appear
# in an Edit's file_path) is not mistaken for engaging it.
if [ "$tool" = "Bash" ]; then
  case "$input" in
    *run-context.sh*|*entrance-ack.sh*)
      mkdir -p "$state_dir" 2>/dev/null || true
      : > "$marker" 2>/dev/null || true
      ;;
  esac
  allow
fi

# --- Only the build move is gated -------------------------------------------------------
case "$tool" in
  Edit|Write|MultiEdit|NotebookEdit) : ;;
  *) allow ;;
esac

# Already engaged this session? Nothing to enforce.
[ -f "$marker" ] && allow

# Extract the target path (first "file_path" wins; edit tools put it before old/new_string).
fp=$(printf '%s\n' "$input" \
  | grep -o '"file_path"[[:space:]]*:[[:space:]]*"[^"]*"' \
  | head -1 | sed 's/.*:[[:space:]]*"\(.*\)"$/\1/')

# Pipeline bookkeeping and scratch space are never "building" — exempt them so an entrance can
# write its own run artifacts, and so throwaway scratch work is never walled off.
case "$fp" in
  */.engineering/*|.engineering/*|/tmp/*|/private/tmp/*|/var/folders/*|*/scratchpad/*) allow ;;
esac

# No path parsed at all: fail open rather than block on a shape we did not understand.
[ -n "$fp" ] || allow

deny "No entrance ran this session, so building is blocked. Do not self-certify this as trivial or explore your way past it. Shape the request first: run /signal (a feature or vague ask) or /triage (a reported defect) — each engages the pipeline and lifts this gate. To continue already-approved work, or on the user's explicit authorization to bypass, run engineering/scripts/entrance-ack.sh with a reason first. The block is on Edit/Write of real files; reading, searching, and .engineering/ or scratch writes are free."
