#!/bin/sh
# Foundation suite: every non-live check. (e2e.sh is live/CI-only and excluded here.)
set -e
d=$(CDPATH= cd "$(dirname "$0")" && pwd)
sh "$d/hook.sh"
sh "$d/run-context.sh"
sh "$d/reconcile.sh"
sh "$d/absorb-signal.sh"
sh "$d/absorb-vernacular.sh"
sh "$d/absorb-verity.sh"
sh "$d/absorb-approval-gate.sh"
sh "$d/validate.sh"
for name in to-spec interrogating-requirements clarifying-docblocks rewriting-docblock-prose; do
  sh "$d/frontmatter.sh" "$d/../skills/$name"
done
sh "$d/stacked-prs.sh"
echo "ALL FOUNDATION CHECKS PASS"
