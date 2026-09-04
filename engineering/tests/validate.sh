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

REF="$PLUGIN/skills/document/references"
for f in comprehension-gate.md receipt-schema.md; do
  [ -f "$REF/$f" ]; check $? "references/$f exists"
done

if [ -f "$REF/comprehension-gate.md" ]; then
  grep_flat "$REF/comprehension-gate.md" "Restates the signature";       check $? "gate names the restates-the-signature failure"
  grep_flat "$REF/comprehension-gate.md" "Describes mechanism, not purpose"; check $? "gate names the mechanism failure"
  grep_flat "$REF/comprehension-gate.md" "Machine-facing residue";       check $? "gate names the machine-residue failure"
  grep_flat "$REF/comprehension-gate.md" "when in doubt, leave it";      check $? "gate states the leave-it default"
fi

DREF="$PLUGIN/skills/using-diagrams/references/diagram-rules.md"
[ -f "$DREF" ]; check $? "using-diagrams references/diagram-rules.md exists"
if [ -f "$DREF" ]; then
  grep_flat "$DREF" "72 columns including the comment leader"; check $? "diagram rules state the width budget"
fi

if [ -f "$REF/receipt-schema.md" ]; then
  grep_flat "$REF/receipt-schema.md" "lines_after";  check $? "receipt schema documents lines_after"
  grep_flat "$REF/receipt-schema.md" "end_before = start - 1"; check $? "receipt schema documents the insertion form"
fi

# No language table may be reintroduced in the document phase's own files — this is
# vernacular's invariant that it never hard-codes a language/stack table. Scoped to just the
# document skill dir (conductor plus its references) so it checks only the code that owns it.
if find "$PLUGIN/skills/document" -type f -exec grep -liE 'detecting-the-stack|stack-marker' {} + 2>/dev/null | grep -q .; then
  bad "no stack-detection artefact exists in the vernacular docs skills"
else
  ok "no stack-detection artefact exists in the vernacular docs skills"
fi

# --- rewriter (dispatched beat, now a reference under document) ---------------

REWRITER="$PLUGIN/skills/document/references/rewrite-beat.md"
[ -f "$REWRITER" ]; check $? "document/references/rewrite-beat.md exists"

if [ -f "$REWRITER" ]; then
  head -1 "$REWRITER" | grep -qv '^---$'; check $? "rewrite beat is a reference, not a skill (no frontmatter)"
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

COND="$PLUGIN/skills/document/SKILL.md"
[ -f "$COND" ]; check $? "document/SKILL.md exists"

if [ -f "$COND" ]; then
  grep -q '^name: document$' "$COND"; check $? "conductor frontmatter names itself"
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

# --- domain-modeling stays removed -------------------------------------------
# A previously-removed skill; guard that it does not creep back.
[ ! -e "$PLUGIN/skills/domain-modeling" ]; check $? "domain-modeling skill removed"

# --- requesting-code-review stays removed ------------------------------------
# The thin request-a-review wrapper was retired: build applies its review-protocol reference
# per task, and finish applies it once on the whole branch. Guard
# that the wrapper does not creep back.
[ ! -e "$PLUGIN/skills/requesting-code-review" ]; check $? "retired requesting-code-review skill is absent"

# --- diagrams: authoring phases consider a diagram ---------------------------
# using-diagrams is *consider*, not *always draw*, so the obligation does not flood. The
# authoring phases (to-spec, plan) each carry a "consider a diagram" obligation.
UD="$PLUGIN/skills/using-diagrams/SKILL.md"
if [ -f "$UD" ]; then
  grep_flat "$UD" "consider a diagram"; check $? "using-diagrams states the consider-a-diagram authoring obligation"
fi
for sk in to-spec plan; do
  f="$PLUGIN/skills/$sk/SKILL.md"
  grep_flat "$f" "using-diagrams" && grep_flat "$f" "consider a diagram"
  check $? "$sk carries the consider-a-diagram obligation via using-diagrams"
done

# --- codebase-design companions ----------------------------------------------
# codebase-design states its principle in SKILL.md and carries the mechanics in uppercase
# companion files beside it. Each companion must both exist AND be referenced from SKILL.md:
# a companion nothing links is unreachable, and a SKILL.md reference to a deleted file is a
# dangling pointer. Neither failure trips the frontmatter checks above, so guard both here.
# PATTERN-MATRIX.md (the selectable GoF matrix) and SHAPE-REVIEW.md (the evaluative SOLID +
# anti-pattern lens) joined DEEPENING.md and DESIGN-IT-TWICE.md when the design-pattern
# catalog landed.
CD="$PLUGIN/skills/codebase-design"
for comp in DEEPENING.md DESIGN-IT-TWICE.md PATTERN-MATRIX.md SHAPE-REVIEW.md TENANCY-SHARED-DB.md TENANCY-ISOLATED-DB.md; do
  [ -f "$CD/$comp" ]; check $? "codebase-design/$comp exists"
  grep_flat "$CD/SKILL.md" "$comp"; check $? "codebase-design/SKILL.md references $comp"
done

# --- codebase-design tenancy boundary (design-time multi-tenancy prevention) --
# The tenancy companions carry the design-time boundary decision, split by tenancy model the
# same way guardtower's review facets are — but stated by the designer, not auto-detected. The
# shared-DB companion must actually cover the shared-schema failure shape (a caller left free to
# build an unscoped query, ambient vs. explicit tenant context, discriminator mass-assignment,
# cross-tenant reach); the isolated-DB companion must cover the near-disjoint per-tenant-database
# failure shape (where/when the tenant connection is resolved and switched, carrying tenant
# context across async boundaries, central/landlord vs. tenant DB binding) plus the cross-tenant
# reach authorization decision both models share. SKILL.md must wire
# the behavior: determine the model, consult ONLY the matching companion, then force the decision
# when a boundary touches tenant-scoped data.
CDSK="$CD/SKILL.md"
SDB="$CD/TENANCY-SHARED-DB.md"
if [ -f "$SDB" ]; then
  grep_flat "$SDB" "unscoped query"; check $? "TENANCY-SHARED-DB covers where scoping lives so no caller builds an unscoped query"
  grep_flat "$SDB" "ambient"; check $? "TENANCY-SHARED-DB mentions ambient tenant context"
  grep_flat "$SDB" "explicit tenant"; check $? "TENANCY-SHARED-DB mentions explicit tenant context"
  grep_flat "$SDB" "mass-assignable"; check $? "TENANCY-SHARED-DB covers discriminator mass-assignment"
  grep_flat "$SDB" "cross-tenant reach"; check $? "TENANCY-SHARED-DB covers whether cross-tenant reach is permitted"
fi
IDB="$CD/TENANCY-ISOLATED-DB.md"
if [ -f "$IDB" ]; then
  grep_flat "$IDB" "connection is resolved and switched"; check $? "TENANCY-ISOLATED-DB covers where/when the tenant connection is resolved and switched"
  grep_flat "$IDB" "across async boundaries"; check $? "TENANCY-ISOLATED-DB covers carrying tenant context across async boundaries"
  grep_flat "$IDB" "landlord vs. tenant DB binding"; check $? "TENANCY-ISOLATED-DB covers central/landlord vs. tenant DB binding"
  grep_flat "$IDB" "cross-tenant reach"; check $? "TENANCY-ISOLATED-DB covers whether cross-tenant reach is permitted"
fi
grep_flat "$CDSK" "Tenancy boundary"; check $? "codebase-design SKILL.md has a Tenancy boundary section"
grep_flat "$CDSK" "determine the app's tenancy model"; check $? "Tenancy boundary section states determine-model behavior"
grep_flat "$CDSK" "consult only the matching companion"; check $? "Tenancy boundary section states consult-only-the-matching behavior"
grep_flat "$CDSK" "force the tenant-boundary decision"; check $? "Tenancy boundary section states force-when-relevant behavior"

# --- no personal emails (GitHub addresses only) ------------------------------
# Convention: people (stakeholders, sign-off, approvers, authors) are identified by name or
# GitHub handle — never a personal or business email. The only email form allowed anywhere in
# the suite is a GitHub address. interrogating-requirements carries the rule at the capture
# point; this guard enforces it across every tracked skill and command.
grep_flat "$PLUGIN/skills/interrogating-requirements/SKILL.md" "Never record a personal email"
check $? "interrogating-requirements forbids recording a personal email"
personal_email=$(grep -rhoE '[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}' "$PLUGIN/skills" "$PLUGIN/commands" 2>/dev/null | grep -viE '@users\.noreply\.github\.com$' | sort -u)
[ -z "$personal_email" ]; check $? "no personal email address appears in any skill/command (GitHub addresses only)"

# --- entry-point skills and READMEs -------------------------------------------

# vernacular and implement were shallow wrappers adding nothing over document and
# build; they were removed rather than converted, and those two skills are invoked
# directly. Guard both directions: no wrapper skill exists, and the underlying skill still
# carries the behavior the wrapper used to describe (the ref-resolution/two-rules discipline;
# direct-invocation plan-finding).
for wrapper in implement vernacular; do
  [ ! -e "$PLUGIN/skills/$wrapper" ]; check $? "skills/$wrapper does not exist (was a shallow wrapper)"
done
CDB="$PLUGIN/skills/document/SKILL.md"
grep_flat "$CDB" "never authors a docblock"; check $? "document states the prose-only rule directly"

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

# No slash-commands remain: the plugin's entry points are all skills now (decoupling from
# Claude-specific command syntax). Assert nothing survives under commands/, and that the root
# README makes no stale slash-command count claim.
cmd_actual=$(find "$PLUGIN/commands" -name '*.md' 2>/dev/null | wc -l | tr -d ' ')
[ "$cmd_actual" = 0 ]; check $? "no slash-commands remain on disk (all entry points are skills)"
if grep -qE '[0-9]+ slash commands' "$ROOT/README.md"; then false; else true; fi
check $? "root README makes no stale slash-command count claim"

# --- plan review phase (arch-lens reference) ------------------------------------
# plan makes each task sketch its interface, then runs its arch-lens review BEFORE the plan
# gate: an architecture lens (codebase-design in review mode) plus a one-off-data-structure scan
# that flags each candidate to the human. The review folded from a skill into a reference the plan
# conductor loads. Guard the reference exists, the seam is wired before the gate, and
# codebase-design carries the review mode the arch-lens review depends on.
RP="$PLUGIN/skills/plan/references/arch-lens.md"
[ -f "$RP" ]; check $? "plan/references/arch-lens.md exists"
if [ -f "$RP" ]; then
  head -1 "$RP" | grep -qv '^---$'; check $? "arch-lens is a reference, not a skill (no frontmatter)"
  grep_flat "$RP" "codebase-design"; check $? "arch-lens review runs the architecture lens via codebase-design"
  # The one-off flags are put to the human as an explicit choice; the question mechanism is left to
  # the harness, so guard the tool-agnostic phrasing, not a harness-specific question tool.
  grep_flat "$RP" "explicit choice"; check $? "arch-lens review flags one-off data structures as an explicit choice"
  ! grep_flat "$RP" "AskUserQuestion"; check $? "arch-lens review names no harness-specific question tool"
fi
WP="$PLUGIN/skills/plan/SKILL.md"
grep_flat "$WP" "arch-lens.md"; check $? "plan loads the arch-lens review reference"
grep_flat "$WP" "Interfaces block"; check $? "plan has tasks carry a code-sketch Interfaces block"
# The review phase must sit before the plan gate: the arch-lens load appears earlier in the
# file than the plan-approval marker the gate mints.
awk '/arch-lens/{r=NR} /plan\/APPROVED\.md/{if(!g)g=NR} END{exit !(r && g && r < g)}' "$WP"
check $? "plan runs the arch-lens review before the plan gate"

# codebase-design's review mode is what the arch-lens review leans on; SHAPE-REVIEW names the one-off shape.
grep_flat "$CD/SKILL.md" "Review mode"; check $? "codebase-design carries a review mode"
grep_flat "$CD/SHAPE-REVIEW.md" "one-off data structure"; check $? "SHAPE-REVIEW names the reinvented data-structure smell"

# --- build tracks the plan as todos --------------------------------
# The unattended build stays legible by mirroring the plan into a todo list: one todo per task,
# marked in_progress/completed in lockstep with the plan's checkboxes. The todo mechanism is left
# to the harness (mirroring superpowers), so this guards the tool-agnostic phrasing, not a tool
# name — a check tied to Claude Code's TodoWrite would tether the skill to one harness.
EP="$PLUGIN/skills/build/SKILL.md"
grep_flat "$EP" "one todo per task"; check $? "build seeds the plan into a todo list"
! grep_flat "$EP" "TodoWrite"; check $? "build names no harness-specific todo tool"
grep_flat "$EP" "in_progress"; check $? "build marks a task in_progress as it starts"

exit $fail
