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
SPECFMT="$PLUGIN/skills/to-spec/SPEC-FORMAT.md"

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

# --- hardening: guard the enforcement endpoints, not just the marker names ----
# These back the name-mention checks above with the behavior each name is supposed to
# carry, so a revert that keeps the word but guts the rule is still caught.

# writing-plans must actually REFUSE on marker absence (the bypass + hand-run backstop),
# not merely mention the marker.
grep_flat "$PLANS" "the marker is the trace, the status line is only the checkbox"
check $? "writing-plans refuses on marker absence (trace over the checkbox), not just names it"

# writing-plans catches a status line hand-edited to Approved after the mint (hand-run row).
grep_flat "$PLANS" "hand-edited status line"
check $? "writing-plans catches a hand-edited Approved status line"

# brainstorming writes the marker ONLY at gate-pass, never before — the property that
# stops an early or fabricated marker standing in for real approval.
grep_flat "$BRAIN" "Write it only at gate-pass, after full approval"
check $? "brainstorming writes the marker only at gate-pass, never before"

# to-spec transcribes §6 FROM the marker (closes to-spec confabulating its own approach).
grep_flat "$TOSPEC" "transcribe §6 from the marker"
check $? "to-spec transcribes the spec's approach section from the marker"

# to-spec keeps the affirmative marker-decides rule. The negative guard above watches one
# exact phrasing; this asserts the correct rule is present, so a reverter who reuses the
# file's live "only reachable through" idiom cannot escape by rewording.
grep_flat "$TOSPEC" "assumption that this skill is only reachable through"
check $? "to-spec keeps the explicit no-assumption rule (marker presence, not reachability)"

# SPEC-FORMAT.md's status note must agree with the skill: marker-conditional, not always Approved.
grep_flat "$SPECFMT" "marker-conditional"
check $? "SPEC-FORMAT.md documents the status line as marker-conditional"

[ "$fail" = 0 ] && echo "APPROVAL-GATE CONTENT: ALL CHECKS PASS" || echo "APPROVAL-GATE CONTENT: FAILURES ABOVE"
exit $fail
