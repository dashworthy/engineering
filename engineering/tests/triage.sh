#!/bin/sh
set -e
ROOT=$(CDPATH= cd "$(dirname "$0")/../.." && pwd)
cd "$ROOT/engineering"
fail=0
grep -q "run-context.sh\" triage" skills/triage/SKILL.md || { echo "FAIL: triage must establish/join a run"; fail=1; }
grep -q "\.engineering/" skills/triage/SKILL.md || { echo "FAIL: triage must log to .engineering/<run>/triage"; fail=1; }
for t in diagnosing-bugs signal brainstorming to-spec; do
  grep -rq "$t" skills/triage/SKILL.md skills/triage/references || { echo "FAIL: triage missing route to $t"; fail=1; }
done
# The under-specified / feature-in-disguise route (spec-decision row 3) routes to signal ONLY — signal now
# owns the brainstorming→to-spec gate tail internally. The presence loop above can't catch a revert that
# re-adds that tail to the row, because brainstorming/to-spec still appear legitimately in row 4; guard the
# row line itself with a negative grep.
if grep -E 'feature request in disguise' skills/triage/references/spec-decision.md | grep -qE 'brainstorming|to-spec'; then echo "FAIL: under-specified route must not re-carry the brainstorming/to-spec gate tail (signal owns it)"; fail=1; fi
if grep -rqi "issue tracker\|label\|PR state" skills/triage; then echo "FAIL: triage carries tracker coupling"; fail=1; fi
grep -q "triage" commands/triage.md || { echo "FAIL: /triage wrapper missing"; fail=1; }
[ "$fail" = 0 ] && echo "PASS triage.sh" || exit 1
