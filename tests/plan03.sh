#!/bin/sh
set -e
d=$(CDPATH= cd "$(dirname "$0")" && pwd)
sh "$d/frontmatter.sh" "$d/../skills/plan"
sh "$d/frontmatter.sh" "$d/../skills/build"
sh "$d/frontmatter.sh" "$d/../skills/brainstorming"
sh "$d/frontmatter.sh" "$d/../skills/spec"
sh "$d/frontmatter.sh" "$d/../skills/using-codebase-design"
sh "$d/triage.sh"
echo "ALL PLAN-03 CHECKS PASS"
