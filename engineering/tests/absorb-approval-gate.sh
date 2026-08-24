#!/bin/sh
# Approval-gate enforcement: the brainstorming approval gate must be mechanically
# enforced, not honor-system. Prose-anchor checks over the shipped SKILL bodies (the
# suite's convention for model-executed skills). No script enforces the gate at runtime
# by design; these assertions are what keep the enforcing prose from silently regressing.
# POSIX sh. Run from anywhere: sh engineering/tests/absorb-approval-gate.sh

ROOT=$(cd "$(dirname "$0")/../.." && pwd)
PLUGIN="$ROOT/engineering"
fail=0

ok()   { printf 'ok   - %s\n' "$1"; }
bad()  { printf 'FAIL - %s\n' "$1"; fail=1; }
check(){ if [ "$1" -eq 0 ]; then ok "$2"; else bad "$2"; fi }

# Match a prose anchor regardless of how the source is line-wrapped (see validate.sh).
grep_flat() {  # grep_flat <file> <literal phrase>
  tr '\n' ' ' < "$1" | tr -s ' ' | grep -qF -- "$2"
}

BRAIN="$PLUGIN/skills/brainstorming/SKILL.md"
TOSPEC="$PLUGIN/skills/to-spec/SKILL.md"
PLANS="$PLUGIN/skills/writing-plans/SKILL.md"

# --- brainstorming writes the marker at gate-pass ----------------------------
grep_flat "$BRAIN" "APPROVED.md"; check $? "brainstorming names the APPROVED.md marker"
grep_flat "$BRAIN" "gate-pass";   check $? "brainstorming writes the marker at gate-pass"

# --- to-spec stamps conditional on the marker --------------------------------
grep_flat "$TOSPEC" "APPROVED.md";        check $? "to-spec reads the APPROVED.md marker"
grep_flat "$TOSPEC" "no approval marker"; check $? "to-spec stamps Draft when no approval marker resolves"

# Regression guard: the unconditional-stamp assumption must be gone. Its return is the bug.
! grep_flat "$TOSPEC" "only ever reached through"
check $? "to-spec no longer assumes it is only ever reached through brainstorming"

# --- writing-plans requires the marker, not just the status line -------------
grep_flat "$PLANS" "APPROVED.md"; check $? "writing-plans requires the APPROVED.md marker"

[ "$fail" = 0 ] && echo "APPROVAL-GATE CONTENT: ALL CHECKS PASS" || echo "APPROVAL-GATE CONTENT: FAILURES ABOVE"
exit $fail
