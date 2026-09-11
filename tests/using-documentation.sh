#!/bin/sh
# The using-documentation producer skill must exist, name itself in frontmatter, and carry the
# load-bearing rules of its contract: where it writes, judged/surgical production, user-only
# minting, and composition with using-diagrams. (Task 4 extends this file to assert the three
# format references once they exist.)
set -e
ROOT=$(CDPATH= cd "$(dirname "$0")/.." && pwd)
SK="$ROOT/skills/using-documentation/SKILL.md"

[ -f "$SK" ] || { echo "FAIL: $SK does not exist"; exit 1; }
grep -q '^name: using-documentation$' "$SK" || { echo "FAIL: SKILL.md frontmatter must name using-documentation"; exit 1; }

flat() { tr '\n' ' ' < "$SK" | tr -s ' ' | grep -qiF -- "$1" || { echo "FAIL: using-documentation missing anchor: $1"; exit 1; }; }

flat "docs/toc.md"
flat "docs/{domain}/{feature}"
flat "judged"
flat "surgical"
flat "never invent"          # user-only minting: agent never invents a domain/feature name
flat "using-diagrams"

# The three format references the producer renders from.
REFS="$ROOT/skills/using-documentation/references"
for r in FEATURE-DOC-TEMPLATE.md TOC-FORMAT.md REFERENCE-TABLE-FORMAT.md; do
  [ -f "$REFS/$r" ] || { echo "FAIL: missing reference $r"; exit 1; }
done
# The template is generic — no leakage from the exemplar it was distilled from.
for bad in Wastequip OroCommerce configurator; do
  grep -qi "$bad" "$REFS/FEATURE-DOC-TEMPLATE.md" && { echo "FAIL: FEATURE-DOC-TEMPLATE leaks project-specific term: $bad"; exit 1; }
done
grep -qF "consumable-markdown.md" "$REFS/FEATURE-DOC-TEMPLATE.md" || { echo "FAIL: FEATURE-DOC-TEMPLATE must cite consumable-markdown.md"; exit 1; }
# The toc format carries the domain/grouping column; the reference-table format does not.
grep -qiF "Domain" "$REFS/TOC-FORMAT.md" || { echo "FAIL: TOC-FORMAT must carry a Domain/grouping column"; exit 1; }
grep -qF "|" "$REFS/REFERENCE-TABLE-FORMAT.md" || { echo "FAIL: REFERENCE-TABLE-FORMAT must show a table"; exit 1; }

echo "PASS using-documentation.sh"
