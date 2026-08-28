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
  # ADR-0004 analysis boundary
  grep_flat "$TECH" "0004"; check $? "reviewing-technical cites ADR-0004"
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
  # ADR-0004 analysis boundary
  grep_flat "$ARCH" "0004"; check $? "reviewing-architectural cites ADR-0004"
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

exit $fail
