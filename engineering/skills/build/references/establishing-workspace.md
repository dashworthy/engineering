# Establishing the workspace

Build owns VCS isolation: before a single file changes, the work is moved into a workspace
nothing else depends on — its own checkout or its own branch, off whatever branch is currently
checked out. This is the one place the pipeline creates that workspace; the pre-build phases
(the entrances, the design dialogue, spec, plan) run on the current branch and write only the
gitignored `.engineering/<run>/` scratch, so nothing lands on the branch until here.

The isolation *kind* was settled at the plan gate and recorded in the plan's Global Constraints
as an `Isolation:` line — `worktree` (the default) or `feature-branch`. Read it, then follow the
steps below. The base is simply the branch checked out now: trunk for a signal or triage run, the
review branch for a `receiving-code-review` run (that entrance checked it out).

## Detect existing isolation first

Creating a workspace when one already exists wastes the setup and can leave two copies drifting
apart. Before creating anything, work out whether isolation is already in place — a worktree this
session created, or a non-default branch already checked out on top of the base.

When it is ambiguous whether the current checkout is already a linked worktree, confirm it: inside
a work tree, `git rev-parse --git-dir --git-common-dir` printing two different paths while
`git rev-parse --show-superproject-working-tree` prints nothing is a linked worktree (already
isolated); equal paths are the repository's one shared checkout, and a non-empty superproject path
is a submodule — treat neither as isolation.

Already isolated: skip creation, go straight to project setup below. Not isolated: create the
recorded kind.

## Worktree (the `worktree` default)

Prefer the harness's native worktree tool over raw `git worktree` — it creates the linked
worktree, picks a branch, and switches the session's working directory in one step, and it refuses
to run again on top of a worktree it created earlier in the same session. Give it a name that says
what the task is, not a timestamp. No native tool, or it declines (for example outside a git
repository): fall back to `git worktree add -b <task-branch> <path>`, then change into the new
path — nothing past this point runs from the original directory.

**Migrate the run directory into the worktree.** A linked worktree is a fresh, separate directory;
the gitignored `.engineering/` the earlier phases wrote lives back in the original checkout and does
not follow. Move it across so this build (and `finish` after it) can read the plan, spec, and
markers:

```
mv <original-checkout>/.engineering <worktree-path>/.engineering
```

It is local scratch, so a move is safe and leaves no copy behind to drift.

## Feature branch (the `feature-branch` choice)

No worktree: cut a named feature branch off the base in the current checkout with
`git switch -c <task-branch>`, where `<task-branch>` carries the run's slug. The gitignored
`.engineering/` stays exactly where it is — an untracked directory is untouched by a branch switch —
so there is nothing to migrate. Never leave the work sitting on the default branch.

## Run project setup and confirm a clean baseline

A freshly isolated directory with nothing installed is not yet a workspace anyone can build on. Run
whatever this project uses to go from a bare checkout to something runnable — dependency install, a
bootstrap script, generated files — before touching the task.

Then run the project's test suite once, before making any change, and note the result. This is not
the task's verification (that is `engineering:using-verification`, run later against the change
made); it answers the narrower question of whether the workspace was clean before this build touched
it, so a pre-existing red baseline is not later mistaken for damage this build caused.

## Report readiness

Before the first task, say plainly where the build is happening and how it started: the workspace's
path and branch, whether it was created fresh or already existed, and the baseline test result.
