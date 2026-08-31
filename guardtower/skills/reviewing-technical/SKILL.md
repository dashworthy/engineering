---
name: reviewing-technical
description: "Guardtower's technical facet: review a change for reinventing what a library or an already-imported module already provides (reuse over reinvention), for inefficient data access (N+1, unbounded queries), and for correctness-scoped best-practice defects, returning capped, floored, self-contained findings. Use when a technical review of a diff/branch/PR is requested."
---

# Reviewing — Technical facet

Say this first, plainly: `Using the guardtower technical facet to review this change.`

## What this guarantees

One thing: given the change under review, this facet looks for technical defects — reinventing what
already exists, inefficient data access, and correctness-scoped best-practice lapses — and returns a
short, ordered, self-contained list of findings, capped and floored, with a durable record written
to its artifact. It is **report-only**: it never edits code.

This facet self-limits at the source (see `../reviewing/references/hard-stops.md`), under the shared `../reviewing/references/facet-contract.md`.

Its analysis stays inside a fixed boundary:
the diff, the reviewer's knowledge of well-known and standard libraries, and a glance at the public
surface of the modules the change already imports — **no proactive repo-wide scan or function
index**. Reinventing an already-imported `eq()` is in reach; reinventing a bespoke helper that lives
elsewhere in the repo and the change never imports is an accepted blind spot, not a defect this facet
chases.

## The workflow

1. **Relevance gate — first, before any lens work.** Does this change contain logic worth a technical
   review? New or changed functions, data-access code, loops over collections, comparison / date /
   string handling, non-trivial computation — in scope. A pure config, docs, or formatting change, or
   a trivial constant edit, is **not**: short-circuit and return `relevance: { skipped: <reason> }`,
   having spent almost nothing, and write an artifact recording the skip.

2. **Apply the lenses.** For a change that passed the gate, work
   [references/technical-checklist.md](references/technical-checklist.md), leading with the two
   high-value classes:
   - **Reuse over reinvention** — for each helper, comparison, loop, or parser the change *newly
     introduces*, check it against the standard library, well-known libraries, and the public surface
     of the modules the change already imports. If something already provides it, that's a finding.
   - **Inefficient data access** — N+1 patterns, queries inside loops, unbounded or unpaginated loads,
     repeated identical queries.
   - **Correctness-scoped best practices** — only defects with a correctness or maintainability
     consequence; never style.

3. **Floor, then cap.** Drop every candidate weaker than `caps.floor` (on the weaker of its severity
   and confidence). Order what remains most-severe-first and keep at most `caps.top_n`.

4. **Write the artifact and return.** Write the kept findings to `artifact_path` in the Finding schema
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
