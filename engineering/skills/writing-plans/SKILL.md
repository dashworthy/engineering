---
name: writing-plans
description: "Turn an approved spec into an ordered, bite-sized implementation plan with TDD integration points, then hold the plan-approval gate — present the plan, wait for approval, mint the plan-approval marker. Use after a spec is approved and before building."
---

# Writing Plans

Say this first, plainly: `Using the writing-plans skill to create the implementation plan.`

## What this guarantees

One thing: given an approved spec, this skill produces an ordered implementation plan —
or, when the spec doesn't fit in one, an ordered set of them — written to
`.engineering/<run>/plan/`, where every step is small enough to build and check
in on its own and the test-driven cycle is wired into the step sequence instead of left as
an aside. It does not guarantee the plan is short, only that nothing in it is too big to
finish and verify in one sitting.

## Reading the spec

Start from an approved Tier-1 spec in `.engineering/<run>/spec/` — a path, or
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

**Or start from the right-size bypass marker.** The spec-approval marker is one of two
acceptable preconditions; the other is the spec-skip marker
`.engineering/<run>/to-spec/SPEC-SKIPPED.md`, which `brainstorming` mints when the human
explicitly opts to skip spec creation for a small, well-pinned change. When that marker is
present there is no spec to read — plan directly from the recommended design `brainstorming`
handed over, treating it as the approach the plan sequences. Accept **either**
`to-spec/APPROVED.md` **or** `to-spec/SPEC-SKIPPED.md`; with neither present, no gate was
cleared upstream, so refuse and stop the same as for a missing spec-approval marker. Whichever
precondition opened the plan, the plan gate below is unchanged and still holds.

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

## Show the code, not just the intent

The plan owns the concrete code. The spec's §6 named the boundary at decision altitude —
which boundary, its chosen shape, what a caller must know — and deliberately stopped short of
the exact signature; typing it out is the plan's job. So where §6 committed to a boundary, a
task here realizes it: the signature, the fields, the returned shape. The spec says *which*;
the plan says *exactly how it's typed*.

A task that changes an interface or adds a type describes it in prose *and* shows it. Carry
a short code sketch in the task — an **Interfaces block** — of the actual shape the step
produces: the function or method signature, the new type or its fields, the shape of the
data returned, or the one assertion the task's test turns on. Enough that a reader sees the
change the task will actually make, not so much that the task becomes the implementation
written ahead of time.

A sketch is an illustration, not the finished code: name the signature and the fields, elide
the body with a comment (`# walk the rule set once, return the Decision`) rather than writing
it out. Show the surface a reader needs to judge the change — the signature a caller will
type, the type a caller will hold, the assertion that proves the behavior — and stop there. A task
whose change is pure scaffolding (a directory, an empty stub) has no shape to sketch and
carries none; a task that introduces or reshapes a boundary always does, because the code
sketch is what the review phase below reads to judge the boundary's shape and catch a one-off
data structure before a human ever sees the plan.

Fence every sketch as a code block so it survives the review phase and the human read intact:

```
check(user, resource, action) -> Decision
# Decision.allowed: bool
# Decision.reason: str | None   — populated only when allowed is False
```

## Consider a diagram for a task's shape

When a task describes a data model, a flow, or a state machine, consider a diagram via
`engineering:using-diagrams` — the guard is *consider*, not *always draw*; the skill's own
earned-its-place test decides whether one is actually drawn. A plan that pictures a tricky flow
once is easier to build against than one that leaves every builder to reconstruct it.

## Each task's closing steps

Every task closes the same way, and the plan spells the closing steps out rather than leaving
them to whoever executes it. After a task's build steps and their commits — the tree now clean —
and before the task hands off to the next one (or, in a stacked plan, to its own PR):

- **Clarify the task's docblocks.** A `- [ ]` step naming `engineering:document`
  explicitly (the `vernacular` flow — not described around it as "tidy the comments"), run once
  against the task's committed changes. It rewrites only the prose of docblocks the task's diff
  already reached, proves executable code and structured annotations came out byte-identical, and
  self-noops when the diff reaches no docblock — so it is safe to run on every task. It requires a
  clean tree, which is why it runs after the task's work is committed, and its own rewrite is then
  committed too, so the clarified prose is part of what a reviewer reads. This runs after the task
  is done and before any PR is opened for it — never carried over into the next task.

The commit of that clarification, and — in a stacked plan — the submit-PR step, follow it (see
PR strategy).

## PR strategy

Most plans ship as a single pull request opened at the end. Some plans instead ship as a
*stack* — one pull request per task, each based on the branch of the task before it — so a
reviewer can approve and land the tasks in order rather than reading the whole change at
once. Which one a plan uses is decided at plan-writing time, not left to whoever executes
it — and it is decided by **asking**: put it to your human partner as a single structured
choice, using a tool to ask it where one is available (**Single PR at the end** (Recommended), or **Stacked — one PR per task**), and
do not finalize the plan until they choose. This is a required gate, not a default you may
assume: even when the spec or the caller seems to imply one, confirm it through the question
rather than reading it off silently.

When the plan is stacked, record it in the plan's Global Constraints as a single line —
`PR strategy: stacked (one PR per task, via engineering:using-stacked-pull-requests)` — so
every downstream skill reads the same marker. State in that same section that a stacked
plan is **not eligible for** `executing-plans`' subagent parallel mode: stacking is linear,
each task's branch is based on the one before it, so the tasks run sequentially and cannot
fan out across parallel agents.

A stacked plan also changes the shape of each task. In addition to the ordinary steps, a
stacked task **opens** with a step that starts the task's stacked branch off the previous
task's branch — or off the trunk, for the first task, which has no previous task — (before
any of the task's commits land), and **closes**, after the commit step and the docblock-clarity
step (see Each task's closing steps), with a step to **submit the stacked PR** for the task via
`engineering:using-stacked-pull-requests`.

Leave non-stacked plans exactly as they are: no PR-strategy line, no per-task branch or
submit steps, the single-PR-at-the-end flow unchanged. Stacked mode is opt-in per plan.

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

A plan set is a set of complete plans, not one plan's steps distributed across several
files that only add up to whole once all of them land.

## Writing the plan file, then reviewing it

Write to `.engineering/<run>/plan/<YYYY-MM-DD>-<topic>.md`. `<YYYY-MM-DD>` is
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

## Review the plan before the gate

The self-review above is a check on the plan *as a document* — coverage, placeholders,
consistency. It does not judge the plan's *design*: whether the interfaces the tasks sketch
are well-shaped, and whether any task quietly introduces a one-off data structure where an
existing type would do. That judgment is `reviewing-plans`' job, and it runs here — after the
plan is written and self-reviewed, before a human ever sees it.

**Invoke `engineering:reviewing-plans` now, on the plan just written.** It reads the plan's
Interfaces blocks and code sketches, runs the architecture lens over them (via
`codebase-design` in review mode), and scans for reinvented data structures — flagging each
to the human as an explicit choice before it can stand. It hands back the plan revised
for whatever it found: a signature reshaped to close a leak, a bespoke shape replaced with
the existing type, or an ad-hoc structure the human explicitly approved. This is why the
tasks carry code sketches at all — a plan that only describes its changes in prose gives the
review phase nothing concrete to judge.

The review phase is not a human gate — it is a machine pass with per-item human approvals
inside it (the one-off-data-structure flags). The human gate is still the plan gate below,
and it comes after review, so the plan the human approves is the reviewed one. Do not present
the plan for approval until `reviewing-plans` has returned.

## What this does not do

- It does not **design.** The approach a plan sequences into steps was already settled in
  `brainstorming` and written into the spec's approach section by `to-spec`; this skill
  does not weigh alternatives or choose between them, it schedules the one already chosen.
- It does not **run the tasks.** Driving each task through `engineering:tdd` and gating with
  `engineering:code-review` is `executing-plans` — a separate skill, downstream of this one.
  This skill schedules the work and, on approval, hands off to it; it does not perform the
  build itself.

## The plan gate — present the plan, then hold for approval

The plan gate is the pipeline's second human-approval gate; the first is the spec gate in
`to-spec`. A written plan is a draft until a human approves it: present the finished plan,
then put the verdict to the human as a structured choice — `Approve` or `Request changes`, using a
tool to ask it where one is available — so the
turn holds and nothing is built against the plan until they pick Approve. On `Request changes`
(their edits ride the free-form escape or the reply), revise and present again; do not hand
an unapproved plan onward. No such tool, or a headless run: present `Approve` / `Request changes`
as plain text, say the run is degraded, and wait for an explicit typed approval — treat silence as
not-approved.

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

The only stop on this skill is the plan gate itself, and it sits *before* approval: a plan
the human has not approved waits at the gate and is not handed onward. Once the human
approves — the marker written, the finish strategy authorized — that approval *is* the go,
and the plan gate was the last human stop before the build runs. There is no second gate at
this seam, so print the plan's path — or, for a set, every path in sequence — and **invoke
`executing-plans` now.** "Stop" here means stop *writing the plan*; it is not a stop to ask
the human whether to build. Parking an approved plan with a "want me to start implementing?"
is not an available move — the approval was the answer to that question; `executing-plans` is
the next act, take it. Running the plan task by task is `executing-plans`' job — it reads the
plan this skill wrote (and the plan-approval marker behind it) and works it task by task.
(`engineering:executing-plans` remains the entry point for building a plan approved in an
earlier session; a plan approved just now does not wait for it.)
