#!/bin/sh
set -e
ROOT=$(CDPATH= cd "$(dirname "$0")/../.." && pwd)
cd "$ROOT/engineering"
fail=0
# vernacular was a shallow wrapper over the docs phase; it gets no skill or command of its own.
# The docs phase is the `document` conductor, invoked directly and carrying the full behavior.
[ ! -e skills/vernacular ] || { echo "FAIL: skills/vernacular must not exist (shallow wrapper; invoke document directly)"; fail=1; }
[ ! -e commands/vernacular.md ] || { echo "FAIL: commands/vernacular.md must be removed"; fail=1; }
[ -f skills/document/SKILL.md ] || { echo "FAIL: skills/document/SKILL.md must exist"; fail=1; }
if grep -rn "\.vernacular" skills; then echo "FAIL: stale .vernacular path"; fail=1; fi
grep -rq "\.engineering/" skills/document/SKILL.md || { echo "FAIL: run dir not redirected"; fail=1; }
[ "$fail" = 0 ] && echo "PASS absorb-vernacular.sh" || exit 1
