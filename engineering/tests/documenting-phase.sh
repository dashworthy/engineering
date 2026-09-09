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

# --- validation-protocol orchestrator + four lens docs (Task 6) ---------------
REFS="$ROOT/engineering/skills/documenting/references"
VP="$REFS/validation-protocol.md"
[ -f "$VP" ] || { echo "FAIL: validation-protocol.md does not exist"; exit 1; }
for lens in accuracy structure links scope; do
  [ -f "$REFS/lenses/$lens.md" ] || { echo "FAIL: missing lens $lens.md"; exit 1; }
done

vpflat() { tr '\n' ' ' < "$VP" | tr -s ' ' | grep -qiF -- "$1" || { echo "FAIL: validation-protocol missing anchor: $1"; exit 1; }; }
vpflat "using-parallel-agents"   # fan-out mechanics
vpflat "inline floor"            # trivial-doc inline path, mirroring review-protocol
vpflat "why it bites"            # reuses review-protocol's finding grammar

# The structure lens carries the plain-language / anti-"claudish" fold-in; accuracy checks the diff.
grep -qiF "claudish" "$REFS/lenses/structure.md" || { echo "FAIL: structure lens must carry the anti-claudish check"; exit 1; }
grep -qiF "diff" "$REFS/lenses/accuracy.md" || { echo "FAIL: accuracy lens must check against the shipped diff"; exit 1; }

echo "PASS documenting-phase.sh"
