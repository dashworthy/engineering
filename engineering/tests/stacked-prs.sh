#!/bin/sh
# Content gate for the stacked-pull-requests feature. Pins the required prose of every file
# the feature touches via flattened fixed-string anchors, in the same idiom as validate.sh.
# Prose is line-wrapped for readability, so every check flattens newlines before matching;
# a check must not depend on where a cosmetic wrap happens to fall.
# Run from anywhere: sh engineering/tests/stacked-prs.sh
set -e
PLUGIN=$(CDPATH= cd "$(dirname "$0")/.." && pwd)
fail=0

# grep_flat <file> <literal phrase>: match a phrase regardless of line wrapping. The `--`
# before the pattern is load-bearing — an anchor beginning with '#' or '-' would otherwise be
# read as options.
grep_flat() { tr '\n' ' ' < "$1" | tr -s ' ' | grep -qF -- "$2"; }

# need <file> <phrase> <label>
need() {
  if [ ! -f "$1" ]; then printf 'FAIL - %s (missing file %s)\n' "$3" "$1"; fail=1; return; fi
  if grep_flat "$1" "$2"; then printf 'ok   - %s\n' "$3"; else printf 'FAIL - %s\n' "$3"; fail=1; fi
}

# --- the new skill -----------------------------------------------------------
S="$PLUGIN/skills/using-stacked-pull-requests/SKILL.md"
need "$S" "Using the using-stacked-pull-requests skill" "skill: say-this-first line"
need "$S" "## What this guarantees"                      "skill: guarantees section"
need "$S" "one pull request per task"                    "skill: one PR per task guarantee"
need "$S" "Graphite"                                     "skill: names Graphite"
need "$S" "gt"                                           "skill: names gt"
need "$S" "gh"                                           "skill: names gh baseline"
need "$S" "one branch per task"                          "skill: one branch per task model"
need "$S" "base is its parent branch"                    "skill: PR base is parent branch"
need "$S" "restack"                                      "skill: restack section"
need "$S" "Land the stack"                               "skill: land-the-stack section"
need "$S" "bottom-up"                                    "skill: land bottom-up in order"
need "$S" "## What this does not do"                     "skill: does-not-do section"

# --- writing-plans emits stacked-PR plans ------------------------------------
W="$PLUGIN/skills/writing-plans/SKILL.md"
need "$W" "PR strategy: stacked"                         "writing-plans: stacked strategy marker"
need "$W" "using-stacked-pull-requests"                  "writing-plans: names the skill"
need "$W" "not eligible for"                             "writing-plans: parallel-mode exclusion"
need "$W" "submit the stacked PR"                        "writing-plans: per-task submit step"

# --- executing-plans honors the strategy -------------------------------------
E="$PLUGIN/skills/executing-plans/SKILL.md"
need "$E" "PR strategy"                                  "executing-plans: reads PR strategy"
need "$E" "using-stacked-pull-requests"                  "executing-plans: names the skill"
need "$E" "sequentially"                                 "executing-plans: stacked runs sequentially"

# --- finishing-a-development-branch lands the stack --------------------------
F="$PLUGIN/skills/finishing-a-development-branch/SKILL.md"
need "$F" "Land the stack"                               "finishing: land-the-stack option"
need "$F" "using-stacked-pull-requests"                  "finishing: delegates to the skill"

[ "$fail" = 0 ] && echo "STACKED-PRS CONTENT: ALL CHECKS PASS" || { echo "STACKED-PRS CONTENT FAILED"; exit 1; }
