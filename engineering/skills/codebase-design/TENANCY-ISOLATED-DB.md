# Shaping a tenant boundary — isolated-database (database-per-tenant) model

Use this when the app is multi-tenant in the **database-per-tenant** (or schema-per-tenant)
model — each tenant has its own database or schema, and no tenant's rows sit in the same table as
another's. Here isolation is not a query predicate; it is a **connection boundary**. One tenant's
data stays out of another's hands because the operation runs against that tenant's own connection.
The failure modes are near-disjoint from the shared-database model: there is no discriminator to
forget, but there is a connection to route, and the leaks are about *which database an operation
talks to*, not *which rows it filters*.

Like the shared-database companion, this is the leakage principle (`SKILL.md`, "Information hiding
and leakage") applied to one invariant. A boundary where the caller must remember to point the
operation at the right connection is an **information leak** — the module externalizing its
connection-routing invariant — and "which layer resolves and switches the connection" is a
**depth** question. Shape the boundary so the right-connection guarantee is hidden behind it, not
re-established at every call site.

## Where and when the connection is resolved and switched

The load-bearing decision. Decide, as part of the interface, where the tenant **connection is
resolved and switched** — and make it a place a caller cannot bypass. Two shapes to weigh:

- **The module resolves and switches.** A resolver or middleware establishes the current tenant's
  connection at the edge of the operation (per request, per job), and the data layer binds to
  "the current tenant connection" without any caller naming it. The interface stays narrow: the
  caller states *what* to do; the module runs it against the right database. A caller has no way
  to run an operation against the wrong database because it never handles a connection at all.
- **The caller passes the connection.** Every repository method takes a connection or a tenant
  handle the caller is trusted to supply correctly. This is the leak: the routing invariant lives
  at every call site, and a handle pulled from the wrong variable, defaulted, or left over from a
  previous tenant is a cross-tenant operation that type-checks cleanly.

Prefer the first, but pin down *when* the switch happens relative to the work, and what the data
layer does if no tenant connection has been established — it must fail loudly, never silently fall
through to a default or central connection. An operation that runs before the switch, or after the
context has been torn down, is the same leak as passing the wrong handle.

## Carrying tenant context across async boundaries

The sharpest failure in this model. A connection established for a request lives only as long as
that request. Work that runs **across async boundaries** — a queued job, a scheduled/cron task, an
event listener, a broadcast handler, a CLI command — starts with no ambient tenant connection, or
worse, inherits whatever connection a previous unit of work left current on a reused worker. The
boundary decision must state how tenant identity travels *with the work* across that gap:

- A job, event, or scheduled task carries the tenant it belongs to as part of its own payload, and
  re-establishes that tenant's connection when it runs — it does not assume the ambient connection
  is still the right one.
- The interface for enqueuing work makes the tenant a required part of dispatch, not an optional
  extra a caller can omit and have "work anyway" against whatever connection happens to be current.
- Anything that fans out across tenants (a nightly job over every tenant) switches the connection
  explicitly for each one and never lets one tenant's iteration leak into the next.

A data layer that reads "the current connection" inside async work, trusting it to still be the
right tenant, is the module externalizing an invariant it cannot see the caller violate.

## Central/landlord vs. tenant DB binding

A database-per-tenant app almost always has a **central (landlord)** database too — the registry
of tenants, billing, global configuration, the routing table itself — alongside the per-tenant
databases. Every model and repository binds to one side or the other, and the binding is part of
the shaped interface, not left implicit. Decide and state:

- Which entities live in the **landlord** database (tenants, plans, global settings) and which live
  in each **tenant** database (the tenant's own domain data), so a model is never ambiguous about
  which connection it belongs to.
- That a landlord-bound operation does not run against a tenant connection and vice versa — the two
  are different stores with different contents, and an operation pointed at the wrong one either
  finds nothing or writes tenant data into the shared landlord store.
- Where provisioning lives (creating and migrating a new tenant's database) — a landlord-side
  operation that reaches into per-tenant space, and one of the few places both connections are in
  play at once, so the interface for it must be explicit about which store each step touches.

## Whether cross-tenant reach is permitted at all

The connection boundary keeps the mechanics honest, but it does not by itself decide whether a
boundary is *allowed* to touch more than one tenant — and that authorization question is the same
one the shared model asks, not a per-model failure mode. Decide it at design time. Most operations
run against exactly one tenant's connection and should be shaped so reaching a second tenant's
database is structurally impossible through them. A few genuinely need **cross-tenant reach** — a
platform-admin console, a cross-tenant analytics rollup, a support tool that opens each tenant's
database in turn. When that reach is a real requirement it is a *designed contract*, not accidental
exposure: give it its own narrow, separately-authorized interface that is explicit about switching
between tenant connections, and never let an ordinary single-tenant path silently acquire a second
connection. The fan-out is mechanical; the permission is a decision the interface must make.

## The decision that travels into the spec

For a boundary that touches tenant-scoped data in this model, the shaped interface must state:
where and when the **connection is resolved and switched** (module-owned, unbypassable, failing
loudly when absent), how tenant identity is carried **across async boundaries** so no work runs
against a stale or default connection, which side of the **landlord** vs. tenant binding each
entity sits on, and whether **cross-tenant reach** is permitted and if so through what separate
interface. That set of answers is part of §6 of the spec, not an implementation detail deferred to
build time.
