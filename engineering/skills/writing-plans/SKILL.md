---
name: writing-plans
description: "[Planning] Turn an approved spec in docs/dashworthy/engineering/specs/ into an ordered, bite-sized implementation plan written to docs/dashworthy/engineering/plans/, with TDD integration points and a closing test-hardening task, then hold the plan-approval gate — present the plan, wait for approval, and mint the run's plan-approval marker. Use after a spec is approved and before building. Reads CONTEXT.md/docs/adr when present, and cites recorded conventions from docs/standards/ inline at each task via using-code-conventions."
---

# Writing Plans

Say this first, plainly: `Using the writing-plans skill to create the implementation plan.`

## What this guarantees

One thing: given an approved spec, this skill produces an ordered implementation plan —
or, when the spec doesn't fit in one, an ordered set of them — written to
`docs/dashworthy/engineering/plans/`, where every step is small enough to build and check
in on its own, the test-driven cycle is wired into the step sequence instead of left as
an aside, and the plan does not end until a hardening task is sitting on it. It does not
guarantee the plan is short, only that nothing in it is too big to finish and verify in
one sitting.

Nothing else is guaranteed. Read `## What this does not do` before assuming this skill
reaches past turning an approved spec into a sequence of steps.

## Reading the spec

Start from an approved Tier-1 spec in `docs/dashworthy/engineering/specs/` — a path, or
the spec already sitting in context. A plan built from a spec still in draft is a plan
built on a decision nobody has actually made; if the spec's own status line doesn't say
Approved, say so and stop rather than plan around a draft.

The status line alone is not proof — check the trace behind it. Resolve the run from
`.engineering/.current-run` and confirm the spec-approval marker,
`.engineering/<run>/to-spec/APPROVED.md`, actually exists. An `Approved` status with
no marker behind it is the signature of a hand-edited status line or a spec written before
this mechanism existed — either way the spec gate was never cleared, so refuse and stop
rather than plan it. This mirrors `finishing-a-development-branch`'s rule to prefer the
trace over the checkbox: the marker is the trace, the status line is only the checkbox.

Read `CONTEXT.md` and `docs/adr/`, at the project root, when either exists. A naming
convention or a settled boundary recorded there constrains how a task's file paths and
interfaces get written, the same way it constrains a fresh module boundary in
`codebase-design`. Neither file is required — most specs get planned with no `CONTEXT.md`
in sight, and that's ordinary, not a degraded run.

Two things about the spec matter more than its prose: its Constraints section and any
decision table it carries. Both travel into the plan close to verbatim — see Global
Constraints, below — because a task author three steps in should never have to re-derive
a binding decision by inference from the spec's narrative.

## Shaping the plan

A plan is not the spec restated with checkboxes glued on. It is the spec's approach
broken into steps small enough that each one can be built, verified, and committed before
moving to the next — a step that takes a full session to finish is too big and belongs
split, not attempted whole.

Each step:

- Is a single `- [ ]` line (or a short run of them under one task heading), not a
  paragraph of prose disguised as a checkbox.
- Names exact file paths — `Create: path/to/file.ext` or `Modify: path/to/file.ext` —
  never "the relevant module" or "the config." A step whose target file isn't nameable
  yet is a step that isn't ready to be written.
- Where it changes behavior, is wired into the test-driven cycle rather than described
  around it: write the failing test, run it and confirm it fails for the stated reason,
  implement the minimum that makes it pass, run it again and confirm green, then commit.
  A step that jumps straight to "implement X" with no failing test ahead of it has skipped
  the part of the cycle that proves the test would have caught the regression.
- Carries its own verification — a command to run and the output that counts as passing —
  so a task's own gate lives with the step, not in a separate document nobody reopens.

**Global Constraints.** Open the plan with a section, copied verbatim from the spec's
Constraints and any binding decision table — not paraphrased, not summarized — so every
task downstream can point back at one shared block instead of each task restating, and
risking drifting from, what the spec actually said. A task's own text should read as "per
Global Constraints, this uses X," not repeat the reasoning for X.

## Citing recorded conventions at each task

A recorded convention only reaches the builder if the plan carries it. When the project keeps a
standards tree at `docs/standards/`, invoke `engineering:using-code-conventions` while shaping
the plan: it reads the standards index, matches each task's kind of work against the **When
relevant** column, and cites the governing convention file inline on the task itself —
`(convention: docs/standards/<area>/<rule>.md)`. The citation travels with the task into
`executing-plans`, so the subagent that builds it opens the rule before writing code rather than
after `code-review` catches the violation. Cite the file by path, never a paraphrase, so the
task always resolves to the current rule. A project with no standards tree gets no citations —
read when present, skipped when absent, exactly like `CONTEXT.md`; this skill consults the tree
but never writes it (recording is `recording-code-conventions`).

## Consider a diagram for a task's shape

When a task describes a data model, a flow, or a state machine, consider a diagram via
`engineering:using-diagrams` — the guard is *consider*, not *always draw*; the skill's own
earned-its-place test decides whether one is actually drawn. A plan that pictures a tricky flow
once is easier to build against than one that leaves every builder to reconstruct it.

## PR strategy

Most plans ship as a single pull request opened at the end. Some plans instead ship as a
*stack* — one pull request per task, each based on the branch of the task before it — so a
reviewer can approve and land the tasks in order rather than reading the whole change at
once. Which one a plan uses is decided at plan-writing time, not left to whoever executes
it: ask your human partner, or take it from the spec or the caller when they've already
said.

When the plan is stacked, record it in the plan's Global Constraints as a single line —
`PR strategy: stacked (one PR per task, via engineering:using-stacked-pull-requests)` — so
every downstream skill reads the same marker. State in that same section that a stacked
plan is **not eligible for** `executing-plans`' subagent parallel mode: stacking is linear,
each task's branch is based on the one before it, so the tasks run sequentially and cannot
fan out across parallel agents.

A stacked plan also changes the shape of each task. In addition to the ordinary steps, a
stacked task **opens** with a step that starts the task's stacked branch off the previous
task's branch — or off the trunk, for the first task, which has no previous task — (before
any of the task's commits land), and **closes**, after the commit
step, with a step to **submit the stacked PR** for the task via
`engineering:using-stacked-pull-requests`. The closing Phase 3.5 hardening task is no
exception — in a stacked plan its work goes up as the top-of-stack PR, on its own branch
based on the last build task's branch, like every other task.

Leave non-stacked plans exactly as they are: no PR-strategy line, no per-task branch or
submit steps, the single-PR-at-the-end flow unchanged. Stacked mode is opt-in per plan.

## Offer to record a planning decision as an ADR

When sequencing turns on a decision with genuine live alternatives — an ordering or a
boundary between plans that another planner could reasonably have drawn differently — offer to
record it as an ADR via `engineering:recording-adrs`, written `Proposed`. The bar is real live
alternatives, not every routine sequencing call, and the developer may decline; declining is
what keeps ADR intake from flooding.

## Splitting into a plan set

Some specs cover one subsystem end to end; a single ordered plan fits them. Others cover
several subsystems that don't depend on each other's internals to ship — each could go out
on its own and leave the codebase in a working state. When the spec is the second kind,
write a plan set: one plan file per independent piece, each internally ordered, sequenced
against each other only where one piece's task genuinely produces something the next
consumes.

The test for whether a split is warranted is not "is this spec long" — it's "does
finishing plan A alone leave working software, with plan B not yet started." If stopping
after A leaves the build broken until B lands, that's one plan with two phases, not two
plans. If it doesn't, splitting means a reviewer can approve and ship A without holding B
hostage to it, and a set of small plans is easier to reason about than one long one that
happens to have a seam in the middle.

Every plan in a set still gets its own closing hardening task — a plan set is a set of
complete plans, not one plan's steps distributed across several files that only add up to
whole once all of them land.

## The closing hardening task

Every plan this skill writes ends with a task, after the last build step, whose entire job
is to invoke `engineering:conducting-test-hardening`. This is not optional and not
situational — it is the last task on every plan this skill produces, without exception,
placed as its own numbered phase after the build work (call it Phase 3.5: build is
Phase 3, hardening is what closes it out before the plan is done).

The reasoning is not "tests are good" — it's where the check for missing tests lives.
Nothing else in this plugin forces a hardening pass to happen; there's no hook watching
for one. The only thing that reliably makes it happen is a task sitting on the plan
itself, where `executing-plans` will reach it in the ordinary course of working through
the plan, the same way it reaches any other step. A plan without this task is a plan whose
hardening depends on somebody remembering to ask for it afterward — exactly the gap this
task closes.

Write the task the same shape as any other: a `- [ ]` line, a short description of what it
covers, and the invocation itself — `engineering:conducting-test-hardening` — named
explicitly rather than described around ("run the tests," "check coverage"). Whoever
executes the plan dispatches that skill by name; this skill's job stops at putting the
task there.

## Writing the plan file, then reviewing it

Write to `docs/dashworthy/engineering/plans/<YYYY-MM-DD>-<topic>.md`. `<YYYY-MM-DD>` is
today's date — the day the plan is written, not the spec's approval date, which may be
days or weeks earlier. `<topic>` is the spec's own topic slug, reused rather than
reinvented, so the spec and the plan it produced sort next to each other by name. For a
plan set, keep the shared topic and distinguish members with an ordinal and a short
per-plan suffix — `<topic>-01-<subsystem>.md`, `<topic>-02-<subsystem>.md` — ordered the
same way the set is sequenced.

Before calling the plan finished, run a self-review pass over what was just written:

- **Spec coverage.** Walk the spec's goals, constraints, and decision table entries one by
  one and confirm each has a task that addresses it. An item with no task behind it is
  either forgotten or genuinely out of scope for this plan — decide which, and if it's the
  former, add the task rather than note the gap and move on.
- **Placeholder scan.** Search the finished plan for anything a task author would have to
  guess at — `TBD`, `...`, "the appropriate file," a step with no file path, a verification
  with nothing to run. A plan with a placeholder in it isn't a draft of a finished plan;
  it's an unfinished one that looks done at a glance.
- **Type consistency.** Confirm every task follows the same shape — a Files block, an
  Interfaces block where the task has one, numbered steps, a closing verification command
  — and that steps describing the same kind of thing (a test, a command, a commit) are
  phrased the same way throughout. A plan that shifts format halfway through reads as two
  plans stitched together, and whoever executes it has to re-learn the pattern partway in.

## What this does not do

- It does not **design.** The approach a plan sequences into steps was already settled in
  `brainstorming` and written into the spec's approach section by `to-spec`; this skill
  does not weigh alternatives or choose between them, it schedules the one already chosen.
- It does not **execute the plan.** Running the plan task by task, driving each one
  through `engineering:tdd`, gating with `engineering:code-review`, and reaching the
  closing hardening task when the plan gets there is `executing-plans` — a separate skill,
  downstream of this one, that this skill does not invoke itself.
- It does not **run the hardening task.** It writes the task that invokes
  `engineering:conducting-test-hardening`; it does not dispatch that skill itself. The
  task sits on the plan for whoever executes it to reach.
- It does not **require `CONTEXT.md` or an ADR.** Both are read when present and ignored
  when absent — this skill does not stall a plan waiting on documentation the project
  never wrote.
- It does not **plan around a draft.** A spec whose status isn't Approved doesn't get
  planned; it gets named as the reason nothing was written.

## The plan gate — present the plan, then hold for approval

The plan gate is the pipeline's second human-approval gate; the first is the spec gate in
`to-spec`. A written plan is a draft until a human approves it: present the finished plan
and wait for the human's approval before anything is built against it. If they send it back,
revise and present again; do not hand an unapproved plan onward.

On approval, create the run's writing-plans phase directory with
`run-context.sh writing-plans <slug>` and write `.engineering/<run>/writing-plans/APPROVED.md`
into it — a Tier-2, run-scoped trace that the plan cleared the gate. `executing-plans` reads
that marker as its precondition and refuses to build without it, so mint it only on approval,
never before.

**The finish strategy is authorized here too.** Because this is the last human stop before the
build runs unattended, the plan gate is also where the branch's finish strategy gets settled —
how it re-enters the repository (merge, pull request, or landing a stack) and whether its
branch is deleted afterward. Record it in the plan's Global Constraints as a `Finish strategy:`
line, so `finishing-a-development-branch` carries out a choice the human already authorized
rather than stopping to ask again at the end. A stacked plan's `PR strategy: stacked` line
already implies landing the stack; state the cleanup intent alongside it.

## Handoff

Once the plan is approved and its marker written, print the plan's path — or, for a set,
every path in sequence — and stop. What happens next is `executing-plans`' job, not this
skill's: it reads the plan this skill wrote (and the plan-approval marker behind it) and
works it task by task.
