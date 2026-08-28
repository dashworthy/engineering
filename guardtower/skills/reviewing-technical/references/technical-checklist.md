# Technical review checklist — reuse, efficiency, correctness

The lens for the technical facet. Language-agnostic: these are classes of defect to reason about in
whatever stack the change is written in, not a rule table for one framework. The `Carbon.eq()` case
is an *illustration* of reinventing what a dependency already provides, not a Laravel target.
Contents:

- Reuse over reinvention — the headline class, and its analysis boundary
- Inefficient data access
- Correctness-scoped best practices
- What is not a finding

## Reuse over reinvention

For each helper, comparison, loop, parser, or conversion the change **newly introduces**, ask whether
something already provides it:

- **Standard library** — the language's own built-ins for dates, collections, strings, math, I/O.
  Hand-rolling what the standard library already does correctly is a finding.
- **Well-known libraries** — an already-depended-on library's documented API. The motivating case: a
  hand-written comparison of two dates when the date library already exposes `eq()` / `isSame()` /
  equivalent. Re-implementing a library primitive is a finding.
- **Already-imported modules** — the public surface of the modules *this change already imports or
  uses*. If the change writes a private helper that duplicates a function it already imports, that's a
  finding.

**The boundary.** Reason from the diff, model knowledge of standard and well-known
libraries, and a glance at the public surface of already-imported modules — and **no proactive
repo-wide scan or function index**. A bespoke helper that exists elsewhere in the repository but the
change does not import is out of reach and *not* a finding here: chasing it would mean the repo-wide
scan the token budget rules out. Say what is reinvented and what already provides it, so the reviewer
can confirm without the author's context.

## Inefficient data access

Data access is where a small change quietly turns into a large cost. Look for:

- **N+1 queries** — a query issued once per element of a collection, where one batched query (a join,
  an `IN`, a preload/eager-load) would do.
- **Queries inside loops** — any round-trip to a database, cache, or service repeated per iteration.
- **Unbounded / unpaginated loads** — fetching an entire table or collection into memory when the
  change only needs a page, a count, or an existence check.
- **Repeated identical work** — the same query or computation run several times where one result could
  be reused within the request.

These are language- and store-agnostic: the shape (a round-trip per element, a full load where a
bounded one suffices) is the defect, whatever the query API.

## Correctness-scoped best practices

Only best-practice lapses with a **correctness or maintainability consequence** — never style:

- A resource opened and not reliably closed (file, connection, lock) on every path, including errors.
- Mutable shared state a concurrent caller could observe mid-update.
- An error-prone construct: an off-by-one boundary, an equality/identity confusion, a truthiness trap
  the language is known for, a silent numeric coercion.
- Reinvented control flow that a clearer, already-available construct expresses without the footgun.

## What is not a finding

Keep the floor honest — these belong to other facets, to a linter, or to no one:

- A style / formatting / naming preference with no correctness consequence — a linter owns it, or
  nobody does.
- A reuse a linter or the language's own tooling already flags automatically.
- A micro-optimization with no measured or reasoned cost on the change's actual path (below the
  confidence floor).
- A security or architectural concern — the Security or Architectural facet owns it, not this one.
- A pre-existing inefficiency the change neither introduces nor touches (out of scope — review the
  diff).
