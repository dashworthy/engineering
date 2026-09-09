#!/bin/sh
# The consulting-documentation reference must exist and drive brainstorming's Explore-context beat
# to read the docs index BEFORE greps, use it to target (not replace) code reading, and record
# which docs were consulted so the spec can cite them.
set -e
ROOT=$(CDPATH= cd "$(dirname "$0")/../.." && pwd)
REF="$ROOT/engineering/skills/brainstorming/references/consulting-documentation.md"
BS="$ROOT/engineering/skills/brainstorming/SKILL.md"

[ -f "$REF" ] || { echo "FAIL: $REF does not exist"; exit 1; }

rflat() { tr '\n' ' ' < "$REF" | tr -s ' ' | grep -qiF -- "$1" || { echo "FAIL: consulting-documentation missing anchor: $1"; exit 1; }; }
rflat "docs/toc.md"          # read the index first
rflat "before"               # before greps
rflat "grep"
rflat "target"               # target code reading, not replace it
rflat "record"               # record which docs were consulted (for citation)

# brainstorming's Explore-context beat cites the reference.
bflat() { tr '\n' ' ' < "$BS" | tr -s ' ' | grep -qiF -- "$1" || { echo "FAIL: brainstorming missing anchor: $1"; exit 1; }; }
bflat "consulting-documentation"

echo "PASS consulting-docs.sh"
