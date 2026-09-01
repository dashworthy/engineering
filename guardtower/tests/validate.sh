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
  grep_flat "$ORCH" "AskUserQuestion"; check $? "reviewing runs the facet menu via AskUserQuestion"
  grep_flat "$ORCH" "pre-checked"; check $? "reviewing states the 3 core facets are pre-checked"
  grep_flat "$ORCH" ".guardtower/"; check $? "reviewing writes under .guardtower/"
  grep_flat "$ORCH" "dispatching-parallel-agents"; check $? "reviewing fans out via dispatching-parallel-agents"
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
  printf '%s' "$desc" | grep -qi "reuse"; check $? "reviewing-technical description names reuse"
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
  grep_flat "$TCL" "Reuse over reinvention"; check $? "technical-checklist covers reuse over reinvention"
  grep_flat "$TCL" "Inefficient data access"; check $? "technical-checklist covers inefficient data access"
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
  # menu complete — all seven facets wired, no row still "coming soon"
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
