#!/bin/sh
# Structural and behavioural validation for the engineering plugin.
# POSIX sh. Uses python3 (stdlib only) for JSON. Never requires jq.
# Run from anywhere: sh engineering/tests/validate.sh

ROOT=$(cd "$(dirname "$0")/../.." && pwd)
PLUGIN="$ROOT/engineering"
fail=0

ok()   { printf 'ok   - %s\n' "$1"; }
bad()  { printf 'FAIL - %s\n' "$1"; fail=1; }
check(){ if [ "$1" -eq 0 ]; then ok "$2"; else bad "$2"; fi }

# Match a prose anchor regardless of how the source is line-wrapped. Prose in these documents is
# wrapped for readability; a check that depends on where the wrap falls breaks on a purely
# cosmetic reflow. `--` before the pattern is load-bearing: without it grep parses an anchor
# beginning with a hyphen as its own options and dies with a usage error instead of searching.
grep_flat() {  # grep_flat <file> <literal phrase>
  tr '\n' ' ' < "$1" | tr -s ' ' | grep -qF -- "$2"
}

# --- manifest ---------------------------------------------------------------

[ -f "$PLUGIN/.claude-plugin/plugin.json" ]; check $? "plugin.json exists"

if [ -f "$PLUGIN/.claude-plugin/plugin.json" ]; then
  python3 - "$PLUGIN/.claude-plugin/plugin.json" <<'PY'
import json,sys
d=json.load(open(sys.argv[1]))
required={"name","description","version","author","license"}
missing=required-set(d)
assert not missing, f"plugin.json missing keys: {sorted(missing)}"
assert d["name"]=="engineering", f'name is {d["name"]!r}, expected "engineering"'
import re
assert re.fullmatch(r"\d+\.\d+\.\d+", str(d["version"])), f'version {d["version"]!r} is not semver'
assert d["license"]=="MIT", f'license is {d["license"]!r}, expected "MIT"'
PY
  check $? "plugin.json is well-formed"
fi

# --- marketplace registration ------------------------------------------------

python3 - "$ROOT/.claude-plugin/marketplace.json" "$PLUGIN/.claude-plugin/plugin.json" <<'PY'
import json,sys
d=json.load(open(sys.argv[1]))
names=[p["name"] for p in d["plugins"]]
assert "engineering" in names, f"engineering not registered; found {names}"
e=[p for p in d["plugins"] if p["name"]=="engineering"][0]
assert e["source"]=="./engineering", f'source is {e["source"]!r}'
pv=json.load(open(sys.argv[2]))["version"]
assert e["version"]==pv, f'marketplace version {e["version"]!r} != plugin.json {pv!r}'
PY
check $? "marketplace engineering entry version matches plugin.json"

# --- references --------------------------------------------------------------

REF="$PLUGIN/skills/clarifying-docblocks/references"
for f in comprehension-gate.md diagram-rules.md receipt-schema.md; do
  [ -f "$REF/$f" ]; check $? "references/$f exists"
done

if [ -f "$REF/comprehension-gate.md" ]; then
  grep_flat "$REF/comprehension-gate.md" "Restates the signature";       check $? "gate names the restates-the-signature failure"
  grep_flat "$REF/comprehension-gate.md" "Describes mechanism, not purpose"; check $? "gate names the mechanism failure"
  grep_flat "$REF/comprehension-gate.md" "Machine-facing residue";       check $? "gate names the machine-residue failure"
  grep_flat "$REF/comprehension-gate.md" "when in doubt, leave it";      check $? "gate states the leave-it default"
fi

if [ -f "$REF/diagram-rules.md" ]; then
  grep_flat "$REF/diagram-rules.md" "72 columns including the comment leader"; check $? "diagram rules state the width budget"
fi

if [ -f "$REF/receipt-schema.md" ]; then
  grep_flat "$REF/receipt-schema.md" "lines_after";  check $? "receipt schema documents lines_after"
  grep_flat "$REF/receipt-schema.md" "end_before = start - 1"; check $? "receipt schema documents the insertion form"
fi

# No language table may be reintroduced in vernacular's own docs skills — this is
# vernacular's invariant that it never hard-codes a language/stack table. Scoped to just
# those three skill dirs: the conducting-test-hardening skill legitimately ships its own
# detecting-the-stack.md / stack-markers.md references, and those must not trip this check.
if find "$PLUGIN/skills/clarifying-docblocks" "$PLUGIN/skills/rewriting-docblock-prose" -type f -exec grep -liE 'detecting-the-stack|stack-marker' {} + 2>/dev/null | grep -q .; then
  bad "no stack-detection artefact exists in the vernacular docs skills"
else
  ok "no stack-detection artefact exists in the vernacular docs skills"
fi

# --- rewriter ----------------------------------------------------------------

REWRITER="$PLUGIN/skills/rewriting-docblock-prose/SKILL.md"
[ -f "$REWRITER" ]; check $? "rewriting-docblock-prose/SKILL.md exists"

if [ -f "$REWRITER" ]; then
  head -1 "$REWRITER" | grep -q '^---$'; check $? "rewriter has frontmatter"
  grep -q '^name: rewriting-docblock-prose$' "$REWRITER"; check $? "rewriter frontmatter names itself"
  grep_flat "$REWRITER" "never return a description you wrote"; check $? "rewriter states the receipt-only return"
  grep_flat "$REWRITER" "Never claim a range containing an annotation line"; check $? "rewriter states the annotation prohibition"
  grep_flat "$REWRITER" "whole lines"; check $? "rewriter states the whole-line replacement rule"
  grep_flat "$REWRITER" "never author a docblock where none existed"; check $? "rewriter states existing-docblocks-only scope"
  grep_flat "$REWRITER" "flagged"; check $? "rewriter states the self-flag concession"
fi

# The verifier skill was retired in 0.5.0: vernacular defers claim-checking to the human's
# git-diff review. Its removal is a guarded invariant, not an omission.
[ ! -e "$PLUGIN/skills/verifying-docblock-claims" ]; check $? "retired verifier skill is absent"

# --- conductor ---------------------------------------------------------------

COND="$PLUGIN/skills/clarifying-docblocks/SKILL.md"
[ -f "$COND" ]; check $? "clarifying-docblocks/SKILL.md exists"

if [ -f "$COND" ]; then
  grep -q '^name: clarifying-docblocks$' "$COND"; check $? "conductor frontmatter names itself"
  grep_flat "$COND" "file modified relative to"; check $? "conductor states the dirty-file halt"
  grep_flat "$COND" "never opens a source file"; check $? "conductor states the context firewall"
  grep_flat "$COND" "restore it from"; check $? "conductor states the quarantine-and-restore path"
  grep_flat "$COND" "Left alone"; check $? "conductor reports the left-alone count"
  grep_flat "$COND" "run-context.sh"; check $? "conductor derives the run directory via run-context.sh"
  # The dispatch payload must name skill_path so a subagent can resolve its own SKILL.md. One
  # payload now (the verifier was retired in 0.5.0), so one occurrence suffices.
  grep -c 'skill_path' "$COND" | awk '$1 >= 1 {exit 0} {exit 1}'
  check $? "conductor names skill_path in the dispatch payload"
  ! grep_flat "$COND" "so there is none to read"
  check $? "conductor does not claim --unified=0 removes the diff body"
  grep_flat "$COND" "Never run a bare"; check $? "conductor forbids the unfiltered git diff"
  grep_flat "$COND" "no comment leader"; check $? "conductor prefilters files with no docblock"
  grep_flat "$COND" "inline path"; check $? "conductor states the small-run inline path"
  grep_flat "$COND" "Verify these yourself"; check $? "conductor reports rewriter self-flags"
fi

# --- first-class-artifact doctrine -------------------------------------------
# The doctrine is defined before it is applied: ADRs, the glossary, and diagrams each
# declare themselves an application of this one pattern. The pattern has three elements
# and resolves the glossary-vs-ADR consumption question with two named profiles.
DOCTRINE="$PLUGIN/skills/recording-adrs/references/first-class-artifact.md"
[ -f "$DOCTRINE" ]; check $? "first-class-artifact doctrine exists"

if [ -f "$DOCTRINE" ]; then
  grep_flat "$DOCTRINE" "intake trigger";      check $? "doctrine names the intake-trigger pattern element"
  grep_flat "$DOCTRINE" "index";               check $? "doctrine names the index pattern element"
  grep_flat "$DOCTRINE" "active consumption";  check $? "doctrine names the active-consumption pattern element"
  grep_flat "$DOCTRINE" "trail";               check $? "doctrine names the trail consumption profile"
  grep_flat "$DOCTRINE" "lookup";              check $? "doctrine names the lookup consumption profile"
fi

# --- recording-adrs single writer --------------------------------------------
# The single writer of docs/adr/. Mirrors recording-code-conventions' single-writer role,
# but an ADR is a point-in-time record, not a standing rule — so it carries NO hardening
# interrogation and NO individual-approval gate. Its intake does not flood: it fires only on
# a decision with live alternatives, and the developer can decline.
RECADR="$PLUGIN/skills/recording-adrs/SKILL.md"
[ -f "$RECADR" ]; check $? "recording-adrs/SKILL.md exists"

if [ -f "$RECADR" ]; then
  grep -q '^name: recording-adrs$' "$RECADR"; check $? "recording-adrs frontmatter names itself"
  grep_flat "$RECADR" "docs/adr/";            check $? "recording-adrs states it writes docs/adr/"
  grep_flat "$RECADR" "single writer";        check $? "recording-adrs states it is the single writer"
  grep_flat "$RECADR" "live alternatives";    check $? "recording-adrs states the live-alternatives intake bar"
  grep_flat "$RECADR" "can decline";          check $? "recording-adrs states the developer can decline (no flood)"
  grep_flat "$RECADR" "Proposed";             check $? "recording-adrs states the Proposed lifecycle state"
  grep_flat "$RECADR" "Accepted";             check $? "recording-adrs states the Accepted lifecycle state"
  grep_flat "$RECADR" "Superseded";           check $? "recording-adrs states the Superseded lifecycle state"
  grep_flat "$RECADR" "no approval gate";     check $? "recording-adrs states it carries no approval gate"
  grep_flat "$RECADR" "per-run/per-phase";    check $? "recording-adrs describes the per-run/per-phase tracking ledger"
  grep_flat "$RECADR" "derived from the index"; check $? "recording-adrs states the tracking view is derived from the index (not a second source of truth)"
fi

ADRFMT="$PLUGIN/skills/recording-adrs/ADR-FORMAT.md"
[ -f "$ADRFMT" ]; check $? "recording-adrs/ADR-FORMAT.md exists (moved from domain-modeling)"
ADRIDX="$PLUGIN/skills/recording-adrs/ADR-INDEX-FORMAT.md"
[ -f "$ADRIDX" ]; check $? "recording-adrs/ADR-INDEX-FORMAT.md exists"
if [ -f "$ADRIDX" ]; then
  grep_flat "$ADRIDX" "When relevant"; check $? "ADR index format has a When relevant match column"
  grep_flat "$ADRIDX" "Status";        check $? "ADR index format has a Status column"
fi

# The ADR trail's index is seeded with the one ADR already on disk, so using-adrs has a map
# to read from day one. docs/adr/ is a per-repo runtime artifact at the repo root.
ADRSEED="$ROOT/docs/adr/index.md"
[ -f "$ADRSEED" ]; check $? "docs/adr/index.md exists"
if [ -f "$ADRSEED" ]; then
  grep_flat "$ADRSEED" "0001-derive-verity-configuration-fresh-each-run.md"; check $? "ADR index links ADR 0001"
  grep_flat "$ADRSEED" "Accepted"; check $? "ADR index records ADR 0001 as Accepted"
fi

# --- using-adrs consumer -----------------------------------------------------
# The ADR analogue of using-code-conventions, under the trail profile: read the index, match
# the When relevant column, cite the governing ADR by path at the work item, skip Superseded.
USEADR="$PLUGIN/skills/using-adrs/SKILL.md"
[ -f "$USEADR" ]; check $? "using-adrs/SKILL.md exists"

if [ -f "$USEADR" ]; then
  grep -q '^name: using-adrs$' "$USEADR"; check $? "using-adrs frontmatter names itself"
  grep_flat "$USEADR" "docs/adr/index.md"; check $? "using-adrs reads the ADR index"
  grep_flat "$USEADR" "When relevant";     check $? "using-adrs matches the When relevant column"
  grep_flat "$USEADR" "by path";           check $? "using-adrs cites the governing ADR by path at the work item"
  grep_flat "$USEADR" "Superseded";        check $? "using-adrs skips Superseded rows"
fi

# --- command and READMEs ------------------------------------------------------

CMD="$PLUGIN/commands/vernacular.md"
[ -f "$CMD" ]; check $? "commands/vernacular.md exists"
if [ -f "$CMD" ]; then
  grep -q '^description:' "$CMD"; check $? "command has a description"
  grep_flat "$CMD" "clarifying-docblocks"; check $? "command invokes the conductor by name"
fi

[ -f "$PLUGIN/README.md" ]; check $? "engineering/README.md exists"

# The root README must name the engineering plugin.
grep_flat "$ROOT/README.md" "engineering"; check $? "root README lists engineering"

# --- README consistency ------------------------------------------------------
# These pin the facts an earlier gap analysis found drifting: the install URL was
# wrong in one of three READMEs, and the advertised skill count had no guard.

# Every install snippet points at the same marketplace repo.
url_root=$(grep 'plugin marketplace add' "$ROOT/README.md" | head -1)
for r in "$PLUGIN/README.md" "$ROOT/laravel/README.md"; do
  [ -f "$r" ] || continue
  u=$(grep 'plugin marketplace add' "$r" | head -1)
  [ "$u" = "$url_root" ]; check $? "install URL in $(basename "$(dirname "$r")")/README matches root"
done

# The skill count the root README advertises matches the skills on disk.
claimed=$(grep -oE '[0-9]+ skills' "$ROOT/README.md" | grep -oE '[0-9]+' | head -1)
actual=$(find "$PLUGIN/skills" -name SKILL.md | wc -l | tr -d ' ')
[ "$claimed" = "$actual" ]; check $? "root README skill count ($claimed) matches disk ($actual)"

# The command count the root README advertises matches the commands on disk, and every command
# file is named in the README's command list — the command analogue of the skill guard above.
# A conventions PR shipped two commands the README never listed and the advertised count still
# said eight; the skill-count guard had no command twin to catch it.
cmd_claimed=$(grep -oE '[0-9]+ slash commands' "$ROOT/README.md" | grep -oE '[0-9]+' | head -1)
cmd_actual=$(find "$PLUGIN/commands" -name '*.md' | wc -l | tr -d ' ')
[ "$cmd_claimed" = "$cmd_actual" ]; check $? "root README command count ($cmd_claimed) matches disk ($cmd_actual)"
for c in "$PLUGIN"/commands/*.md; do
  name=$(basename "$c" .md)
  grep_flat "$ROOT/README.md" "/$name"; check $? "root README names /$name"
done

exit $fail
