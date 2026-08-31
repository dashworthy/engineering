---
name: reviewing-architectural
description: "Guardtower's architectural facet: review a change for the structural defects visible in a diff — a coupling or dependency-direction violation the change introduces, responsibility piled onto a module that already owns something else, a duplicated abstraction, or a leaky abstraction — returning capped, floored, self-contained findings. Use when an architectural review of a diff/branch/PR is requested, or when guardtower's reviewing orchestrator dispatches the architectural facet."
---

# Reviewing — Architectural facet

Say this first, plainly: `Using the guardtower architectural facet to review this change.`

## What this guarantees

One thing: given the change under review, this facet looks for the structural defects a diff can
actually show — a coupling or dependency-direction violation, responsibility/cohesion creep, a
duplicated abstraction, a leaky abstraction — and returns a short, ordered, self-contained list of
findings, capped and floored, with a durable record written to its artifact. It is **report-only**:
it never edits code.

It is a *self-limiting* facet: it runs its relevance gate first and enforces its own caps and floor,
at the source, before it returns — the orchestrator does not trim it afterward. See the shared spine
it obeys: `../reviewing/references/hard-stops.md` and `../reviewing/references/facet-contract.md`.

Its analysis stays inside a fixed boundary:
the boundaries the diff itself moves, read against the reviewer's knowledge of layering and the
public surface of the modules the change already touches — **no proactive repo-wide scan or
dependency-graph build**. A coupling violation the change introduces at a boundary it crosses is in
reach; the whole system's architecture the diff never touches is an explicit non-goal, not a defect
this facet chases.

## The request and result

The orchestrator hands this facet the contract request: `change_ref`, an optional `spec_ref`, an
`artifact_path` (`.guardtower/<run>/reviewing-architectural/findings.md`), and `caps` (`top_n`,
`floor`). It returns the contract result: its `relevance` verdict, its `findings` (already floored
and capped to `top_n`), and the written `artifact_path`.

## The workflow

1. **Relevance gate — first, before any lens work, and sharp.** This facet fires **only when the
   change moves a boundary** — adds a new module, package, or layer; introduces a new cross-module or
   cross-layer dependency (a new import crossing a boundary); moves responsibility between modules; or
   introduces a new abstraction or interface. A change entirely within one module's existing
   responsibility — editing a function body, adding a field, fixing a bug in place — moves no boundary
   and is **not** in scope: short-circuit and return `relevance: { skipped: <reason> }`, having spent
   almost nothing, and write an artifact recording the skip. This gate is deliberately narrow; it is
   what keeps most diffs from triggering any architectural work at all.

2. **Apply the lenses.** For a change that moved a boundary, work
   [references/architectural-checklist.md](references/architectural-checklist.md), across the four
   diff-visible classes:
   - **Dependency-direction / coupling violation** — a new import that points the wrong way (a lower
     layer reaching up to a higher one) or crosses a boundary it should not.
   - **Responsibility / cohesion creep** — an unrelated responsibility piled onto a module that
     already owns something else.
   - **Duplicated abstraction** — a second way to do something the codebase already models.
   - **Leaky abstraction** — a new interface that exposes its internals, forcing callers to know
     implementation detail.

3. **Floor, then cap.** Drop every candidate weaker than `caps.floor` (on the weaker of its severity
   and confidence). Order what remains most-severe-first and keep at most `caps.top_n`.

4. **Write the artifact and return.** Write the kept findings to `artifact_path` in the Finding schema
   (severity, confidence, location, claim, why, optional suggestion) — each `claim`/`why` legible to a
   reviewer with no shared context. Write the artifact even when nothing survives the floor (record
   "no findings above the floor"). Return the contract result.

## What this does not do

- It does not **fix** anything — report-only; a `suggestion` names a direction, never an edit.
- It does not **audit the whole architecture** — its reach is the boundaries the diff moves;
  it does not build a dependency graph or grade the system the change never touches.
- It does not **review beyond the architectural lens** — a security or technical smell it happens to
  notice is out of scope; another facet owns it.
- It does not **flag pre-existing structure** — architecture the change neither introduces nor worsens
  is not a finding; the cap and floor keep this facet to defects the diff actually creates.
