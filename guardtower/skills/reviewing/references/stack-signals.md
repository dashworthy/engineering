# Stack signals — classifying a repo's frameworks for the menu-proposal gate

This reference is how the orchestrator decides, **once per run at the repo level**, whether to
*propose* the `reviewing-framework-best-practices` facet — and which stack(s) it covers for this
run. It is read and reasoned against by the agent; it is **not** a script, a grep list, or a
checklist to mechanically match. The goal is the set of frameworks the application actually runs,
so the menu offers the facet whose idiom-specific findings actually apply.

This is the **repo-level** gate — the upper of guardtower's two gates, the same one
`multi-tenancy-signals.md` runs for the tenant-isolation facets. It selects which facets appear
(and pre-checked); the facet then runs its own **per-change relevance gate** on the actual diff,
narrowed further to the file(s) a change actually touches (see
[`reviewing-framework-best-practices`'s own index](../../reviewing-framework-best-practices/references/framework-best-practices-index.md)).
A facet proposed here can still skip itself on a change that touches no stack-relevant surface.

**One structural difference from `multi-tenancy-signals.md`:** that gate emits a single verdict
from a mutually-exclusive set (`shared`/`per-db`/`both`/`none`/`ambiguous`), because a repo runs
one tenancy model. This gate emits a **set** of matched stacks instead, because stacks are not
mutually exclusive the way tenancy models are — a repo commonly runs more than one at once (a
Laravel backend with a Tailwind-styled Blade or Inertia/React frontend, for instance).

## What to read

Judge from the codebase as it stands, not from the diff under review — which frameworks a repo
runs is a property of the application, not of one change. Look at the dependency manifest
(`composer.json`, `package.json`), the presence of framework-specific config/entry files, and the
directory layout each framework conventionally expects.

## Laravel signals

- `laravel/framework` present in `composer.json`'s `require`.
- An `artisan` file at the repo root.
- The conventional Laravel directory layout — `app/Http/Controllers`, `routes/web.php` or
  `routes/api.php`, `database/migrations/`.

## Tailwind signals

- `tailwindcss` present in `package.json`'s `dependencies` or `devDependencies`.
- A `tailwind.config.js` or `tailwind.config.ts` at the repo root, **or** a CSS entry file using
  the v4 CSS-first `@theme` directive / `@import "tailwindcss"`.

## Classification — the verdict

Emit the **set** of matched stacks — zero or more of: `laravel`, `tailwind`. These are the only
two this facet covers today; the other seven (Symfony, React, Vue, TypeScript, JavaScript,
Backbone, OroCommerce) are a deferred follow-up and are never part of this verdict yet, however
strong their signals might look — do not guess at their detection ahead of their own reference
file existing.

- **Non-empty set** — propose the `reviewing-framework-best-practices` facet, pre-checked.
- **Empty set** — propose neither; the facet does not appear on the menu at all, mirroring how
  the tenant-isolation facets don't appear under a `none` verdict.

There is no `ambiguous` case here the way there is for tenancy: a stack is either present in the
dependency manifest/layout or it is not, and an absent or weak signal simply does not join the
set — no human question is needed to resolve it. The verdict governs only *which stacks the
proposed facet covers this run*; it never runs the facet by itself, never suppresses a facet the
human selects manually, and never overrides the facet's own per-change relevance gate.
