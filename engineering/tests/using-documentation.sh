#!/bin/sh
# The using-documentation producer skill must exist, name itself in frontmatter, and carry the
# load-bearing rules of its contract: where it writes, judged/surgical production, user-only
# minting, and composition with using-diagrams. (Task 4 extends this file to assert the three
# format references once they exist.)
set -e
ROOT=$(CDPATH= cd "$(dirname "$0")/../.." && pwd)
SK="$ROOT/engineering/skills/using-documentation/SKILL.md"

[ -f "$SK" ] || { echo "FAIL: $SK does not exist"; exit 1; }
grep -q '^name: using-documentation$' "$SK" || { echo "FAIL: SKILL.md frontmatter must name using-documentation"; exit 1; }

flat() { tr '\n' ' ' < "$SK" | tr -s ' ' | grep -qiF -- "$1" || { echo "FAIL: using-documentation missing anchor: $1"; exit 1; }; }

flat "docs/toc.md"
flat "docs/{domain}/{feature}"
flat "judged"
flat "surgical"
flat "never invent"          # user-only minting: agent never invents a domain/feature name
flat "using-diagrams"

echo "PASS using-documentation.sh"
