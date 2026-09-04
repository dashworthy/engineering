#!/bin/sh
# Structural and behavioural validation for the guardtower plugin.
# POSIX sh. Uses python3 (stdlib only) for JSON. Never requires jq.
# Run from anywhere: sh guardtower/tests/validate.sh

ROOT=$(cd "$(dirname "$0")/../.." && pwd)
PLUGIN="$ROOT/guardtower"
fail=0

ok()   { printf 'ok   - %s\n' "$1"; }
bad()  { printf 'FAIL - %s\n' "$1"; fail=1; }
check(){ if [ "$1" -eq 0 ]; then ok "$2"; else bad "$2"; fi }

# Match a prose anchor regardless of how the source is line-wrapped. `--` before the pattern is
# load-bearing: without it grep parses an anchor beginning with a hyphen as its own options.
grep_flat() {  # grep_flat <file> <literal phrase>
  tr '\n' ' ' < "$1" | tr -s ' ' | grep -qF -- "$2"
}

# ============================================================================
# Task 1 — scaffold + marketplace/README wiring
# ============================================================================

# --- manifest ---------------------------------------------------------------

[ -f "$PLUGIN/.claude-plugin/plugin.json" ]; check $? "plugin.json exists"

if [ -f "$PLUGIN/.claude-plugin/plugin.json" ]; then
  python3 - "$PLUGIN/.claude-plugin/plugin.json" <<'PY'
import json,sys,re
d=json.load(open(sys.argv[1]))
required={"name","description","version","author","license"}
missing=required-set(d)
assert not missing, f"plugin.json missing keys: {sorted(missing)}"
assert d["name"]=="guardtower", f'name is {d["name"]!r}, expected "guardtower"'
assert re.fullmatch(r"\d+\.\d+\.\d+", str(d["version"])), f'version {d["version"]!r} is not semver'
assert d["license"]=="MIT", f'license is {d["license"]!r}, expected "MIT"'
PY
  check $? "plugin.json is well-formed"
fi

# --- marketplace registration -----------------------------------------------

if [ -f "$ROOT/.claude-plugin/marketplace.json" ]; then
  python3 - "$ROOT/.claude-plugin/marketplace.json" "$PLUGIN/.claude-plugin/plugin.json" <<'PY'
import json,sys
d=json.load(open(sys.argv[1]))
names=[p["name"] for p in d["plugins"]]
assert "guardtower" in names, f"guardtower not registered; found {names}"
g=[p for p in d["plugins"] if p["name"]=="guardtower"][0]
assert g["source"]=="./guardtower", f'source is {g["source"]!r}'
pv=json.load(open(sys.argv[2]))["version"]
assert g["version"]==pv, f'marketplace version {g["version"]!r} != plugin.json {pv!r}'
PY
  check $? "marketplace guardtower entry matches plugin.json"
else
  bad "root marketplace.json exists"
fi

# --- READMEs ----------------------------------------------------------------

[ -f "$PLUGIN/README.md" ]; check $? "guardtower/README.md exists"
[ -f "$ROOT/README.md" ] && grep -q "guardtower" "$ROOT/README.md"; check $? "root README names guardtower"

# ============================================================================
# Task 3 — reviewing orchestrator skill
# ============================================================================

ORCH="$PLUGIN/skills/reviewing/SKILL.md"
[ -f "$ORCH" ]; check $? "reviewing/SKILL.md exists"

if [ -f "$ORCH" ]; then
  head -1 "$ORCH" | grep -q '^---$'; check $? "reviewing has frontmatter"
  grep -q '^name: reviewing$' "$ORCH"; check $? "reviewing frontmatter names itself"
  # description carries discovery triggers
  awk '/^description:/{print; exit}' "$ORCH" | grep -qi "review"; check $? "reviewing description carries a review trigger"
  awk '/^description:/{print; exit}' "$ORCH" | grep -qi "guardtower"; check $? "reviewing description names guardtower"
  # orchestrator responsibilities named in the body
  # The facet menu is a structured multi-select choice; the question mechanism is left to the
  # harness, so guard the tool-agnostic phrasing, not a harness-specific question tool.
  grep_flat "$ORCH" "multi-select choice"; check $? "reviewing runs the facet menu as a multi-select choice"
  ! grep_flat "$ORCH" "AskUserQuestion"; check $? "reviewing names no harness-specific question tool"
  grep_flat "$ORCH" "pre-checked"; check $? "reviewing states the core facets are pre-checked"
  grep_flat "$ORCH" ".guardtower/"; check $? "reviewing writes under .guardtower/"
  grep_flat "$ORCH" "dispatching-parallel-agents"; check $? "reviewing fans out via dispatching-parallel-agents"
  # Each dispatched facet is tracked as its own todo (one seam, one item) so the human sees what was
  # dispatched and what completed. The todo mechanism is left to the harness (mirroring executing-plans),
  # so guard the tool-agnostic phrasing, not a harness-specific tool name.
  grep_flat "$ORCH" "one todo per selected facet"; check $? "reviewing seeds a todo per selected facet"
  ! grep_flat "$ORCH" "TodoWrite"; check $? "reviewing names no harness-specific todo tool"
  grep_flat "$ORCH" "in_progress"; check $? "reviewing marks a facet in_progress as it is dispatched"
  grep_flat "$ORCH" "reconcil"; check $? "reviewing reconciles across facets"
  grep_flat "$ORCH" "report-only"; check $? "reviewing states it is report-only"
  # references linked one level deep
  grep_flat "$ORCH" "references/facet-contract.md"; check $? "reviewing links references/facet-contract.md"
  grep_flat "$ORCH" "references/hard-stops.md"; check $? "reviewing links references/hard-stops.md"
fi

CONTRACT="$PLUGIN/skills/reviewing/references/facet-contract.md"
[ -f "$CONTRACT" ]; check $? "reviewing/references/facet-contract.md exists"
if [ -f "$CONTRACT" ]; then
  for field in change_ref artifact_path relevance findings severity confidence top_n floor; do
    grep_flat "$CONTRACT" "$field"; check $? "facet-contract names the $field field"
  done
fi

STOPS="$PLUGIN/skills/reviewing/references/hard-stops.md"
[ -f "$STOPS" ]; check $? "reviewing/references/hard-stops.md exists"
if [ -f "$STOPS" ]; then
  grep_flat "$STOPS" "Relevance gate"; check $? "hard-stops names the relevance gate"
  grep_flat "$STOPS" "Top-N"; check $? "hard-stops names the top-N severity cap"
  grep_flat "$STOPS" "floor"; check $? "hard-stops names the confidence/severity floor"
  grep_flat "$STOPS" "at the source"; check $? "hard-stops states facets self-enforce at the source"
fi

# ============================================================================
# Task 4 — /guardtower command
# ============================================================================

CMD="$PLUGIN/commands/guardtower.md"
[ -f "$CMD" ]; check $? "commands/guardtower.md exists"
if [ -f "$CMD" ]; then
  head -1 "$CMD" | grep -q '^---$'; check $? "guardtower command has frontmatter"
  grep -q '^description:' "$CMD"; check $? "guardtower command frontmatter has a description"
  grep -q '^argument-hint:' "$CMD"; check $? "guardtower command frontmatter has an argument-hint"
  grep_flat "$CMD" "guardtower:reviewing"; check $? "guardtower command invokes the reviewing skill"
  grep_flat "$CMD" "CLAUDE_PLUGIN_ROOT"; check $? "guardtower command resolves scripts via CLAUDE_PLUGIN_ROOT"
fi

# ============================================================================
# Task 5 — reviewing-security facet skill
# ============================================================================

SEC="$PLUGIN/skills/reviewing-security/SKILL.md"
[ -f "$SEC" ]; check $? "reviewing-security/SKILL.md exists"
if [ -f "$SEC" ]; then
  head -1 "$SEC" | grep -q '^---$'; check $? "reviewing-security has frontmatter"
  grep -q '^name: reviewing-security$' "$SEC"; check $? "reviewing-security frontmatter names itself"
  desc=$(awk '/^description:/{print; exit}' "$SEC")
  printf '%s' "$desc" | grep -qi "security"; check $? "reviewing-security description carries a security trigger"
  printf '%s' "$desc" | grep -qi "OWASP"; check $? "reviewing-security description names OWASP"
  printf '%s' "$desc" | grep -qi "authorization"; check $? "reviewing-security description names authorization"
  # self-limiting behavior, at the source
  grep_flat "$SEC" "relevance gate"; check $? "reviewing-security runs the relevance gate"
  grep_flat "$SEC" "before any lens work"; check $? "reviewing-security short-circuits before lens work"
  grep_flat "$SEC" "top_n"; check $? "reviewing-security applies the top-N cap"
  grep_flat "$SEC" "floor"; check $? "reviewing-security applies the confidence/severity floor"
  grep_flat "$SEC" "report-only"; check $? "reviewing-security is report-only"
  # writes the artifact per the contract
  grep_flat "$SEC" "findings.md"; check $? "reviewing-security writes findings.md"
  grep_flat "$SEC" "enforced"; check $? "reviewing-security checks authorization is enforced, not assumed"
  grep_flat "$SEC" "references/owasp-checklist.md"; check $? "reviewing-security links references/owasp-checklist.md"
fi

OWASP="$PLUGIN/skills/reviewing-security/references/owasp-checklist.md"
[ -f "$OWASP" ]; check $? "reviewing-security/references/owasp-checklist.md exists"
if [ -f "$OWASP" ]; then
  grep_flat "$OWASP" "Broken Access Control"; check $? "owasp-checklist covers Broken Access Control"
  grep_flat "$OWASP" "Injection"; check $? "owasp-checklist covers Injection"
  grep_flat "$OWASP" "enforced, not assumed"; check $? "owasp-checklist states authorization enforced, not assumed"
fi

# ============================================================================
# Spec 2 Task 1 — reviewing-technical facet skill
# ============================================================================

TECH="$PLUGIN/skills/reviewing-technical/SKILL.md"
[ -f "$TECH" ]; check $? "reviewing-technical/SKILL.md exists"
if [ -f "$TECH" ]; then
  head -1 "$TECH" | grep -q '^---$'; check $? "reviewing-technical has frontmatter"
  grep -q '^name: reviewing-technical$' "$TECH"; check $? "reviewing-technical frontmatter names itself"
  desc=$(awk '/^description:/{print; exit}' "$TECH")
  printf '%s' "$desc" | grep -qi "technical"; check $? "reviewing-technical description carries a technical trigger"
  printf '%s' "$desc" | grep -qi "Novelty"; check $? "reviewing-technical description points reuse to the Novelty facet"
  printf '%s' "$desc" | grep -qiE "inefficient|query"; check $? "reviewing-technical description names inefficiency/queries"
  # self-limiting behavior, at the source
  grep_flat "$TECH" "relevance gate"; check $? "reviewing-technical runs the relevance gate"
  grep_flat "$TECH" "before any lens work"; check $? "reviewing-technical short-circuits before lens work"
  grep_flat "$TECH" "top_n"; check $? "reviewing-technical applies the top-N cap"
  grep_flat "$TECH" "floor"; check $? "reviewing-technical applies the confidence/severity floor"
  grep_flat "$TECH" "report-only"; check $? "reviewing-technical is report-only"
  grep_flat "$TECH" "findings.md"; check $? "reviewing-technical writes findings.md"
  # analysis boundary stated inline (no ADR pointer — the plugin ships without docs/adr/)
  grep_flat "$TECH" "no proactive"; check $? "reviewing-technical states its analysis boundary inline"
  grep_flat "$TECH" "references/technical-checklist.md"; check $? "reviewing-technical links references/technical-checklist.md"
fi

TCL="$PLUGIN/skills/reviewing-technical/references/technical-checklist.md"
[ -f "$TCL" ]; check $? "reviewing-technical/references/technical-checklist.md exists"
if [ -f "$TCL" ]; then
  grep_flat "$TCL" "Inefficient data access"; check $? "technical-checklist covers inefficient data access"
  grep_flat "$TCL" "Correctness-scoped best practices"; check $? "technical-checklist covers correctness-scoped best practices"
  ! grep_flat "$TCL" "Reuse over reinvention"; check $? "technical-checklist no longer owns reuse over reinvention (moved to Novelty)"
  grep_flat "$TCL" "not a finding"; check $? "technical-checklist states what is not a finding"
  grep_flat "$TCL" "no proactive"; check $? "technical-checklist states the no-proactive-scan boundary"
fi

# --- orchestrator wiring: technical is live, not "coming soon" ---------------
if [ -f "$ORCH" ]; then
  if grep -q 'reviewing-technical' "$ORCH"; then
    if grep 'reviewing-technical' "$ORCH" | grep -q 'coming soon'; then
      bad "reviewing menu wires reviewing-technical (not coming soon)"
    else
      ok "reviewing menu wires reviewing-technical (not coming soon)"
    fi
  else
    bad "reviewing menu wires reviewing-technical (not coming soon)"
  fi
fi

# ============================================================================
# Facet — reviewing-novelty facet skill (core; reuse over reinvention)
# ============================================================================

NOV="$PLUGIN/skills/reviewing-novelty/SKILL.md"
[ -f "$NOV" ]; check $? "reviewing-novelty/SKILL.md exists"
if [ -f "$NOV" ]; then
  head -1 "$NOV" | grep -q '^---$'; check $? "reviewing-novelty has frontmatter"
  grep -q '^name: reviewing-novelty$' "$NOV"; check $? "reviewing-novelty frontmatter names itself"
  desc=$(awk '/^description:/{print; exit}' "$NOV")
  printf '%s' "$desc" | grep -qiE "novelty|reuse|reinvent"; check $? "reviewing-novelty description carries a novelty/reuse trigger"
  printf '%s' "$desc" | grep -qiE "framework|standard library|library|module"; check $? "reviewing-novelty description names the source of the existing capability"
  printf '%s' "$desc" | grep -qiE "provides|already"; check $? "reviewing-novelty description names that something already provides it"
  # self-limiting behavior, at the source
  grep_flat "$NOV" "relevance gate"; check $? "reviewing-novelty runs the relevance gate"
  grep_flat "$NOV" "before any lens work"; check $? "reviewing-novelty short-circuits before lens work"
  grep_flat "$NOV" "top_n"; check $? "reviewing-novelty applies the top-N cap"
  grep_flat "$NOV" "floor"; check $? "reviewing-novelty applies the confidence/severity floor"
  grep_flat "$NOV" "report-only"; check $? "reviewing-novelty is report-only"
  grep_flat "$NOV" "findings.md"; check $? "reviewing-novelty writes findings.md"
  # analysis boundary stated inline (no ADR pointer — the plugin ships without docs/adr/)
  grep_flat "$NOV" "no proactive"; check $? "reviewing-novelty states its analysis boundary inline"
  # the defining constraint: it flags duplication, not newness for its own sake
  grep_flat "$NOV" "warranted novelty"; check $? "reviewing-novelty spares warranted novelty (duplication is the defect, not newness)"
  grep_flat "$NOV" "references/novelty-checklist.md"; check $? "reviewing-novelty links references/novelty-checklist.md"
fi

NCL="$PLUGIN/skills/reviewing-novelty/references/novelty-checklist.md"
[ -f "$NCL" ]; check $? "reviewing-novelty/references/novelty-checklist.md exists"
if [ -f "$NCL" ]; then
  grep_flat "$NCL" "Reinvented framework capability"; check $? "novelty-checklist covers a reinvented framework capability"
  grep_flat "$NCL" "Reinvented standard-library primitive"; check $? "novelty-checklist covers a reinvented standard-library primitive"
  grep_flat "$NCL" "Reinvented library API"; check $? "novelty-checklist covers a reinvented library API"
  grep_flat "$NCL" "Reinvented already-imported capability"; check $? "novelty-checklist covers a reinvented already-imported capability"
  grep_flat "$NCL" "Warranted novelty"; check $? "novelty-checklist states warranted novelty is not a finding"
  grep_flat "$NCL" "not a finding"; check $? "novelty-checklist states what is not a finding"
  grep_flat "$NCL" "no proactive"; check $? "novelty-checklist states the no-proactive-scan boundary"
fi

# --- orchestrator wiring: novelty is live, not "coming soon" -----------------
if [ -f "$ORCH" ]; then
  if grep -q 'reviewing-novelty' "$ORCH"; then
    if grep 'reviewing-novelty' "$ORCH" | grep -q 'coming soon'; then
      bad "reviewing menu wires reviewing-novelty (not coming soon)"
    else
      ok "reviewing menu wires reviewing-novelty (not coming soon)"
    fi
  else
    bad "reviewing menu wires reviewing-novelty (not coming soon)"
  fi
fi

# --- README lists the novelty facet -----------------------------------------
if [ -f "$PLUGIN/README.md" ]; then
  grep_flat "$PLUGIN/README.md" "Novelty"; check $? "README lists the novelty facet"
fi

# ============================================================================
# Spec 2 Task 2 — reviewing-architectural facet skill
# ============================================================================

ARCH="$PLUGIN/skills/reviewing-architectural/SKILL.md"
[ -f "$ARCH" ]; check $? "reviewing-architectural/SKILL.md exists"
if [ -f "$ARCH" ]; then
  head -1 "$ARCH" | grep -q '^---$'; check $? "reviewing-architectural has frontmatter"
  grep -q '^name: reviewing-architectural$' "$ARCH"; check $? "reviewing-architectural frontmatter names itself"
  desc=$(awk '/^description:/{print; exit}' "$ARCH")
  printf '%s' "$desc" | grep -qi "architectur"; check $? "reviewing-architectural description carries an architecture trigger"
  printf '%s' "$desc" | grep -qiE "coupling|dependency"; check $? "reviewing-architectural description names coupling/dependency"
  # self-limiting behavior, at the source
  grep_flat "$ARCH" "relevance gate"; check $? "reviewing-architectural runs the relevance gate"
  grep_flat "$ARCH" "before any lens work"; check $? "reviewing-architectural short-circuits before lens work"
  grep_flat "$ARCH" "moves a boundary"; check $? "reviewing-architectural gate fires only when the change moves a boundary"
  grep_flat "$ARCH" "top_n"; check $? "reviewing-architectural applies the top-N cap"
  grep_flat "$ARCH" "floor"; check $? "reviewing-architectural applies the confidence/severity floor"
  grep_flat "$ARCH" "report-only"; check $? "reviewing-architectural is report-only"
  grep_flat "$ARCH" "findings.md"; check $? "reviewing-architectural writes findings.md"
  # analysis boundary stated inline (no ADR pointer — the plugin ships without docs/adr/)
  grep_flat "$ARCH" "no proactive"; check $? "reviewing-architectural states its analysis boundary inline"
  grep_flat "$ARCH" "references/architectural-checklist.md"; check $? "reviewing-architectural links references/architectural-checklist.md"
fi

ACL="$PLUGIN/skills/reviewing-architectural/references/architectural-checklist.md"
[ -f "$ACL" ]; check $? "reviewing-architectural/references/architectural-checklist.md exists"
if [ -f "$ACL" ]; then
  grep_flat "$ACL" "Dependency-direction"; check $? "architectural-checklist covers dependency-direction/coupling"
  grep_flat "$ACL" "Responsibility"; check $? "architectural-checklist covers responsibility/cohesion creep"
  grep_flat "$ACL" "Duplicated abstraction"; check $? "architectural-checklist covers duplicated abstraction"
  grep_flat "$ACL" "Leaky abstraction"; check $? "architectural-checklist covers leaky abstraction"
  grep_flat "$ACL" "not a finding"; check $? "architectural-checklist states what is not a finding"
  grep_flat "$ACL" "the diff"; check $? "architectural-checklist scopes to diff-visible defects"
  grep_flat "$ACL" "no proactive"; check $? "architectural-checklist states the no-repo-scan boundary"
fi

# --- orchestrator wiring: architectural is live, not "coming soon" -----------
if [ -f "$ORCH" ]; then
  if grep -q 'reviewing-architectural' "$ORCH"; then
    if grep 'reviewing-architectural' "$ORCH" | grep -q 'coming soon'; then
      bad "reviewing menu wires reviewing-architectural (not coming soon)"
    else
      ok "reviewing menu wires reviewing-architectural (not coming soon)"
    fi
  else
    bad "reviewing menu wires reviewing-architectural (not coming soon)"
  fi
fi

# ============================================================================
# Spec 3 Task 1 — reviewing-error-handling facet skill
# ============================================================================

EH="$PLUGIN/skills/reviewing-error-handling/SKILL.md"
[ -f "$EH" ]; check $? "reviewing-error-handling/SKILL.md exists"
if [ -f "$EH" ]; then
  head -1 "$EH" | grep -q '^---$'; check $? "reviewing-error-handling has frontmatter"
  grep -q '^name: reviewing-error-handling$' "$EH"; check $? "reviewing-error-handling frontmatter names itself"
  desc=$(awk '/^description:/{print; exit}' "$EH")
  printf '%s' "$desc" | grep -qiE "error.handling|silent failure"; check $? "reviewing-error-handling description carries an error-handling trigger"
  printf '%s' "$desc" | grep -qi "swallow"; check $? "reviewing-error-handling description names swallowed errors"
  printf '%s' "$desc" | grep -qiE "resilience|fallback"; check $? "reviewing-error-handling description names resilience/fallback"
  # self-limiting behavior, at the source
  grep_flat "$EH" "relevance gate"; check $? "reviewing-error-handling runs the relevance gate"
  grep_flat "$EH" "before any lens work"; check $? "reviewing-error-handling short-circuits before lens work"
  grep_flat "$EH" "top_n"; check $? "reviewing-error-handling applies the top-N cap"
  grep_flat "$EH" "floor"; check $? "reviewing-error-handling applies the confidence/severity floor"
  grep_flat "$EH" "report-only"; check $? "reviewing-error-handling is report-only"
  grep_flat "$EH" "findings.md"; check $? "reviewing-error-handling writes findings.md"
  # analysis boundary stated inline (no ADR pointer — the plugin ships without docs/adr/)
  grep_flat "$EH" "no proactive"; check $? "reviewing-error-handling states its analysis boundary inline"
  grep_flat "$EH" "references/error-handling-checklist.md"; check $? "reviewing-error-handling links references/error-handling-checklist.md"
fi

EHCL="$PLUGIN/skills/reviewing-error-handling/references/error-handling-checklist.md"
[ -f "$EHCL" ]; check $? "reviewing-error-handling/references/error-handling-checklist.md exists"
if [ -f "$EHCL" ]; then
  grep_flat "$EHCL" "Swallowed"; check $? "error-handling-checklist covers swallowed/empty catch"
  grep_flat "$EHCL" "Over-broad catch"; check $? "error-handling-checklist covers over-broad catch"
  grep_flat "$EHCL" "Masking fallback"; check $? "error-handling-checklist covers masking fallback"
  grep_flat "$EHCL" "Dropped"; check $? "error-handling-checklist covers dropped propagation"
  grep_flat "$EHCL" "Ignored"; check $? "error-handling-checklist covers ignored rejection/return-code"
  grep_flat "$EHCL" "not a finding"; check $? "error-handling-checklist states what is not a finding"
fi

# --- orchestrator wiring: error-handling is live, not "coming soon" -----------
if [ -f "$ORCH" ]; then
  if grep -q 'reviewing-error-handling' "$ORCH"; then
    if grep 'reviewing-error-handling' "$ORCH" | grep -q 'coming soon'; then
      bad "reviewing menu wires reviewing-error-handling (not coming soon)"
    else
      ok "reviewing menu wires reviewing-error-handling (not coming soon)"
    fi
  else
    bad "reviewing menu wires reviewing-error-handling (not coming soon)"
  fi
fi

# ============================================================================
# Spec 3 Task 2 — reviewing-test-quality facet skill
# ============================================================================

TQ="$PLUGIN/skills/reviewing-test-quality/SKILL.md"
[ -f "$TQ" ]; check $? "reviewing-test-quality/SKILL.md exists"
if [ -f "$TQ" ]; then
  head -1 "$TQ" | grep -q '^---$'; check $? "reviewing-test-quality has frontmatter"
  grep -q '^name: reviewing-test-quality$' "$TQ"; check $? "reviewing-test-quality frontmatter names itself"
  desc=$(awk '/^description:/{print; exit}' "$TQ")
  printf '%s' "$desc" | grep -qiE "test.quality|test review"; check $? "reviewing-test-quality description carries a test-quality trigger"
  printf '%s' "$desc" | grep -qiE "exercise|assertion"; check $? "reviewing-test-quality description names exercising/assertions"
  printf '%s' "$desc" | grep -qiE "regression|fail if"; check $? "reviewing-test-quality description names catching a regression"
  # self-limiting behavior, at the source
  grep_flat "$TQ" "relevance gate"; check $? "reviewing-test-quality runs the relevance gate"
  grep_flat "$TQ" "before any lens work"; check $? "reviewing-test-quality short-circuits before lens work"
  grep_flat "$TQ" "top_n"; check $? "reviewing-test-quality applies the top-N cap"
  grep_flat "$TQ" "floor"; check $? "reviewing-test-quality applies the confidence/severity floor"
  grep_flat "$TQ" "report-only"; check $? "reviewing-test-quality is report-only"
  grep_flat "$TQ" "findings.md"; check $? "reviewing-test-quality writes findings.md"
  # the defining constraint: it reasons structurally and does NOT execute the suite
  grep_flat "$TQ" "judges structurally, and never runs the suite"; check $? "reviewing-test-quality states it never runs the suite"
  # analysis boundary stated inline (no ADR pointer — the plugin ships without docs/adr/)
  grep_flat "$TQ" "no proactive"; check $? "reviewing-test-quality states its analysis boundary inline"
  grep_flat "$TQ" "references/test-quality-checklist.md"; check $? "reviewing-test-quality links references/test-quality-checklist.md"
fi

TQCL="$PLUGIN/skills/reviewing-test-quality/references/test-quality-checklist.md"
[ -f "$TQCL" ]; check $? "reviewing-test-quality/references/test-quality-checklist.md exists"
if [ -f "$TQCL" ]; then
  grep_flat "$TQCL" "Vacuous"; check $? "test-quality-checklist covers vacuous/tautological assertion"
  grep_flat "$TQCL" "not exercised"; check $? "test-quality-checklist covers the changed path not exercised"
  grep_flat "$TQCL" "too weak"; check $? "test-quality-checklist covers assertion too weak"
  grep_flat "$TQCL" "edge case"; check $? "test-quality-checklist covers an uncovered introduced edge case"
  grep_flat "$TQCL" "mock"; check $? "test-quality-checklist covers assertions bound to a mock"
  grep_flat "$TQCL" "not a finding"; check $? "test-quality-checklist states what is not a finding"
  grep_flat "$TQCL" "without running"; check $? "test-quality-checklist reasons structurally, without running the suite"
fi

# --- orchestrator wiring: test-quality is live, not "coming soon" -------------
if [ -f "$ORCH" ]; then
  if grep -q 'reviewing-test-quality' "$ORCH"; then
    if grep 'reviewing-test-quality' "$ORCH" | grep -q 'coming soon'; then
      bad "reviewing menu wires reviewing-test-quality (not coming soon)"
    else
      ok "reviewing menu wires reviewing-test-quality (not coming soon)"
    fi
  else
    bad "reviewing menu wires reviewing-test-quality (not coming soon)"
  fi
fi

# ============================================================================
# Spec 3 Task 3 — reviewing-data-safety facet skill
# ============================================================================

DS="$PLUGIN/skills/reviewing-data-safety/SKILL.md"
[ -f "$DS" ]; check $? "reviewing-data-safety/SKILL.md exists"
if [ -f "$DS" ]; then
  head -1 "$DS" | grep -q '^---$'; check $? "reviewing-data-safety has frontmatter"
  grep -q '^name: reviewing-data-safety$' "$DS"; check $? "reviewing-data-safety frontmatter names itself"
  desc=$(awk '/^description:/{print; exit}' "$DS")
  printf '%s' "$desc" | grep -qiE "data.safety|migration"; check $? "reviewing-data-safety description carries a data-safety trigger"
  printf '%s' "$desc" | grep -qiE "destructive|irreversible"; check $? "reviewing-data-safety description names destructive/irreversible ops"
  printf '%s' "$desc" | grep -qiE "data.loss|data loss"; check $? "reviewing-data-safety description names data loss"
  # self-limiting behavior, at the source
  grep_flat "$DS" "relevance gate"; check $? "reviewing-data-safety runs the relevance gate"
  grep_flat "$DS" "before any lens work"; check $? "reviewing-data-safety short-circuits before lens work"
  grep_flat "$DS" "top_n"; check $? "reviewing-data-safety applies the top-N cap"
  grep_flat "$DS" "floor"; check $? "reviewing-data-safety applies the confidence/severity floor"
  grep_flat "$DS" "report-only"; check $? "reviewing-data-safety is report-only"
  grep_flat "$DS" "findings.md"; check $? "reviewing-data-safety writes findings.md"
  # analysis boundary stated inline (no ADR pointer — the plugin ships without docs/adr/)
  grep_flat "$DS" "no proactive"; check $? "reviewing-data-safety states its analysis boundary inline"
  grep_flat "$DS" "visible in the diff"; check $? "reviewing-data-safety scopes to the operation visible in the diff"
  grep_flat "$DS" "references/data-safety-checklist.md"; check $? "reviewing-data-safety links references/data-safety-checklist.md"
fi

DSCL="$PLUGIN/skills/reviewing-data-safety/references/data-safety-checklist.md"
[ -f "$DSCL" ]; check $? "reviewing-data-safety/references/data-safety-checklist.md exists"
if [ -f "$DSCL" ]; then
  grep_flat "$DSCL" "Unbounded"; check $? "data-safety-checklist covers unbounded UPDATE/DELETE"
  grep_flat "$DSCL" "live data"; check $? "data-safety-checklist covers drop/rename of live data"
  grep_flat "$DSCL" "rollback"; check $? "data-safety-checklist covers a migration with no rollback"
  grep_flat "$DSCL" "idempotent"; check $? "data-safety-checklist covers non-idempotent migration"
  grep_flat "$DSCL" "Irreversible"; check $? "data-safety-checklist covers an irreversible op with no guard"
  grep_flat "$DSCL" "not a finding"; check $? "data-safety-checklist states what is not a finding"
fi

# --- orchestrator wiring: data-safety is live, not "coming soon" --------------
if [ -f "$ORCH" ]; then
  if grep -q 'reviewing-data-safety' "$ORCH"; then
    if grep 'reviewing-data-safety' "$ORCH" | grep -q 'coming soon'; then
      bad "reviewing menu wires reviewing-data-safety (not coming soon)"
    else
      ok "reviewing menu wires reviewing-data-safety (not coming soon)"
    fi
  else
    bad "reviewing menu wires reviewing-data-safety (not coming soon)"
  fi
fi

# ============================================================================
# Spec 3 Task 4 — reviewing-api-compat facet skill
# ============================================================================

AC="$PLUGIN/skills/reviewing-api-compat/SKILL.md"
[ -f "$AC" ]; check $? "reviewing-api-compat/SKILL.md exists"
if [ -f "$AC" ]; then
  head -1 "$AC" | grep -q '^---$'; check $? "reviewing-api-compat has frontmatter"
  grep -q '^name: reviewing-api-compat$' "$AC"; check $? "reviewing-api-compat frontmatter names itself"
  desc=$(awk '/^description:/{print; exit}' "$AC")
  printf '%s' "$desc" | grep -qiE "api.compat|backward.compat"; check $? "reviewing-api-compat description carries an api/backward-compat trigger"
  printf '%s' "$desc" | grep -qi "breaking"; check $? "reviewing-api-compat description names breaking changes"
  printf '%s' "$desc" | grep -qiE "public|contract"; check $? "reviewing-api-compat description names public contracts"
  # self-limiting behavior, at the source
  grep_flat "$AC" "relevance gate"; check $? "reviewing-api-compat runs the relevance gate"
  grep_flat "$AC" "before any lens work"; check $? "reviewing-api-compat short-circuits before lens work"
  grep_flat "$AC" "top_n"; check $? "reviewing-api-compat applies the top-N cap"
  grep_flat "$AC" "floor"; check $? "reviewing-api-compat applies the confidence/severity floor"
  grep_flat "$AC" "report-only"; check $? "reviewing-api-compat is report-only"
  grep_flat "$AC" "findings.md"; check $? "reviewing-api-compat writes findings.md"
  # analysis boundary stated inline (no ADR pointer — the plugin ships without docs/adr/)
  grep_flat "$AC" "no proactive"; check $? "reviewing-api-compat states its analysis boundary inline"
  grep_flat "$AC" "visible in the diff"; check $? "reviewing-api-compat scopes to the contract change visible in the diff"
  grep_flat "$AC" "references/api-compat-checklist.md"; check $? "reviewing-api-compat links references/api-compat-checklist.md"
fi

ACCL="$PLUGIN/skills/reviewing-api-compat/references/api-compat-checklist.md"
[ -f "$ACCL" ]; check $? "reviewing-api-compat/references/api-compat-checklist.md exists"
if [ -f "$ACCL" ]; then
  grep_flat "$ACCL" "Removed or renamed"; check $? "api-compat-checklist covers a removed/renamed public member"
  grep_flat "$ACCL" "Changed signature"; check $? "api-compat-checklist covers a changed signature"
  grep_flat "$ACCL" "Changed response"; check $? "api-compat-checklist covers a changed response shape/status"
  grep_flat "$ACCL" "Widened requirement"; check $? "api-compat-checklist covers a widened input requirement"
  grep_flat "$ACCL" "Changed serialization"; check $? "api-compat-checklist covers a changed serialization"
  grep_flat "$ACCL" "not a finding"; check $? "api-compat-checklist states what is not a finding"
fi

# --- orchestrator wiring: api-compat is live, not "coming soon" ---------------
if [ -f "$ORCH" ]; then
  if grep -q 'reviewing-api-compat' "$ORCH"; then
    if grep 'reviewing-api-compat' "$ORCH" | grep -q 'coming soon'; then
      bad "reviewing menu wires reviewing-api-compat (not coming soon)"
    else
      ok "reviewing menu wires reviewing-api-compat (not coming soon)"
    fi
  else
    bad "reviewing menu wires reviewing-api-compat (not coming soon)"
  fi
  # menu complete — all thirteen facets wired, no row still "coming soon"
  if grep -q 'coming soon' "$ORCH"; then
    bad "reviewing menu is complete — no facet row still 'coming soon'"
  else
    ok "reviewing menu is complete — no facet row still 'coming soon'"
  fi
fi

# ============================================================================
# Plan 01 Task 1 — reviewing-tenant-isolation-shared-db facet skill
# ============================================================================

TISHARED="$PLUGIN/skills/reviewing-tenant-isolation-shared-db/SKILL.md"
[ -f "$TISHARED" ]; check $? "reviewing-tenant-isolation-shared-db/SKILL.md exists"
if [ -f "$TISHARED" ]; then
  head -1 "$TISHARED" | grep -q '^---$'; check $? "reviewing-tenant-isolation-shared-db has frontmatter"
  grep -q '^name: reviewing-tenant-isolation-shared-db$' "$TISHARED"; check $? "reviewing-tenant-isolation-shared-db frontmatter names itself"
  desc=$(awk '/^description:/{print; exit}' "$TISHARED")
  printf '%s' "$desc" | grep -qiE "tenant|multi-tenan"; check $? "reviewing-tenant-isolation-shared-db description carries a tenant trigger"
  printf '%s' "$desc" | grep -qiE "shared.database|single.database|shared.schema"; check $? "reviewing-tenant-isolation-shared-db description names the shared-DB model"
  printf '%s' "$desc" | grep -qiE "scope|scoping|isolation"; check $? "reviewing-tenant-isolation-shared-db description names scoping/isolation"
  grep_flat "$TISHARED" "relevance gate"; check $? "reviewing-tenant-isolation-shared-db runs the relevance gate"
  grep_flat "$TISHARED" "before any lens work"; check $? "reviewing-tenant-isolation-shared-db short-circuits before lens work"
  grep_flat "$TISHARED" "top_n"; check $? "reviewing-tenant-isolation-shared-db applies the top-N cap"
  grep_flat "$TISHARED" "floor"; check $? "reviewing-tenant-isolation-shared-db applies the confidence/severity floor"
  grep_flat "$TISHARED" "report-only"; check $? "reviewing-tenant-isolation-shared-db is report-only"
  grep_flat "$TISHARED" "findings.md"; check $? "reviewing-tenant-isolation-shared-db writes findings.md"
  grep_flat "$TISHARED" "no proactive"; check $? "reviewing-tenant-isolation-shared-db states its analysis boundary inline"
  grep_flat "$TISHARED" "visible in the diff"; check $? "reviewing-tenant-isolation-shared-db scopes its reach to the diff"
  grep_flat "$TISHARED" "references/tenant-isolation-shared-db-checklist.md"; check $? "reviewing-tenant-isolation-shared-db links references/tenant-isolation-shared-db-checklist.md"
fi

TISHAREDCL="$PLUGIN/skills/reviewing-tenant-isolation-shared-db/references/tenant-isolation-shared-db-checklist.md"
[ -f "$TISHAREDCL" ]; check $? "reviewing-tenant-isolation-shared-db/references/tenant-isolation-shared-db-checklist.md exists"
if [ -f "$TISHAREDCL" ]; then
  grep_flat "$TISHAREDCL" "Missing tenant scope"; check $? "shared-db-checklist covers missing tenant scope on a query"
  grep_flat "$TISHAREDCL" "Global-scope bypass"; check $? "shared-db-checklist covers global-scope bypass / raw query"
  grep_flat "$TISHAREDCL" "Cross-tenant reference by ID"; check $? "shared-db-checklist covers cross-tenant reference by ID"
  grep_flat "$TISHAREDCL" "Mass-assignment"; check $? "shared-db-checklist covers mass-assignment of the discriminator"
  grep_flat "$TISHAREDCL" "Cross-tenant aggregate"; check $? "shared-db-checklist covers cross-tenant aggregate/report"
  grep_flat "$TISHAREDCL" "cache key"; check $? "shared-db-checklist covers an un-namespaced cache key"
  grep_flat "$TISHAREDCL" "not a finding"; check $? "shared-db-checklist states what is not a finding"
fi

# ============================================================================
# Plan 01 Task 2 — reviewing-tenant-isolation-isolated-db facet skill
# ============================================================================

TISOLATED="$PLUGIN/skills/reviewing-tenant-isolation-isolated-db/SKILL.md"
[ -f "$TISOLATED" ]; check $? "reviewing-tenant-isolation-isolated-db/SKILL.md exists"
if [ -f "$TISOLATED" ]; then
  head -1 "$TISOLATED" | grep -q '^---$'; check $? "reviewing-tenant-isolation-isolated-db has frontmatter"
  grep -q '^name: reviewing-tenant-isolation-isolated-db$' "$TISOLATED"; check $? "reviewing-tenant-isolation-isolated-db frontmatter names itself"
  desc=$(awk '/^description:/{print; exit}' "$TISOLATED")
  printf '%s' "$desc" | grep -qiE "tenant|multi-tenan"; check $? "reviewing-tenant-isolation-isolated-db description carries a tenant trigger"
  printf '%s' "$desc" | grep -qiE "per-tenant|per.database|database-per|schema-per|isolated.database"; check $? "reviewing-tenant-isolation-isolated-db description names the per-tenant-DB model"
  printf '%s' "$desc" | grep -qiE "connection|isolation"; check $? "reviewing-tenant-isolation-isolated-db description names connection/isolation"
  grep_flat "$TISOLATED" "relevance gate"; check $? "reviewing-tenant-isolation-isolated-db runs the relevance gate"
  grep_flat "$TISOLATED" "before any lens work"; check $? "reviewing-tenant-isolation-isolated-db short-circuits before lens work"
  grep_flat "$TISOLATED" "top_n"; check $? "reviewing-tenant-isolation-isolated-db applies the top-N cap"
  grep_flat "$TISOLATED" "floor"; check $? "reviewing-tenant-isolation-isolated-db applies the confidence/severity floor"
  grep_flat "$TISOLATED" "report-only"; check $? "reviewing-tenant-isolation-isolated-db is report-only"
  grep_flat "$TISOLATED" "findings.md"; check $? "reviewing-tenant-isolation-isolated-db writes findings.md"
  grep_flat "$TISOLATED" "no proactive"; check $? "reviewing-tenant-isolation-isolated-db states its analysis boundary inline"
  grep_flat "$TISOLATED" "visible in the diff"; check $? "reviewing-tenant-isolation-isolated-db scopes its reach to the diff"
  grep_flat "$TISOLATED" "references/tenant-isolation-isolated-db-checklist.md"; check $? "reviewing-tenant-isolation-isolated-db links references/tenant-isolation-isolated-db-checklist.md"
fi

TISOLATEDCL="$PLUGIN/skills/reviewing-tenant-isolation-isolated-db/references/tenant-isolation-isolated-db-checklist.md"
[ -f "$TISOLATEDCL" ]; check $? "reviewing-tenant-isolation-isolated-db/references/tenant-isolation-isolated-db-checklist.md exists"
if [ -f "$TISOLATEDCL" ]; then
  grep_flat "$TISOLATEDCL" "Connection not switched"; check $? "isolated-db-checklist covers connection/tenant context not switched"
  grep_flat "$TISOLATEDCL" "context leaking across requests"; check $? "isolated-db-checklist covers tenant context leaking across requests"
  grep_flat "$TISOLATEDCL" "Background"; check $? "isolated-db-checklist covers background/queued/scheduled work on the wrong connection"
  grep_flat "$TISOLATEDCL" "landlord"; check $? "isolated-db-checklist covers central/landlord vs tenant DB confusion"
  grep_flat "$TISOLATEDCL" "Migration"; check $? "isolated-db-checklist covers migration targeting the wrong DB set"
  grep_flat "$TISOLATEDCL" "Cross-cutting per-tenant store"; check $? "isolated-db-checklist covers a cross-cutting per-tenant store not switched"
  grep_flat "$TISOLATEDCL" "not a finding"; check $? "isolated-db-checklist states what is not a finding"
fi

# ============================================================================
# Plan 01 Task 3 — reviewing-data-presentation facet skill
# ============================================================================

DATAPRES="$PLUGIN/skills/reviewing-data-presentation/SKILL.md"
[ -f "$DATAPRES" ]; check $? "reviewing-data-presentation/SKILL.md exists"
if [ -f "$DATAPRES" ]; then
  head -1 "$DATAPRES" | grep -q '^---$'; check $? "reviewing-data-presentation has frontmatter"
  grep -q '^name: reviewing-data-presentation$' "$DATAPRES"; check $? "reviewing-data-presentation frontmatter names itself"
  desc=$(awk '/^description:/{print; exit}' "$DATAPRES")
  printf '%s' "$desc" | grep -qiE "presentation|present"; check $? "reviewing-data-presentation description carries a presentation trigger"
  printf '%s' "$desc" | grep -qiE "disambiguat|distinguish|ambiguous|identity"; check $? "reviewing-data-presentation description names identity disambiguation"
  grep_flat "$DATAPRES" "relevance gate"; check $? "reviewing-data-presentation runs the relevance gate"
  grep_flat "$DATAPRES" "before any lens work"; check $? "reviewing-data-presentation short-circuits before lens work"
  grep_flat "$DATAPRES" "top_n"; check $? "reviewing-data-presentation applies the top-N cap"
  grep_flat "$DATAPRES" "floor"; check $? "reviewing-data-presentation applies the confidence/severity floor"
  grep_flat "$DATAPRES" "report-only"; check $? "reviewing-data-presentation is report-only"
  grep_flat "$DATAPRES" "findings.md"; check $? "reviewing-data-presentation writes findings.md"
  grep_flat "$DATAPRES" "no proactive"; check $? "reviewing-data-presentation states its analysis boundary inline"
  grep_flat "$DATAPRES" "visible in the diff"; check $? "reviewing-data-presentation scopes its reach to the diff"
  grep_flat "$DATAPRES" "references/data-presentation-checklist.md"; check $? "reviewing-data-presentation links references/data-presentation-checklist.md"
fi

DATAPRESCL="$PLUGIN/skills/reviewing-data-presentation/references/data-presentation-checklist.md"
[ -f "$DATAPRESCL" ]; check $? "reviewing-data-presentation/references/data-presentation-checklist.md exists"
if [ -f "$DATAPRESCL" ]; then
  grep_flat "$DATAPRESCL" "Non-unique label"; check $? "data-presentation-checklist covers a non-unique label without its disambiguating path"
  grep_flat "$DATAPRESCL" "Collision-prone identifier"; check $? "data-presentation-checklist covers a collision-prone identifier without a distinguishing key"
  grep_flat "$DATAPRESCL" "Indistinguishable"; check $? "data-presentation-checklist covers indistinguishable records in a list/selection"
  grep_flat "$DATAPRESCL" "Disambiguator removed by rendering"; check $? "data-presentation-checklist covers a disambiguator removed by truncation/responsive hiding"
  grep_flat "$DATAPRESCL" "accessibility"; check $? "data-presentation-checklist scopes out general UX/accessibility inline"
  grep_flat "$DATAPRESCL" "not a finding"; check $? "data-presentation-checklist states what is not a finding"
fi

# ============================================================================
# Plan 01 Task 4 — detection seam, orchestrator wiring, signals reference
# ============================================================================

MTSIG="$PLUGIN/skills/reviewing/references/multi-tenancy-signals.md"
[ -f "$MTSIG" ]; check $? "reviewing/references/multi-tenancy-signals.md exists"
if [ -f "$MTSIG" ]; then
  grep_flat "$MTSIG" "shared-schema"; check $? "multi-tenancy-signals documents shared-schema signals"
  grep_flat "$MTSIG" "tenant_id"; check $? "multi-tenancy-signals names the discriminator-column signal"
  grep_flat "$MTSIG" "per-tenant"; check $? "multi-tenancy-signals documents per-tenant-DB signals"
  grep_flat "$MTSIG" "connection"; check $? "multi-tenancy-signals names the per-tenant connection signal"
  grep_flat "$MTSIG" '`shared`'; check $? "multi-tenancy-signals verdict includes shared"
  grep_flat "$MTSIG" '`per-db`'; check $? "multi-tenancy-signals verdict includes per-db"
  grep_flat "$MTSIG" '`both`'; check $? "multi-tenancy-signals verdict includes both"
  grep_flat "$MTSIG" '`none`'; check $? "multi-tenancy-signals verdict includes none"
  grep_flat "$MTSIG" '`ambiguous`'; check $? "multi-tenancy-signals verdict includes ambiguous"
  grep_flat "$MTSIG" "ask once"; check $? "multi-tenancy-signals resolves ambiguous by asking once"
fi

if [ -f "$ORCH" ]; then
  grep_flat "$ORCH" "references/multi-tenancy-signals.md"; check $? "reviewing links references/multi-tenancy-signals.md"
  grep_flat "$ORCH" "menu-proposal"; check $? "reviewing states the menu-proposal detection step"
  grep_flat "$ORCH" "two-gate"; check $? "reviewing states the two-gate model"
fi

# --- orchestrator wiring: shared-DB tenant facet is live, not "coming soon" ---
if [ -f "$ORCH" ]; then
  if grep -q 'reviewing-tenant-isolation-shared-db' "$ORCH"; then
    if grep 'reviewing-tenant-isolation-shared-db' "$ORCH" | grep -q 'coming soon'; then
      bad "reviewing menu wires reviewing-tenant-isolation-shared-db (not coming soon)"
    else
      ok "reviewing menu wires reviewing-tenant-isolation-shared-db (not coming soon)"
    fi
  else
    bad "reviewing menu wires reviewing-tenant-isolation-shared-db (not coming soon)"
  fi
fi

# --- orchestrator wiring: isolated-DB tenant facet is live, not "coming soon" -
if [ -f "$ORCH" ]; then
  if grep -q 'reviewing-tenant-isolation-isolated-db' "$ORCH"; then
    if grep 'reviewing-tenant-isolation-isolated-db' "$ORCH" | grep -q 'coming soon'; then
      bad "reviewing menu wires reviewing-tenant-isolation-isolated-db (not coming soon)"
    else
      ok "reviewing menu wires reviewing-tenant-isolation-isolated-db (not coming soon)"
    fi
  else
    bad "reviewing menu wires reviewing-tenant-isolation-isolated-db (not coming soon)"
  fi
fi

# --- orchestrator wiring: data-presentation facet is live, not "coming soon" --
if [ -f "$ORCH" ]; then
  if grep -q 'reviewing-data-presentation' "$ORCH"; then
    if grep 'reviewing-data-presentation' "$ORCH" | grep -q 'coming soon'; then
      bad "reviewing menu wires reviewing-data-presentation (not coming soon)"
    else
      ok "reviewing menu wires reviewing-data-presentation (not coming soon)"
    fi
  else
    bad "reviewing menu wires reviewing-data-presentation (not coming soon)"
  fi
fi

# --- README lists the three new facets --------------------------------------
if [ -f "$PLUGIN/README.md" ]; then
  grep_flat "$PLUGIN/README.md" "Tenant Isolation"; check $? "README lists the tenant-isolation facets"
  grep_flat "$PLUGIN/README.md" "Data Presentation"; check $? "README lists the data-presentation facet"
fi

# ============================================================================
# Plan 02 Task 1 — reviewing-concurrency facet skill
# ============================================================================

CONC="$PLUGIN/skills/reviewing-concurrency/SKILL.md"
[ -f "$CONC" ]; check $? "reviewing-concurrency/SKILL.md exists"
if [ -f "$CONC" ]; then
  head -1 "$CONC" | grep -q '^---$'; check $? "reviewing-concurrency has frontmatter"
  grep -q '^name: reviewing-concurrency$' "$CONC"; check $? "reviewing-concurrency frontmatter names itself"
  desc=$(awk '/^description:/{print; exit}' "$CONC")
  printf '%s' "$desc" | grep -qiE "concurren|race|thread.saf"; check $? "reviewing-concurrency description carries a concurrency trigger"
  printf '%s' "$desc" | grep -qiE "interleav|check-then-act|read-modify-write|TOCTOU"; check $? "reviewing-concurrency description names an interleaving class"
  printf '%s' "$desc" | grep -qiE "lock|transaction|atomic|synchroniz"; check $? "reviewing-concurrency description names a synchronization primitive"
  grep_flat "$CONC" "relevance gate"; check $? "reviewing-concurrency runs the relevance gate"
  grep_flat "$CONC" "before any lens work"; check $? "reviewing-concurrency short-circuits before lens work"
  grep_flat "$CONC" "top_n"; check $? "reviewing-concurrency applies the top-N cap"
  grep_flat "$CONC" "floor"; check $? "reviewing-concurrency applies the confidence/severity floor"
  grep_flat "$CONC" "report-only"; check $? "reviewing-concurrency is report-only"
  grep_flat "$CONC" "findings.md"; check $? "reviewing-concurrency writes findings.md"
  grep_flat "$CONC" "no proactive"; check $? "reviewing-concurrency states its analysis boundary inline"
  grep_flat "$CONC" "visible in the diff"; check $? "reviewing-concurrency scopes its reach to the diff"
  grep_flat "$CONC" "references/concurrency-checklist.md"; check $? "reviewing-concurrency links references/concurrency-checklist.md"
fi

CONCCL="$PLUGIN/skills/reviewing-concurrency/references/concurrency-checklist.md"
[ -f "$CONCCL" ]; check $? "reviewing-concurrency/references/concurrency-checklist.md exists"
if [ -f "$CONCCL" ]; then
  grep_flat "$CONCCL" "Check-then-act"; check $? "concurrency-checklist covers check-then-act (TOCTOU)"
  grep_flat "$CONCCL" "Non-atomic read-modify-write"; check $? "concurrency-checklist covers non-atomic read-modify-write"
  grep_flat "$CONCCL" "Lost update"; check $? "concurrency-checklist covers lost update on shared state"
  grep_flat "$CONCCL" "Missing lock or transaction"; check $? "concurrency-checklist covers a compound op missing its lock/transaction"
  grep_flat "$CONCCL" "Shared mutable state"; check $? "concurrency-checklist covers shared mutable state without synchronization"
  grep_flat "$CONCCL" "not a finding"; check $? "concurrency-checklist states what is not a finding"
fi

# --- orchestrator wiring: concurrency is live, not "coming soon" -------------
if [ -f "$ORCH" ]; then
  if grep -q 'reviewing-concurrency' "$ORCH"; then
    if grep 'reviewing-concurrency' "$ORCH" | grep -q 'coming soon'; then
      bad "reviewing menu wires reviewing-concurrency (not coming soon)"
    else
      ok "reviewing menu wires reviewing-concurrency (not coming soon)"
    fi
  else
    bad "reviewing menu wires reviewing-concurrency (not coming soon)"
  fi
fi

# ============================================================================
# Plan 02 Task 2 — reviewing-idempotency facet skill
# ============================================================================

IDEM="$PLUGIN/skills/reviewing-idempotency/SKILL.md"
[ -f "$IDEM" ]; check $? "reviewing-idempotency/SKILL.md exists"
if [ -f "$IDEM" ]; then
  head -1 "$IDEM" | grep -q '^---$'; check $? "reviewing-idempotency has frontmatter"
  grep -q '^name: reviewing-idempotency$' "$IDEM"; check $? "reviewing-idempotency frontmatter names itself"
  desc=$(awk '/^description:/{print; exit}' "$IDEM")
  printf '%s' "$desc" | grep -qiE "idempoten|retry.saf"; check $? "reviewing-idempotency description carries an idempotency trigger"
  printf '%s' "$desc" | grep -qiE "twice|retr|replay|redeliver|duplicate"; check $? "reviewing-idempotency description names a repeat trigger"
  printf '%s' "$desc" | grep -qiE "webhook|consumer|queue|at-least-once|idempotency key"; check $? "reviewing-idempotency description names a repeatable-effect surface"
  grep_flat "$IDEM" "relevance gate"; check $? "reviewing-idempotency runs the relevance gate"
  grep_flat "$IDEM" "before any lens work"; check $? "reviewing-idempotency short-circuits before lens work"
  grep_flat "$IDEM" "top_n"; check $? "reviewing-idempotency applies the top-N cap"
  grep_flat "$IDEM" "floor"; check $? "reviewing-idempotency applies the confidence/severity floor"
  grep_flat "$IDEM" "report-only"; check $? "reviewing-idempotency is report-only"
  grep_flat "$IDEM" "findings.md"; check $? "reviewing-idempotency writes findings.md"
  grep_flat "$IDEM" "no proactive"; check $? "reviewing-idempotency states its analysis boundary inline"
  grep_flat "$IDEM" "visible in the diff"; check $? "reviewing-idempotency scopes its reach to the diff"
  grep_flat "$IDEM" "references/idempotency-checklist.md"; check $? "reviewing-idempotency links references/idempotency-checklist.md"
fi

IDEMCL="$PLUGIN/skills/reviewing-idempotency/references/idempotency-checklist.md"
[ -f "$IDEMCL" ]; check $? "reviewing-idempotency/references/idempotency-checklist.md exists"
if [ -f "$IDEMCL" ]; then
  grep_flat "$IDEMCL" "Side effect with no idempotency key"; check $? "idempotency-checklist covers a side effect with no idempotency key"
  grep_flat "$IDEMCL" "Non-idempotent retry"; check $? "idempotency-checklist covers a non-idempotent retry"
  grep_flat "$IDEMCL" "At-least-once treated as exactly-once"; check $? "idempotency-checklist covers at-least-once treated as exactly-once"
  grep_flat "$IDEMCL" "Duplicate on replay"; check $? "idempotency-checklist covers a duplicate on replay"
  grep_flat "$IDEMCL" "Partial-completion re-run"; check $? "idempotency-checklist covers a partial-completion re-run"
  grep_flat "$IDEMCL" "not a finding"; check $? "idempotency-checklist states what is not a finding"
fi

# --- orchestrator wiring: idempotency is live, not "coming soon" -------------
if [ -f "$ORCH" ]; then
  if grep -q 'reviewing-idempotency' "$ORCH"; then
    if grep 'reviewing-idempotency' "$ORCH" | grep -q 'coming soon'; then
      bad "reviewing menu wires reviewing-idempotency (not coming soon)"
    else
      ok "reviewing menu wires reviewing-idempotency (not coming soon)"
    fi
  else
    bad "reviewing menu wires reviewing-idempotency (not coming soon)"
  fi
fi

# ============================================================================
# Plan 02 Task 3 — reviewing-numeric-precision facet skill
# ============================================================================

NUM="$PLUGIN/skills/reviewing-numeric-precision/SKILL.md"
[ -f "$NUM" ]; check $? "reviewing-numeric-precision/SKILL.md exists"
if [ -f "$NUM" ]; then
  head -1 "$NUM" | grep -q '^---$'; check $? "reviewing-numeric-precision has frontmatter"
  grep -q '^name: reviewing-numeric-precision$' "$NUM"; check $? "reviewing-numeric-precision frontmatter names itself"
  desc=$(awk '/^description:/{print; exit}' "$NUM")
  printf '%s' "$desc" | grep -qiE "numeric|precision|money|units"; check $? "reviewing-numeric-precision description carries a numeric-precision trigger"
  printf '%s' "$desc" | grep -qiE "float|rounding|truncat"; check $? "reviewing-numeric-precision description names a precision class"
  printf '%s' "$desc" | grep -qiE "unit mismatch|overflow|cast|cents|scale"; check $? "reviewing-numeric-precision description names a units/overflow class"
  grep_flat "$NUM" "relevance gate"; check $? "reviewing-numeric-precision runs the relevance gate"
  grep_flat "$NUM" "before any lens work"; check $? "reviewing-numeric-precision short-circuits before lens work"
  grep_flat "$NUM" "top_n"; check $? "reviewing-numeric-precision applies the top-N cap"
  grep_flat "$NUM" "floor"; check $? "reviewing-numeric-precision applies the confidence/severity floor"
  grep_flat "$NUM" "report-only"; check $? "reviewing-numeric-precision is report-only"
  grep_flat "$NUM" "findings.md"; check $? "reviewing-numeric-precision writes findings.md"
  grep_flat "$NUM" "no proactive"; check $? "reviewing-numeric-precision states its analysis boundary inline"
  grep_flat "$NUM" "visible in the diff"; check $? "reviewing-numeric-precision scopes its reach to the diff"
  grep_flat "$NUM" "references/numeric-precision-checklist.md"; check $? "reviewing-numeric-precision links references/numeric-precision-checklist.md"
fi

NUMCL="$PLUGIN/skills/reviewing-numeric-precision/references/numeric-precision-checklist.md"
[ -f "$NUMCL" ]; check $? "reviewing-numeric-precision/references/numeric-precision-checklist.md exists"
if [ -f "$NUMCL" ]; then
  grep_flat "$NUMCL" "Binary float for an exact value"; check $? "numeric-precision-checklist covers a binary float for an exact value"
  grep_flat "$NUMCL" "Silent rounding or truncation"; check $? "numeric-precision-checklist covers silent rounding or truncation"
  grep_flat "$NUMCL" "Unit mismatch"; check $? "numeric-precision-checklist covers a unit mismatch"
  grep_flat "$NUMCL" "Integer overflow"; check $? "numeric-precision-checklist covers integer overflow"
  grep_flat "$NUMCL" "Precision lost on a cast"; check $? "numeric-precision-checklist covers precision lost on a cast"
  grep_flat "$NUMCL" "Mixed scale or currency"; check $? "numeric-precision-checklist covers mixed scale or currency without normalization"
  grep_flat "$NUMCL" "not a finding"; check $? "numeric-precision-checklist states what is not a finding"
fi

# --- orchestrator wiring: numeric-precision is live, not "coming soon" -------
if [ -f "$ORCH" ]; then
  if grep -q 'reviewing-numeric-precision' "$ORCH"; then
    if grep 'reviewing-numeric-precision' "$ORCH" | grep -q 'coming soon'; then
      bad "reviewing menu wires reviewing-numeric-precision (not coming soon)"
    else
      ok "reviewing menu wires reviewing-numeric-precision (not coming soon)"
    fi
  else
    bad "reviewing menu wires reviewing-numeric-precision (not coming soon)"
  fi
fi

# --- README lists the three added facets ------------------------------------
if [ -f "$PLUGIN/README.md" ]; then
  grep_flat "$PLUGIN/README.md" "Concurrency & Race Safety"; check $? "README lists the concurrency facet"
  grep_flat "$PLUGIN/README.md" "Idempotency & Retry Safety"; check $? "README lists the idempotency facet"
  grep_flat "$PLUGIN/README.md" "Numeric Precision & Units"; check $? "README lists the numeric-precision facet"
fi

# ============================================================================
# Facet — reviewing-api-consumption facet skill
# ============================================================================

APICON="$PLUGIN/skills/reviewing-api-consumption/SKILL.md"
[ -f "$APICON" ]; check $? "reviewing-api-consumption/SKILL.md exists"
if [ -f "$APICON" ]; then
  head -1 "$APICON" | grep -q '^---$'; check $? "reviewing-api-consumption has frontmatter"
  grep -q '^name: reviewing-api-consumption$' "$APICON"; check $? "reviewing-api-consumption frontmatter names itself"
  desc=$(awk '/^description:/{print; exit}' "$APICON")
  printf '%s' "$desc" | grep -qiE "api.consumption|api usage|consuming"; check $? "reviewing-api-consumption description carries an API-consumption trigger"
  printf '%s' "$desc" | grep -qiE "over-fetch|over.fetch|fetch|polling|call volume"; check $? "reviewing-api-consumption description names an over-fetch/over-call class"
  printf '%s' "$desc" | grep -qiE "429|rate.limit"; check $? "reviewing-api-consumption description names the 429/rate-limit class"
  grep_flat "$APICON" "relevance gate"; check $? "reviewing-api-consumption runs the relevance gate"
  grep_flat "$APICON" "before any lens work"; check $? "reviewing-api-consumption short-circuits before lens work"
  grep_flat "$APICON" "top_n"; check $? "reviewing-api-consumption applies the top-N cap"
  grep_flat "$APICON" "floor"; check $? "reviewing-api-consumption applies the confidence/severity floor"
  grep_flat "$APICON" "report-only"; check $? "reviewing-api-consumption is report-only"
  grep_flat "$APICON" "findings.md"; check $? "reviewing-api-consumption writes findings.md"
  grep_flat "$APICON" "no proactive"; check $? "reviewing-api-consumption states its analysis boundary inline"
  grep_flat "$APICON" "visible in the diff"; check $? "reviewing-api-consumption scopes its reach to the diff"
  grep_flat "$APICON" "references/api-consumption-checklist.md"; check $? "reviewing-api-consumption links references/api-consumption-checklist.md"
fi

APICONCL="$PLUGIN/skills/reviewing-api-consumption/references/api-consumption-checklist.md"
[ -f "$APICONCL" ]; check $? "reviewing-api-consumption/references/api-consumption-checklist.md exists"
if [ -f "$APICONCL" ]; then
  grep_flat "$APICONCL" "Over-fetching payload"; check $? "api-consumption-checklist covers over-fetching payload"
  grep_flat "$APICONCL" "Client-side work the API"; check $? "api-consumption-checklist covers client-side work the API offers server-side"
  grep_flat "$APICONCL" "Excessive call volume"; check $? "api-consumption-checklist covers excessive call volume"
  grep_flat "$APICONCL" "Rate-limit"; check $? "api-consumption-checklist covers rate-limit (429) safety"
  grep_flat "$APICONCL" "not a finding"; check $? "api-consumption-checklist states what is not a finding"
fi

# --- orchestrator wiring: api-consumption is live, not "coming soon" ----------
if [ -f "$ORCH" ]; then
  if grep -q 'reviewing-api-consumption' "$ORCH"; then
    if grep 'reviewing-api-consumption' "$ORCH" | grep -q 'coming soon'; then
      bad "reviewing menu wires reviewing-api-consumption (not coming soon)"
    else
      ok "reviewing menu wires reviewing-api-consumption (not coming soon)"
    fi
  else
    bad "reviewing menu wires reviewing-api-consumption (not coming soon)"
  fi
fi

# --- README lists the api-consumption facet ---------------------------------
if [ -f "$PLUGIN/README.md" ]; then
  grep_flat "$PLUGIN/README.md" "API Consumption"; check $? "README lists the api-consumption facet"
fi

# ============================================================================
# Facet — reviewing-accessibility facet skill
# ============================================================================

A11Y="$PLUGIN/skills/reviewing-accessibility/SKILL.md"
[ -f "$A11Y" ]; check $? "reviewing-accessibility/SKILL.md exists"
if [ -f "$A11Y" ]; then
  head -1 "$A11Y" | grep -q '^---$'; check $? "reviewing-accessibility has frontmatter"
  grep -q '^name: reviewing-accessibility$' "$A11Y"; check $? "reviewing-accessibility frontmatter names itself"
  desc=$(awk '/^description:/{print; exit}' "$A11Y")
  printf '%s' "$desc" | grep -qiE "accessib|a11y"; check $? "reviewing-accessibility description carries an accessibility trigger"
  printf '%s' "$desc" | grep -qiE "alt text|label|aria|contrast|keyboard|semantic"; check $? "reviewing-accessibility description names a defect class"
  printf '%s' "$desc" | grep -qiE "assistive|screen reader|perceiv|operab"; check $? "reviewing-accessibility description names the perceivability/operability concern"
  grep_flat "$A11Y" "relevance gate"; check $? "reviewing-accessibility runs the relevance gate"
  grep_flat "$A11Y" "before any lens work"; check $? "reviewing-accessibility short-circuits before lens work"
  grep_flat "$A11Y" "top_n"; check $? "reviewing-accessibility applies the top-N cap"
  grep_flat "$A11Y" "floor"; check $? "reviewing-accessibility applies the confidence/severity floor"
  grep_flat "$A11Y" "report-only"; check $? "reviewing-accessibility is report-only"
  grep_flat "$A11Y" "findings.md"; check $? "reviewing-accessibility writes findings.md"
  grep_flat "$A11Y" "no proactive"; check $? "reviewing-accessibility states its analysis boundary inline"
  grep_flat "$A11Y" "visible in the diff"; check $? "reviewing-accessibility scopes its reach to the diff"
  grep_flat "$A11Y" "references/accessibility-checklist.md"; check $? "reviewing-accessibility links references/accessibility-checklist.md"
fi

A11YCL="$PLUGIN/skills/reviewing-accessibility/references/accessibility-checklist.md"
[ -f "$A11YCL" ]; check $? "reviewing-accessibility/references/accessibility-checklist.md exists"
if [ -f "$A11YCL" ]; then
  grep_flat "$A11YCL" "Structural & naming"; check $? "accessibility-checklist covers structural & naming defects"
  grep_flat "$A11YCL" "Color & contrast"; check $? "accessibility-checklist covers color & contrast"
  grep_flat "$A11YCL" "Motion & timing"; check $? "accessibility-checklist covers motion & timing"
  grep_flat "$A11YCL" "Dynamic announcements"; check $? "accessibility-checklist covers dynamic announcements"
  grep_flat "$A11YCL" "data-presentation"; check $? "accessibility-checklist cedes identity-ambiguity to data-presentation"
  grep_flat "$A11YCL" "not a finding"; check $? "accessibility-checklist states what is not a finding"
fi

# --- orchestrator wiring: accessibility is live, not "coming soon" ------------
if [ -f "$ORCH" ]; then
  if grep -q 'reviewing-accessibility' "$ORCH"; then
    if grep 'reviewing-accessibility' "$ORCH" | grep -q 'coming soon'; then
      bad "reviewing menu wires reviewing-accessibility (not coming soon)"
    else
      ok "reviewing menu wires reviewing-accessibility (not coming soon)"
    fi
  else
    bad "reviewing menu wires reviewing-accessibility (not coming soon)"
  fi
fi

# --- README lists the accessibility facet -----------------------------------
if [ -f "$PLUGIN/README.md" ]; then
  grep_flat "$PLUGIN/README.md" "Accessibility"; check $? "README lists the accessibility facet"
fi

# ============================================================================
# Framework best practices — Laravel content
# ============================================================================

LARAVELCL="$PLUGIN/skills/reviewing-framework-best-practices/references/laravel.md"
[ -f "$LARAVELCL" ]; check $? "reviewing-framework-best-practices/references/laravel.md exists"
if [ -f "$LARAVELCL" ]; then
  grep_flat "$LARAVELCL" "Form Request"; check $? "laravel.md covers validation/authorization placement"
  grep_flat "$LARAVELCL" "Eloquent"; check $? "laravel.md covers Eloquent/query-shape idioms"
  grep_flat "$LARAVELCL" "withoutOverlapping"; check $? "laravel.md covers queue/cache/scheduling safety"
  grep_flat "$LARAVELCL" "Pest"; check $? "laravel.md covers Pest testing conventions"
  grep_flat "$LARAVELCL" "Inertia"; check $? "laravel.md covers Inertia/React page conventions"
  grep_flat "$LARAVELCL" "env("; check $? "laravel.md covers config/error-handling/mail/events idioms"
  grep_flat "$LARAVELCL" "not a finding"; check $? "laravel.md states what is not a finding"
  grep_flat "$LARAVELCL" "Novelty"; check $? "laravel.md cedes generic reinvention to Novelty"
fi

# ============================================================================
# Framework best practices — Tailwind content
# ============================================================================

TAILWINDCL="$PLUGIN/skills/reviewing-framework-best-practices/references/tailwind.md"
[ -f "$TAILWINDCL" ]; check $? "reviewing-framework-best-practices/references/tailwind.md exists"
if [ -f "$TAILWINDCL" ]; then
  grep_flat "$TAILWINDCL" "utility"; check $? "tailwind.md covers reinvented utility patterns"
  grep_flat "$TAILWINDCL" "dark mode"; check $? "tailwind.md covers responsive/dark-mode consistency"
  grep_flat "$TAILWINDCL" "not a finding"; check $? "tailwind.md states what is not a finding"
fi

# ============================================================================
# reviewing-framework-best-practices facet skill + index
# ============================================================================

FBPIDX="$PLUGIN/skills/reviewing-framework-best-practices/references/framework-best-practices-index.md"
[ -f "$FBPIDX" ]; check $? "framework-best-practices-index.md exists"
if [ -f "$FBPIDX" ]; then
  grep_flat "$FBPIDX" "references/laravel.md"; check $? "index maps Laravel to its file"
  grep_flat "$FBPIDX" "references/tailwind.md"; check $? "index maps Tailwind to its file"
  grep_flat "$FBPIDX" "deliberate exception"; check $? "index states the multi-file exception explicitly"
fi

FBP="$PLUGIN/skills/reviewing-framework-best-practices/SKILL.md"
[ -f "$FBP" ]; check $? "reviewing-framework-best-practices/SKILL.md exists"
if [ -f "$FBP" ]; then
  head -1 "$FBP" | grep -q '^---$'; check $? "reviewing-framework-best-practices has frontmatter"
  grep -q '^name: reviewing-framework-best-practices$' "$FBP"; check $? "reviewing-framework-best-practices frontmatter names itself"
  desc=$(awk '/^description:/{print; exit}' "$FBP")
  printf '%s' "$desc" | grep -qiE "framework|stack|idiom"; check $? "description carries a framework-idiom trigger"
  printf '%s' "$desc" | grep -qiE "laravel|tailwind"; check $? "description names an in-scope stack"
  grep_flat "$FBP" "relevance gate"; check $? "reviewing-framework-best-practices runs the relevance gate"
  grep_flat "$FBP" "before any lens work"; check $? "reviewing-framework-best-practices short-circuits before lens work"
  grep_flat "$FBP" "top_n"; check $? "reviewing-framework-best-practices applies the top-N cap"
  grep_flat "$FBP" "floor"; check $? "reviewing-framework-best-practices applies the confidence/severity floor"
  grep_flat "$FBP" "report-only"; check $? "reviewing-framework-best-practices is report-only"
  grep_flat "$FBP" "findings.md"; check $? "reviewing-framework-best-practices writes findings.md"
  grep_flat "$FBP" "references/framework-best-practices-index.md"; check $? "reviewing-framework-best-practices links its index"
  grep_flat "$FBP" "Novelty"; check $? "reviewing-framework-best-practices states its boundary against Novelty"
  grep_flat "$FBP" "Technical"; check $? "reviewing-framework-best-practices states its boundary against Technical"
  grep_flat "$FBP" "deliberate exception"; check $? "reviewing-framework-best-practices calls out the multi-file exception"
fi

# ============================================================================
# Cross-cutting — shipped skills carry no dangling ADR pointers
# ============================================================================
# docs/adr/ lives at the repo root, outside the packaged plugin, so a facet running
# in a user's project cannot resolve a docs/adr path. The rule each ADR records is
# stated inline in the skill instead; guard against a pointer creeping back in.
adr_hits=$(grep -rl 'docs/adr' "$PLUGIN/skills" "$PLUGIN/README.md" 2>/dev/null || true)
if [ -z "$adr_hits" ]; then
  ok "shipped skills + README carry no docs/adr pointer"
else
  bad "shipped skills + README carry no docs/adr pointer (found in: $(printf '%s' "$adr_hits" | tr '\n' ' '))"
fi

exit $fail
