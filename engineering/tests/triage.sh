#!/bin/sh
set -e
ROOT=$(CDPATH= cd "$(dirname "$0")/../.." && pwd)
cd "$ROOT/engineering"
fail=0
grep -q "run-context.sh\" triage" skills/triage/SKILL.md || { echo "FAIL: triage must establish/join a run"; fail=1; }
grep -q "\.engineering/" skills/triage/SKILL.md || { echo "FAIL: triage must log to .engineering/<run>/triage"; fail=1; }
# Triage isolates in a worktree first, then routes to these skills. signal is NOT among the
# required routes: the two are distinct entrances and never hand off to each other.
for t in using-git-worktrees diagnosing-bugs interrogating-requirements brainstorming to-spec; do
  grep -rq "$t" skills/triage/SKILL.md skills/triage/references || { echo "FAIL: triage missing route to $t"; fail=1; }
done
# The under-specified / feature-in-disguise route is triage's OWN discovery leg —
# interrogating-requirements then brainstorming — never a hand-off to signal, and it does not
# re-carry the to-spec/writing-plans gate tail (that is row 4, downstream of brainstorming).
row=$(grep -E 'feature request in disguise' skills/triage/references/spec-decision.md)
echo "$row" | grep -q 'interrogating-requirements' || { echo "FAIL: under-specified route must drive interrogating-requirements"; fail=1; }
if echo "$row" | grep -q 'signal'; then echo "FAIL: under-specified route row must not name signal (no hand-off between entrances)"; fail=1; fi
if echo "$row" | grep -qE 'to-spec|writing-plans'; then echo "FAIL: under-specified route must not re-carry the to-spec/writing-plans gate tail (row 4 owns it)"; fail=1; fi
# The decoupling is stated explicitly, so a revert that re-introduces a triage->signal hand-off trips here.
grep -q "never invoke each other" skills/triage/references/spec-decision.md || grep -qE "does not .*hand off to|never invoke" skills/triage/SKILL.md || { echo "FAIL: triage must state it never hands off to signal"; fail=1; }
if grep -rqi "issue tracker\|label\|PR state" skills/triage; then echo "FAIL: triage carries tracker coupling"; fail=1; fi
grep -q "triage" commands/triage.md || { echo "FAIL: /triage wrapper missing"; fail=1; }
[ "$fail" = 0 ] && echo "PASS triage.sh" || exit 1
