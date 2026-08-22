---
name: using-stacked-pull-requests
description: "[Foundation] Put each task of a plan on its own branch stacked on the one before it and open one pull request per task, keep the stack current when a lower PR changes, and land the stack in order — via Graphite (gt) when the repo has it, plain git+gh otherwise. Use when a plan's Global Constraints say `PR strategy: stacked`. Model-invoked; no command."
---

# Using Stacked Pull Requests

Say this first, plainly: `Using the using-stacked-pull-requests skill to stack this task's
pull request.`

## What this guarantees

One thing: given a task whose work is already committed, this skill puts that task on its own
branch stacked on the task before it, opens or updates **one pull request per task** based on
the correct parent branch, keeps the stack current when a lower pull request changes, and —
when the stack is ready — lands it in order. It reaches that end state through `gt` when the
repository already uses Graphite and through plain `git` + `gh` when it doesn't; the guarantee
is the stacked PR sitting on the correct base, not which tool put it there.

Nothing else is guaranteed. Read `## What this does not do` before assuming this skill decides
which tasks exist, whether a plan is stacked at all, or when the work is good enough to land.

## When this runs

Only when the plan's Global Constraints carry `PR strategy: stacked`. `writing-plans` writes
that line and emits, per task, a step that starts the task's branch and a step — after the
task's commit — that submits its PR; `executing-plans` reaches those steps in order and
dispatches this skill for them. A plan with no such line is an ordinary single-branch plan and
never reaches here; do not stack a plan that didn't ask to be stacked.

## Detect the tool

Prefer Graphite when the repository is already set up for it: `gt` is on `PATH` **and** the
repo is gt-initialized (its `gt` commands resolve against this repo rather than erroring that
it isn't tracked). Where both hold, use `gt` — its stacks and its restacking are what this skill
would otherwise reconstruct by hand. Where either is missing, fall back to plain `git` + `gh`;
`gh` is the baseline and is already assumed by `finishing-a-development-branch`. This is the
same shape `using-git-worktrees` uses: reach for the better tool when it's actually present,
fall back to raw git when it isn't, and never make the better tool a requirement. Do not
install `gt` or initialize Graphite in a repo that hasn't chosen it — portability means this
skill works in a bare repo with nothing but `git` and `gh`.

## Branch and base model

The model is **one branch per task**, all inside the single worktree `using-git-worktrees`
already established — this skill switches branches within that one checkout, it does not spawn
a worktree per task. The first task's branch starts from the trunk the work targets; task N's
branch starts from task N-1's branch, so the branches form a linear chain in the plan's own
order. A pull request's **base is its parent branch** — task N's PR targets task N-1's branch,
not trunk — which is what makes each PR show only its own task's diff instead of everything
below it. Name each branch for its task, `<topic>/<NN>-<task-slug>`, so `git branch` and the
PR list read in plan order rather than as a pile of unrelated names.

## Start a task's branch

Before a task's commits land, switch to its branch so they land in the right place. With `gt`,
create the branch as a child of the current one (`gt create`). With `git`, branch off the
parent: `git switch -c <topic>/<NN>-<task-slug> <parent-branch>`. This is the step that keeps
the stack linear — a task whose commits land on the parent branch by accident is a task with
no PR of its own and a lower PR that now carries two tasks' worth of diff.

## Submit a task's PR

After the task's commit exists on its branch, push the branch and open (or update) its pull
request against the parent branch. With `gt`, `gt submit` does the push and the PR together and
sets the base for you. With `git` + `gh`, push the branch and run
`gh pr create --base <parent-branch> --head <task-branch>` — the `--base` is what stacks it;
omitting it targets the default branch and collapses the stack. Take the PR's title and body
from the task itself, the same way the commit message came from the task's final step. Re-running
this on a task that already has a PR updates that PR rather than opening a second one.

## Keep the stack current (restack)

When a lower pull request changes — a review pushes a fix into it, or it lands and its commits
move — every branch above it now sits on a stale parent and must **restack** onto the new one.
With `gt`, `gt restack` (or `gt sync` after a merge) rebases the children and fixes their PR
bases automatically. With `git` + `gh`, rebase each child branch onto its updated parent in
order from the bottom up, force-push each with `--force-with-lease`, and, where a parent branch
was deleted by a merge, retarget the child's PR base with `gh pr edit --base <new-base>`. A
stack left un-restacked after a lower PR moves is a stack whose upper PRs show a diff against a
branch that no longer means what they think it does.

## Land the stack

Landing is bottom-up: merge the lowest open PR first, then restack what remains, then the next,
and so on to the top — never the top PR first, which would try to merge every task's diff at
once and defeat the point of stacking. With `gt`, `gt merge` walks the stack in that order and
restacks between merges. With `git` + `gh`, merge the bottom PR (`gh pr merge`), restack the
remainder onto the new trunk, and repeat. This is the path `finishing-a-development-branch`
delegates to when it detects a stacked run and offers **Land the stack** in place of opening a
single pull request; when it hands off here, walk the stack bottom-up until every task's PR has
landed.

## What this does not do

- It does not **write the plan** or decide which tasks exist. The tasks, their order, and their
  branches were set by `writing-plans`; this skill stacks what the plan already laid out.
- It does not **decide whether a plan is stacked.** That is the `PR strategy: stacked` line in
  the plan's Global Constraints; a plan without it is never stacked by this skill.
- It does not **run tdd, code review, or test hardening.** Each task's build, review gate, and
  the closing hardening pass belong to their own skills; this skill runs only after a task's
  work is committed.
- It does not **create the worktree.** `using-git-worktrees` establishes the single isolated
  checkout the whole stack lives in; this skill switches branches inside it and never makes
  another.
- It does not **decide the work is good enough to land.** Whether and when to land the stack is
  the user's call, carried out through `finishing-a-development-branch`; this skill performs the
  bottom-up merge when asked, it does not choose to.
