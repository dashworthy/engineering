#!/bin/sh
# guardtower run-context.sh resolves .guardtower/<run>/<phase>/, and two invocations in one
# session join the SAME <run> (the slug of the second is ignored).
set -e
ROOT=$(CDPATH= cd "$(dirname "$0")/../.." && pwd)
SCRIPT="$ROOT/guardtower/scripts/run-context.sh"
[ -f "$SCRIPT" ] || { echo "FAIL: $SCRIPT missing"; exit 1; }
TMP=$(mktemp -d)
cd "$TMP"

A=$(sh "$SCRIPT" reviewing-security my-review)
B=$(sh "$SCRIPT" reviewing another-slug)   # no/other slug: must join the run A created, phase differs

# writes under .guardtower, not .engineering
case "$A" in */.guardtower/*) : ;; *) echo "FAIL: path not under .guardtower: $A"; exit 1;; esac
[ -f "$TMP/.guardtower/.current-run" ] || { echo "FAIL: pointer not written"; exit 1; }
[ -d "$A" ] && [ -d "$B" ] || { echo "FAIL: scratch dirs not created"; exit 1; }

runA=$(basename "$(dirname "$A")")
runB=$(basename "$(dirname "$B")")
[ "$runA" = "$runB" ] || { echo "FAIL: runs differ ($runA vs $runB) — second slug not ignored"; exit 1; }

# phase subdir tracks the <phase> arg
[ "$(basename "$A")" = "reviewing-security" ] || { echo "FAIL: phase A wrong: $A"; exit 1; }
[ "$(basename "$B")" = "reviewing" ] || { echo "FAIL: phase B wrong: $B"; exit 1; }

# run id is <YYYY-MM-DD>-<slug>
case "$runA" in [0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]-*) : ;; *) echo "FAIL: run id malformed: $runA"; exit 1;; esac

echo "PASS run-context.sh (run=$runA)"
