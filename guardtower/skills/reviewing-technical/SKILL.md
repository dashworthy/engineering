---
name: reviewing-technical
description: "Guardtower's technical facet: review a change for inefficient data access (N+1, queries in loops, unbounded loads) and correctness-scoped best-practice defects (a resource left open, an off-by-one, a truthiness trap), returning capped, floored, self-contained findings. Reuse over reinvention is the Novelty facet's job, not this one. Use when a technical review of a diff/branch/PR is requested."
---

# Reviewing — Technical facet

Say this first, plainly: `Using the guardtower technical facet to review this change.`

## What this guarantees

One thing: given the change under review, this facet looks for technical defects — inefficient data
access and correctness-scoped best-practice lapses — and returns a short, ordered, self-contained
list of findings, capped and floored, with a durable record written to its artifact. It is
**report-only**: it never edits code.

This facet self-limits at the source (see `../reviewing/references/hard-stops.md`), under the shared `../reviewing/references/facet-contract.md`.

Its analysis stays inside a fixed boundary: the diff and a glance at the public surface of the
modules the change already imports — **no proactive repo-wide scan or function index**. An N+1 or an
unbounded load visible in the changed code is in reach; a pre-existing inefficiency the change never
touches is out of scope. Reinvention of an existing capability — a framework, library, or
already-imported module already providing what the change hand-rolls — is a sibling lens the
**Novelty** facet owns; a reinvention this facet happens to notice belongs there, not here.

## The workflow

1. **Relevance gate — first, before any lens work.** Run the relevance gate before touching a single
   lens. Does this change contain logic worth a technical
   review? New or changed functions, data-access code, loops over collections, comparison / date /
   string handling, non-trivial computation — in scope. A pure config, docs, or formatting change, or
   a trivial constant edit, is **not**: short-circuit and return `relevance: { skipped: <reason> }`,
   having spent almost nothing, and write an artifact recording the skip.

2. **Apply the lenses.** For a change that passed the gate, work
   [references/technical-checklist.md](references/technical-checklist.md):
   - **Inefficient data access** — N+1 patterns, queries inside loops, unbounded or unpaginated loads,
     repeated identical queries.
   - **Correctness-scoped best practices** — only defects with a correctness or maintainability
     consequence; never style.

   Reuse over reinvention has moved to the **Novelty** facet — a hand-rolled duplicate of a framework
   idiom, a standard-library primitive, or an already-imported helper is a finding there, not here.

3. **Floor, then cap.** Drop every candidate weaker than `caps.floor` (on the weaker of its severity
   and confidence). Order what remains most-severe-first and keep at most `caps.top_n`.

4. **Write the artifact and return.** Write the kept findings to `artifact_path` (the facet's `findings.md`) in the Finding schema
   (severity, confidence, location, claim, why, optional suggestion) — each `claim`/`why` legible to a
   reviewer with no shared context. Write the artifact even when nothing survives the floor (record
   "no findings above the floor"). Return the contract result.

## What this does not do

- It does not **fix** anything — report-only; a `suggestion` names a direction, never an edit.
- It does not **scan the repository** — its reach is the diff plus already-imported modules;
  it does not build a function index to find every possible reuse.
- It does not **review beyond the technical lens** — a security or architectural smell it happens to
  notice is out of scope; another facet owns it.
- It does not **enumerate style nits** — the cap and floor are deliberate; a long low-signal list of
  formatting and naming preferences is a failure of this facet, not thoroughness.
