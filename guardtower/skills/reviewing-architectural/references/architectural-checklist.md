# Architectural review checklist — the defects a diff can show

The lens for the architectural facet. Language- and stack-agnostic: these are classes of structural
defect to reason about in whatever the change is written in, not a rule table for one framework. Every
class here is scoped to what the **diff** actually moves — a boundary the change crosses, introduces,
or reshapes — not the whole system's architecture, which the diff does not show and this facet does
not audit (ADR-0004). Contents:

- Dependency-direction / coupling violation — the headline class
- Responsibility / cohesion creep
- Duplicated abstraction
- Leaky abstraction
- What is not a finding

## Dependency-direction / coupling violation

The relevance gate already established the change moves a boundary. For each **new import or reference
the change introduces across a boundary**, ask whether it points the right way:

- **Wrong-direction dependency** — a lower or more-foundational layer reaching up to a higher one (a
  domain model importing a controller, a utility importing the application it serves). The arrow
  should point toward stability, not away from it; a new import that reverses it is a finding.
- **A boundary crossed that should not be** — a module reaching directly into another's internals
  when a defined seam exists, or a new dependency that couples two modules the architecture kept
  apart. Say which boundary the new edge crosses, so the reviewer can confirm without the author's
  context.

The reach is the diff: the edges the change **newly adds**, read against model knowledge of layering
and the public surface of what the change already touches — no proactive dependency-graph build.

## Responsibility / cohesion creep

When the change moves responsibility between modules or grows a module's remit, ask whether the
module still does one thing:

- **An unrelated responsibility piled on** — a module that already owns X now also owns Y, where Y
  has no cohesion with X and belongs to its own home. The change makes the module a place two
  unrelated reasons-to-change now meet.
- **Logic landing in the wrong home** — behavior added to a layer that should only coordinate (a
  business rule inside a transport/controller shell), or state added to something that was
  stateless, where an existing module was the natural owner.

## Duplicated abstraction

When the change introduces a new abstraction or interface, ask whether the codebase already models
the same thing:

- **A parallel hierarchy** — a second interface, base type, or factory that does what an existing one
  already does, so the codebase now has two ways to express one concept and every future change must
  pick or update both.
- **A re-modeled concept** — a new type or module that re-describes a domain concept an
  already-touched module already owns. This is the architectural sibling of the technical facet's
  reuse lens: there, a reinvented helper; here, a reinvented *structure*.

## Leaky abstraction

When the change adds a new interface or seam, ask whether it hides its inside:

- **Internals in the signature** — a new interface whose parameters, return shape, or required call
  order force the caller to know how it works inside (a flag that only makes sense if you know which
  internal path runs; a mandatory `open`→`write`→`close` the caller must sequence).
- **A detail that will force callers to change** — a new seam that passes an implementation choice
  straight through, so a later change inside the module will ripple out to every caller. That is the
  sharpest test that the abstraction is not actually abstracting.

## What is not a finding

Keep the floor honest — these belong to other facets, to the whole-repo audit this facet refuses, or
to no one:

- Whole-system architecture the **diff does not touch** — an existing coupling elsewhere, a layering
  the change neither introduces nor worsens. Out of reach by ADR-0004, and an explicit non-goal.
- Pre-existing structure the change leaves exactly as it found it — this facet flags what the diff
  *creates*, not what it inherits.
- A subjective structure preference with no coupling, cohesion, duplication, or leak consequence — a
  different-but-equivalent shape is not a defect.
- A security or technical concern — the Security or Technical facet owns it, not this one.
