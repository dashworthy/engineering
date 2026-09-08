# Vue — framework idiom checklist

The Vue lens for the framework best-practices facet. These are classes of defect specific to how
Vue's reactivity system and component APIs expect a component to be shaped — not the generic
reinvention/inefficiency classes the Novelty and Technical facets already own. The reach is the
diff: a pattern visible in the changed code, not a proactive audit of the whole application.
Authored directly from well-established public Vue conventions — no Boost-style source material
exists for this stack. Contents:

- Reactivity idioms
- Composition/Options API consistency
- Computed vs. method idioms
- `v-for` key idioms
- Watcher idioms
- What is not a finding

## Reactivity idioms

- **A reactive object destructured into plain variables**, losing reactivity — `const { count } =
  state` breaks the connection to `state`'s own reactivity; `toRefs`/`storeToRefs`, or staying
  accessed through the reactive object directly, is the established way to destructure without
  losing it.
- **A `ref`'s `.value` mutated directly inside a template expression** where the template's
  automatic unwrap already applies — or the reverse: a plain object treated as reactive in script
  code without ever being wrapped in `ref`/`reactive`, so mutating it triggers no update at all.

## Composition/Options API consistency

- **A component written in the Options API alongside siblings that have all moved to
  `<script setup>`/Composition API**, or the reverse, in a codebase that has otherwise
  standardized on one — mixing both for equivalent components makes it unclear which pattern a
  new component should follow.

## Computed vs. method idioms

- **A `methods` entry (or a plain function called from the template) recomputing a pure derived
  value on every render**, where `computed` already exists to cache the same derivation and only
  recompute when its own reactive dependencies change.

## `v-for` key idioms

- **A `v-for` with no `:key`, or a key bound to the loop index** on a list that can reorder or
  filter — Vue's own diffing algorithm relies on the key to track identity across re-renders; an
  index key on such a list attaches previous element state to the wrong item after the list
  changes shape.

## Watcher idioms

- **A `watch` reached for with `{ deep: true }`** where a more specific, shallow watch source (a
  `computed`, or a specific property path) would already fire on the same meaningful change — deep
  watching walks the whole object on every mutation, far more work than the change being watched
  for actually needs.
- **A watcher that starts a side effect (a subscription, a timer) with no cleanup** — Vue's own
  `onWatcherCleanup` (or a cleanup function returned from the watch callback) exists precisely so
  a watcher's own side effects don't outlive the condition that started them.

## What is not a finding

- A reinvention of an existing Vue capability with no Vue-specific placement/shape angle — the
  **Novelty** facet owns reuse over reinvention generically.
- A generic inefficiency (an N+1 shape, an unbounded load) with nothing Vue-specific about it —
  the **Technical** facet already covers inefficient data access in the abstract.
- A style/formatting preference with no correctness or maintainability consequence.
- A pre-existing pattern in a file the change doesn't touch — this facet reviews the diff, not
  the whole application.
- A departure from a rule here that matches an established, consistent convention already used
  elsewhere in the project — consistency with the existing codebase outranks a rule in this file.
