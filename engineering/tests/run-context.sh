#!/bin/sh
# Two invocations in one session must resolve to the SAME <run> (G7).
set -e
ROOT=$(CDPATH= cd "$(dirname "$0")/../.." && pwd)
SCRIPT="$ROOT/engineering/scripts/run-context.sh"
TMP=$(mktemp -d)
cd "$TMP"
A=$(sh "$SCRIPT" signal my-feature)
B=$(sh "$SCRIPT" vernacular)          # no slug: must join the run A created
runA=$(basename "$(dirname "$A")")
runB=$(basename "$(dirname "$B")")
[ "$runA" = "$runB" ] || { echo "FAIL: runs differ ($runA vs $runB)"; exit 1; }
[ -f "$TMP/.engineering/.current-run" ] || { echo "FAIL: pointer not written"; exit 1; }
[ -d "$A" ] && [ -d "$B" ] || { echo "FAIL: scratch dirs not created"; exit 1; }
case "$runA" in [0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]-*) : ;; *) echo "FAIL: run id malformed: $runA"; exit 1;; esac

# --fresh mints a per-invocation leaf under the SAME phase dir (so a plan running vernacular
# once per task never shares one receipts/ dir, which would make reconcile re-check a prior
# task's stale receipt). Repeat --fresh calls must return DISTINCT, ordered numeric leaves.
B2=$(sh "$SCRIPT" vernacular)                    # plain: still the shared phase dir
[ "$B2" = "$B" ] || { echo "FAIL: plain vernacular calls stopped sharing ($B vs $B2)"; exit 1; }
F1=$(sh "$SCRIPT" vernacular --fresh)
F2=$(sh "$SCRIPT" vernacular --fresh)
[ "$F1" != "$F2" ] || { echo "FAIL: --fresh returned the same leaf twice ($F1)"; exit 1; }
[ -d "$F1" ] && [ -d "$F2" ] || { echo "FAIL: fresh leaves not created"; exit 1; }
[ "$(dirname "$F1")" = "$B" ] || { echo "FAIL: fresh leaf not under the phase dir ($(dirname "$F1") vs $B)"; exit 1; }
runF=$(basename "$(dirname "$(dirname "$F1")")")
[ "$runF" = "$runA" ] || { echo "FAIL: fresh leaf under a different run ($runF vs $runA)"; exit 1; }
case "$(basename "$F1")" in [0-9][0-9][0-9]) : ;; *) echo "FAIL: fresh leaf not zero-padded numeric: $(basename "$F1")"; exit 1;; esac
[ "$(basename "$F1")" = "001" ] && [ "$(basename "$F2")" = "002" ] || { echo "FAIL: fresh leaves not ordered (got $(basename "$F1"), $(basename "$F2"))"; exit 1; }
echo "PASS run-context.sh (run=$runA, fresh leaves $(basename "$F1")/$(basename "$F2"))"
