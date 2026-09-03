#!/bin/sh
# Signal is the discovery SKILL entrance, driving the shared interrogating-requirements primitive:
# no conductor skill, no expansion beat, no sequencing stage. No stale signal: namespaces or .signal/
# paths; the skill isolates a worktree, redirects artifacts to .engineering/, writes brief.md §1–§6,
# and hands the brief to the engineering:brainstorming design gate, with to-spec running downstream.
set -e
ROOT=$(CDPATH= cd "$(dirname "$0")/../.." && pwd)
cd "$ROOT/engineering"
fail=0
SKILL=skills/signal/SKILL.md
[ -f "$SKILL" ] || { echo "FAIL: skills/signal/SKILL.md must exist (signal is now a skill entrance)"; fail=1; }
[ ! -e commands/signal.md ] || { echo "FAIL: commands/signal.md must be removed (signal is now a skill entrance)"; fail=1; }
if grep -rn "signal:" skills/interrogating-requirements "$SKILL"; then
  echo "FAIL: stale 'signal:' namespace refs"; fail=1; fi
if grep -rn "\.signal/" skills; then
  echo "FAIL: stale '.signal/' paths"; fail=1; fi
# The three absorbed skills must be gone; signal now drives the shared primitive.
for gone in conducting-discovery expanding-scope sequencing-requirements; do
  [ -e "skills/$gone" ] && { echo "FAIL: skills/$gone should have been removed"; fail=1; }
done
grep -q "engineering:interrogating-requirements" "$SKILL" || { echo "FAIL: signal skill must invoke engineering:interrogating-requirements"; fail=1; }
if grep -q "engineering:conducting-discovery" "$SKILL"; then echo "FAIL: signal must not name the removed conductor"; fail=1; fi
grep -q "\.engineering/" "$SKILL" || { echo "FAIL: run dir not redirected to .engineering/"; fail=1; }
# signal is an entrance: it isolates a worktree via using-git-worktrees before obtaining the run dir.
grep -q "using-git-worktrees" "$SKILL" || { echo "FAIL: signal skill must name the worktree-isolation step"; fail=1; }
grep -q "engineering:brainstorming" "$SKILL" || { echo "FAIL: signal must hand the brief to the brainstorming design gate"; fail=1; }
# No expansion beat or sequencing stage survives in the skill or the primitive.
if grep -rqi "expanding-scope\|sequencing-requirements\|expansion beat" "$SKILL" skills/interrogating-requirements/SKILL.md; then echo "FAIL: stale expansion/sequencing references"; fail=1; fi
# brainstorming owns to-spec; the skill must not imperatively dispatch engineering:to-spec itself.
if grep -qiE "(dispatch|invoke|hand[^.]*to)[^.]*engineering:to-spec" "$SKILL"; then echo "FAIL: skill must not dispatch to-spec directly (brainstorming owns that)"; fail=1; fi
[ "$fail" = 0 ] && echo "PASS absorb-signal.sh" || exit 1
