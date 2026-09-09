#!/bin/sh
# The documenting phase must exist, name itself in frontmatter, and carry its contract: it runs
# between build and finish, judges whether documentation is warranted, invokes using-documentation
# to produce, validates via its validation-protocol fan-out, and adds no new human gate.
# (Task 6 extends this file to assert the validation-protocol orchestrator and four lens docs.)
set -e
ROOT=$(CDPATH= cd "$(dirname "$0")/../.." && pwd)
SK="$ROOT/engineering/skills/documenting/SKILL.md"

[ -f "$SK" ] || { echo "FAIL: $SK does not exist"; exit 1; }
grep -q '^name: documenting$' "$SK" || { echo "FAIL: SKILL.md frontmatter must name documenting"; exit 1; }

flat() { tr '\n' ' ' < "$SK" | tr -s ' ' | grep -qiF -- "$1" || { echo "FAIL: documenting phase missing anchor: $1"; exit 1; }; }

flat "build"
flat "finish"
flat "using-documentation"
flat "validation-protocol"
flat "judged"
flat "skip"                 # judged skip with a recorded reason
flat "plan gate already"    # no new human gate — the plan gate already authorized the run

echo "PASS documenting-phase.sh"
