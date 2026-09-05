#!/bin/sh
# Approval-gate model: the human-approval gates are the spec gate (to-spec, when the spec is
# created) and the plan gate (plan, when the plan is created). design holds no
# gate and mints no marker; build runs to completion after the plan gate with no
# mid-flow human checkpoints. These checks pin those specific gates and the stages that hold
# none — adding a further gate elsewhere would not invalidate them. Note code-review is NOT a
# human-approval gate: it runs per task (build' automated gate) and once on the whole
# branch at finish (finish), addressing findings in code without a fresh
# human sign-off. The right-size bypass (design's opt-in SPEC-SKIPPED.md → plan)
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
TOSPEC="$PLUGIN/skills/spec/SKILL.md"
PLANS="$PLUGIN/skills/plan/SKILL.md"
EXEC="$PLUGIN/skills/build/SKILL.md"
FINISH="$PLUGIN/skills/finish/SKILL.md"
SPECFMT="$PLUGIN/skills/spec/references/SPEC-FORMAT.md"

# --- design: no gate, no marker -- approval lives at the spec gate ------
! grep_flat "$BRAIN" "APPROVED.md"
check $? "design no longer writes an approval marker"
! grep_flat "$BRAIN" "hard gate"
check $? "design no longer holds a hard approval gate"
grep_flat "$BRAIN" "approval happens at the spec gate"
check $? "design points design approval to the spec gate"

# --- design: right-size bypass is an explicit opt-in routing choice -----
# design MAY offer to skip spec creation and go straight to the plan, but only through an
# explicit structured choice; on that pick it mints the run-scoped SPEC-SKIPPED.md marker (a routing
# record, NOT an approval) and hands to plan. The default path is unchanged, and the plan
# gate downstream still holds. The bypass must not reintroduce the approval-marker / hard-gate
# strings the two guards above forbid.
# The spec-skip is posed as an explicit structured choice; the question mechanism is left to the
# harness, so guard the tool-agnostic phrasing, not a harness-specific question tool.
grep_flat "$BRAIN" "structured choice"
check $? "design poses the spec-skip as an explicit opt-in"
! grep_flat "$BRAIN" "AskUserQuestion"
check $? "design names no harness-specific question tool"
grep_flat "$BRAIN" "SPEC-SKIPPED.md"
check $? "design mints the spec-skip marker on the opt-in pick"
grep_flat "$BRAIN" "plan"
check $? "design hands straight to plan when the spec is skipped"

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

# --- Gate 2: plan requires the spec marker, then holds the plan gate --
grep_flat "$PLANS" "to-spec/APPROVED.md"
check $? "plan requires the spec-approval marker (relocated from design)"
grep_flat "$PLANS" "to-spec/SPEC-SKIPPED.md"
check $? "plan also accepts the spec-skip marker as its precondition (right-size bypass)"
grep_flat "$PLANS" "the marker is the trace, the status line is only the checkbox"
check $? "plan refuses on spec-marker absence, not just names it"
grep_flat "$PLANS" "hand-edited status line"
check $? "plan catches a hand-edited Approved status line"
grep_flat "$PLANS" "present the finished plan"
check $? "plan holds the plan gate (presents the plan, waits for approval)"
grep_flat "$PLANS" "plan/APPROVED.md"
check $? "plan mints the plan-approval marker"
grep_flat "$PLANS" "finish strategy"
check $? "plan records the finish strategy at the plan gate"
grep_flat "$PLANS" "Isolation:"
check $? "plan records the isolation strategy at the plan gate (worktree/feature-branch)"
! grep_flat "$PLANS" "Review checkpoints"
check $? "plan no longer emits mid-flow review checkpoints"

# --- After Gate 2: build establishes the workspace, then runs with no mid-flow checkpoints -----
grep_flat "$EXEC" "plan/APPROVED.md"
check $? "build requires the plan-approval marker"
grep_flat "$EXEC" "Establish the workspace"
check $? "build establishes the workspace (isolation moved here from the entrances)"
grep_flat "$EXEC" "establishing-workspace.md"
check $? "build loads the establishing-workspace reference for the isolation mechanics"
! grep_flat "$EXEC" "until the user says to continue"
check $? "build no longer stops mid-run waiting for the user"
! grep_flat "$EXEC" "stops the plan for a human look"
check $? "build has no mid-flow human checkpoint"

# --- finishing: executes the plan-authorized finish strategy, no fresh asking --
grep_flat "$FINISH" "finish strategy"
check $? "finishing executes the plan-authorized finish strategy"

# --- finishing: a final whole-branch code-review before integration ------------
# Code-review now runs per task (build' gate) AND once on the whole branch here, so a
# cross-task issue no per-task diff had the scope to catch gets one read before the branch lands.
# It stays a review, not a new approval gate (the plan gate already authorized how the branch
# finishes), so these anchors must not reintroduce a human sign-off at this seam.
grep_flat "$FINISH" "review-protocol.md"
check $? "finishing runs a final whole-branch review via the build review-protocol reference"
grep_flat "$FINISH" "the whole branch"
check $? "finishing reviews the whole branch as a unit before integrating (not just per-task)"
grep_flat "$FINISH" "not a new approval gate"
check $? "finishing's whole-branch review stays a review, not a fresh human gate"

[ "$fail" = 0 ] && echo "APPROVAL-GATE CONTENT: ALL CHECKS PASS" || echo "APPROVAL-GATE CONTENT: FAILURES ABOVE"
exit $fail
