#!/bin/sh
set -e
ROOT=$(CDPATH= cd "$(dirname "$0")/../.." && pwd)
cd "$ROOT/engineering"
fail=0
# vernacular was a shallow wrapper over clarifying-docblocks; it gets no skill or command of its
# own. clarifying-docblocks is invoked directly and carries the full behavior itself.
[ ! -e skills/vernacular ] || { echo "FAIL: skills/vernacular must not exist (shallow wrapper; invoke clarifying-docblocks directly)"; fail=1; }
[ ! -e commands/vernacular.md ] || { echo "FAIL: commands/vernacular.md must be removed"; fail=1; }
[ -f skills/clarifying-docblocks/SKILL.md ] || { echo "FAIL: skills/clarifying-docblocks/SKILL.md must exist"; fail=1; }
if grep -rn "\.vernacular" skills; then echo "FAIL: stale .vernacular path"; fail=1; fi
grep -rq "\.engineering/" skills/clarifying-docblocks/SKILL.md || { echo "FAIL: run dir not redirected"; fail=1; }
[ "$fail" = 0 ] && echo "PASS absorb-vernacular.sh" || exit 1
