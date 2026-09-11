
# Reviewing — Tenant Isolation facet

Say this first, plainly: `Using the code-review tenant-isolation facet to review this change.`

## What this guarantees

One thing: given the change under review in a multi-tenant app, this facet looks for cross-tenant
leaks — one tenant reading, mutating, or being served another's data — and returns a short,
ordered, self-contained list of findings, capped and floored, with a durable record written to its
artifact. It is **report-only**: it never edits code.

A multi-tenant app isolates tenants one of two ways, and the defect classes differ by which. This
facet carries **both lenses** and **branches on the deployment topology** the orchestrator's
menu-proposal step determined — the same tenancy verdict that proposes this
facet also selects which lens applies:

- **Shared-database lens** — a **single-database, shared-schema** app, where every tenant's rows
  share the same tables and are told apart by a discriminator column, so isolation is a
  `WHERE tenant_id` predicate. Selected on a `shared` (or `both`) verdict.
- **Isolated-database lens** — a **database-per-tenant / schema-per-tenant** app, where each
  tenant has its own database and isolation is a connection boundary, not a query predicate.
  Selected on a `per-db` (or `both`) verdict.

On a `both` verdict, apply both lenses; on `shared`, only the shared-database lens; on `per-db`,
only the isolated-database lens. The two are mutually exclusive per statement — a given piece of
data is isolated one way or the other — so this branch never doubles work, it routes it.

This facet self-limits at the source (see `../../hard-stops.md`), under the shared
`../../facet-contract.md`.

Its analysis stays inside a fixed boundary: it reasons about the query, write, or operation
**visible in the diff** — the statement, scope, association, connection switch, job, or migration
the change actually contains — read against the reviewer's knowledge of how the relevant isolation
model fails. It does **no proactive** whole-schema crawl, call-graph trace, or request-lifecycle
trace to prove which tenant's rows a statement can reach or which connection is live; a
missing-scope or wrong-connection operation the diff shows is in reach, and what the diff does not
show is an accepted blind spot, not a defect this facet chases.

## The workflow

1. **Relevance gate — first, before any lens work, and sharp.** Run the relevance gate before
   touching a single lens. This facet fires **only when two things hold at once**: the application
   is multi-tenant (the topology the step-1 verdict named), *and* the change touches a
   tenant-scoped surface for that topology:
   - **Shared-database:** a query, write, association, aggregate, or cache of a table carrying the
     tenant discriminator.
   - **Isolated-database:** a connection or tenant-context surface — a tenant-scoped query, a
     connection switch, a queued/scheduled/background job over tenant data, or a migration.

   A single-tenant app, or a change touching only global/shared-reference tables (shared-database)
   or central/landlord data (isolated-database), application logic, config, or docs is **not** in
   scope: short-circuit and return `relevance: { skipped: <reason> }`, having spent almost nothing,
   and write an artifact recording the skip. This gate is deliberately narrow; it is what keeps
   most diffs from triggering any tenant-isolation work at all.

2. **Apply the lens the topology selects.** Work the checklist for the selected lens (both, on a
   `both` verdict).

   - **Shared-database lens.** Work
     [references/tenant-isolation-shared-db-checklist.md](references/tenant-isolation-shared-db-checklist.md):
     a missing tenant scope on a query; a global-scope bypass / raw query (`withoutGlobalScope`/
     `unscoped`); a cross-tenant reference by a caller-supplied ID; mass-assignment of the tenant
     discriminator; a cross-tenant aggregate/report/export; an un-namespaced cache key on
     tenant-scoped data.

   - **Isolated-database lens.** Work
     [references/tenant-isolation-isolated-db-checklist.md](references/tenant-isolation-isolated-db-checklist.md):
     a connection not switched for the operation; tenant context leaking across requests
     (singleton/container bleed); background/queued/scheduled work on the wrong connection; central/
     landlord vs. tenant DB confusion; a migration targeting the wrong DB set; a cross-cutting
     per-tenant store (cache, filesystem, session, queue) left keyed globally.

3. **Floor, then cap, then tally the cap's drops** per hard-stops.md §2–3 — drop below
   `caps.floor`, keep at most `caps.top_n`, and report `dropped` (how many genuine above-floor
   findings the cap held back) so nothing real vanishes unseen. The cap spans whichever lens(es)
   ran.
4. **Write the artifact and return** per facet-contract.md's Finding schema, to `findings.md`.

## What this does not do

- It does not **crawl the schema, trace callers, or follow the request lifecycle** — its reach is
  the statement or operation the diff shows; it does not enumerate every query against a table,
  prove which enforced global scope constrains a finder it can't see, or follow the container's
  binding graph to prove which connection is live at runtime.
- It does not **guess the topology** — the deployment model comes from the step-1 tenancy verdict;
  this facet applies the lens that verdict selects rather than inferring the model itself.
- It does not **review beyond tenant isolation** — a security, correctness, or data-safety smell it
  happens to notice is out of scope; another facet owns it.
- It does not **flag a deliberately global/central path** — a shared-reference table, an enforced
  global scope the diff relies on, an authorized cross-tenant admin tool, an operation that
  resolves and switches the tenant connection first, or work meant to run on the central/landlord
  DB is not a finding; the cap and floor keep this facet to a real cross-tenant leak.
