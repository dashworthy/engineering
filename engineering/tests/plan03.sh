#!/bin/sh
set -e
d=$(CDPATH= cd "$(dirname "$0")" && pwd)
sh "$d/frontmatter.sh" "$d/../skills/writing-plans"
sh "$d/frontmatter.sh" "$d/../skills/executing-plans"
sh "$d/frontmatter.sh" "$d/../skills/brainstorming"
sh "$d/frontmatter.sh" "$d/../skills/resolving-merge-conflicts"
sh "$d/triage.sh"
echo "ALL PLAN-03 CHECKS PASS"
