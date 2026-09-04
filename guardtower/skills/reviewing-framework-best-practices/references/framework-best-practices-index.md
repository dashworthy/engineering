# Framework best-practices index

This is a deliberate exception: this facet is the first in guardtower with more than one
reference file.
Depth varies enormously by stack — Laravel has real, deep source material; others are much
thinner — so a single flat checklist would force the facet to read every stack's content on
every run regardless of relevance. This index plus one file per stack keeps that read scoped to
the stack(s) a change actually touches.

| Stack    | Detected by (files the diff touches)                                                                          | Read |
|----------|------------------------------------------------------------------------------------------------------------------|------|
| Laravel  | `*.php` under an Eloquent/Illuminate-namespaced app, `routes/*.php`, `app/Http/**`, `database/migrations/**`, `tests/**/*.php` (Pest/PHPUnit)      | [`references/laravel.md`](laravel.md) |
| Tailwind | Tailwind utility classes in Blade/JSX/Vue templates, `tailwind.config.{js,ts}`, an `@theme`/`@import "tailwindcss"` CSS file | [`references/tailwind.md`](tailwind.md) |

A change can match more than one row (e.g. a Blade template touching both Laravel and Tailwind
conventions) — read every matched stack's file, not just the first match.

Symfony, React, Vue, TypeScript, JavaScript, Backbone, and OroCommerce are not yet covered — a
deferred follow-up, not a row silently approximated by one of the two above.
