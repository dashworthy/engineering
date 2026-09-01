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
for f in comprehension-gate.md receipt-schema.md; do
  [ -f "$REF/$f" ]; check $? "references/$f exists"
done

if [ -f "$REF/comprehension-gate.md" ]; then
  grep_flat "$REF/comprehension-gate.md" "Restates the signature";       check $? "gate names the restates-the-signature failure"
  grep_flat "$REF/comprehension-gate.md" "Describes mechanism, not purpose"; check $? "gate names the mechanism failure"
  grep_flat "$REF/comprehension-gate.md" "Machine-facing residue";       check $? "gate names the machine-residue failure"
  grep_flat "$REF/comprehension-gate.md" "when in doubt, leave it";      check $? "gate states the leave-it default"
fi

# diagram-rules.md is the docblock ASCII width rule, owned by using-diagrams (not the
# docblock skill), so it is checked where it actually lives.
DR="$PLUGIN/skills/using-diagrams/references/diagram-rules.md"
[ -f "$DR" ]; check $? "using-diagrams/references/diagram-rules.md exists"
if [ -f "$DR" ]; then
  grep_flat "$DR" "72 columns including the comment leader"; check $? "diagram rules state the width budget"
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

# --- gutted subsystems stay gutted -------------------------------------------
# ADRs and the code-conventions subsystem were removed wholesale; guard that neither the
# skills, the commands, nor the repo-root docs/adr/ tree come back.
[ ! -e "$PLUGIN/skills/domain-modeling" ];              check $? "domain-modeling skill removed"
[ ! -e "$PLUGIN/skills/recording-adrs" ];               check $? "recording-adrs skill removed"
[ ! -e "$PLUGIN/skills/using-adrs" ];                   check $? "using-adrs skill removed"
[ ! -e "$PLUGIN/skills/identifying-code-conventions" ]; check $? "identifying-code-conventions skill removed"
[ ! -e "$PLUGIN/skills/recording-code-conventions" ];   check $? "recording-code-conventions skill removed"
[ ! -e "$PLUGIN/skills/using-code-conventions" ];       check $? "using-code-conventions skill removed"
[ ! -e "$PLUGIN/commands/conventions-init.md" ];        check $? "conventions-init command removed"
[ ! -e "$PLUGIN/commands/record-convention.md" ];       check $? "record-convention command removed"
[ ! -e "$ROOT/docs/adr" ];                              check $? "docs/adr/ tree removed"

# --- diagrams first-class: authoring phases consider a diagram ---------------
# The authoring phases (to-spec, writing-plans) each carry a "consider a diagram" obligation —
# guard is *consider*, not *always draw*, so it does not flood.
UD="$PLUGIN/skills/using-diagrams/SKILL.md"
if [ -f "$UD" ]; then
  grep_flat "$UD" "consider a diagram";      check $? "using-diagrams states the consider-a-diagram authoring obligation"
fi
for sk in to-spec writing-plans; do
  f="$PLUGIN/skills/$sk/SKILL.md"
  grep_flat "$f" "using-diagrams" && grep_flat "$f" "consider a diagram"
  check $? "$sk carries the consider-a-diagram obligation via using-diagrams"
done

# --- codebase-design companions ----------------------------------------------
# codebase-design states its principle in SKILL.md and carries the mechanics in uppercase
# companion files beside it. Each companion must both exist AND be referenced from SKILL.md:
# a companion nothing links is unreachable, and a SKILL.md reference to a deleted file is a
# dangling pointer. Neither failure trips the frontmatter or ADR-clause checks above, so guard
# both here. PATTERN-MATRIX.md (the selectable GoF matrix) and SHAPE-REVIEW.md (the evaluative
# SOLID + anti-pattern lens) joined DEEPENING.md and DESIGN-IT-TWICE.md when the design-pattern
# catalog landed.
CD="$PLUGIN/skills/codebase-design"
for comp in DEEPENING.md DESIGN-IT-TWICE.md PATTERN-MATRIX.md SHAPE-REVIEW.md; do
  [ -f "$CD/$comp" ]; check $? "codebase-design/$comp exists"
  grep_flat "$CD/SKILL.md" "$comp"; check $? "codebase-design/SKILL.md references $comp"
done

# --- no personal emails (GitHub addresses only) ------------------------------
# Convention: people (stakeholders, sign-off, approvers, authors) are identified by name or
# GitHub handle — never a personal or business email. The only email form allowed anywhere in
# the suite is a GitHub address. interrogating-requirements carries the rule at the capture
# point; this guard enforces it across every tracked skill and command.
grep_flat "$PLUGIN/skills/interrogating-requirements/SKILL.md" "Never record a personal email"
check $? "interrogating-requirements forbids recording a personal email"
personal_email=$(grep -rhoE '[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}' "$PLUGIN/skills" "$PLUGIN/commands" 2>/dev/null | grep -viE '@users\.noreply\.github\.com$' | sort -u)
[ -z "$personal_email" ]; check $? "no personal email address appears in any skill/command (GitHub addresses only)"

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
