# Framework best-practices index

This is a deliberate exception: this facet is the first in guardtower with more than one
reference file.
Depth varies enormously by stack — Laravel has real, deep source material; others are much
thinner — so a single flat checklist would force the facet to read every stack's content on
every run regardless of relevance. This index plus one file per stack keeps that read scoped to
the stack(s) a change actually touches.

| Stack      | Detected by (files the diff touches)                                                                          | Read |
|------------|------------------------------------------------------------------------------------------------------------------|------|
| Laravel    | `*.php` under an Eloquent/Illuminate-namespaced app, `routes/*.php`, `app/Http/**`, `database/migrations/**`, `tests/**/*.php` (Pest/PHPUnit)      | [`references/laravel.md`](laravel.md) |
| Tailwind   | Tailwind utility classes in Blade/JSX/Vue templates, `tailwind.config.{js,ts}`, an `@theme`/`@import "tailwindcss"` CSS file | [`references/tailwind.md`](tailwind.md) |
| Symfony    | `*.php` under a Symfony-conventional `src/Controller`/`src/Entity`/`config/services.yaml` app — including an OroCommerce app, which is Symfony underneath | [`references/symfony.md`](symfony.md) |
| OroCommerce | `*.php` under an Oro-conventional `src/*/Bundle` layout, an Oro entity-extend/workflow/layout/DataGrid config | [`references/orocommerce.md`](orocommerce.md) |
| React      | `.jsx`/`.tsx` component files, `useEffect`/`useState`/hook usage, outside Inertia-only page conventions | [`references/react.md`](react.md) |
| Vue        | `.vue` single-file components, Composition/Options API usage | [`references/vue.md`](vue.md) |
| TypeScript | `.ts`/`.tsx` files, a `tsconfig.json` in the touched project | [`references/typescript.md`](typescript.md) |
| JavaScript | `.js` files outside a more specific detected framework's own directory | [`references/javascript.md`](javascript.md) |
| Backbone   | `Backbone.View`/`Backbone.Model` usage, `.extend({...})` view/model definitions | [`references/backbone.md`](backbone.md) |

A change can match more than one row — read every matched stack's file, not just the first match.
For example, a Blade template touching both Laravel and Tailwind conventions reads both files; an
OroCommerce PHP change matching both the Symfony row (generic DI/controller/Doctrine idioms) and
the OroCommerce row (Oro-platform-specific idioms) reads both `symfony.md` and `orocommerce.md`;
a `.tsx` React component reads both `react.md` and `typescript.md`.
