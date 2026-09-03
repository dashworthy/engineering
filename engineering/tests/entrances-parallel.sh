#!/bin/sh
# The three entrances are parallel and self-contained skills: each SKILL.md carries the identical
# four-beat labeled skeleton (1. Isolate via using-git-worktrees -> 2. establish/join a run via
# run-context.sh -> 3. a divergent shape-context beat -> 4. hand to engineering:brainstorming), and
# none invokes another entrance — the three converge on brainstorming, never on each other.
set -e
ROOT=$(CDPATH= cd "$(dirname "$0")/../.." && pwd)
cd "$ROOT/engineering"
fail=0

ENTRANCES="signal triage receiving-code-review"

for e in $ENTRANCES; do
  CMD="skills/$e/SKILL.md"
  [ -f "$CMD" ] || { echo "FAIL: $CMD must exist"; fail=1; continue; }
  [ ! -e "commands/$e.md" ] || { echo "FAIL: commands/$e.md must be removed (entrances are skills now)"; fail=1; }

  # Four labeled skeleton beats, in order, identical across the three commands.
  grep -q "^## 1\. Isolate" "$CMD" || { echo "FAIL: $e missing labeled beat 1 (Isolate)"; fail=1; }
  grep -q "using-git-worktrees" "$CMD" || { echo "FAIL: $e beat 1 must name the worktree-isolation step"; fail=1; }
  grep -qE "^## 2\. Establish" "$CMD" || { echo "FAIL: $e missing labeled beat 2 (Establish/join a run)"; fail=1; }
  grep -q "run-context.sh" "$CMD" || { echo "FAIL: $e beat 2 must establish/join a run via run-context.sh"; fail=1; }
  grep -qE "^## 3\. Shape context" "$CMD" || { echo "FAIL: $e missing labeled beat 3 (Shape context)"; fail=1; }
  grep -qE "^## 4\. Hand to brainstorming" "$CMD" || { echo "FAIL: $e missing labeled beat 4 (Hand to brainstorming)"; fail=1; }
  grep -q "engineering:brainstorming" "$CMD" || { echo "FAIL: $e beat 4 must hand context to brainstorming"; fail=1; }

  # Convergence, not cross-calls: no entrance invokes another entrance.
  for other in $ENTRANCES; do
    [ "$other" = "$e" ] && continue
    if grep -qE "/$other\b|engineering:$other\b" "$CMD"; then
      echo "FAIL: $e invokes another entrance ($other) — entrances converge on brainstorming, never each other"; fail=1
    fi
  done
done

[ "$fail" = 0 ] && echo "PASS entrances-parallel.sh" || exit 1
