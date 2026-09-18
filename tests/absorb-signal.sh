#!/bin/sh
# Signal is the discovery SKILL entrance, driving the shared interrogating-requirements primitive:
# no conductor skill, no expansion beat, no sequencing stage. No stale signal: namespaces or .signal/
# paths; the skill runs on the current branch, redirects artifacts to .engineering/, writes brief.md §1–§6,
# and hands the brief to engineering:brainstorming (the design dialogue), with the spec phase downstream.
set -e
ROOT=$(CDPATH= cd "$(dirname "$0")/.." && pwd)
cd "$ROOT"
fail=0
SKILL=skills/signal/SKILL.md
INTERROGATE=skills/interrogating-requirements/SKILL.md
[ -f "$SKILL" ] || { echo "FAIL: skills/signal/SKILL.md must exist (signal is now a skill entrance)"; fail=1; }
[ ! -e commands/signal.md ] || { echo "FAIL: commands/signal.md must be removed (signal is now a skill entrance)"; fail=1; }
[ -f "$INTERROGATE" ] || { echo "FAIL: skills/interrogating-requirements/SKILL.md must exist (shared interrogation skill)"; fail=1; }
if grep -rn "signal:" "$INTERROGATE" "$SKILL"; then
  echo "FAIL: stale 'signal:' namespace refs"; fail=1; fi
if grep -rn "\.signal/" skills; then
  echo "FAIL: stale '.signal/' paths"; fail=1; fi
# The three absorbed skills must be gone; signal now drives the shared primitive.
for gone in conducting-discovery expanding-scope sequencing-requirements; do
  [ -e "skills/$gone" ] && { echo "FAIL: skills/$gone should have been removed"; fail=1; }
done
grep -q "engineering:interrogating-requirements" "$SKILL" || { echo "FAIL: signal skill must invoke the shared engineering:interrogating-requirements skill"; fail=1; }
if grep -q "engineering:conducting-discovery" "$SKILL"; then echo "FAIL: signal must not name the removed conductor"; fail=1; fi
# The .engineering/ run-dir convention now lives in the shared establishing-run reference, which
# run-context.sh returns paths under; signal points to it rather than restating the path inline.
grep -q "references/establishing-run.md" "$SKILL" || { echo "FAIL: signal must load the shared establishing-run reference"; fail=1; }
grep -q "\.engineering/" references/establishing-run.md || { echo "FAIL: establishing-run.md must document the .engineering/ run dir"; fail=1; }
# Isolation moved to build: signal runs on the current branch and carries no Isolate beat.
! grep -q "^## 1\. Isolate" "$SKILL" || { echo "FAIL: signal must not carry an Isolate beat (isolation is build's job now)"; fail=1; }
grep -q "engineering:brainstorming" "$SKILL" || { echo "FAIL: signal must hand the brief to the design design gate"; fail=1; }
# No expansion beat or sequencing stage survives in the skill or the primitive.
if grep -rqi "expanding-scope\|sequencing-requirements\|expansion beat" "$SKILL" "$INTERROGATE"; then echo "FAIL: stale expansion/sequencing references"; fail=1; fi
# brainstorming owns the spec hand-off; signal must not imperatively dispatch engineering:spec itself.
if grep -qiE "(dispatch|invoke|hand[^.]*to)[^.]*engineering:spec" "$SKILL"; then echo "FAIL: skill must not dispatch spec directly (brainstorming owns that)"; fail=1; fi
[ "$fail" = 0 ] && echo "PASS absorb-signal.sh" || exit 1
