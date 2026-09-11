---
name: build
description: "The build phase: execute an approved plan task by task — each driven through the TDD loop and gated by an internal review. Runs to completion with no human checkpoints. Use to build out a plan that already exists under .engineering/<run>/plan/."
---

# Build

Say this first, plainly: `Using the build skill to execute the plan.`

## What this guarantees

One thing: given an approved plan, this skill works it task by task, in
order, until every task is checked off — and for each one that changes behavior, a test
existed before the code, gated by an independent review before the box gets checked. Nothing
on the plan gets marked done without going through the cycle the plan was written to enforce.

## Finding the plan

Accept a plan path directly if the caller supplied one. When `plan` hands off in the same run —
`.engineering/.current-run` resolves and its `.engineering/<run>/plan/APPROVED.md` marker is
present — take that run's plan and start: the plan gate just approved it, so re-confirming which
plan to build would only re-ask a question already answered. There is no second gate at this
seam; proceed without a fresh prompt.

Only when the plan is **ambiguous** — this skill was invoked cold, with no active run and no
path supplied, so the plan would be chosen by file mtime — confirm which plan with the user
before starting. Guessing wrong there means driving several tasks through tdd and code-review
against the wrong plan before anyone notices; a same-run handoff carries no such ambiguity.

A run has exactly one plan file — never a numbered set. If `.engineering/<run>/plan/` holds
more than one plan document, that is a leftover or a mistake, not a set to work in sequence;
confirm which plan is the live one with the user rather than working them in filename order.

A plan already partly checked off is a plan already in progress, not a fresh one — resume
at its first unchecked step rather than starting over or redoing work already marked done.

Before working any task, confirm the plan cleared its gate: resolve the run from
`.engineering/.current-run` and check that `.engineering/<run>/plan/APPROVED.md`
exists. Without that marker the plan gate was never cleared (or the plan was hand-written
outside the pipeline), and this skill refuses to build rather than run an unapproved plan
unattended — the same trace-over-checkbox rule the spec gate uses, one step downstream. This
is the last human-approval gate before the build; once it clears, the plan runs to completion
with no further human stops.

## Establish the workspace

Before touching any code, move the work into an isolated workspace — the branch or worktree the
whole build runs in. This is the one place the pipeline creates it: the entrances and the design
phases ran on the current branch, writing only gitignored `.engineering/` scratch, so nothing has
landed on the branch yet. Read the plan's Global Constraints for the `Isolation:` line
(`worktree` or `feature-branch`, settled at the plan gate) and follow
`references/establishing-workspace.md` — it detects isolation that already exists and joins it,
otherwise creates the recorded kind (a worktree, migrating the run's `.engineering/` into it, or a
feature branch cut in the current checkout), then runs project setup and confirms a clean baseline.
Everything below runs inside that workspace.

## Run directory

`.engineering/<run>/implement/` in the **user's** project — never inside the plugin.
`<run>` is not yours to name: obtain it by running
`sh "${CLAUDE_PLUGIN_ROOT}/scripts/run-context.sh" implement`, which prints the absolute
path of `.engineering/<run>/implement/` and creates it if needed. If this skill runs
standalone — no earlier phase has run in this session — this same call creates the
`.engineering/.current-run` pointer itself; if a run is already active, it joins that run
instead.

Keep a short running note here of which task last finished and what its commit was — not
a copy of the plan, and not a transcript of every tdd cycle, just enough that a session
picking this plan back up mid-way can confirm where it left off without re-deriving it
from `git log` alone.

## Track the plan as todos

Before working the first task, seed your todo list from the plan: create one todo per task in
the plan, in the plan's order, in whatever todo list your harness provides. This is not optional
bookkeeping — the todo list is how a long, unattended run stays legible, to you as you work it
and to the human reading along. A plan worked without a todo list is a plan whose progress lives only in your head and the
plan file's checkboxes, and the two drift the moment anything goes sideways.

Keep the list and the plan in lockstep as you go: exactly one task is
`in_progress` at a time, each task is marked `completed` the instant its box is checked, and
nothing is marked done before it actually is. A resumed run rebuilds the list from the plan's checked and unchecked tasks before
starting, so the todo list picks up where the plan left off rather than starting empty. The
per-task loop below names where each transition happens.

## The per-task loop

Work tasks in the order the plan lists them — the plan's own order encodes what depends on
what, and a task three steps down may assume a task two steps up already landed. For each
task, in order:

1. **Read the task whole** — its Files block, its Interfaces block where it has one, and
   every numbered step under it — before touching anything, and **mark its todo `in_progress`**.
   A task read one step at a time is a task whose later steps might contradict a constraint an
   earlier one already set.
2. **Drive the build steps through the TDD loop** — load `references/tdd-loop.md` and follow it.
   Where a step changes behavior, that means the red-green-refactor cycle the loop owns, not
   implementation written straight from the plan's prose. A step that's pure scaffolding — a
   directory, a stub file with no behavior yet — has nothing for the loop to grip and can be done
   directly; anything that produces behavior gets a test that existed first.
3. **Run the task's own verification** — the command its steps name and the output they
   say counts as passing. A task whose verification doesn't come back clean is not done,
   whatever the code looks like; fix it and check again before moving on.
4. **Gate the task's own diff** — load `references/review-protocol.md` and apply it. A clean
   review is what earns the box; a review with findings gets addressed and then re-reviewed on the
   corrected diff before the box is checked. This gate is automated — it does not stop for a human —
   so a finding is resolved in the diff, not referred upward for a ruling. (This is the internal
   per-task gate; a deeper, opt-in review is the `code-review` skill's job, not this one.)
5. **Check the box** — flip the task's `- [ ]` to `- [x]` in the plan file itself, and **mark
   its todo `completed`** in the same breath, so the two records never disagree. The plan is the
   durable record of progress; a task that's actually done and still shows unchecked is a plan
   lying about its own state to the next person who opens it.
6. **Commit** — run the commit the task's own final step already specifies. Plans written
   by `plan` carry the exact `git add`/`git commit` invocation as that task's last
   step; run it as written rather than composing a message of your own.

Then move to the next task.

## Stacked plans (PR strategy)

Every plan carries a `PR strategy: stacked` line in its Global Constraints — the pipeline ships
work only as stacks (see `plan`). Two things follow for execution.

First, a stacked plan runs **sequentially** — task by task, in order. The stack is linear, so
tasks cannot fan out across parallel agents; there is no subagent parallel mode.

Second, a stacked plan's tasks carry extra steps the plan author already wrote: a step at the
top that starts the task's stacked branch off the previous task's branch, and a step at the
bottom that submits the task's stacked PR. Honor those steps as written — they invoke
`engineering:using-stacked-pull-requests`, which owns all the branch-and-PR mechanics; this
skill adds no PR logic of its own beyond running the plan's steps in order. Run a task's
opening step before its commit steps, so its commits land on that task's own branch rather
than the previous task's by accident.

Build and push **every task, as it finishes** — the submit step runs the moment a task's box is
checked, before the next task starts, so each task's branch and PR go up on their own. Never
batch the pushes to the end of the run, and **never pause to ask** whether to build the PR now
or wait — there is no checkpoint here. The plan gate already authorized the whole stack; a task
that is committed and gated is a task whose PR goes up immediately, without a "want me to push
this one?" The run is unattended by design (see "What this guarantees") — asking along the way
is the one thing it must not do.

## What this does not do

- It does not **write the plan.** The tasks and their order were all decided during
  planning before this skill ever runs; this skill executes what's already on the
  page, it doesn't add, remove, or reorder a task itself.
- It does not **decide the plan is finished early.** A plan is done when its last task is
  checked, not when the build tasks look complete or the user seems satisfied partway
  through.
- It does not **punt a task's own gaps to "later."** A gap a task turns up while being built — a
  finding from its own review gate, a missing case, a follow-up the change plainly needs — is
  closed in that task's diff, or surfaced as an explicit decision the human can see; it is never
  left as a `TODO`, a "next steps" note, or a hand-off nobody tracks, for a pass that may never
  come. See `engineering:refusing-deferral`.

## Handoff

Once the last task is checked off, report the plan's path and its final commit, then **hand off
to `engineering:documenting` now** — the documentation phase, which runs on the green branch
between build and finish: it judges whether the run changed documented behavior and, when it did,
writes or updates the feature's docs and validates them before finish integrates the branch.
`documenting` hands to `engineering:finish` in turn — which carries out the finish strategy the
plan gate already authorized (open a pull request, or cleanup — the pipeline never merges) without
asking again, re-verifying green itself first. Deciding *how* the branch integrates is not this
skill's job; reaching the phase that comes next is. So don't stop at the checked box and hand
control back with a "want me to finish the branch?" — there is no gate at this seam (the plan gate
already settled the finish strategy), the plan is complete, and documenting-then-finishing is the
next act. Take it.
