#!/bin/sh
set -e
d=$(CDPATH= cd "$(dirname "$0")" && pwd)
sh "$d/frontmatter.sh" "$d/../skills/codebase-design"
sh "$d/frontmatter.sh" "$d/../skills/tdd"
sh "$d/frontmatter.sh" "$d/../skills/diagnosing-bugs"
sh "$d/frontmatter.sh" "$d/../skills/code-review"
# No NOTICE / attribution introduced by this plan.
if grep -rIl "NOTICE" "$d/../skills/codebase-design" "$d/../skills/tdd" "$d/../skills/diagnosing-bugs" "$d/../skills/code-review" 2>/dev/null; then
  echo "FAIL: attribution/NOTICE leak"; exit 1; fi
echo "ALL PLAN-02 CHECKS PASS"
