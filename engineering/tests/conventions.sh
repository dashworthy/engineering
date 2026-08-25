#!/bin/sh
# Content assertions for the code-conventions subsystem (spec: brainstorming-both-entrances).
# Each build task adds its assertions here first (red), then authors to green. Kept separate
# from acceptance.sh so the subsystem's content bar lives in one growing file.
set -e
d=$(CDPATH= cd "$(dirname "$0")" && pwd)
eng=$(CDPATH= cd "$d/.." && pwd)
fail=0

skills="$eng/skills"
rec="$skills/recording-code-conventions"
fmt="$rec/STANDARDS-FORMAT.md"

# --- Task 1: STANDARDS-FORMAT.md — the convention-document shape + the index table shape ---
if [ ! -f "$fmt" ]; then
  echo "FAIL: STANDARDS-FORMAT.md missing at $fmt"; fail=1
else
  # Boundary fields — the two mandatory headings, matched whole-line so "## What it is"
  # is verified independently of "## What it is not" (a substring grep conflates them).
  grep -qxF "## What it is" "$fmt" || { echo "FAIL: STANDARDS-FORMAT missing '## What it is' heading"; fail=1; }
  grep -qxF "## What it is not" "$fmt" || { echo "FAIL: STANDARDS-FORMAT missing '## What it is not' heading"; fail=1; }
  # Provenance block — the four fields, anchored to their bold labels so an unrelated
  # word ("whole", "source/provenance" column) can't false-green the check.
  grep -qi "provenance" "$fmt" || { echo "FAIL: STANDARDS-FORMAT missing a provenance block"; fail=1; }
  for label in "**Who:**" "**When:**" "**Source:**" "**Lifecycle:**"; do
    grep -qF "$label" "$fmt" || { echo "FAIL: STANDARDS-FORMAT provenance missing $label"; fail=1; }
  done
  # Lifecycle states — active / amended / retired — the amend-vs-supersede resolution.
  for s in active amended retired; do
    grep -qi "$s" "$fmt" || { echo "FAIL: STANDARDS-FORMAT missing lifecycle state '$s'"; fail=1; }
  done
  # The eight index columns (spec §5) verified as one header row, so a broken/missing
  # index header can't pass on stray column words scattered through the prose.
  grep -qF "| Name | Topic/category | When relevant | Status | Date created | Last amended | Link | Source/provenance |" "$fmt" \
    || { echo "FAIL: STANDARDS-FORMAT missing the eight-column index header row"; fail=1; }
fi

[ "$fail" = 0 ] && echo "CONVENTIONS CHECKS PASS" || { echo "CONVENTIONS FAILED"; exit 1; }
