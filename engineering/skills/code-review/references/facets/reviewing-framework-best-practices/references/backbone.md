# Backbone — framework idiom checklist

The Backbone lens for the framework best-practices facet. These are classes of defect specific to
how Backbone's view/model/event lifecycle expects a change to be shaped — not the generic
reinvention/inefficiency classes the Novelty and Technical facets already own. The reach is the
diff: a pattern visible in the changed code, not a proactive audit of the whole application.
Authored directly from well-established public Backbone conventions — no Boost-style source
material exists for this stack. Contents:

- View lifecycle idioms
- Event-binding idioms
- Model/collection sync idioms
- Re-render idioms
- What is not a finding

## View lifecycle idioms

- **A view removed or discarded (navigated away from, replaced) with no `stopListening()`/
  `remove()` call** — its event bindings stay attached to a model or collection that outlives it,
  the classic Backbone "zombie view": a detached view whose handlers keep firing and mutating DOM
  that's no longer on the page, or leaking memory the garbage collector can't reclaim because a
  live model still references it.

## Event-binding idioms

- **`model.on(...)` bound directly instead of `this.listenTo(model, ...)`** — `listenTo` is what
  registers the binding on the *view's own* internal ledger, which is what makes a single
  `stopListening()` call at teardown able to clean up every binding the view made, regardless of
  how many models or collections it listened to. A direct `.on()` binding isn't in that ledger, so
  teardown doesn't reach it.

## Model/collection sync idioms

- **A model attribute set via direct property assignment** (`model.attributes.foo = x`) instead
  of `model.set('foo', x)` — bypasses the `change`/`change:foo` event the rest of the view layer
  depends on to know the attribute changed at all, so anything listening for that event to
  re-render silently misses the update.

## Re-render idioms

- **A view's DOM manipulated directly in an event handler** (`this.$el.find(...).text(...)`)
  instead of going through the view's own `render()` — the DOM and the model's actual state drift
  apart the next time something else triggers a full re-render, since `render()` rebuilds from the
  model without knowing about the handler's direct edit.

## What is not a finding

- A reinvention of an existing Backbone capability with no Backbone-specific placement/shape
  angle — the **Novelty** facet owns reuse over reinvention generically.
- A generic inefficiency (an N+1 shape, an unbounded load) with nothing Backbone-specific about
  it — the **Technical** facet already covers inefficient data access in the abstract.
- A style/formatting preference with no correctness or maintainability consequence.
- A pre-existing pattern in a file the change doesn't touch — this facet reviews the diff, not
  the whole application.
- A departure from a rule here that matches an established, consistent convention already used
  elsewhere in the project — consistency with the existing codebase outranks a rule in this file.
