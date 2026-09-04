#!/bin/sh
set -e
d=$(CDPATH= cd "$(dirname "$0")" && pwd)
sh "$d/frontmatter.sh" "$d/../skills/codebase-design"
# tdd, diagnosing-bugs, and code-review folded into the build conductor as references
# (build/references/{tdd-loop,diagnosing,review-protocol}.md); they are no longer skills.
# No NOTICE / attribution introduced by this plan — scan codebase-design and the folded references.
if grep -rIl "NOTICE" "$d/../skills/codebase-design" "$d/../skills/build/references" 2>/dev/null; then
  echo "FAIL: attribution/NOTICE leak"; exit 1; fi
echo "ALL PLAN-02 CHECKS PASS"
