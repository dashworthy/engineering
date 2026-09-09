# Consulting documentation (brainstorming reference)

The `documenting` phase writes durable feature docs under `docs/`, indexed by `docs/toc.md`. This
reference is the other end of that loop: before design greps the codebase, it reads those docs to
learn where to look. The goal is focused exploration — the docs guide the agent straight to the
files that matter, instead of a grep that sprawls the whole tree — and a record of what was read,
so the spec can cite it.

Docs are a **guide, not the ground truth.** They can be stale, and they never substitute for
reading the actual code. They tell you *where* to look and *what to expect*; the files themselves
tell you what is true today.

## The order

1. **Read the index first.** Open `docs/toc.md` (if the project has one). It lists every
   documented feature with a one-line description and a domain — enough to find the features this
   work touches without opening anything else. No `docs/` tree, or no `toc.md`? There is nothing to
   consult; fall back to ordinary exploration and note that the docs did not exist yet.
2. **Follow the toc to the relevant feature docs.** For each feature this work touches, open its
   `docs/{domain}/{feature}/README.md`. Read the overview and the technical reference; use the
   feature doc's own reference table to jump to a sub-doc when a specific aspect is in play.
3. **Let the docs target your code reading.** The doc names the modules, the boundaries, the data
   model — use those names to go straight to the relevant files and read them. This is the step
   that replaces a broad grep with a narrow one: you are looking *for* what the doc pointed at, not
   sweeping the tree to discover it. Read the code; confirm what the doc claimed; notice where the
   code has moved on from the doc.
4. **Record what you consulted.** Keep the list of doc files you read — it travels with the
   recommended design into the spec, whose §7 cites the docs consulted (see the `spec` phase). A
   citation is both a courtesy to the next reader and a signal of which docs were load-bearing on
   this design.

## When the docs are wrong

If a doc contradicts the code, the code wins — but the contradiction is worth surfacing: it means
the doc drifted, and the `documenting` phase for this run (or a backfill) should bring it current.
Note it; do not silently trust the stale doc, and do not silently ignore the drift.
