#!/bin/sh
# Approval-gate model: the human-approval gates are the spec gate (to-spec, when the spec is
# created) and the plan gate (writing-plans, when the plan is created). brainstorming holds no
# gate and mints no marker; executing-plans runs to completion after the plan gate with no
# mid-flow human checkpoints. These checks pin those specific gates and the stages that hold
# none — adding a further gate elsewhere would not invalidate them. Note code-review is NOT a
# human-approval gate: it runs per task (executing-plans' automated gate) and once on the whole
# branch at finish (finishing-a-development-branch), addressing findings in code without a fresh
# human sign-off. The right-size bypass (brainstorming's opt-in SPEC-SKIPPED.md → writing-plans)
# is likewise a routing choice, not a gate: it skips only the spec-CREATION step, never a human
# approval — the plan gate still holds on that path. Prose-anchor checks over the shipped SKILL
# bodies (the suite's convention for model-executed skills). No script enforces the gates at
# runtime by design; these assertions keep the enforcing prose from silently regressing.
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
EXEC="$PLUGIN/skills/executing-plans/SKILL.md"
FINISH="$PLUGIN/skills/finishing-a-development-branch/SKILL.md"
SPECFMT="$PLUGIN/skills/to-spec/SPEC-FORMAT.md"

# --- brainstorming: no gate, no marker -- approval lives at the spec gate ------
! grep_flat "$BRAIN" "APPROVED.md"
check $? "brainstorming no longer writes an approval marker"
! grep_flat "$BRAIN" "hard gate"
check $? "brainstorming no longer holds a hard approval gate"
grep_flat "$BRAIN" "approval happens at the spec gate"
check $? "brainstorming points design approval to the spec gate"

# --- brainstorming: right-size bypass is an explicit opt-in routing choice -----
# brainstorming MAY offer to skip spec creation and go straight to the plan, but only through an
# explicit structured choice; on that pick it mints the run-scoped SPEC-SKIPPED.md marker (a routing
# record, NOT an approval) and hands to writing-plans. The default path is unchanged, and the plan
# gate downstream still holds. The bypass must not reintroduce the approval-marker / hard-gate
# strings the two guards above forbid.
# The spec-skip is posed as an explicit structured choice; the question mechanism is left to the
# harness, so guard the tool-agnostic phrasing, not a harness-specific question tool.
grep_flat "$BRAIN" "structured choice"
check $? "brainstorming poses the spec-skip as an explicit opt-in"
! grep_flat "$BRAIN" "AskUserQuestion"
check $? "brainstorming names no harness-specific question tool"
grep_flat "$BRAIN" "SPEC-SKIPPED.md"
check $? "brainstorming mints the spec-skip marker on the opt-in pick"
grep_flat "$BRAIN" "writing-plans"
check $? "brainstorming hands straight to writing-plans when the spec is skipped"

# --- Gate 1: to-spec presents the spec, waits for approval, mints the marker ---
grep_flat "$TOSPEC" "APPROVED.md"
check $? "to-spec mints the spec-approval marker"
grep_flat "$TOSPEC" "run-context.sh to-spec"
check $? "to-spec creates its own phase dir for the spec-approval marker"
grep_flat "$TOSPEC" "wait for the human's approval"
check $? "to-spec holds the spec gate (waits for explicit approval)"
grep_flat "$TOSPEC" "only on approval"
check $? "to-spec flips the status to Approved only on approval"
# Regression guard: the old unconditional-stamp assumption must stay gone.
! grep_flat "$TOSPEC" "only ever reached through"
check $? "to-spec makes no assumption about how it was reached"

# --- SPEC-FORMAT: status is Draft at write, Approved after the gate -----------
grep_flat "$SPECFMT" "flips it to Approved"
check $? "SPEC-FORMAT documents the Draft-then-Approved flip at the spec gate"

# --- Gate 2: writing-plans requires the spec marker, then holds the plan gate --
grep_flat "$PLANS" "to-spec/APPROVED.md"
check $? "writing-plans requires the spec-approval marker (relocated from brainstorming)"
grep_flat "$PLANS" "to-spec/SPEC-SKIPPED.md"
check $? "writing-plans also accepts the spec-skip marker as its precondition (right-size bypass)"
grep_flat "$PLANS" "the marker is the trace, the status line is only the checkbox"
check $? "writing-plans refuses on spec-marker absence, not just names it"
grep_flat "$PLANS" "hand-edited status line"
check $? "writing-plans catches a hand-edited Approved status line"
grep_flat "$PLANS" "present the finished plan"
check $? "writing-plans holds the plan gate (presents the plan, waits for approval)"
grep_flat "$PLANS" "writing-plans/APPROVED.md"
check $? "writing-plans mints the plan-approval marker"
grep_flat "$PLANS" "finish strategy"
check $? "writing-plans records the finish strategy at the plan gate"
! grep_flat "$PLANS" "Review checkpoints"
check $? "writing-plans no longer emits mid-flow review checkpoints"

# --- After Gate 2: executing-plans runs with no mid-flow human checkpoints -----
grep_flat "$EXEC" "writing-plans/APPROVED.md"
check $? "executing-plans requires the plan-approval marker"
! grep_flat "$EXEC" "until the user says to continue"
check $? "executing-plans no longer stops mid-run waiting for the user"
! grep_flat "$EXEC" "stops the plan for a human look"
check $? "executing-plans has no mid-flow human checkpoint"

# --- finishing: executes the plan-authorized finish strategy, no fresh asking --
grep_flat "$FINISH" "finish strategy"
check $? "finishing executes the plan-authorized finish strategy"

# --- finishing: a final whole-branch code-review before integration ------------
# Code-review now runs per task (executing-plans' gate) AND once on the whole branch here, so a
# cross-task issue no per-task diff had the scope to catch gets one read before the branch lands.
# It stays a review, not a new approval gate (the plan gate already authorized how the branch
# finishes), so these anchors must not reintroduce a human sign-off at this seam.
grep_flat "$FINISH" "engineering:code-review"
check $? "finishing runs a final engineering:code-review pass"
grep_flat "$FINISH" "the whole branch"
check $? "finishing reviews the whole branch as a unit before integrating (not just per-task)"
grep_flat "$FINISH" "not a new approval gate"
check $? "finishing's whole-branch review stays a review, not a fresh human gate"

[ "$fail" = 0 ] && echo "APPROVAL-GATE CONTENT: ALL CHECKS PASS" || echo "APPROVAL-GATE CONTENT: FAILURES ABOVE"
exit $fail
