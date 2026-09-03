---
name: reviewing-data-safety
description: "Guardtower's data-safety facet: review a change for destructive or irreversible data operations — an unbounded UPDATE/DELETE, a drop or rename of a column/table holding live data, a migration with no rollback, a non-idempotent migration, an irreversible op with no guard — the data-loss risks in a migration, schema change, or bulk data operation, returning capped, floored, self-contained findings. Use when a data-safety / migration review of a diff/branch/PR is requested."
---

# Reviewing — Data & Migration Safety facet

Say this first, plainly: `Using the guardtower data-safety facet to review this change.`

## What this guarantees

One thing: given the change under review, this facet looks for destructive or irreversible data
operations — an unbounded write, a drop of live data, a migration that can't be rolled back or safely
re-run — and returns a short, ordered, self-contained list of findings, capped and floored, with a
durable record written to its artifact. It is **report-only**: it never edits code.

This facet self-limits at the source (see `../reviewing/references/hard-stops.md`), under the shared `../reviewing/references/facet-contract.md`.

Its analysis stays inside a fixed boundary:
it reasons about the data operation **visible in the diff** — the migration, schema change, or bulk
statement the change actually contains — read against the reviewer's knowledge of how such
operations behave. It does **no proactive** data-flow graph or table-usage scan to prove which rows a
statement touches or who else reads the data; a destructive operation the diff shows is in reach, and
what the diff does not show is an accepted blind spot, not a defect this facet chases.

## The workflow

1. **Relevance gate — first, before any lens work, and sharp.** Run the relevance gate before touching
   a single lens. This facet fires **only when the
   change touches data at rest** — a migration, a schema change, or a bulk data operation (a mass
   `UPDATE`/`DELETE`, a backfill, a drop). A change with no data-mutating surface — application logic,
   config, docs, a read-only query, a single-row write in normal code — is **not** in scope:
   short-circuit and return `relevance: { skipped: <reason> }`, having spent almost nothing, and
   write an artifact recording the skip. This gate is deliberately narrow; it is what keeps most
   diffs from triggering any data-safety work at all.

2. **Apply the lenses.** For a change that passed the gate, work
   [references/data-safety-checklist.md](references/data-safety-checklist.md), across the
   diff-visible classes:
   - **Unbounded UPDATE/DELETE** — no `WHERE`, or a predicate that affects all rows.
   - **Drop / rename of live data** — a column or table holding live data dropped or renamed with no
     preservation path.
   - **No rollback** — a migration with no down / rollback path.
   - **Non-idempotent migration** — one that fails or corrupts if re-run (not reentrant).
   - **Irreversible op with no guard** — a destructive operation with no backup, guard, or
     confirmation.

3. **Floor, then cap** per hard-stops.md §2–3 — drop below `caps.floor`, keep at most
   `caps.top_n`.
4. **Write the artifact and return** per facet-contract.md's Finding schema, to
   `findings.md`.

## What this does not do

- It does not **trace the data** — its reach is the operation the diff shows; it does not build a
  data-flow graph or scan every consumer of a table to prove impact.
- It does not **review beyond data safety** — a security or correctness smell it happens to notice is
  out of scope; another facet owns it.
- It does not **flag safe migrations** — a bounded, reversible, idempotent migration is not a finding
  just because it touches data; the cap and floor keep this facet to a real data-safety risk — data
  loss or corruption, including a migration that cannot be safely re-run.
