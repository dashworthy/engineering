# Tenancy boundary — consult and force

Once the tenancy model is determined (step 1 in the SKILL's *Tenancy boundary* section), these are
the remaining two steps for a boundary that touches tenant-scoped data in a multi-tenant app.

## 2. Consult only the matching companion

Two companion files sit in `references/`, one per model, and their failure modes are near-disjoint —
so consult only the matching companion and leave the other closed. `references/TENANCY-SHARED-DB.md`
carries the shared-database boundary decision — where the scope lives so no caller can build an
unscoped query, ambient vs. explicit tenant context, discriminator mass-assignment, and whether
cross-tenant reach is permitted at all. `references/TENANCY-ISOLATED-DB.md` carries the
isolated-database decision — where and when the tenant connection is resolved and switched, carrying
tenant context across async boundaries, and central/landlord vs. tenant DB binding. A shared-database
app has no connection to route; an isolated-database app has no discriminator to forget. Reading the
wrong companion is reading for failure modes this app cannot have.

## 3. Force it when relevant, skip it silently otherwise

For a boundary that touches tenant-scoped data in a multi-tenant app, force the tenant-boundary
decision the matching companion frames — where isolation lives (a query scope for the shared model, a
connection for the isolated one) and the model-specific choices the companion sets out around it — as
a **required** part of the shaped interface, and let it travel into the spec's §6 with the rest of
the interface's shape. It is not optional, because an optional isolation lens is one a design under
time pressure skips, and the skip is the exact omission that ships the leak. For a single-tenant app,
or a boundary that touches no tenant-scoped data (a stateless formatter, a pure calculation, a config
loader), there is nothing to decide — skip it with no ceremony, the design-time echo of a review
facet's per-change relevance gate.
