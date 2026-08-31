# 0004. Bound every guardtower facet's analysis to the diff plus model knowledge

## Status

Accepted

## Context

guardtower's token discipline rests on three hard stops enforced inside each facet (ADR-0003):
a relevance gate, a top-N severity cap, and a confidence/severity floor. Those stops bound how
much a facet *emits* and whether it *runs at all* — but they say nothing about how much a facet
is allowed to *read* to reach its findings. A facet that consults the whole repository to do its
job would blow the budget before any cap or floor could apply, exactly the way pre-source
trimming does.

Two facets make the question concrete. The Technical facet must catch reinventing what already
exists (the motivating case: a hand-written date comparison where an imported library already
provides `eq()`). The Architectural facet must catch coupling and dependency-direction
violations. Both invite an expensive answer:

- **Reuse detection** could build a proactive repo-wide function/helper index so it finds any
  existing helper anywhere in the tree — but that cost scales with repository size, not diff
  size, and collides head-on with the budget constraint. Whole-repo work is also an explicit
  guardtower non-goal.
- **Coupling analysis** could build the whole dependency graph to reason about architecture —
  same unbounded cost, same non-goal.

If a facet's reading scope is left unstated, each facet author redraws it, and the plugin's cost
stops being a function of the change under review. The property the hard stops depend on — that a
review's cost tracks the diff, not the repo — has to be fixed at the input boundary, not just the
output.

## Decision

Every guardtower facet bounds its analysis to the change under review (the diff), plus the
reviewing model's parametric knowledge of well-known and standard libraries, plus a glance at the
public surface of the modules the change already imports or uses. No facet performs a proactive
repo-wide scan, function index, or dependency-graph build.

## Consequences

- Every facet's cost is a function of the diff size, not the repository size — the property the
  three hard stops (ADR-0003) rely on to keep total spend finite.
- Reuse detection catches reinventing what a standard/well-known library or an already-imported
  module provides (the `Carbon.eq()` class), but will **not** catch reinventing a bespoke helper
  that lives elsewhere in the repo and the change does not import. That blind spot is accepted on
  purpose; closing it would require the repo-wide index this ADR rejects.
- Architectural analysis reasons only about boundaries visible in the diff — a new import
  crossing a layer, a responsibility moved — not about the whole dependency graph, and so cannot
  flag a pre-existing coupling the change merely sits near.
- The boundary is uniform across facets, so it extends unchanged to later facets whose natural
  temptation is also repo-wide reading — Data & Migration Safety (reachability of a destructive
  change) and API & Backward Compatibility (who consumes a changed contract): both reason from
  the diff and its imports, not a repo sweep.
- This complements ADR-0003 rather than restating it: ADR-0003 fixes *where* the hard stops run
  (inside each self-limiting facet); this ADR fixes *what input scope* those facets run over.
