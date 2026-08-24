#!/bin/sh
# No stale signal: namespaces or .signal/ paths survive absorption; brief is Tier-2;
# the brief is handed to the engineering:brainstorming design gate, and to-spec runs downstream.
set -e
ROOT=$(CDPATH= cd "$(dirname "$0")/../.." && pwd)
cd "$ROOT/engineering"
fail=0
if grep -rn "signal:" skills/conducting-discovery skills/interrogating-requirements skills/expanding-scope skills/sequencing-requirements commands/signal.md; then
  echo "FAIL: stale 'signal:' namespace refs"; fail=1; fi
if grep -rn "\.signal/" skills commands/signal.md; then
  echo "FAIL: stale '.signal/' paths"; fail=1; fi
grep -q "engineering:conducting-discovery" commands/signal.md || { echo "FAIL: command must dispatch engineering:conducting-discovery"; fail=1; }
grep -rq "\.engineering/" skills/conducting-discovery/SKILL.md || { echo "FAIL: run dir not redirected to .engineering/"; fail=1; }
# Positive guard scoped to the release hand-off phrase itself — absent from the pre-change file,
# where the release step dispatched to-spec — so it fails on a revert, unlike a bare "brainstorming"
# grep that the Overview already satisfied.
grep -qE "Hand off to .*engineering:brainstorming" skills/conducting-discovery/SKILL.md || { echo "FAIL: signal's release must hand the brief to the brainstorming design gate"; fail=1; }
# Belt-and-braces: no verbatim conductor->to-spec dispatch. The scoped positive above is the primary guard.
if grep -qiE "dispatch[^.]*engineering:to-spec" skills/conducting-discovery/SKILL.md; then echo "FAIL: conductor must not dispatch to-spec directly (brainstorming owns that)"; fail=1; fi
[ "$fail" = 0 ] && echo "PASS absorb-signal.sh" || exit 1
