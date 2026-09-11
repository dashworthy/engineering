---
name: using-stacked-pull-requests
description: "Put each plan task on its own branch stacked on the one before it, open one pull request per task, and keep the stack current when a lower PR changes — via Graphite (gt) when present, plain git+gh otherwise. The pipeline opens and maintains the stack but never lands it; a human merges the PRs outside the pipeline. Use when a plan's Global Constraints say `PR strategy: stacked`."
---

# Using Stacked Pull Requests

Say this first, plainly: `Using the using-stacked-pull-requests skill to stack this task's
pull request.`

## What this guarantees

One thing: given a task whose work is already committed, this skill produces **one pull
request per task**, each based on the correct parent branch, and keeps the stack current when a
lower pull request changes. It never merges the stack — landing is a human's job outside the
pipeline. It reaches that end
state through `gt` when the repository already uses Graphite and through plain `git` + `gh`
when it doesn't; the guarantee is the stacked PR sitting on the correct base, not which tool
put it there.

## When this runs

Only when the plan's Global Constraints carry `PR strategy: stacked`. `plan` writes
that line and emits, per task, a step that starts the task's branch and a step — after the
task's commit — that submits its PR. A plan with no such line is an ordinary single-branch plan and
never reaches here; do not stack a plan that didn't ask to be stacked.

## Detect the tool

Prefer Graphite when the repository is already set up for it: `gt` on `PATH` **and** the repo
gt-initialized (its `gt` commands resolve against this repo rather than erroring that it isn't
tracked). Where both hold, use `gt` — its stacks and restacking are what this skill would
otherwise reconstruct by hand. Where either is missing, fall back to plain `git` + `gh` (the
baseline, already assumed by `finish`). Same prefer-native-else-raw-git
shape build uses to set up its worktree. Do not install `gt` or initialize Graphite in a repo that
hasn't chosen it — this skill works in a bare repo with nothing but `git` and `gh`.

## Branch and base model

The model is **one branch per task**, all inside the single isolated checkout build
already established — the worktree or feature branch build set up. Either way it is one checkout:
this skill switches branches within it, and it does not spawn a worktree per task. The first task's
branch starts from the trunk the work targets — the branch the PRs merge into, not build's own
isolation branch, so even in the feature-branch case the stack sits on task branches and no
work lands on the default branch; task N's
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

Do this **per task, the moment its work is committed** — not batched at the end of the run, and
never gated by a question. Building and pushing the PR is an automatic step of finishing a task,
not a decision to put to the human: do not ask whether to push now or wait, and do not hold the
push until later tasks are done. Each task's PR goes up as that task lands.

## Keep the stack current (restack)

When a lower pull request changes — a review pushes a fix into it, or it lands and its commits
move — every branch above it now sits on a stale parent and must **restack** onto the new one.
With `gt`, `gt restack` (or `gt sync` after a merge) rebases the children and fixes their PR
bases automatically. With `git` + `gh`, rebase each child branch onto its updated parent in
order from the bottom up, force-push each with `--force-with-lease`, and, where a parent branch
was deleted by a merge, retarget the child's PR base with `gh pr edit --base <new-base>`.

## The pipeline does not land the stack

This skill opens and maintains the stack; it never merges it. Landing a stacked run is
bottom-up — the lowest open PR first, then restack what remains, then the next — but that
merge is a human's job, done outside the pipeline once the PRs are reviewed and approved. When
a human lands a lower PR that way, the branches above it need restacking onto the new base;
that is the "Keep the stack current" step above, and it is the only part of landing this skill
takes part in.

## What this does not do

- It does not **write the plan** or decide which tasks exist. The tasks, their order, and their
  branches were set by `plan`; this skill stacks what the plan already laid out.
- It does not **decide whether a plan is stacked.** That's the `PR strategy: stacked` line —
  see "When this runs"; a plan without it is never stacked here.
- It does not **run tdd, code review, or test hardening.** Each task's build, review gate, and
  the closing hardening pass belong to `build`; this skill runs only after a task's
  work is committed.
- It does not **establish the isolation.** `build` already did — a worktree, or a feature
  branch in the shared checkout — and that single checkout is
  where the whole stack lives; this skill switches branches inside it and never creates isolation
  of its own. (`build`'s Establish-the-workspace step is where that isolation is created.)
- It does not **land or merge the stack.** The pipeline integrates only by opening pull
  requests; merging the stack bottom-up is a human's job outside the pipeline, once the PRs are
  approved. This skill opens and maintains the stack — it never merges it, and is never asked to.
