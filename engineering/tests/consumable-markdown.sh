#!/bin/sh
# The shared consumable-markdown reference must exist and carry its load-bearing conventions,
# so both SPEC-FORMAT and the feature-doc template can cite one source of truth.
set -e
ROOT=$(CDPATH= cd "$(dirname "$0")/../.." && pwd)
REF="$ROOT/engineering/references/consumable-markdown.md"

[ -f "$REF" ] || { echo "FAIL: $REF does not exist"; exit 1; }

# Match prose anchors regardless of line-wrapping (same approach as validate.sh).
flat() { tr '\n' ' ' < "$REF" | tr -s ' ' | grep -qiF -- "$1" || { echo "FAIL: consumable-markdown missing anchor: $1"; exit 1; }; }

flat "top-line hook"
flat "progressive disclosure"
flat "bold"                 # bold key terms on first use
flat "table"                # tables for enumerables
flat "diagrams at the point"
flat "worked example"

echo "PASS consumable-markdown.sh"
