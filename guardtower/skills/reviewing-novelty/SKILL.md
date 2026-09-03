---
name: reviewing-novelty
description: "Guardtower's novelty facet: review a change for reinventing a capability that the framework in use, the standard library, a depended-on library, or an already-imported module already provides — a hand-rolled primitive a library already exposes, a reimplemented framework idiom, a private helper duplicating a function the change already imports — returning capped, floored, self-contained findings. Use when a novelty / reuse-over-reinvention review of a diff/branch/PR is requested."
---

# Reviewing — Novelty facet

Say this first, plainly: `Using the guardtower novelty facet to review this change.`

## What this guarantees

One thing: given the change under review, this facet asks a single question — *did we reinvent
something that already exists?* — and returns a short, ordered, self-contained list of findings,
capped and floored, with a durable record written to its artifact. It is **report-only**: it never
edits code.

The defect is ordinary and expensive: new code that rebuilds a capability the stack already provides
adds a maintenance surface for a problem already solved, and often tests or reimplements the
framework rather than the change. The finding is *duplication of an existing capability*, never
newness for its own sake.

This facet self-limits at the source (see `../reviewing/references/hard-stops.md`), under the shared `../reviewing/references/facet-contract.md`.

Its analysis stays inside a fixed boundary: the diff, the reviewer's knowledge of the framework in
use, the standard library, and well-known / already-depended-on libraries, and a glance at the
public surface of the modules the change already imports — **no proactive repo-wide scan or function
index**. Reinventing a framework idiom, a standard-library primitive, a documented library API, or an
already-imported helper is in reach; a bespoke helper that lives elsewhere in the repository and the
change never imports is an accepted blind spot, not a defect this facet chases — chasing it would
mean the repo-wide scan the token budget rules out.

## The workflow

1. **Relevance gate — first, before any lens work.** Run the relevance gate before touching a single
   lens. Does this change *introduce new code* — a helper, a test, a loop, a comparison, a
   conversion, a bit of framework wiring — that could plausibly duplicate an existing capability? New
   or changed functions, hand-rolled utilities, tests that reach for internals, framework
   boilerplate — in scope. A pure config, docs, or formatting change, a trivial constant edit, or a
   change that only deletes code, is **not**: short-circuit and return `relevance: { skipped: <reason> }`,
   having spent almost nothing, and write an artifact recording the skip.

2. **Apply the lens.** For a change that passed the gate, work
   [references/novelty-checklist.md](references/novelty-checklist.md). For each capability the change
   *newly introduces*, ask whether something already provides it:
   - **Framework idiom** — the framework in use already exposes it as a first-class feature.
   - **Standard library** — the language's own built-ins for dates, collections, strings, math, I/O.
   - **Well-known / depended-on library** — a documented API of a library the project already pulls in.
   - **Already-imported module** — the public surface of a module *this change already imports or
     uses*; a private helper duplicating it is a finding.
   Name what was reinvented and what already provides it, so a reviewer can confirm without the
   author's context.

3. **Floor, then cap.** Drop every candidate weaker than `caps.floor` (on the weaker of its severity
   and confidence). Order what remains most-severe-first and keep at most `caps.top_n`.

4. **Write the artifact and return.** Write the kept findings to `artifact_path` (the facet's `findings.md`) in the Finding schema
   (severity, confidence, location, claim, why, optional suggestion) — each `claim`/`why` legible to a
   reviewer with no shared context. Write the artifact even when nothing survives the floor (record
   "no findings above the floor"). Return the contract result.

## What this does not do

- It does not **fix** anything — report-only; a `suggestion` names a direction, never an edit.
- It does not **scan the repository** — its reach is the diff plus already-imported modules and the
  reviewer's knowledge of the framework and well-known libraries; it does not build a function index
  to find every bespoke helper that might exist elsewhere.
- It does not **flag warranted novelty** — new code for a problem the stack does *not* already solve
  is the job, not a finding. The finding is duplication of an existing capability, not newness.
- It does not **review beyond reuse** — inefficient data access and correctness lapses belong to the
  Technical facet; a security or architectural smell belongs to its own facet.
