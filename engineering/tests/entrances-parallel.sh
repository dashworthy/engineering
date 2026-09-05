#!/bin/sh
# The three entrances are parallel and self-contained skills sharing an establish-run -> shape-context
# -> hand-to-engineering:brainstorming skeleton. Isolation moved to build, so no entrance carries an
# Isolate beat; receiving-code-review adds one leading beat the others don't — checking out the review
# branch. None invokes another entrance — the three converge on design, never on each other.
set -e
ROOT=$(CDPATH= cd "$(dirname "$0")/../.." && pwd)
cd "$ROOT/engineering"
fail=0

ENTRANCES="signal triage receiving-code-review"

for e in $ENTRANCES; do
  CMD="skills/$e/SKILL.md"
  [ -f "$CMD" ] || { echo "FAIL: $CMD must exist"; fail=1; continue; }
  [ ! -e "commands/$e.md" ] || { echo "FAIL: commands/$e.md must be removed (entrances are skills now)"; fail=1; }

  # Shared skeleton beats (numbers vary: rcr leads with a review-branch beat). No Isolate beat.
  ! grep -q "^## 1\. Isolate" "$CMD" || { echo "FAIL: $e must not carry an Isolate beat (isolation is build's job now)"; fail=1; }
  grep -qE "^## [0-9]+\. Establish" "$CMD" || { echo "FAIL: $e missing the Establish/join a run beat"; fail=1; }
  grep -q "run-context.sh" "$CMD" || { echo "FAIL: $e must establish/join a run via run-context.sh"; fail=1; }
  grep -qE "^## [0-9]+\. Shape context" "$CMD" || { echo "FAIL: $e missing the Shape context beat"; fail=1; }
  grep -qE "^## [0-9]+\. Hand to design" "$CMD" || { echo "FAIL: $e missing the Hand to design beat"; fail=1; }
  grep -q "engineering:brainstorming" "$CMD" || { echo "FAIL: $e must hand context to design"; fail=1; }

  # Convergence, not cross-calls: no entrance invokes another entrance.
  for other in $ENTRANCES; do
    [ "$other" = "$e" ] && continue
    if grep -qE "/$other\b|engineering:$other\b" "$CMD"; then
      echo "FAIL: $e invokes another entrance ($other) — entrances converge on design, never each other"; fail=1
    fi
  done
done

# receiving-code-review adds a leading base-selection beat the others don't.
grep -q "^## 1\. Check out the review branch" "skills/receiving-code-review/SKILL.md" || { echo "FAIL: receiving-code-review must check out the review branch first (base selection)"; fail=1; }

[ "$fail" = 0 ] && echo "PASS entrances-parallel.sh" || exit 1
