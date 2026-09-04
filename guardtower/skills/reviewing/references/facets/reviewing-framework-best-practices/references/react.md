# React — framework idiom checklist

The standalone-React lens for the framework best-practices facet. This covers React itself —
component and hook idioms — not Inertia's page-navigation conventions, which already live in
`laravel.md`'s own Inertia-specific section and stay there untouched. The reach is the diff: a
pattern visible in the changed code, not a proactive audit of the whole application. Authored
directly from well-established public React conventions — no Boost-style source material exists
for this stack. Contents:

- Hook idioms
- State management idioms
- List/key idioms
- Side-effect idioms
- Memoization idioms
- What is not a finding

## Hook idioms

- **A `useEffect` dependency array missing a value the effect body actually reads** — a
  stale-closure risk: the effect keeps referencing the value's first-render binding instead of
  the current one, silently drifting from what the component's own state or props say.
- **Derived state computed via `useEffect` + `useState`** where a plain expression evaluated
  during render already produces the same value — an extra render cycle and a redundant piece of
  state to keep in sync, for a value that was already computable without either.

## State management idioms

- **State prop-drilled through several layers with no layer actually using it**, where the
  codebase already has an established Context (or store) pattern for the same kind of
  cross-cutting value — the drilled prop couples every intermediate component to a value it has
  no business knowing about.
- **A state object mutated directly** (`state.items.push(x)`, `state.field = y`) instead of
  replaced with a new reference — defeats React's referential-equality change detection, so a
  re-render the mutation should have triggered silently doesn't happen.

## List/key idioms

- **An array index used as a list `key`** on a list that can reorder, filter, or have items
  inserted/removed from the middle — React reuses component instances by key, so an index key on
  such a list attaches previous state (input values, focus, animation) to the wrong item after
  the list changes shape.

## Side-effect idioms

- **A `fetch` or subscription started in `useEffect` with no cleanup/abort returned** — the
  request or listener outlives the component's mount, leaking a network call whose response
  updates unmounted state, or a subscription callback that never unsubscribes.

## Memoization idioms

- **`React.memo`, `useMemo`, or `useCallback` reached for with no actual expensive computation or
  referential-equality problem it's solving** — the inverse of a missing-optimization defect: this
  is memoization applied where nothing warranted it, adding an extra comparison and a dependency
  array to maintain for no measurable benefit.

## What is not a finding

- A reinvention of an existing React capability with no React-specific placement/shape angle —
  the **Novelty** facet owns reuse over reinvention generically.
- A generic inefficiency (an N+1 shape, an unbounded load) with nothing React-specific about it —
  the **Technical** facet already covers inefficient data access in the abstract.
- Inertia's own page-navigation and page-prop conventions (`router.visit`, shared data, page
  component resolution) — those are `laravel.md`'s Inertia-specific section's job, not this file's;
  a React-in-Inertia app still gets this file's component/hook idioms reviewed, but the
  navigation layer belongs to the other file.
- A style/formatting preference with no correctness or maintainability consequence.
- A pre-existing pattern in a file the change doesn't touch — this facet reviews the diff, not
  the whole application.
- A departure from a rule here that matches an established, consistent convention already used
  elsewhere in the project — consistency with the existing codebase outranks a rule in this file.
