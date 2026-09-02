#!/bin/sh
# Verifies the build-gate: require-entrance.sh (PreToolUse) blocks the build move until the
# session engages the pipeline, and session-entrance-reset.sh re-gates a fresh session.
set -e
ROOT=$(CDPATH= cd "$(dirname "$0")/../.." && pwd)
HOOK="$ROOT/engineering/hooks/require-entrance.sh"
RESET="$ROOT/engineering/hooks/session-entrance-reset.sh"
T=$(mktemp -d 2>/dev/null || echo "${TMPDIR:-/tmp}/require-entrance-$$")
mkdir -p "$T"
export CLAUDE_PROJECT_DIR="$T"

fail=0
# emits "deny" on stdout when blocked; empty (default-allow) otherwise.
verdict() { printf '%s' "$2" | sh "$HOOK"; }
is_deny() { case "$(verdict "$1" "$2")" in *'"deny"'*) return 0;; *) return 1;; esac; }

check_deny() { if is_deny "$1" "$2"; then echo "ok   - $1"; else echo "FAIL - $1 (expected deny)"; fail=1; fi; }
check_allow() { if is_deny "$1" "$2"; then echo "FAIL - $1 (expected allow)"; fail=1; else echo "ok   - $1"; fi; }

EDIT_REAL='{"tool_name":"Edit","tool_input":{"file_path":"/repo/src/app.php","old_string":"a","new_string":"b"}}'

check_deny  "fresh session blocks a real Edit"                 "$EDIT_REAL"
check_allow "Read is never gated"                              '{"tool_name":"Read","tool_input":{"file_path":"/repo/src/app.php"}}'
check_allow ".engineering writes are exempt"                   '{"tool_name":"Write","tool_input":{"file_path":"/repo/.engineering/r/signal/brief.md","content":"x"}}'
check_allow "scratchpad writes are exempt"                     '{"tool_name":"Write","tool_input":{"file_path":"/x/scratchpad/n.md","content":"x"}}'
check_deny  "editing run-context.sh itself is still gated"     '{"tool_name":"Edit","tool_input":{"file_path":"/repo/engineering/scripts/run-context.sh","old_string":"a","new_string":"b"}}'

# Engaging the pipeline via Bash lifts the gate for the session.
check_allow "Bash run-context.sh lifts the gate"              '{"tool_name":"Bash","tool_input":{"command":"sh engineering/scripts/run-context.sh signal x"}}'
[ -f "$T/.engineering/.state/entered" ] && echo "ok   - entrance marker written" || { echo "FAIL - marker not written"; fail=1; }
check_allow "real Edit allowed after entrance"                "$EDIT_REAL"

# A fresh session (startup/clear) re-gates.
sh "$RESET"
[ -f "$T/.engineering/.state/entered" ] && { echo "FAIL - reset left marker"; fail=1; } || echo "ok   - reset cleared marker"
check_deny  "real Edit blocked again after reset"             "$EDIT_REAL"

# Explicit acknowledgement is the sanctioned bypass.
check_allow "Bash entrance-ack.sh lifts the gate"            '{"tool_name":"Bash","tool_input":{"command":"sh engineering/scripts/entrance-ack.sh reason"}}'
check_allow "real Edit allowed after ack"                     "$EDIT_REAL"

# The deny payload must be valid PreToolUse JSON.
sh "$RESET"
verdict "x" "$EDIT_REAL" | python3 -c '
import json,sys
d=json.load(sys.stdin)
o=d["hookSpecificOutput"]
assert o["hookEventName"]=="PreToolUse", d
assert o["permissionDecision"]=="deny", d
assert "/signal" in o["permissionDecisionReason"] and "/triage" in o["permissionDecisionReason"], "reason must name the entrances"
' || { echo "FAIL - deny payload not valid PreToolUse JSON"; fail=1; }
echo "ok   - deny payload is valid PreToolUse JSON naming the entrances"

rm -rf "$T"
[ "$fail" -eq 0 ] || { echo "FAIL require-entrance.sh"; exit 1; }
echo "PASS require-entrance.sh"
