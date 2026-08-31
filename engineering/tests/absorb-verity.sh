#!/bin/sh
set -e
ROOT=$(CDPATH= cd "$(dirname "$0")/../.." && pwd)
cd "$ROOT/engineering"
fail=0
if grep -rn "\.verity" skills; then echo "FAIL: stale .verity path"; fail=1; fi
if grep -rn "verity:" skills; then echo "FAIL: stale verity: namespace"; fail=1; fi
# Verity's session-start reminder must NOT be ported: the only hook is the entrance bootstrap.
if grep -rq "Verity applies once implementation work is finished" hooks/ 2>/dev/null; then
  echo "FAIL: verity session-start reminder was ported"; fail=1; fi
[ -f hooks/session-start.sh ] && grep -q "/triage" hooks/session-start.sh || { echo "FAIL: entrance bootstrap missing"; fail=1; }

# --- Sever assertions: the four test-hardening skills have moved to verity ---
# engineering must no longer carry the skills, reference them (in skills OR commands), or
# read their run record.
for skill in conducting-test-hardening auditing-test-gaps verifying-test-integrity writing-tests-from-brief; do
  if [ -d "skills/$skill" ]; then
    echo "FAIL: skills/$skill still exists (moved to verity)"; fail=1; fi
  if grep -rlq "$skill" skills commands; then
    echo "FAIL: content still references $skill ($(grep -rl "$skill" skills commands | tr '\n' ' '))"; fail=1; fi
done
# The finishing-a-development-branch filesystem reader for the hardening run record is gone.
if grep -q "test-hardening/" skills/finishing-a-development-branch/SKILL.md 2>/dev/null; then
  echo "FAIL: finishing-a-development-branch still reads .engineering/<run>/test-hardening/"; fail=1; fi

[ "$fail" = 0 ] && echo "PASS absorb-verity.sh" || exit 1
