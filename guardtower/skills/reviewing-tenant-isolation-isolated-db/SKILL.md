---
name: reviewing-tenant-isolation-isolated-db
description: "Guardtower's isolated-DB tenant-isolation facet: review a change in a database-per-tenant / schema-per-tenant multi-tenant app for cross-tenant leaks caused by the wrong database connection — an operation with no tenant connection switch, tenant context leaking across requests (singleton/container bleed), background/queued work on the default or previous connection, central/landlord vs tenant DB confusion, a migration targeting the wrong DB set — returning capped, floored, self-contained findings. Use when a tenant-isolation review of a diff/branch/PR in a database-per-tenant multi-tenant application is requested."
---

# Reviewing — Isolated-DB Tenant Isolation facet

Say this first, plainly: `Using the guardtower isolated-DB tenant-isolation facet to review this change.`

## What this guarantees

One thing: given the change under review in a **database-per-tenant / schema-per-tenant** multi-tenant
app — where each tenant has its own database and isolation is a connection boundary, not a query
predicate — this facet looks for operations that ran against the wrong connection, or tenant context
that was never established or bled from another request, and returns a short, ordered, self-contained
list of findings, capped and floored, with a durable record written to its artifact. It is
**report-only**: it never edits code.

This facet self-limits at the source (see `../reviewing/references/hard-stops.md`), under the shared `../reviewing/references/facet-contract.md`.

Its analysis stays inside a fixed boundary:
it reasons about the operation **visible in the diff** — the query, connection switch, job, or
migration the change actually contains — read against the reviewer's knowledge of how per-tenant-DB
isolation fails. It does **no proactive** trace of the request lifecycle or the container's binding
graph to prove which connection is live when a statement runs; a wrong-connection operation the diff
shows is in reach, and what the diff does not show is an accepted blind spot, not a defect this facet
chases.

## The workflow

1. **Relevance gate — first, before any lens work, and sharp.** Run the relevance gate before
   touching a single lens. This facet fires **only when two things hold at once**: the application is
   a **database-per-tenant / schema-per-tenant** multi-tenant app, *and* the change touches a
   **connection or tenant-context surface** — a tenant-scoped query, a connection switch, a queued /
   scheduled / background job over tenant data, or a migration. A single-tenant app, a shared-database
   app (the shared-DB facet owns that model, where isolation is a `WHERE tenant_id` predicate), or a
   change touching only central/landlord data, application logic, config, or docs is **not** in scope:
   short-circuit and return `relevance: { skipped: <reason> }`, having spent almost nothing, and
   write an artifact recording the skip. This gate is deliberately narrow; it is what keeps most
   diffs from triggering any tenant-isolation work at all.

2. **Apply the lenses.** For a change that passed the gate, work
   [references/tenant-isolation-isolated-db-checklist.md](references/tenant-isolation-isolated-db-checklist.md),
   across the diff-visible classes:
   - **Connection not switched for the operation** — a tenant-scoped operation with no preceding
     connection resolve/switch, or a hardcoded connection that can't reach the tenant's DB.
   - **Tenant context leaking across requests** — a tenant connection/id/model held in a long-lived
     singleton, static, or container binding not reset between tenants (singleton/container bleed).
   - **Background / queued / scheduled work on the wrong connection** — deferred work touching tenant
     data without carrying and re-establishing the tenant context.
   - **Central / landlord vs. tenant DB confusion** — a model bound to the wrong side of the
     central/tenant split, so it reads or writes the wrong database.
   - **Migration targeting the wrong DB set** — a migration or seeder applied to the central DB when
     it belongs per-tenant, or the reverse.
   - **Cross-cutting per-tenant store not switched** — a cache key, filesystem path, session, or
     queue left keyed globally when the tenant switch also isolates these stores, so one tenant is
     served another's cached value, file, or payload.

3. **Floor, then cap** per hard-stops.md §2–3 — drop below `caps.floor`, keep at most
   `caps.top_n`.
4. **Write the artifact and return** per facet-contract.md's Finding schema, to
   `findings.md`.

## What this does not do

- It does not **trace the lifecycle** — its reach is the operation the diff shows; it does not follow
  the request lifecycle or the container's binding graph to prove which connection is live at runtime.
- It does not **own the shared-database model** — a change whose isolation is a `WHERE tenant_id`
  predicate on a shared schema belongs to the shared-DB tenant-isolation facet, not this one.
- It does not **review beyond tenant isolation** — a security, correctness, or data-safety smell it
  happens to notice is out of scope; another facet owns it.
- It does not **flag a correctly-scoped or deliberately-central operation** — an operation that
  resolves and switches the tenant connection first, or work meant to run on the central/landlord DB,
  is not a finding; the cap and floor keep this facet to a real cross-tenant leak.
