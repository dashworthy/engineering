# Shaping a tenant boundary — shared-database (single-schema) model

Use this when the app is multi-tenant in the **single-database, shared-schema** model — every
tenant's rows live in the same tables, told apart by a discriminator column (`tenant_id`,
`account_id`, `org_id`). Here isolation is a **query predicate**: a row belongs to a tenant, and
the way one tenant's data stays out of another's hands is that every query carries the predicate
that filters to the current tenant. The design question is not *whether* to filter — it is
**where the filter lives**, so that no caller is in a position to forget it.

This is not a new concern bolted on; it is the leakage principle
(`SKILL.md`, "Information hiding and leakage") applied to one specific invariant. A tenant scope
the caller has to remember to add is an **information leak** — the module externalizing its own
isolation invariant — and "which layer enforces isolation" is a **depth** question, the same one
the depth principle asks about every other responsibility. Shape the boundary so isolation is
hidden behind it, paid once, not re-derived at every call site.

## Where scoping lives — so no caller builds an unscoped query

The load-bearing decision. Isolation must be enforced by the module that owns the data, not
assembled by each caller. Two shapes to weigh:

- **The module owns the predicate.** A base repository, a default query scope, a model-layer
  global scope, or a row-level-security policy applies the tenant filter automatically, so the
  *only* query a caller can express is already scoped. An **unscoped query** is not something a
  caller has to remember to avoid — it is something they cannot accidentally write, because the
  narrow interface never hands them an unfiltered query object in the first place.
- **The caller passes the tenant.** Every method takes a `tenant_id` and is trusted to put it in
  the `WHERE` clause. This is the leak: the isolation invariant now lives at every call site, and
  the boundary holds only as long as every author, on every future call site, remembers. One
  forgotten predicate is one tenant reading another's rows.

Prefer the first. This is the leak test from `SKILL.md` applied directly: if a caller *can*
construct an **unscoped query** against tenant-owned data through this interface, the interface is
passing the isolation detail through rather than hiding it. Design it so the unscoped query is
unreachable, and keep the one deliberate escape hatch (a genuinely cross-tenant admin report)
explicit, named, and separate — never the default path.

## Ambient vs. explicit tenant context

Once the module owns the predicate, it needs the current tenant from somewhere. Two shapes,
again a depth-vs-leak trade:

- **Ambient tenant context.** The current tenant is resolved once (from the request, the session,
  the auth token) and held where the data layer can read it, so a caller writes `orders.recent()`
  and the scope is applied from ambient context it never names. The interface stays narrow; the
  caller states *what*, the module supplies *which tenant* from the context it owns.
- **An explicit tenant parameter in every signature.** Each method takes the tenant as an
  argument — `orders.recent(tenant_id)`. This reads as safer but is the leak wearing a
  responsible face: the isolation invariant is back in the caller's hands, threaded through every
  signature, and an **explicit tenant** argument passed wrong (or defaulted, or pulled from the
  wrong variable) is a cross-tenant read that type-checks cleanly.

Ambient is usually the deep shape — but ambient context has its own failure: work that runs
*outside* the request that set it (a queued job, a scheduled task, a CLI command, an event
handler) has no ambient tenant, and a data layer that silently reads an empty or stale context
there is worse than an explicit parameter would have been. So the boundary decision includes:
**where is ambient context established, and what does the data layer do when it is absent** — fail
loudly, never fall through to unscoped. If a code path genuinely cannot carry ambient context,
that path — and only that path — takes the tenant explicitly, as a documented exception.

## Mass-assignment of the discriminator

The tenant discriminator is not an ordinary column. If the boundary lets a caller set or update
`tenant_id` through the same mass-assignment path it uses for real attributes, a caller (or a
crafted request body) can move a row into another tenant or create one already pointing at a
victim tenant. Shape the write interface so the discriminator is set by the module from the
current tenant context, never accepted from caller-supplied input — guard it out of the
mass-assignable set, the same way a module hides any other invariant it must own.

## Whether cross-tenant reach is permitted at all

Finally, decide — at design time, as part of the interface — whether this boundary may reach
across tenants *ever*. Most boundaries are strictly single-tenant and should be shaped so
**cross-tenant reach** is structurally impossible through them. A few genuinely need it (a
platform-admin console, a cross-tenant analytics rollup, a support tool). When cross-tenant reach
is a real requirement, it is a *designed contract*, not accidental exposure: give it its own
narrow, explicit, separately-authorized interface — never widen the ordinary tenant-scoped path
to allow it. An interface that can be either scoped or unscoped depending on an argument is the
leak and the cross-tenant hole in one shape.

## The decision that travels into the spec

For a boundary that touches tenant-scoped data in this model, the shaped interface must state:
where the scope lives (module-owned, so no **unscoped query** is reachable), whether tenant
context is **ambient** or an **explicit tenant** parameter and how absence of ambient context
fails, that the discriminator is not mass-assignable, and whether **cross-tenant reach** is
permitted and if so through what separate interface. That set of answers is part of §6 of the
spec, not an implementation detail deferred to build time.
