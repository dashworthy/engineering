# 0002. Represent the ADR tracking view as a derived view over the index, not a persisted ledger

## Status

Accepted

## Context

The first-class-ADR work needs a *tracking* view — which decisions were made in a given run or
phase, and where each stands (Proposed / Accepted / Superseded) — distinct from the index's
*lookup* role (find the decision governing this work). Two shapes were on the table:

- a separate per-run/per-phase ledger file, maintained alongside `docs/adr/index.md`; or
- a view derived from `docs/adr/index.md` on demand.

A separate ledger file is a second source of truth for the same facts the index already holds
(Status per ADR). The moment the two disagree, a reader cannot tell which is right — the exact
drift the doctrine's "index and records move together" rule and the single-writer discipline
exist to prevent.

## Decision

The ADR tracking view is a view **derived from `docs/adr/index.md`** on demand — filter the
index by Status and group by the run/phase that proposed each decision — not a separately
persisted ledger file.

## Consequences

One source of truth: the index. The tracking view costs a read-and-filter each time it is
wanted, rather than a file someone must keep in sync; in exchange there is no ledger that can
drift from the index. Run/phase grouping depends on that provenance being recoverable from the
decision point that proposed the ADR; where it is not, the view still groups by Status.
