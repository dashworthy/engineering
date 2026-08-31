#!/bin/sh
# Structural and behavioural validation for the verity plugin.
# POSIX sh. Uses python3 (stdlib only) for JSON. Never requires jq.
# Run from anywhere: sh verity/tests/validate.sh

ROOT=$(cd "$(dirname "$0")/../.." && pwd)
PLUGIN="$ROOT/verity"
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
# Task 1.1 — scaffold + marketplace/README wiring
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
assert d["name"]=="verity", f'name is {d["name"]!r}, expected "verity"'
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
assert "verity" in names, f"verity not registered; found {names}"
v=[p for p in d["plugins"] if p["name"]=="verity"][0]
assert v["source"]=="./verity", f'source is {v["source"]!r}'
pv=json.load(open(sys.argv[2]))["version"]
assert v["version"]==pv, f'marketplace version {v["version"]!r} != plugin.json {pv!r}'
PY
  check $? "marketplace verity entry matches plugin.json"
else
  bad "root marketplace.json exists"
fi

# --- READMEs ----------------------------------------------------------------

[ -f "$PLUGIN/README.md" ]; check $? "verity/README.md exists"
[ -f "$ROOT/README.md" ] && grep -q "verity" "$ROOT/README.md"; check $? "root README names verity"

# ============================================================================
# Task 1.3 — the four skills, copied in, names unchanged
# ============================================================================

for skill in conducting-test-hardening auditing-test-gaps verifying-test-integrity writing-tests-from-brief; do
  S="$PLUGIN/skills/$skill/SKILL.md"
  [ -f "$S" ]; check $? "skills/$skill/SKILL.md exists"
  if [ -f "$S" ]; then
    head -1 "$S" | grep -q '^---$'; check $? "$skill has frontmatter"
    grep -q "^name: $skill$" "$S"; check $? "$skill frontmatter names itself"
  fi
done

# reference files travel with the skills that own them
for ref in brief-schema brief-template detecting-the-stack measuring-reports stack-markers; do
  [ -f "$PLUGIN/skills/conducting-test-hardening/references/$ref.md" ]
  check $? "conducting-test-hardening ships references/$ref.md"
done
[ -f "$PLUGIN/skills/verifying-test-integrity/references/defect-taxonomy.md" ]
check $? "verifying-test-integrity ships references/defect-taxonomy.md"

# ============================================================================
# Task 1.4 — foundation dependencies inlined, no cross-plugin reference
# ============================================================================

# verity is standalone: nothing under skills/ may reach back into engineering:
if grep -rq "engineering:" "$PLUGIN/skills"; then
  bad "no engineering: reference survives in verity/skills ($(grep -rl "engineering:" "$PLUGIN/skills" | tr '\n' ' '))"
else
  ok "no engineering: reference survives in verity/skills"
fi

COND="$PLUGIN/skills/conducting-test-hardening/SKILL.md"
if [ -f "$COND" ]; then
  # (a) the three dispatching-parallel-agents fan-out principles, stated inline
  grep_flat "$COND" "one message"; check $? "conducting inlines: fan out in one message (single wave)"
  grep_flat "$COND" "whole wave"; check $? "conducting inlines: wait for the whole wave before merging"
  grep_flat "$COND" "rather than dropping it"; check $? "conducting inlines: surface a failed/timed-out agent"
  # (b) the verification-before-completion gate principle, stated inline
  grep_flat "$COND" "run the verification commands"; check $? "conducting inlines: run the verification commands"
  grep_flat "$COND" "confirm their"; check $? "conducting inlines: confirm the actual output before claiming met"
fi

# ============================================================================
# Task 1.5 — run record written under .verity/, never .engineering/
# ============================================================================

if grep -rq "\.engineering" "$PLUGIN/skills"; then
  bad "no .engineering path survives in verity/skills ($(grep -rl "\.engineering" "$PLUGIN/skills" | tr '\n' ' '))"
else
  ok "no .engineering path survives in verity/skills"
fi

if [ -f "$COND" ]; then
  grep_flat "$COND" ".verity/<run>/test-hardening/"; check $? "conducting writes its run record under .verity/<run>/test-hardening/"
fi

# ============================================================================
# Task 1.6 — /harden command
# ============================================================================

CMD="$PLUGIN/commands/harden.md"
[ -f "$CMD" ]; check $? "commands/harden.md exists"
if [ -f "$CMD" ]; then
  head -1 "$CMD" | grep -q '^---$'; check $? "harden command has frontmatter"
  grep -q '^description:' "$CMD"; check $? "harden command frontmatter has a description"
  grep -q '^argument-hint:' "$CMD"; check $? "harden command frontmatter has an argument-hint"
  grep_flat "$CMD" "verity:conducting-test-hardening"; check $? "harden command invokes the conducting-test-hardening skill"
  grep_flat "$CMD" "CLAUDE_PLUGIN_ROOT"; check $? "harden command resolves scripts via CLAUDE_PLUGIN_ROOT"
fi

exit $fail
