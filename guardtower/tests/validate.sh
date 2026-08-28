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
# (Task 3/4/5 assertions appended as those tasks are built.)
# ============================================================================

exit $fail
