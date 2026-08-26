#!/bin/sh
# Content assertions for the code-conventions subsystem (spec: brainstorming-both-entrances).
# Each build task adds its assertions here first (red), then authors to green. Kept separate
# from acceptance.sh so the subsystem's content bar lives in one growing file.
set -e
d=$(CDPATH= cd "$(dirname "$0")" && pwd)
eng=$(CDPATH= cd "$d/.." && pwd)
fail=0

# Match a prose anchor regardless of how the source is line-wrapped. These documents wrap prose
# for readability, so a check anchored to a phrase that straddles a wrap must flatten newlines
# first or it reports a false negative on content that is present. Mirrors validate.sh's helper.
grep_flat() {  # grep_flat <file> <literal phrase>
  tr '\n' ' ' < "$1" | tr -s ' ' | grep -qF -- "$2"
}

skills="$eng/skills"
rec="$skills/recording-code-conventions"
fmt="$rec/STANDARDS-FORMAT.md"

# --- Task 1: STANDARDS-FORMAT.md — the convention-document shape + the index table shape ---
if [ ! -f "$fmt" ]; then
  echo "FAIL: STANDARDS-FORMAT.md missing at $fmt"; fail=1
else
  # Boundary fields — the two mandatory headings, matched whole-line so "## What it is"
  # is verified independently of "## What it is not" (a substring grep conflates them).
  grep -qxF "## Rule" "$fmt" || { echo "FAIL: STANDARDS-FORMAT missing the mandatory '## Rule' heading (the line a builder obeys)"; fail=1; }
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
  # The write is atomic: the convention document and its index row move as one, or the
  # index drifts (the exact failure STANDARDS-FORMAT calls worse than no index).
  grep -qF "the two move together or not at all" "$sk" || { echo "FAIL: SKILL.md must state the doc and its index row are written together"; fail=1; }
fi

if [ ! -f "$gate" ]; then
  echo "FAIL: references/approval-gate.md missing"; fail=1
else
  # The gate defines a concrete conflict-detection criterion and the per-candidate flow.
  grep -qi "conflict" "$gate" || { echo "FAIL: approval-gate.md must name the conflict-detection criterion"; fail=1; }
  grep -qi "contradict" "$gate" || { echo "FAIL: approval-gate.md must define contradiction concretely"; fail=1; }
  grep -qi "individual" "$gate" || { echo "FAIL: approval-gate.md must require per-candidate individual approval"; fail=1; }
  # The criterion must be the concrete one, not a bare word "contradict": two conventions
  # conflict when a single piece of code cannot satisfy both at once. Anchored to that phrase.
  grep -qiF "cannot satisfy both at once" "$gate" || { echo "FAIL: approval-gate.md must state the concrete conflict criterion (one piece of code cannot satisfy both)"; fail=1; }
  # The three per-candidate verdicts, anchored to their bold labels.
  grep -qF "**Approve**" "$gate" || { echo "FAIL: approval-gate.md must offer the Approve verdict"; fail=1; }
  grep -qF "**Edit**" "$gate" || { echo "FAIL: approval-gate.md must offer the Edit verdict"; fail=1; }
  grep -qF "**Reject**" "$gate" || { echo "FAIL: approval-gate.md must offer the Reject verdict"; fail=1; }
fi

if [ ! -f "$hard" ]; then
  echo "FAIL: references/hardening-interrogation.md missing"; fail=1
else
  # The interrogation fixes the is / is-not / robustness turns in the choice-menu style.
  grep -qi "what it is not" "$hard" || { echo "FAIL: hardening-interrogation.md must fix the 'what it is not' turn"; fail=1; }
  grep -qi "robustness" "$hard" || { echo "FAIL: hardening-interrogation.md must fix the robustness turn"; fail=1; }
  grep_flat "$hard" "one question per turn" || { echo "FAIL: hardening-interrogation.md must hold the one-question-per-turn rule"; fail=1; }
  grep_flat "$hard" "conventional default framing" || { echo "FAIL: hardening-interrogation.md must offer a conventional default (choice-menu style)"; fail=1; }
fi

# --- Task 3: identifying-code-conventions — the discoverer (surfaces, never codifies) ---
id="$skills/identifying-code-conventions/SKILL.md"
if [ ! -f "$id" ]; then
  echo "FAIL: identifying-code-conventions/SKILL.md missing"; fail=1
else
  grep -qxF "name: identifying-code-conventions" "$id" || { echo "FAIL: identifying SKILL.md frontmatter name"; fail=1; }
  # Two surfacing modes — anchored to the body's bold labels, not substrings that also appear
  # in the frontmatter description (which would pass even with the body gutted).
  grep -qiF "observed repetition" "$id" || { echo "FAIL: identifying must describe inference from observed repetition"; fail=1; }
  grep -qF "**Inference from code.**" "$id" || { echo "FAIL: identifying must have the inference-from-code mode"; fail=1; }
  grep -qF "**file:line**" "$id" || { echo "FAIL: identifying inference must carry file:line evidence"; fail=1; }
  grep -qF "**Capture from the developer.**" "$id" || { echo "FAIL: identifying must have the capture-from-the-developer mode"; fail=1; }
  # Presents each candidate individually and hands it, rough, to the single writer.
  grep -qxF "## Every candidate, individually, to recording" "$id" || { echo "FAIL: identifying must route each candidate individually to recording"; fail=1; }
  grep_flat "$id" "hand each one individually" || { echo "FAIL: identifying must hand each candidate to the writer"; fail=1; }
  grep -qF "approval-gate.md" "$id" || { echo "FAIL: identifying must name the shared approval-gate.md"; fail=1; }
  # The inference heuristic (§8): when observed repetition is worth surfacing.
  grep -qi "heuristic" "$id" || { echo "FAIL: identifying must state the inference heuristic"; fail=1; }
  # The heuristic's actual conditions, anchored to their bold labels — so the whole
  # condition list can't be deleted while the word "heuristic" survives in the heading.
  grep -qF "**It recurs across independent sites**" "$id" || { echo "FAIL: identifying heuristic missing the cross-site recurrence condition"; fail=1; }
  grep -qF "**It was a real choice.**" "$id" || { echo "FAIL: identifying heuristic missing the real-choice condition"; fail=1; }
fi

# --- Task 4: using-code-conventions — the read/consume side (cites conventions at work items) ---
u="$skills/using-code-conventions/SKILL.md"
if [ ! -f "$u" ]; then
  echo "FAIL: using-code-conventions/SKILL.md missing"; fail=1
else
  grep -qxF "name: using-code-conventions" "$u" || { echo "FAIL: using SKILL.md frontmatter name"; fail=1; }
  # Body markers (whole-line headings), so a gutted body can't false-green off the description.
  grep_flat "$u" "convention file inline, right at that work item" || { echo "FAIL: using must cite the governing convention inline at the work item"; fail=1; }
  grep -qxF "## Match on the When relevant column" "$u" || { echo "FAIL: using must match on the index When relevant column"; fail=1; }
  grep -qxF "## Skip retired conventions" "$u" || { echo "FAIL: using must skip retired rows"; fail=1; }
  # Cite the file by path, not a paraphrase — a paraphrase goes stale when the rule is amended.
  grep -qiF "not a paraphrase" "$u" || { echo "FAIL: using must cite the convention file, not a paraphrase of the rule"; fail=1; }
fi

# --- Task 5: conventions-init command — thin invoker, onboard an existing codebase ---
init="$eng/commands/conventions-init.md"
if [ ! -f "$init" ]; then
  echo "FAIL: commands/conventions-init.md missing"; fail=1
else
  grep -q "^description:" "$init" || { echo "FAIL: conventions-init needs a description:"; fail=1; }
  grep -q "^argument-hint:" "$init" || { echo "FAIL: conventions-init needs an argument-hint:"; fail=1; }
  grep -qF "engineering:identifying-code-conventions" "$init" || { echo "FAIL: conventions-init must invoke engineering:identifying-code-conventions"; fail=1; }
  grep -qF "engineering:recording-code-conventions" "$init" || { echo "FAIL: conventions-init must name the writer half (engineering:recording-code-conventions)"; fail=1; }
  # §8 init re-run behaviour: first run scaffolds; re-run augments, never clobbers approved rows.
  grep -qi "first run" "$init" || { echo "FAIL: conventions-init must state first-run scaffolding"; fail=1; }
  grep -qi "augment" "$init" || { echo "FAIL: conventions-init must state re-run augments (never clobbers)"; fail=1; }
  # The augment claim's teeth: a re-run must never clobber already-approved conventions.
  grep -qiF "never clobbers" "$init" || { echo "FAIL: conventions-init re-run must state it never clobbers approved rows"; fail=1; }
fi

# --- Task 6: record-convention command — thin invoker, dictate one convention from the head ---
recmd="$eng/commands/record-convention.md"
if [ ! -f "$recmd" ]; then
  echo "FAIL: commands/record-convention.md missing"; fail=1
else
  grep -q "^description:" "$recmd" || { echo "FAIL: record-convention needs a description:"; fail=1; }
  grep -q "^argument-hint:" "$recmd" || { echo "FAIL: record-convention needs an argument-hint:"; fail=1; }
  grep -qF "engineering:recording-code-conventions" "$recmd" || { echo "FAIL: record-convention must invoke engineering:recording-code-conventions"; fail=1; }
fi

# --- Task 7: PR-time convention detection inside code-review (additive) ---
cr="$skills/code-review/SKILL.md"
if [ ! -f "$cr" ]; then
  echo "FAIL: code-review/SKILL.md missing"; fail=1
else
  grep -qxF "## Convention detection in the diff (additive)" "$cr" || { echo "FAIL: code-review must add the additive convention-detection section"; fail=1; }
  grep -qF "**Harvest new idioms.**" "$cr" || { echo "FAIL: code-review step must harvest new idioms as candidates"; fail=1; }
  grep -qF "**Flag violations.**" "$cr" || { echo "FAIL: code-review step must flag violations of recorded conventions"; fail=1; }
  grep -qiF "PR diff only" "$cr" || { echo "FAIL: code-review step must be scoped to the PR diff only"; fail=1; }
  grep -qF "recording-code-conventions" "$cr" || { echo "FAIL: code-review harvest must route through recording-code-conventions (the gate)"; fail=1; }
  grep -qF "using-code-conventions" "$cr" || { echo "FAIL: code-review violation-flagging must read via using-code-conventions"; fail=1; }
fi

# --- Task 8: ADR -> convention spawn seam in domain-modeling (additive, one-directional) ---
dm="$skills/domain-modeling/SKILL.md"
if [ ! -f "$dm" ]; then
  echo "FAIL: domain-modeling/SKILL.md missing"; fail=1
else
  grep -qxF "## Spawning a convention from an ADR (one-directional)" "$dm" || { echo "FAIL: domain-modeling must add the ADR->convention spawn section"; fail=1; }
  grep -qF "recording-code-conventions" "$dm" || { echo "FAIL: the spawn must enter the gate via recording-code-conventions"; fail=1; }
  # Anchored to the body's bold label (not the heading, which the section-existence check
  # above already pins), so the one-directional guarantee prose itself must survive.
  grep -qF "**one-directional**" "$dm" || { echo "FAIL: the seam body must state the relationship is one-directional"; fail=1; }
  grep -qiF "provenance" "$dm" || { echo "FAIL: the spawning ADR must be recorded in the convention's provenance"; fail=1; }
  # The §8 resolution: the trigger is manual, never automatic — anchored to its bold label.
  grep -qF "**manual, opt-in hand-off, never automatic**" "$dm" || { echo "FAIL: the spawn trigger must be stated as manual/opt-in, never automatic (§8)"; fail=1; }
fi

# --- Task 9: writing-plans wires the read side into planning (the [Build] consumer is reachable) ---
# The read side (using-code-conventions) is [Build]-tagged but consumed at plan-write time: the
# citation is placed on a task so it travels to the executing subagent. Without a pointer from
# writing-plans, the skill is reachable only if its own description happens to self-trigger — every
# sibling consumption point (code-review reads specs, planning reads CONTEXT.md/adr) is wired by
# an explicit name. This guard keeps that wiring from silently rotting back out.
wp="$skills/writing-plans/SKILL.md"
if [ ! -f "$wp" ]; then
  echo "FAIL: writing-plans/SKILL.md missing"; fail=1
else
  grep -qF "using-code-conventions" "$wp" || { echo "FAIL: writing-plans must invoke using-code-conventions to cite governing conventions at each task"; fail=1; }
  grep -qF "docs/standards" "$wp" || { echo "FAIL: writing-plans must name the standards tree (docs/standards/) it consults"; fail=1; }
fi

[ "$fail" = 0 ] && echo "CONVENTIONS CHECKS PASS" || { echo "CONVENTIONS FAILED"; exit 1; }
