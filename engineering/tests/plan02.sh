#!/bin/sh
set -e
d=$(CDPATH= cd "$(dirname "$0")" && pwd)
# using-codebase-design is a shared skill (its shape lenses in using-codebase-design/SKILL.md); to-spec became
# the spec skill; tdd and code-review folded into build/references/; diagnosing.md into
# triage/references/. brainstorming, spec, and using-codebase-design are skills.
# No NOTICE / attribution introduced — scan the moved references.
if grep -rIl "NOTICE" "$d/../skills/using-codebase-design/references" "$d/../skills/spec/references" "$d/../skills/build/references" "$d/../skills/triage/references" 2>/dev/null; then
  echo "FAIL: attribution/NOTICE leak"; exit 1; fi
echo "ALL PLAN-02 CHECKS PASS"
