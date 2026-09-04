#!/bin/sh
set -e
d=$(CDPATH= cd "$(dirname "$0")" && pwd)
# codebase-design folded into the design conductor as design/references/shape-lenses.md; tdd,
# diagnosing-bugs, and code-review folded into build/references/. None are skills any more.
# No NOTICE / attribution introduced — scan the folded design + build references.
if grep -rIl "NOTICE" "$d/../skills/design/references" "$d/../skills/build/references" 2>/dev/null; then
  echo "FAIL: attribution/NOTICE leak"; exit 1; fi
echo "ALL PLAN-02 CHECKS PASS"
