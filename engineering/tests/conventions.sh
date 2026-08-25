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
  # Lifecycle is binary — active / retired — and amendment is a separate path recorded
  # by the Last amended date, not a status of its own (amend-vs-supersede resolution).
  for s in active retired; do
    grep -qi "$s" "$fmt" || { echo "FAIL: STANDARDS-FORMAT missing lifecycle state '$s'"; fail=1; }
  done
  grep -qi "amend" "$fmt" || { echo "FAIL: STANDARDS-FORMAT missing the amend path"; fail=1; }
  # The eight index columns (spec §5) verified as one header row, so a broken/missing
  # index header can't pass on stray column words scattered through the prose.
  grep -qF "| Name | Topic/category | When relevant | Status | Date created | Last amended | Link | Source/provenance |" "$fmt" \
    || { echo "FAIL: STANDARDS-FORMAT missing the eight-column index header row"; fail=1; }
fi

# --- Task 2: recording-code-conventions — the single writer, gate, interrogation, amend/retire ---
sk="$rec/SKILL.md"
gate="$rec/references/approval-gate.md"
hard="$rec/references/hardening-interrogation.md"

if [ ! -f "$sk" ]; then
  echo "FAIL: recording-code-conventions/SKILL.md missing"; fail=1
else
  grep -qxF "name: recording-code-conventions" "$sk" || { echo "FAIL: SKILL.md frontmatter name must be recording-code-conventions"; fail=1; }
  # The writer wires every path through the two shared references and the format doc.
  grep -qF "references/approval-gate.md" "$sk" || { echo "FAIL: SKILL.md must cite references/approval-gate.md"; fail=1; }
  grep -qF "references/hardening-interrogation.md" "$sk" || { echo "FAIL: SKILL.md must cite references/hardening-interrogation.md"; fail=1; }
  grep -qF "STANDARDS-FORMAT.md" "$sk" || { echo "FAIL: SKILL.md must state it writes per STANDARDS-FORMAT.md"; fail=1; }
  grep -qi "index row" "$sk" || { echo "FAIL: SKILL.md must state it adds/updates the index row"; fail=1; }
  # Anchored to the bold labels of the amend/retire section, not a bare substring, so a
  # gutted section can't false-green on an incidental "amend"/"retire" elsewhere.
  grep -qF "**Amend**" "$sk" || { echo "FAIL: SKILL.md must describe the amend path"; fail=1; }
  grep -qF "**Retire**" "$sk" || { echo "FAIL: SKILL.md must describe the retire path"; fail=1; }
fi

if [ ! -f "$gate" ]; then
  echo "FAIL: references/approval-gate.md missing"; fail=1
else
  # The gate defines a concrete conflict-detection criterion and the per-candidate flow.
  grep -qi "conflict" "$gate" || { echo "FAIL: approval-gate.md must name the conflict-detection criterion"; fail=1; }
  grep -qi "contradict" "$gate" || { echo "FAIL: approval-gate.md must define contradiction concretely"; fail=1; }
  grep -qi "individual" "$gate" || { echo "FAIL: approval-gate.md must require per-candidate individual approval"; fail=1; }
fi

if [ ! -f "$hard" ]; then
  echo "FAIL: references/hardening-interrogation.md missing"; fail=1
else
  # The interrogation fixes the is / is-not / robustness turns in the choice-menu style.
  grep -qi "what it is not" "$hard" || { echo "FAIL: hardening-interrogation.md must fix the 'what it is not' turn"; fail=1; }
  grep -qi "robustness" "$hard" || { echo "FAIL: hardening-interrogation.md must fix the robustness turn"; fail=1; }
  grep -qi "one question" "$hard" || { echo "FAIL: hardening-interrogation.md must hold the one-question-per-turn rule"; fail=1; }
  grep -qi "conventional default" "$hard" || { echo "FAIL: hardening-interrogation.md must offer a conventional default (choice-menu style)"; fail=1; }
fi

[ "$fail" = 0 ] && echo "CONVENTIONS CHECKS PASS" || { echo "CONVENTIONS FAILED"; exit 1; }
