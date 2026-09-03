#!/bin/sh
set -e
ROOT=$(CDPATH= cd "$(dirname "$0")/../.." && pwd)
cd "$ROOT/engineering"
fail=0
[ -f skills/vernacular/SKILL.md ] || { echo "FAIL: skills/vernacular/SKILL.md must exist (vernacular is a skill now)"; fail=1; }
[ ! -e commands/vernacular.md ] || { echo "FAIL: commands/vernacular.md must be removed (vernacular is a skill now)"; fail=1; }
if grep -rn "\.vernacular" skills; then echo "FAIL: stale .vernacular path"; fail=1; fi
grep -rq "\.engineering/" skills/clarifying-docblocks/SKILL.md || { echo "FAIL: run dir not redirected"; fail=1; }
[ "$fail" = 0 ] && echo "PASS absorb-vernacular.sh" || exit 1
