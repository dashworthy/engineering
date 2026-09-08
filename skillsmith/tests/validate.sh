#!/bin/sh
# Structural validation for the skillsmith plugin's audit — the guardtower-shaped,
# per-seam auditing-skills skill and its uniform check contract.
# POSIX sh. Uses python3 (stdlib only) for JSON. Never requires jq.
# Run from anywhere: sh skillsmith/tests/validate.sh

ROOT=$(cd "$(dirname "$0")/../.." && pwd)
PLUGIN="$ROOT/skillsmith"
AUDIT="$PLUGIN/skills/auditing-skills"
ORCH="$AUDIT/SKILL.md"
CHECKS="$AUDIT/references/checks"
fail=0

ok()   { printf 'ok   - %s\n' "$1"; }
bad()  { printf 'FAIL - %s\n' "$1"; fail=1; }
check(){ if [ "$1" -eq 0 ]; then ok "$2"; else bad "$2"; fi }

# Match a prose anchor regardless of how the source is line-wrapped. `--` before the pattern is
# load-bearing: without it grep parses an anchor beginning with a hyphen as its own options.
grep_flat() {  # grep_flat <file> <literal phrase>
  tr '\n' ' ' < "$1" | tr -s ' ' | grep -qF -- "$2"
}

# The eleven seams. The first ten are STATIC (they read the artifact and own a checklist under
# their own references/); the eleventh, auditing-pressure-test, is BEHAVIORAL and handled apart.
STATIC_SEAMS="auditing-anti-patterns auditing-verbosity auditing-confusing-logic \
auditing-discoverability auditing-progressive-disclosure auditing-force-calibration \
auditing-cross-skill-duplication auditing-subagent-economics auditing-dead-skills \
auditing-runtime-integrity"
PRESSURE_SEAM="auditing-pressure-test"

# ============================================================================
# Manifest + marketplace + README wiring
# ============================================================================

[ -f "$PLUGIN/.claude-plugin/plugin.json" ]; check $? "plugin.json exists"
if [ -f "$PLUGIN/.claude-plugin/plugin.json" ]; then
  python3 - "$PLUGIN/.claude-plugin/plugin.json" <<'PY'
import json,sys,re
d=json.load(open(sys.argv[1]))
required={"name","description","version","author","license"}
missing=required-set(d)
assert not missing, f"plugin.json missing keys: {sorted(missing)}"
assert d["name"]=="skillsmith", f'name is {d["name"]!r}, expected "skillsmith"'
assert re.fullmatch(r"\d+\.\d+\.\d+", str(d["version"])), f'version {d["version"]!r} is not semver'
assert d["license"]=="MIT", f'license is {d["license"]!r}, expected "MIT"'
PY
  check $? "plugin.json is well-formed"
fi

if [ -f "$ROOT/.claude-plugin/marketplace.json" ]; then
  python3 - "$ROOT/.claude-plugin/marketplace.json" "$PLUGIN/.claude-plugin/plugin.json" <<'PY'
import json,sys
d=json.load(open(sys.argv[1]))
names=[p["name"] for p in d["plugins"]]
assert "skillsmith" in names, f"skillsmith not registered; found {names}"
s=[p for p in d["plugins"] if p["name"]=="skillsmith"][0]
assert s["source"]=="./skillsmith", f'source is {s["source"]!r}'
pv=json.load(open(sys.argv[2]))["version"]
assert s["version"]==pv, f'marketplace version {s["version"]!r} != plugin.json {pv!r}'
PY
  check $? "marketplace skillsmith entry matches plugin.json"
else
  bad "root marketplace.json exists"
fi

[ -f "$PLUGIN/README.md" ]; check $? "skillsmith/README.md exists"
[ -f "$ROOT/README.md" ] && grep -q "skillsmith" "$ROOT/README.md"; check $? "root README names skillsmith"

# testing-skills was folded into the audit's pressure-test seam and removed — nothing may still
# reference it, and its skill directory must be gone.
[ ! -d "$PLUGIN/skills/testing-skills" ]; check $? "standalone testing-skills skill is removed (folded into the pressure-test seam)"
# Scan the shipped plugin, not this suite (whose own assertion text names the folded skill).
if grep -rn "testing-skills" "$PLUGIN" 2>/dev/null | grep -v '/tests/' >/dev/null 2>&1; then
  bad "no dangling 'testing-skills' reference remains in the plugin"
else
  ok "no dangling 'testing-skills' reference remains in the plugin"
fi

# ============================================================================
# The auditing-skills orchestrator
# ============================================================================

[ -f "$ORCH" ]; check $? "auditing-skills/SKILL.md exists"
if [ -f "$ORCH" ]; then
  head -1 "$ORCH" | grep -q '^---$'; check $? "auditing-skills has frontmatter"
  grep -q '^name: auditing-skills$' "$ORCH"; check $? "auditing-skills frontmatter names itself"
  # description carries discovery triggers for BOTH the static audit and the behavioral seam
  awk '/^description:/{print; exit}' "$ORCH" | grep -qi "audit"; check $? "description carries an audit trigger"
  awk '/^description:/{print; exit}' "$ORCH" | grep -qiE "pressure|followed|hardening|discovered"; check $? "description carries a behavioral/compliance trigger"

  # propose-and-apply gate (NOT report-only — the audit's departure from guardtower)
  grep_flat "$ORCH" "one finding, one question"; check $? "orchestrator puts each finding as its own question"
  grep_flat "$ORCH" "apply the approved"; check $? "orchestrator applies approved fixes (propose-and-apply, not report-only)"

  # tool-agnostic idioms — no harness-specific tool named as the only mechanism
  grep_flat "$ORCH" "multi-select choice"; check $? "orchestrator runs the seam menu as a multi-select choice"
  ! grep_flat "$ORCH" "AskUserQuestion"; check $? "orchestrator names no harness-specific question tool"
  grep_flat "$ORCH" "in whatever todo list your harness provides"; check $? "orchestrator tracks todos tool-agnostically"
  ! grep_flat "$ORCH" "TodoWrite"; check $? "orchestrator names no harness-specific todo tool"

  # fan-out + reconcile + pre-check machinery
  grep_flat "$ORCH" "pre-check"; check $? "orchestrator pre-fills the menu"
  grep_flat "$ORCH" "dispatching-parallel-agents"; check $? "orchestrator fans out via dispatching-parallel-agents"
  grep_flat "$ORCH" "reconcil"; check $? "orchestrator reconciles across seams"
  grep_flat "$ORCH" "one todo per selected check"; check $? "orchestrator seeds a todo per selected seam"
  grep_flat "$ORCH" "in_progress"; check $? "orchestrator marks a seam in_progress as it is dispatched"

  # the unresolvable-reference trap: dispatched seams get their own absolute path
  grep_flat "$ORCH" "absolute path"; check $? "orchestrator hands each seam the absolute path to its check.md"

  # shared references linked one level deep from the orchestrator
  grep_flat "$ORCH" "references/check-contract.md"; check $? "orchestrator links references/check-contract.md"
  grep_flat "$ORCH" "references/hard-stops.md"; check $? "orchestrator links references/hard-stops.md"
  grep_flat "$ORCH" "references/subagent-economics.md"; check $? "orchestrator links references/subagent-economics.md"

  # the pressure-test seam is the deliberate exception: opt-in, never pre-checked, always dispatched
  grep_flat "$ORCH" "never pre-checked"; check $? "orchestrator states the pressure-test seam is never pre-checked"
  grep_flat "$ORCH" "always dispatched"; check $? "orchestrator states the pressure-test seam is always dispatched, never inlined"
fi

# ============================================================================
# The shared contract + hard-stops
# ============================================================================

CONTRACT="$AUDIT/references/check-contract.md"
[ -f "$CONTRACT" ]; check $? "references/check-contract.md exists"
if [ -f "$CONTRACT" ]; then
  for field in check relevance findings dropped severity confidence location saving fix top_n floor; do
    grep_flat "$CONTRACT" "$field"; check $? "check-contract names the $field field"
  done
  grep_flat "$CONTRACT" "absolute path to its own"; check $? "check-contract hands the seam its own absolute path (resolves references)"
  grep_flat "$CONTRACT" "behavioral"; check $? "check-contract accounts for the one behavioral seam"
fi

STOPS="$AUDIT/references/hard-stops.md"
[ -f "$STOPS" ]; check $? "references/hard-stops.md exists"
if [ -f "$STOPS" ]; then
  grep_flat "$STOPS" "Relevance gate"; check $? "hard-stops names the relevance gate"
  grep_flat "$STOPS" "Top-N"; check $? "hard-stops names the top-N cap"
  grep_flat "$STOPS" "floor"; check $? "hard-stops names the confidence/severity floor"
  grep_flat "$STOPS" "at the source"; check $? "hard-stops states seams self-enforce at the source"
fi

[ -f "$AUDIT/references/subagent-economics.md" ]; check $? "references/subagent-economics.md exists (shared lens)"

# ============================================================================
# Every seam is wired into the menu, and every seam self-limits at the source
# ============================================================================

for seam in $STATIC_SEAMS $PRESSURE_SEAM; do
  cm="$CHECKS/$seam/check.md"
  [ -f "$cm" ]; check $? "$seam/check.md exists"
  # the orchestrator menu links this seam
  if [ -f "$ORCH" ]; then
    grep_flat "$ORCH" "references/checks/$seam/check.md"; check $? "menu wires $seam"
  fi
  if [ -f "$cm" ]; then
    grep_flat "$cm" "Say this first"; check $? "$seam states its say-this-first line"
    grep_flat "$cm" "Relevance gate"; check $? "$seam runs the relevance gate first"
    grep_flat "$cm" "../../hard-stops.md"; check $? "$seam cites the shared hard-stops"
    grep_flat "$cm" "../../check-contract.md"; check $? "$seam cites the shared contract"
    # report-only-and-propose: a seam proposes; the orchestrator applies
    grep_flat "$cm" "report-only"; check $? "$seam is report-only (proposes; orchestrator applies)"
  fi
done

# --- every STATIC seam owns a checklist under its own references/, cited one level deep ---
for seam in $STATIC_SEAMS; do
  cm="$CHECKS/$seam/check.md"
  if [ "$seam" = "auditing-subagent-economics" ]; then
    # the one static seam with no local checklist: it reuses the shared economics reference
    grep_flat "$cm" "../../subagent-economics.md"; check $? "$seam reuses the shared subagent-economics lens (no duplicate checklist)"
    continue
  fi
  # its checklist is <name-minus-auditing>-checklist.md — derive and confirm it is cited and exists
  base=$(printf '%s' "$seam" | sed 's/^auditing-//')
  cl="references/${base}-checklist.md"
  grep_flat "$cm" "$cl"; check $? "$seam cites its own $cl"
  [ -f "$CHECKS/$seam/$cl" ]; check $? "$seam/$cl exists"
done

# ============================================================================
# The behavioral pressure-test seam — the deliberate exception
# ============================================================================

PT="$CHECKS/$PRESSURE_SEAM/check.md"
if [ -f "$PT" ]; then
  grep_flat "$PT" "behavioral"; check $? "pressure-test declares itself behavioral"
  grep_flat "$PT" "never inlined"; check $? "pressure-test is always dispatched, never inlined"
  grep_flat "$PT" "never pre-checked"; check $? "pressure-test is opt-in (never pre-checked)"
  grep_flat "$PT" "fresh subagent"; check $? "pressure-test runs trials on fresh subagents"
  grep_flat "$PT" "rationalization"; check $? "pressure-test returns surviving rationalizations as findings"
  # its folded depth, cited one level deep
  grep_flat "$PT" "references/harness.md"; check $? "pressure-test links references/harness.md"
  grep_flat "$PT" "references/pressure-scenarios.md"; check $? "pressure-test links references/pressure-scenarios.md"
  [ -f "$CHECKS/$PRESSURE_SEAM/references/harness.md" ]; check $? "pressure-test/references/harness.md exists (folded from testing-skills)"
  [ -f "$CHECKS/$PRESSURE_SEAM/references/pressure-scenarios.md" ]; check $? "pressure-test/references/pressure-scenarios.md exists (folded from testing-skills)"
fi

# ============================================================================
# Link integrity — every relative .md link in the audit skill resolves
# ============================================================================

broken=""
for f in $(find "$AUDIT" -name '*.md'); do
  d=$(dirname "$f")
  for link in $(grep -oE '\]\(([^)]+\.md)\)' "$f" 2>/dev/null | sed -E 's/\]\(([^)]+)\)/\1/'); do
    case "$link" in
      http*|/*) continue ;;   # skip absolutes / URLs
    esac
    [ -f "$d/$link" ] || broken="$broken\n  $f -> $link"
  done
done
if [ -z "$broken" ]; then
  ok "every relative .md link in auditing-skills resolves"
else
  printf 'FAIL - broken links:%b\n' "$broken"; fail=1
fi

# ============================================================================
echo
if [ "$fail" -eq 0 ]; then
  echo "ALL SKILLSMITH AUDIT CHECKS PASS"
else
  echo "SOME SKILLSMITH AUDIT CHECKS FAILED"
fi
exit $fail
