
# Reviewing — Framework Best Practices facet

Say this first, plainly: `Using the code-review framework best-practices facet to review this
change.`

## What this guarantees

One thing: given the change under review, this facet looks for stack-specific idiom
violations — conventions particular to a detected framework, not the general principles every
other facet already reasons about — and returns a short, ordered, self-contained list of
findings, capped and floored, with a durable record written to its artifact. It is
**report-only**: it never edits code.

This facet self-limits at the source (see `../../hard-stops.md`), under the
shared `../../facet-contract.md`.

This is a deliberate exception: unlike every other facet, this one's lens is split across the
per-stack table below (*What this facet covers*) plus one file per stack, not a single checklist —
read only the file(s) the matched stack(s) in that table name. Ten stacks are covered: Laravel,
Tailwind, Symfony, OroCommerce, React, Vue, TypeScript, JavaScript, Backbone, and Electron — the
last covering Electron's **non-security idiom** only (main/renderer split, main-thread work,
lifecycle, packaging); Electron *security* (renderer isolation, preload/IPC, navigation,
shell/protocol) is the **Security** facet's Electron lens, not this facet's. A stack with no matching
row in the table below is out of scope for this facet, not silently approximated by whichever file
happens to be closest.

## What this facet covers

Depth varies enormously by stack — Laravel has real, deep source material; others are much thinner —
so a single flat checklist would force the facet to read every stack's content on every run
regardless of relevance. This table plus one file per stack keeps that read scoped to the stack(s) a
change actually touches.

| Stack      | Detected by (files the diff touches)                                                                          | Read |
|------------|------------------------------------------------------------------------------------------------------------------|------|
| Laravel    | `*.php` under an Eloquent/Illuminate-namespaced app, `routes/*.php`, `app/Http/**`, `database/migrations/**`, `tests/**/*.php` (Pest/PHPUnit)      | [`references/laravel.md`](references/laravel.md) |
| Tailwind   | Tailwind utility classes in Blade/JSX/Vue templates, `tailwind.config.{js,ts}`, an `@theme`/`@import "tailwindcss"` CSS file | [`references/tailwind.md`](references/tailwind.md) |
| Symfony    | `*.php` under a Symfony-conventional `src/Controller`/`src/Entity`/`config/services.yaml` app — including an OroCommerce app, which is Symfony underneath | [`references/symfony.md`](references/symfony.md) |
| OroCommerce | `*.php` under an Oro-conventional `src/*/Bundle` layout, an Oro entity-extend/workflow/layout/DataGrid config | [`references/orocommerce.md`](references/orocommerce.md) |
| React      | `.jsx`/`.tsx` component files, `useEffect`/`useState`/hook usage, outside Inertia-only page conventions | [`references/react.md`](references/react.md) |
| Vue        | `.vue` single-file components, Composition/Options API usage | [`references/vue.md`](references/vue.md) |
| TypeScript | `.ts`/`.tsx` files, a `tsconfig.json` in the touched project | [`references/typescript.md`](references/typescript.md) |
| JavaScript | `.js` files outside a more specific detected framework's own directory | [`references/javascript.md`](references/javascript.md) |
| Backbone   | `Backbone.View`/`Backbone.Model` usage, `.extend({...})` view/model definitions | [`references/backbone.md`](references/backbone.md) |
| Electron   | an `electron` dependency in `package.json`; a main-process entry (`app.whenReady`, `BrowserWindow`), preload scripts, or Electron packaging/asar config — the **idiom** surface only (Electron *security* is the Security facet's) | [`references/electron.md`](references/electron.md) |

A change can match more than one row — read every matched stack's file, not just the first match.
For example, a Blade template touching both Laravel and Tailwind conventions reads both files; an
OroCommerce PHP change matching both the Symfony row (generic DI/controller/Doctrine idioms) and the
OroCommerce row (Oro-platform-specific idioms) reads both `symfony.md` and `orocommerce.md`; a `.tsx`
React component reads both `react.md` and `typescript.md`.

## The workflow

1. **Relevance gate — first, before any lens work.** Run the relevance gate before touching a
   single lens: read the *What this facet covers* table above. Does the diff touch a file matching a
   listed stack's detection signal? No match on any row: short-circuit and return
   `relevance: { skipped: <reason> }`, having spent almost nothing (only the table was read), and
   write an artifact recording the skip.
2. **Apply the lens(es).** For each matched stack, read its reference file and work its classes of
   defect against the diff. A change matching more than one stack (e.g. a Blade template touching
   both Laravel and Tailwind conventions) applies every matched file's lens, not just the first.
3. **Floor, then cap, then tally the cap's drops** per hard-stops.md §2–3 — drop below
   `caps.floor`, keep at most `caps.top_n`, and report `dropped` (how many genuine
   above-floor findings the cap held back) so nothing real vanishes unseen.
4. **Write the artifact and return** per facet-contract.md's Finding schema, to `findings.md`.

Idiom-specific findings — a convention particular to the detected stack — are this facet's job.
A reinvention of an existing framework capability with no stack-specific placement/shape angle
belongs to the **Technical** facet's reuse-over-reinvention lens; a generic inefficiency with
nothing stack-specific about it belongs to the **Technical** facet's efficiency lens — this facet
does not duplicate either. Where a stack's own reference
file draws a further boundary against a sibling facet (Laravel's against Security, for instance),
that boundary is stated there, not repeated here.

## What this does not do

- It does not **cover a stack with no reference file** — a stack outside the ten covered stacks is
  out of scope, not silently approximated by whichever file happens to be closest.
- It does not **scan the repository** beyond the diff and the index/stack files it reads — no
  proactive repo-wide audit of every file in a detected stack.
- It does not **enumerate style nits** with no idiom-shape consequence — the cap and floor are
  deliberate, same as every other facet.
