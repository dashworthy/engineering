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

# --- review lenses (orchestrator + three lens references) --------------------
# review-protocol.md is an orchestrator that fans out one subagent per lens; each lens's
# own judgement lives in its own reference under references/lenses/.
LENSES="$PLUGIN/skills/build/references/lenses"
for lens in standards spec eli5; do
  [ -f "$LENSES/$lens.md" ]; check $? "review lens $lens.md exists"
done
RP="$PLUGIN/skills/build/references/review-protocol.md"
[ -f "$RP" ]; check $? "review-protocol.md exists (orchestrator)"
if [ -f "$RP" ]; then
  for lens in standards spec eli5; do
    grep_flat "$RP" "$lens"; check $? "orchestrator names the $lens lens"
  done
  grep_flat "$RP" "using-parallel-agents"; check $? "orchestrator fans out via using-parallel-agents"
  grep_flat "$RP" "inline"; check $? "orchestrator keeps the small-diff inline floor"
fi
if [ -f "$LENSES/eli5.md" ]; then
  grep_flat "$LENSES/eli5.md" "when in doubt, leave it"; check $? "eli5 lens keeps the untouchable-prose rule"
  grep_flat "$LENSES/eli5.md" "public symbol"; check $? "eli5 lens flags a missing docblock on a public symbol"
  grep_flat "$LENSES/eli5.md" "never author, edit, or propose"; check $? "eli5 lens is prose-only (never structured tags)"
fi

# --- references --------------------------------------------------------------

DREF="$PLUGIN/skills/using-diagrams/references/diagram-rules.md"
[ -f "$DREF" ]; check $? "using-diagrams references/diagram-rules.md exists"
if [ -f "$DREF" ]; then
  grep_flat "$DREF" "72 columns including the comment leader"; check $? "diagram rules state the width budget"
fi

# --- document phase stays retired --------------------------------------------
# The document (vernacular) phase and its byte-proof were retired: the eli5 review lens now
# owns docblock quality, surfacing findings the build loop fixes in the diff. Guard that the
# skill, its references, and the reconcile proof do not creep back.
[ ! -e "$PLUGIN/skills/document" ]; check $? "retired document skill dir is absent"
[ ! -e "$PLUGIN/scripts/reconcile.py" ]; check $? "retired reconcile.py proof is absent"

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
# The spec skill and plan each carry it.
for f in "$PLUGIN/skills/spec/SKILL.md" "$PLUGIN/skills/plan/SKILL.md"; do
  grep_flat "$f" "using-diagrams" && grep_flat "$f" "consider a diagram"
  check $? "$(basename "$(dirname "$f")")/$(basename "$f") carries the consider-a-diagram obligation via using-diagrams"
done

# --- using-codebase-design companions ----------------------------------------------
# using-codebase-design states its principle in SKILL.md and carries the mechanics in uppercase
# companion files beside it. Each companion must both exist AND be referenced from SKILL.md:
# a companion nothing links is unreachable, and a SKILL.md reference to a deleted file is a
# dangling pointer. Neither failure trips the frontmatter checks above, so guard both here.
# PATTERN-MATRIX.md (the selectable GoF matrix) and SHAPE-REVIEW.md (the evaluative SOLID +
# anti-pattern lens) joined DEEPENING.md and DESIGN-IT-TWICE.md when the design-pattern
# catalog landed.
# using-codebase-design is a shared skill; its shape lenses live in using-codebase-design/SKILL.md and its
# uppercase companions under using-codebase-design/references/.
CD="$PLUGIN/skills/using-codebase-design/references"
CDSK="$PLUGIN/skills/using-codebase-design/SKILL.md"
for comp in DEEPENING.md DESIGN-IT-TWICE.md PATTERN-MATRIX.md SHAPE-REVIEW.md TENANCY-SHARED-DB.md TENANCY-ISOLATED-DB.md; do
  [ -f "$CD/$comp" ]; check $? "using-codebase-design/references/$comp exists"
  grep_flat "$CDSK" "$comp"; check $? "using-codebase-design SKILL.md references $comp"
done

# --- using-codebase-design tenancy boundary (design-time multi-tenancy prevention) --
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
grep_flat "$CDSK" "Tenancy boundary"; check $? "using-codebase-design SKILL.md has a Tenancy boundary section"
grep_flat "$CDSK" "determine the app's tenancy model"; check $? "Tenancy boundary section states determine-model behavior"
grep_flat "$CDSK" "consult only the matching companion"; check $? "Tenancy boundary section states consult-only-the-matching behavior"
grep_flat "$CDSK" "force the tenant-boundary decision"; check $? "Tenancy boundary section states force-when-relevant behavior"

# --- no personal emails (GitHub addresses only) ------------------------------
# Convention: people (stakeholders, sign-off, approvers, authors) are identified by name or
# GitHub handle — never a personal or business email. The only email form allowed anywhere in
# the suite is a GitHub address. interrogating-requirements carries the rule at the capture
# point; this guard enforces it across every tracked skill and command.
grep_flat "$PLUGIN/references/interrogating-requirements.md" "Never record a personal email"
check $? "interrogating-requirements forbids recording a personal email"
personal_email=$(grep -rhoE '[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}' "$PLUGIN/skills" "$PLUGIN/references" "$PLUGIN/commands" 2>/dev/null | grep -viE '@users\.noreply\.github\.com$' | sort -u)
[ -z "$personal_email" ]; check $? "no personal email address appears in any skill/command (GitHub addresses only)"

# --- entry-point skills and READMEs -------------------------------------------

# vernacular and implement were shallow wrappers; they were removed rather than converted.
# (The document phase vernacular once wrapped is itself now retired — see "document phase stays
# retired" above.) Guard that neither wrapper dir creeps back.
for wrapper in implement vernacular; do
  [ ! -e "$PLUGIN/skills/$wrapper" ]; check $? "skills/$wrapper does not exist (was a shallow wrapper)"
done

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
# gate: an architecture lens (using-codebase-design in review mode) plus a one-off-data-structure scan
# that flags each candidate to the human. The review folded from a skill into a reference the plan
# conductor loads. Guard the reference exists, the seam is wired before the gate, and
# using-codebase-design carries the review mode the arch-lens review depends on.
RP="$PLUGIN/skills/plan/references/arch-lens.md"
[ -f "$RP" ]; check $? "plan/references/arch-lens.md exists"
if [ -f "$RP" ]; then
  head -1 "$RP" | grep -qv '^---$'; check $? "arch-lens is a reference, not a skill (no frontmatter)"
  grep_flat "$RP" "using-codebase-design"; check $? "arch-lens review runs the architecture lens via engineering:using-codebase-design"
  # The one-off flags are put to the human as an explicit choice; the question mechanism is left to
  # the harness, so guard the tool-agnostic phrasing, not a harness-specific question tool.
  grep_flat "$RP" "explicit choice"; check $? "arch-lens review flags one-off data structures as an explicit choice"
  ! grep_flat "$RP" "AskUserQuestion"; check $? "arch-lens review names no harness-specific question tool"
fi
WP="$PLUGIN/skills/plan/SKILL.md"
grep_flat "$WP" "arch-lens.md"; check $? "plan loads the arch-lens review reference"
grep_flat "$WP" "Interfaces block"; check $? "plan has tasks carry a code-sketch Interfaces block"
# Anti-deferral: plan creation never asks the user to defer requested work, and the self-review
# pass checks that no requested work was silently dropped from the plan.
grep_flat "$WP" "deferral menu dropped on the user"; check $? "plan creation does not ask the user to defer requested work"
grep_flat "$WP" "No deferred request"; check $? "plan self-review checks for silently deferred requested work"
grep_flat "$WP" "refusing-deferral"; check $? "plan names engineering:refusing-deferral"
# The review phase must sit before the plan gate: the arch-lens load appears earlier in the
# file than the plan-approval marker the gate mints.
awk '/arch-lens/{r=NR} /plan\/APPROVED\.md/{if(!g)g=NR} END{exit !(r && g && r < g)}' "$WP"
check $? "plan runs the arch-lens review before the plan gate"

# using-codebase-design's review mode is what the arch-lens review leans on; SHAPE-REVIEW names the one-off shape.
grep_flat "$CDSK" "Review mode"; check $? "using-codebase-design carries a review mode"
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

# --- one spec, one plan (no splitting) -----------------------------------------
# A run yields exactly one spec and one plan. The plan-set fan-out and brainstorming's
# "too large to fit one spec" decomposition were removed; oversized scope is escalated, not
# split. Guard the invariant positively and lock the removed prose out so it can't creep back.
grep_flat "$WP" "One spec, one plan"; check $? "plan states the one-spec-one-plan invariant"
! grep_flat "$WP" "Splitting into a plan set"; check $? "plan carries no plan-set splitting section"
! grep_flat "$WP" "write a plan set"; check $? "plan never instructs writing a plan set"
BR="$PLUGIN/skills/brainstorming/SKILL.md"
! grep_flat "$BR" "too large to fit one spec"; check $? "brainstorming no longer decomposes an oversized spec"

# --- spec carries an ELI5 (plain-language summary) -----------------------------
# Every spec renders a §0 ELI5 up top: a jargon-free synthesis of the whole spec for easy
# consumption. Guard the format section exists and the spec conductor knows it is synthesized.
SF="$PLUGIN/skills/spec/references/SPEC-FORMAT.md"
[ -f "$SF" ]; check $? "spec/references/SPEC-FORMAT.md exists"
grep_flat "$SF" "## 0. ELI5"; check $? "SPEC-FORMAT carries the section-0 ELI5 summary"
SSK="$PLUGIN/skills/spec/SKILL.md"
grep_flat "$SSK" "ELI5"; check $? "spec conductor names the ELI5 section"

# --- code-review: opt-in deep review with three findings routes --------------
# The deep-review orchestrator folded in from guardtower is report-only, but after reconciling it
# puts the fate of the findings to the human: keep them local, post them to the PR, or hand them to
# the fix pipeline. Guard the skill exists, still edits nothing, and wires all three routes — the
# hand-off target most of all, since that is the piece this fold added.
CR="$PLUGIN/skills/code-review/SKILL.md"
[ -f "$CR" ]; check $? "skills/code-review/SKILL.md exists"
if [ -f "$CR" ]; then
  grep -q '^name: code-review$' "$CR"; check $? "code-review frontmatter names itself"
  grep_flat "$CR" "run-context.sh"; check $? "code-review derives its run directory via run-context.sh"
  grep_flat "$CR" ".engineering/<run>/"; check $? "code-review writes under the engineering run directory"
  ! grep_flat "$CR" ".guardtower"; check $? "code-review leaves no .guardtower path behind"
  grep_flat "$CR" "Report locally"; check $? "code-review offers the report-locally route"
  grep_flat "$CR" "Post to the PR"; check $? "code-review offers the post-to-PR route"
  grep_flat "$CR" "engineering:receiving-code-review"; check $? "code-review hands findings off to receiving-code-review"
  grep_flat "$CR" "never edits code"; check $? "code-review states it never edits code even when routing findings onward"
  # The routing choice is left to the harness, like the plan and receiving-code-review gates — no
  # skill may hard-code Claude Code's question tool.
  ! grep_flat "$CR" "AskUserQuestion"; check $? "code-review names no harness-specific question tool"
fi

exit $fail
