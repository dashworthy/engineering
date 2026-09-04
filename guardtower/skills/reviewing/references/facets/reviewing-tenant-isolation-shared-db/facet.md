
# Reviewing — Shared-DB Tenant Isolation facet

Say this first, plainly: `Using the guardtower shared-DB tenant-isolation facet to review this change.`

## What this guarantees

One thing: given the change under review in a **single-database, shared-schema** multi-tenant app —
where every tenant's rows share the same tables and are told apart by a discriminator column — this
facet looks for queries and writes that lost their tenant scope and so read, mutate, or expose one
tenant's data to another, and returns a short, ordered, self-contained list of findings, capped and
floored, with a durable record written to its artifact. It is **report-only**: it never edits code.

This facet self-limits at the source (see `../../hard-stops.md`), under the shared `../../facet-contract.md`.

Its analysis stays inside a fixed boundary:
it reasons about the query or write **visible in the diff** — the statement, scope, or association the
change actually contains — read against the reviewer's knowledge of how shared-schema isolation
fails. It does **no proactive** whole-schema crawl or call-graph trace to prove which tenant's rows a
statement can reach or which enforced global scope already constrains it; a missing-scope operation
the diff shows is in reach, and what the diff does not show is an accepted blind spot, not a defect
this facet chases.

## The workflow

1. **Relevance gate — first, before any lens work, and sharp.** Run the relevance gate before
   touching a single lens. This facet fires **only when two things hold at once**: the application is
   a **shared-database (single-DB, shared-schema)** multi-tenant app, *and* the change touches
   **tenant-scoped data** — a query, write, association, aggregate, or cache of a table carrying the
   tenant discriminator. A single-tenant app, a database-per-tenant app (the isolated-DB facet owns
   that model), or a change touching only global/shared-reference tables, application logic, config,
   or docs is **not** in scope: short-circuit and return `relevance: { skipped: <reason> }`, having
   spent almost nothing, and write an artifact recording the skip. This gate is deliberately narrow;
   it is what keeps most diffs from triggering any tenant-isolation work at all.

2. **Apply the lenses.** For a change that passed the gate, work
   [references/tenant-isolation-shared-db-checklist.md](references/tenant-isolation-shared-db-checklist.md),
   across the diff-visible classes:
   - **Missing tenant scope on a query** — a read or write on a tenant-scoped table with no tenant
     predicate constraining it.
   - **Global-scope bypass / raw query** — a raw query or an explicit `withoutGlobalScope`/`unscoped`
     escape hatch that skips the injected tenant scope.
   - **Cross-tenant reference by ID** — a foreign key or lookup that trusts a caller-supplied ID
     without confirming the row belongs to the current tenant.
   - **Mass-assignment of the tenant discriminator** — a write that lets the caller set or move
     `tenant_id` from unfiltered input.
   - **Cross-tenant aggregate / report** — an unscoped rollup, report, or export that spans tenants.
   - **Un-namespaced cache key** — a cache or memoization key on tenant-scoped data with no tenant
     component, so one tenant is served another's entry.

3. **Floor, then cap** per hard-stops.md §2–3 — drop below `caps.floor`, keep at most
   `caps.top_n`.
4. **Write the artifact and return** per facet-contract.md's Finding schema, to
   `findings.md`.

## What this does not do

- It does not **crawl the schema or trace callers** — its reach is the statement the diff shows; it
  does not enumerate every query against a table or prove which enforced global scope constrains a
  finder it can't see.
- It does not **own the database-per-tenant model** — a change whose isolation is a connection or
  schema boundary belongs to the isolated-DB tenant-isolation facet, not this one.
- It does not **review beyond tenant isolation** — a security, correctness, or data-safety smell it
  happens to notice is out of scope; another facet owns it.
- It does not **flag a deliberately global path** — a shared-reference table, an enforced global scope
  the diff relies on, or an authorized cross-tenant admin tool is not a finding just because it lacks
  a `WHERE tenant_id`; the cap and floor keep this facet to a real cross-tenant leak.
