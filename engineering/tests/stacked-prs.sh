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

# never <file> <phrase> <label>: fails if the phrase IS present — locks a removal in so the
# merge-as-option prose can't creep back. The pipeline integrates only by pull request.
never() {
  if [ ! -f "$1" ]; then printf 'FAIL - %s (missing file %s)\n' "$3" "$1"; fail=1; return; fi
  if grep_flat "$1" "$2"; then printf 'FAIL - %s (found forbidden: %s)\n' "$3" "$2"; fail=1; else printf 'ok   - %s\n' "$3"; fi
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
need "$S" "The pipeline does not land the stack"         "skill: does-not-land section"
need "$S" "it never merges it"                           "skill: never merges the stack"
need "$S" "bottom-up"                                    "skill: describes bottom-up landing (a human's job)"
need "$S" "## What this does not do"                     "skill: does-not-do section"
need "$S" "Where either is missing, fall back to plain"  "skill: tool fallback rule (not gt-required)"
need "$S" "task N's branch starts from task N-1's branch" "skill: branch-chain start point"
need "$S" "it does not spawn a worktree per task"        "skill: single worktree, not per-task"
need "$S" "<topic>/<NN>-<task-slug>"                     "skill: branch naming convention"
need "$S" "git switch -c"                                "skill: git start-branch command"
need "$S" "gt submit"                                    "skill: gt submit command"
need "$S" "gh pr create --base"                          "skill: gh pr create --base (the flag that stacks)"
need "$S" "--force-with-lease"                           "skill: restack force-push mechanics"
need "$S" "gh pr edit --base"                            "skill: restack retargets a deleted parent"
never "$S" "gh pr merge"                                 "skill: never issues a merge command"

# --- plan emits stacked-PR plans ------------------------------------
W="$PLUGIN/skills/plan/SKILL.md"
need "$W" "PR strategy: stacked"                         "plan: stacked strategy marker"
need "$W" "using-stacked-pull-requests"                  "plan: names the skill"
need "$W" "submit the stacked PR"                        "plan: per-task submit step"
need "$W" "starts the task's stacked branch off the previous task's branch" "plan: per-task opening branch-start step"
need  "$W" "Every plan ships as a"                        "plan: every plan is stacked, no single-PR option"
need  "$W" "there is no parallel fan-out"                "plan: stacking is linear, no parallel fan-out"
never "$W" "opt-in per plan"                             "plan: stacking is mandatory, not opt-in"
never "$W" "Single PR at the end"                        "plan: no single-PR alternative offered"

# --- build honors the strategy -------------------------------------
E="$PLUGIN/skills/build/SKILL.md"
need "$E" "PR strategy"                                  "build: reads PR strategy"
need "$E" "using-stacked-pull-requests"                  "build: names the skill"
need "$E" "sequentially"                                 "build: stacked runs sequentially"
need "$E" "land on that task's own branch" "build: commit on the right branch"

# --- finish opens the stack, never lands it --------------------------
F="$PLUGIN/skills/finish/SKILL.md"
need  "$F" "Open the stacked PRs"                         "finishing: open-the-stacked-PRs option"
need  "$F" "using-stacked-pull-requests"                 "finishing: delegates to the skill"
need  "$F" "open stacked pull requests already sitting on the branch" "finishing: detect stacked via open PRs"
need  "$F" "a human lands it bottom-up, outside the pipeline" "finishing: human lands the stack, not the pipeline"
never "$F" "Merge directly"                              "finishing: no merge-directly option"
never "$F" "gh pr merge"                                 "finishing: issues no merge command"

[ "$fail" = 0 ] && echo "STACKED-PRS CONTENT: ALL CHECKS PASS" || { echo "STACKED-PRS CONTENT FAILED"; exit 1; }
