---
name: using-codebase-design
description: "Shape module interfaces so complexity hides behind narrow, deep boundaries — or, in review mode (argument `review`), judge an already-sketched shape against the same lenses without designing a new one. Use when defining a module's interface, judging whether a boundary earns its keep, or reviewing a proposed interface. Not approach design (brainstorming)."
---

# using-codebase-design

Say this first, plainly: `Using the using-codebase-design skill to shape this interface.`

Shape a module interface deep-not-shallow, or judge one already sketched. using-codebase-design is a shared
skill with two callers: `brainstorming` invokes it when an approach turns on a boundary, and `plan`'s
arch-lens review invokes it in review mode (argument `review`) to judge the interfaces a plan sketches.
Its companion references (`references/DEEPENING.md`, `references/DESIGN-IT-TWICE.md`,
`references/PATTERN-MATRIX.md`, `references/SHAPE-REVIEW.md`, `references/TENANCY-*.md`) carry the mechanics.

## What this guarantees

One thing: given a module — new or existing — this reference produces an interface shaped
deliberately, from at least two competing designs, judged against what it costs a caller
to use and what it hides from them. The interface earned its shape instead of being
whatever fell out of the first draft.

## The depth principle

A module has two costs: what it costs to build, and what it costs every caller to learn
and use. The second cost is paid over and over, by people who never read the
implementation. Judge a module by the ratio between what its interface asks a caller to
know and how much work happens once that caller has asked.

A **deep** module has a narrow, simple interface sitting in front of a large amount of
work. A caller states what it wants; the module decides how. A **shallow** module's
interface is nearly the whole module — every parameter the caller passes maps to a
decision the module makes no attempt to own, so reading the interface teaches you most of
what the implementation does anyway. A shallow module isn't wrong because it is small; it
is wrong because it charges callers close to the full cost of the complexity it contains,
while still keeping that complexity fenced off in a separate file, so nobody gets the
benefit of the fence.

Depth is the goal because a codebase's total cost to work in is closer to the sum of its
interfaces than the sum of its implementations: trading implementation effort for
interface simplicity is usually a good trade, paid once and collected on every call site
forever after.

Depth is not free and not always right — a module that hides too much becomes a black box
nobody can extend, and some seams belong to the caller (a widget library shouldn't decide
your layout for you). Judge each boundary on its own call sites, not by a rule that deeper
is always better.

`references/DEEPENING.md` is the list of concrete moves that turn a shallow
module deep: pulling complexity down behind the interface, widening what one call is
responsible for, collapsing layers that only forward, and defaulting the case that shows
up nine times out of ten. Use it once you've decided a module is shallow and need to know
what to actually change.

## Information hiding and leakage

A module hides information when a caller cannot tell, from the interface alone, how the
module does its job — what data structure it keeps, what order it does things in, what
library or protocol sits underneath. Hiding that is the entire mechanism by which a deep
module stays deep: the caller pays for the interface, not the implementation, only as long
as the implementation stays invisible.

A leak is any place a caller has to know something about the inside to use the outside
correctly. Leaks rarely show up as a leak; they show up as friction at the seam, and the
friction has a small set of recognizable shapes:

- **A parameter that only makes sense with inside knowledge.** A flag whose correct value
  depends on which internal code path the module will take is not configuration — it is
  the caller doing part of the module's job from outside.
- **A required call order.** If callers must call `open` before `write` before `close`, or
  `validate` before `save`, the module has externalized its own state machine. The caller
  now has to hold invariants that belong to the module.
- **Repeated call-site choreography.** When two unrelated call sites contain the same
  three-call sequence in the same order, that sequence is a missing method, and every
  place it's copied is a place the module's internals are exposed and can drift out of
  sync.
- **A change inside the module forcing a change outside it.** This is the sharpest test.
  If renaming a private field, swapping a data structure, or changing an internal
  algorithm requires editing a caller, the interface was never actually hiding that
  detail — it was passing it through.

Not every exposed detail is a leak. A module built specifically to give the caller control
over something — a database transaction boundary, an event ordering guarantee — is meant
to expose that thing; the leak test is about accidental exposure, not designed contracts.

## Tenancy boundary

There is one isolation invariant a leak lets slip with unusually severe consequences: in a
multi-tenant application, the boundary that keeps one tenant's data out of another tenant's
hands. This is not a separate concern from the leakage principle above — it *is* that principle
applied to tenancy. A tenant scope a caller must remember to add is exactly the leak from the
section above (the module externalizing its own isolation invariant); "which layer enforces
isolation" is exactly the depth question. So when a boundary you are shaping touches tenant-scoped
data, deepen the interface the same way — with one extra step, because getting this leak wrong
leaks another customer's data, not just a private field.

1. **Determine the model.** The first move is to determine the app's tenancy model, stated from
   the approach context you already have —
   the designer decides, from what `brainstorming` established about the application, whether it
   is **shared-database** (one schema, rows told apart by a discriminator column), **isolated
   database** (a database or schema per tenant), or **single-tenant** (not multi-tenant at all).
   This is a stated fact, not an auto-detection: this skill runs at design time with a
   human present, so there is no signal-scanning step and no dependency on any other plugin's
   detection machinery. If you cannot state the model from context, ask — do not guess.

2. **Consult only the matching companion.** Two companion files sit in `references/`, one per
   model, and their failure modes are near-disjoint — so consult only the matching companion and
   leave the other closed. `references/TENANCY-SHARED-DB.md` carries the shared-database boundary decision —
   where the scope lives so no caller can build an unscoped query, ambient vs. explicit tenant
   context, discriminator mass-assignment, and whether cross-tenant reach is permitted at all.
   `references/TENANCY-ISOLATED-DB.md` carries the isolated-database decision — where and when the tenant
   connection is resolved and switched, carrying tenant context across async boundaries, and
   central/landlord vs. tenant DB binding. A shared-database app has no connection to route; an
   isolated-database app has no discriminator to forget. Reading the wrong companion is reading
   for failure modes this app cannot have.

3. **Force it when relevant, skip it silently otherwise.** For a boundary that touches
   tenant-scoped data in a multi-tenant app, force the tenant-boundary decision the matching
   companion frames — where isolation lives (a query scope for the shared model, a connection for
   the isolated one) and the model-specific choices the companion sets out around it — as a
   **required** part of the shaped interface, and let it travel into the spec's §6 with the
   rest of the interface's shape. It is not optional, because an optional isolation lens is one a
   design under time pressure skips, and the skip is the exact omission that ships the leak. For a
   single-tenant app, or a boundary that touches no tenant-scoped data (a stateless formatter, a
   pure calculation, a config loader), there is nothing to decide — skip it with no ceremony, the
   design-time echo of a review facet's per-change relevance gate.

## Design-it-twice discipline

Before committing to a module's interface, sketch at least two genuinely different
shapes — two different allocations of responsibility between caller and module, not two
phrasings of the same shape — and do it before writing the implementation, not after.
`references/DESIGN-IT-TWICE.md` owns how to generate a second design that
actually differs from the first, and the criteria for choosing between them once both
exist: what a call site has to know, how much of the module's machinery never has to
reach the interface, and whether the interface lets a caller hold it wrong and not notice.

## Consult the catalog when shaping a boundary

Once two shapes are on the table, before choosing between them, put them through the named
catalog the field already has a vocabulary for. Two companion files carry it, split by how they
are used.

`references/SHAPE-REVIEW.md` is the **evaluative** half: the five SOLID principles and
a set of common anti-patterns, each a lens you run over the two competing shapes to catch one
that is already wrong — a fat interface, a switch that will not stay closed, a god object. Run it
over both shapes as an extra set of judging criteria beside the three in `references/DESIGN-IT-TWICE.md`;
where a lens fires, its remedy usually names a pattern.

`references/PATTERN-MATRIX.md` is the **selectable** half: the 23 Gang-of-Four
patterns, each with the one trigger condition under which it is the appropriate shape. Consult it
for the boundary in front of you. **When — and only when — a named trigger genuinely describes
this boundary**, propose that pattern to the developer as a structured choice, using a tool to ask
it where one is available, the
way `brainstorming` proposes an approach: the pattern as the recommended option, its rationale
tied to *this* session — why this pattern, for this boundary, now, in the words of the design you
are actually shaping — with **"plain shape, no pattern"** always present and the default whenever
no trigger fires. A free-form escape leaves room for a different pattern or a
correction. No such tool: present the same options as plain text and say the run is degraded.

The default is load-bearing. A pattern is worth proposing only when its trigger fires on its
own; running the whole catalog against every boundary and offering the closest match is how a
codebase fills with patterns nobody needed. Trust the model to know each pattern already — the
matrix carries only the decision of *when*, never an explanation of *what* — and let the plain
shape win by default.

## Review mode

This skill has two modes, and they are the design/review split its callers need. The default —
everything above — is **design mode**: given a boundary that needs shaping, it sketches two
competing designs, runs the catalog, and chooses. **Review mode** is the other half: given a
shape *already chosen and written down* — an interface a plan sketches, a signature a task will
produce — it judges that shape and returns findings, without designing a new one.

Enter review mode when invoked with the argument `review` and a proposed shape to judge (this
is how the `plan` conductor's arch-lens review calls this skill over a plan's Interfaces blocks). In review mode:

- **Run `references/SHAPE-REVIEW.md` over the given shape** — the SOLID lens and the anti-pattern table —
  exactly as design mode runs them over its two sketches, but here over the one shape handed in.
  Each lens that fires is a finding: name the smell, name where it shows at this boundary, and
  name the remedy the table points to (a `references/PATTERN-MATRIX.md` pattern, a
  `references/DEEPENING.md` move, or a plain split).
- **Also apply the leakage tests** from *Information hiding and leakage* above — a parameter that
  only makes sense with inside knowledge, a required call order, repeated call-site choreography,
  a change inside forcing a change outside. A sketched interface leaks the same way a built one
  does, and the sketch is the cheapest place to catch it.
- **Skip the generative machinery.** Do not sketch a second design, do not run the pattern
  matrix's proposal-as-a-structured-choice flow, do not choose between shapes — there is one
  shape, supplied, and the job is to judge it, not to replace it. Return the findings and let the
  caller decide what to revise.

Review mode judges a shape; it does not own the fix. The caller — the `plan` conductor's arch-lens review — decides which
findings to close in the plan and which to surface to the human. Hand back the findings and stop.

## Boundaries — what this does not do

- It does not **audit a codebase.** Looking across every module for shallow interfaces
  and drawing an improvement plan is a codebase-wide architecture audit that runs
  this skill's vocabulary at a different scale. This skill shapes the one boundary in
  front of it and stops there.
- It does not **decide what to build.** Whether a feature is worth building, and which
  approach it takes, is settled in `brainstorming`; this skill does not weigh in on product
  direction. It starts once an approach has named a boundary that needs shaping — a module
  new or existing, one that nothing may have built yet — before the spec is written. A
  boundary to shape, not a module already sitting in the tree, is what this skill needs to
  begin.
- It does not **implement.** Sketching interface shapes and choosing between them is not
  writing the module. Once a shape is chosen, building it is ordinary implementation work,
  outside this skill.
