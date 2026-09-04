# JavaScript — framework idiom checklist

The plain-JavaScript lens for the framework best-practices facet. This covers vanilla JS concerns
that show up regardless of framework — React, Vue, and Backbone each already get their own file
for their own framework-specific idioms; this file is what applies underneath all of them, and to
JS with no framework at all. The reach is the diff: a pattern visible in the changed code, not a
proactive audit of the whole codebase. Authored directly from well-established public JavaScript
conventions — no Boost-style source material exists for this stack. Contents:

- Async idioms
- Equality/coercion idioms
- Scope/closure idioms
- Module-system idioms
- What is not a finding

## Async idioms

- **A Promise-returning call with no `await` and no `.catch`/error handling** — the call fires,
  its rejection has nowhere to go, and a failure the caller should have known about is silently
  dropped instead of surfaced.
- **`async`/`await` mixed with raw `.then()` chains for the same kind of operation** within one
  module that has otherwise standardized on one style — the two control-flow styles handle errors
  differently (a `try`/`catch` around `await` vs. a `.catch()` on the chain), so mixing them for
  equivalent operations makes it unclear which error-handling path a given call actually follows.

## Equality/coercion idioms

- **`==`/`!=` used where the values being compared can differ in type in a way that changes the
  result**, as opposed to an established, deliberate loose-equality idiom already used elsewhere
  in the codebase for the same purpose (`x == null` to catch both `null` and `undefined`) — an
  unintentional loose comparison lets a type coercion silently change the outcome of a check.

## Scope/closure idioms

- **A closure captured inside a loop that reads a stale or shared value instead of the
  per-iteration one** — `var` inside a loop body captured by a callback, or a `let` captured by
  reference in an async callback that runs after the loop has already advanced, both read
  whatever the variable holds by the time the callback actually runs, not the value at the
  iteration that created it.

## Module-system idioms

- **CommonJS `require()` and ESM `import` mixed inconsistently** within one module, or across a
  codebase that has otherwise standardized on one module system — the two have different
  resolution and interop semantics, and mixing them for equivalent modules makes it unclear which
  one a new file should use.

## What is not a finding

- A reinvention of an existing JavaScript/standard-library capability with no placement/shape
  angle specific to this checklist — the **Novelty** facet owns reuse over reinvention
  generically.
- A generic inefficiency (an N+1 shape, an unbounded load) with nothing specific to these idioms —
  the **Technical** facet already covers inefficient data access in the abstract.
- React, Vue, or Backbone-specific idioms — those belong to their own files (`react.md`, `vue.md`,
  `backbone.md`), not this one; this file covers what applies underneath all of them.
- A style/formatting preference with no correctness or maintainability consequence.
- A pre-existing pattern in a file the change doesn't touch — this facet reviews the diff, not
  the whole application.
- A departure from a rule here that matches an established, consistent convention already used
  elsewhere in the project — consistency with the existing codebase outranks a rule in this file.
