#!/bin/sh
# Triage is a self-contained SKILL entrance — no backing command. It carries the shared four-beat
# skeleton (Isolate -> establish run -> shape context by verify/reproduce/isolate -> hand to
# design), folds in the isolation mechanics the old references/ carried, and drives the
# shared interrogating-requirements primitive only when expected behavior must be synthesized.
# Everything converges on design: no routing table, no quick-fix row. triage and signal stay
# decoupled — triage never hands off to signal (the entrances converge on design, never on
# each other).
set -e
ROOT=$(CDPATH= cd "$(dirname "$0")/../.." && pwd)
cd "$ROOT/engineering"
fail=0

SKILL=skills/triage/SKILL.md

# The entrance is a skill now; the old /triage command is gone.
[ -f "$SKILL" ] || { echo "FAIL: skills/triage/SKILL.md must exist (triage is now a skill entrance)"; fail=1; }
[ ! -e commands/triage.md ] || { echo "FAIL: commands/triage.md must be removed (triage is now a skill entrance)"; fail=1; }

# Four-beat entrance skeleton, self-contained in the skill.
grep -q "using-git-worktrees" "$SKILL" || { echo "FAIL: triage must carry the Isolate beat (using-git-worktrees)"; fail=1; }
grep -qE 'run-context\.sh" triage|run-context\.sh triage' "$SKILL" || { echo "FAIL: triage must establish/join a run via run-context.sh triage"; fail=1; }
grep -q "\.engineering/" "$SKILL" || { echo "FAIL: triage must log to .engineering/<run>/triage"; fail=1; }
grep -q "engineering:design" "$SKILL" || { echo "FAIL: triage must hand context to design"; fail=1; }

# Shape-context beat: the reproduce/isolate mechanics folded in from the retired checklist.
for anchor in "reproduce" "Confirmed" "Not reproducible" "Under-specified" "domain concept"; do
  grep -qi "$anchor" "$SKILL" || { echo "FAIL: triage skill missing folded-in isolation mechanic: $anchor"; fail=1; }
done

# Interrogation leg (synthesize expected behavior) drives the shared primitive, not a triage-local copy.
grep -q "interrogating-requirements" "$SKILL" || { echo "FAIL: triage must drive interrogating-requirements when expected behavior must be synthesized"; fail=1; }

# Entrance-decoupling: triage never routes to signal.
grep -qiE "never .*hand|does not .*hand off to .*signal|never invoke" "$SKILL" || { echo "FAIL: triage must state it never hands off to signal"; fail=1; }
if grep -qE "engineering:signal|/signal" "$SKILL"; then echo "FAIL: triage skill must not route to signal (entrances never invoke each other)"; fail=1; fi

# The routing table and quick-fix row are gone; everything converges on design.
[ ! -e skills/triage/references/spec-decision.md ] || { echo "FAIL: spec-decision.md routing table must be removed"; fail=1; }
if grep -qi "spec-decision" "$SKILL"; then echo "FAIL: triage must not reference the removed routing table"; fail=1; fi
if grep -qi "quick fix" "$SKILL"; then echo "FAIL: triage quick-fix routing row must be gone"; fail=1; fi

# No tracker coupling.
if grep -qiE "issue tracker|PR state" "$SKILL"; then echo "FAIL: triage carries tracker coupling"; fail=1; fi

[ "$fail" = 0 ] && echo "PASS triage.sh" || exit 1
