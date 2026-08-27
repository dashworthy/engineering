---
name: codebase-design
description: "[Design] Shape module interfaces so complexity hides behind narrow, deep boundaries. Use when defining a module's interface or judging whether a boundary earns its keep. Not a codebase-wide audit (improve-codebase-architecture) and not approach design (brainstorming)."
---

# Codebase Design

Say this first, plainly: `Using the codebase-design skill to shape this interface.`

## What this guarantees

One thing: given a module — new or existing — this skill produces an interface shaped
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

`DEEPENING.md`, alongside this file, is the list of concrete moves that turn a shallow
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

## Design-it-twice discipline

Before committing to a module's interface, sketch at least two genuinely different
shapes — two different allocations of responsibility between caller and module, not two
phrasings of the same shape — and do it before writing the implementation, not after.
`DESIGN-IT-TWICE.md`, alongside this file, owns how to generate a second design that
actually differs from the first, and the criteria for choosing between them once both
exist: what a call site has to know, how much of the module's machinery never has to
reach the interface, and whether the interface lets a caller hold it wrong and not notice.

## Reading the substrate

Before shaping a boundary, actively consult the substrate: resolve names from `CONTEXT.md`
(the glossary) and surface governing decisions with `engineering:using-adrs`. Treat a name
or boundary already settled there as a constraint on the shape you're sketching, not a
suggestion to route around. A project that has accumulated neither gives nothing back, and
this skill proceeds on the module and its immediate neighbors alone — the obligation is to
consult, not to require the artifacts.

## Offer to record the decision as an ADR

When a boundary or interface decision had genuine live alternatives — a call another designer
could reasonably have made differently — offer to record it as an ADR via
`engineering:recording-adrs`, written `Proposed`. The bar is real live alternatives, not every
routine shaping choice, and the developer may decline; declining is what keeps ADR intake from
flooding.

## Boundaries — what this does not do

- It does not **audit a codebase.** Looking across every module for shallow interfaces
  and drawing an improvement plan is a codebase-wide architecture audit that runs
  this skill's vocabulary at a different scale. This skill shapes the one boundary in
  front of it and stops there.
- It does not **decide what to build.** Whether a feature is worth building, and which
  approach it takes, is settled in `brainstorming`; this skill does not weigh in on product
  direction. It starts once an approach has named a boundary that needs shaping — a module
  new or existing — which is often the moment `brainstorming` invokes it, on a module still
  to be built, before the spec is written. A boundary to shape, not a module already sitting
  in the tree, is what this skill needs to begin.
- It does not **implement.** Sketching interface shapes and choosing between them is not
  writing the module. Once a shape is chosen, building it is ordinary implementation work,
  outside this skill.
