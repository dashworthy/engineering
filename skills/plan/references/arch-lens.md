# Reviewing Plans (arch-lens reference)

## What this guarantees

One thing: given a plan already written and self-reviewed, this review returns
that plan with its design vetted — every interface a task sketches has been run through the
architecture lens, every data structure or capability a task introduces is either a reuse of
something the codebase or framework already has or a bespoke choice a human explicitly approved,
and every load-bearing assumption a task rests on has been established or accepted with its risk
recorded. It does not rewrite the plan's approach or reorder its tasks; it catches the shape
defects, the reinvented structures and capabilities, and the unproven assumptions that the
document-level self-review can't see, and hands back a plan corrected for them, so the plan that
reaches the human gate is the reviewed one.

## Where this runs

This review runs after the plan file is written and self-reviewed, before the plan gate — the
human-approval step. So the plan is finished
as a document (no placeholders, full spec coverage, consistent task shape) but has not yet
been shown to a human. Read the plan from the path the conductor is working, or the plan
already sitting in context.

This review is not a human gate. It is a machine pass with three checks, two of which flag their
findings to the human as an explicit choice per finding.

## The three checks

Run all three over the whole plan before revising anything, so a single revision pass closes
everything found rather than the plan churning once per finding.

### 1. The architecture check

Read every **Interfaces block** and code sketch the plan's tasks carry — the signatures,
types, and returned shapes the tasks will actually produce (this is why `plan` makes
tasks sketch them). For each boundary a task introduces or reshapes, run it through
the **shape lenses in review mode**: invoke `engineering:using-codebase-design` with the
argument `review` and the proposed shape, and it returns the findings from its `SHAPE-REVIEW.md`
evaluative lenses — the SOLID questions and the anti-pattern table — without running its
interactive design-it-twice or pattern-proposal machinery. It judges the shape already on the
page; it does not design a new one.

A finding that names a clear defect — a leaked call order, a fat interface a caller uses a
third of, high-level policy bound to a concrete detail, or a task with two branches doing the
same kind of work that aren't built the same way — one composes through the sketched boundary,
a sibling branch reimplements the equivalent behavior on its own instead of using it — is an
objective flaw in the sketch, not a judgment call. Check this last one deliberately: it's easy
to approve because the correctly-routed branch reads clean, and the defect is the inconsistency
between the two, not either branch alone. **Record the fix to close it** — the reshaped signature, the
split interface, the inverted dependency — and apply it in the single revision pass below (see *Revising
the plan*), the same way you'd fix a placeholder the self-review caught. Note the change in the task so a
reader sees the sketch changed and why. You do not need to ask the human to approve closing a defect the
lens objectively fired on; you close it in that pass and the reviewed sketch is what they read at the gate.

The reinvented / one-off data-structure smell is the one exception: don't close it here — it
belongs to the one-off scan below, which flags every candidate to the human rather than revising
silently. When the architecture lens fires on it, carry it into that scan instead of revising it.

If a finding turns on a genuine trade-off rather than a defect — two defensible shapes, the
lens firing on one axis but not clearly wrong — surface it the same way the one-off scan
below surfaces its flags: as an explicit choice put to the human, not a silent revision.

### 2. The reinvention scan — data structures, then capabilities

Walk every data structure the plan's tasks introduce — a new type, a class, a record, or a
bare dict / tuple / array a task uses to carry a set of fields with an invariant. For each
one, ask the sharper question the self-review can't: **does the codebase already have a type
for this?** A task that invents a bespoke shape — a new `dict` with three keys that an
existing value object already models, a second class that duplicates one already in the tree,
an ad-hoc tuple carrying a meaning a named type already carries — is introducing a one-off
data structure where reuse was available, and every one-off structure is a shape the next
reader has to learn and the codebase has to keep in sync by hand.

Search the codebase for an existing type that already carries the shape before deciding a
task's structure is genuinely new. Reuse over reinvention is the default; a new structure has
to earn its place against what already exists.

**Flag each candidate one-off structure to the human as an explicit choice**, using a tool to ask
it where one is available; no such tool, present the choice as plain text and note the run is
degraded. Do not
silently revise these, and do not silently let them stand. Frame the question around the one
structure: name the bespoke shape the task introduces, name the existing type it could reuse
(if one exists), and offer:

- **Reuse `<existing type>`** (the recommended option whenever a real candidate exists) —
  the plan's task is revised to use the existing type instead of the new structure.
- **Keep the new structure** — the human judges the new shape earns its place; it stands, and
  its justification rides the answer so the plan records why a new type was minted.

A free-form escape leaves room for a third path — reshape it differently, or reuse a
type you didn't name. When the human picks reuse (or names a different existing type), revise
the task's Interfaces block and steps to match. When they keep it, leave the structure and
record the approval in the task so the choice is visible at the gate and afterward.

Then widen the same scan from a single data structure to a whole **task-level capability**: for
a task that builds a capability — a retry loop, a cache, a parser, a scheduler, a permission
check — ask the reuse question one level up:
**does the codebase or the framework already provide this?**
A task that hand-rolls a capability an existing module or the framework already
offers is reinvention at the task scale, not just the type scale, and it earns the same flag,
surfaced to the human the same way.

This task-level judgment is **grep-limited** (per the plan's Global Constraints): reason from
what is already in context — the spec, the plan, and general knowledge of what the language and
framework provide — rather than searching the tree. Do not open-scan the codebase for it. At
most **one targeted confirm-grep** is allowed, and only to verify a *specific* named duplicate
before asserting it — verify-only, never discovery. If context and general knowledge do not name
a concrete thing the task duplicates, the honest result is no finding, not a fishing expedition.
Worked example: a task adds its own exponential-backoff retry loop around an HTTP call; general
knowledge says the project's HTTP client (or a shared `BackoffRetry` helper the spec mentions)
already retries, so flag it as capability reinvention and offer reuse. The existing
data-structure scan above is unchanged — it keeps searching for an existing *type* as it always
has; only this task-level addition carries the grep limit.

### 3. The unproven-assumption scan — `rests-on-unproven-assumption`

Walk every task for a load-bearing **assumption the plan or spec never established** — a
dependency assumed present, a data shape assumed available, an upstream behavior assumed
guaranteed, a migration assumed already run. The question is not "is this well-shaped?"
(Check 1) or "does this already exist?" (Check 2) but "**does this task only work if something
unproven is true?**"

This scan is **grep-limited** the same way: judge from the spec, the plan, and general
knowledge; **one targeted confirm-grep** at most to check a *specific* assumption, never an open
scan. It is a judgment call, not an objective defect — so **surface each finding to the human as
an explicit choice**, exactly as the one-off scan above surfaces its flags (a tool where one is
available; plain text noting a degraded run otherwise). Never silently revise a task over an
assumption, and never silently let a load-bearing one stand. Name the assumption, name the task
that rests on it, and offer to either establish it (add a task or check that proves it) or accept
it with the risk recorded in the task.

A plan that rests on nothing unproven yields **no finding here** — "no strong objection" is a
complete, valid result. Do not manufacture a doubt to avoid an empty scan; an invented
assumption is exactly the padding this discipline exists to prevent. Worked example: a task calls
a `feature_flags` table that no earlier task creates and the spec never lists as pre-existing —
surface it as a choice (add the migration, or confirm the table already ships) rather than
assuming it is there.

## Revising the plan

After all three checks, apply everything found in one pass: the architecture defects you're closing
directly, and the one-off-structure resolutions the human chose. Edit the plan file in place —
the Interfaces blocks, the affected steps, and any verification a reshaped interface changes.
A revision that reshapes a signature but leaves a downstream step calling the old shape has
left the plan inconsistent; walk the tasks that touch a changed boundary and bring them along.

Keep the plan's own shape intact: this pass corrects sketches and swaps structures, it does
not add tasks, reorder them, or change the approach the spec settled. If a finding can't be
closed without changing the approach itself — the lens reveals the whole boundary is wrong,
not just its sketch — that's beyond a plan review; say so and hand it back to `plan`
to route to `brainstorming` or `using-codebase-design` rather than patching around it here.

## What this does not do

- It does not **design.** Choosing an approach is the `brainstorming` dialogue; shaping a boundary from two
  competing designs is the `using-codebase-design` skill. The arch-lens review runs the shape lenses'
  *evaluative* pass over a shape already chosen and sketched; it does not generate a shape or weigh approaches.
- It does not **hold the plan gate.** Presenting the plan for human approval and minting the
  plan-approval marker is `plan`. This skill's per-finding flags are explicit-choice
  approvals inside the review, not the gate; it returns the reviewed plan and the gate follows.
- It does not **run the tasks.** Building the plan is `build`, downstream of the gate.