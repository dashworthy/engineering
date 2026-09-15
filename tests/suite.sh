#!/bin/sh
# Foundation suite: every non-live check. (e2e.sh is live/CI-only and excluded here.)
set -e
d=$(CDPATH= cd "$(dirname "$0")" && pwd)
sh "$d/hook.sh"
sh "$d/run-context.sh"
sh "$d/absorb-signal.sh"
sh "$d/absorb-verity.sh"
sh "$d/absorb-approval-gate.sh"
sh "$d/validate.sh"
sh "$d/consumable-markdown.sh"
sh "$d/using-documentation.sh"
sh "$d/documenting-phase.sh"
sh "$d/consulting-docs.sh"
for name in signal triage receiving-code-review brainstorming spec using-codebase-design plan build finish code-review using-documentation documenting; do
  sh "$d/frontmatter.sh" "$d/../skills/$name"
done
sh "$d/stacked-prs.sh"
sh "$d/triage.sh"
sh "$d/code-review-entrance.sh"
sh "$d/entrances-parallel.sh"
echo "ALL FOUNDATION CHECKS PASS"
