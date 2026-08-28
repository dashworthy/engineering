# 0003. Build guardtower as an orchestrator with self-limiting facet skills

## Status

Accepted

## Context

guardtower is a new plugin: an opt-in, in-depth review gate offering seven review facets
(Security, Technical, Architectural, plus Error Handling, Test Quality, Data & Migration
Safety, API & Backward Compatibility). Every facet needs the same spine — run-directory
setup under `.guardtower/<run>/`, a facet-selection menu, a relevance gate, parallel
fan-out, a shared finding/artifact schema, and the hard stops that keep token spend finite
(top-N severity cap and a confidence/severity floor).

A hard constraint pulls against a naive design: the plugin must be robust but not spend
tokens on low-value work. Where the spine lives, and where the hard stops are enforced,
decides whether that constraint is actually met.

Three shapes were live:

- **Orchestrator + thin, self-limiting facets.** One `guardtower:reviewing` skill owns the
  spine; each facet is a lean skill owning only its domain lens, and enforces the hard stops
  itself.
- **Seven fully self-contained facet skills.** No orchestrator; each facet re-implements the
  spine. This duplicates the run-dir/gate/schema/caps machinery across seven files — the
  exact reinvention the Technical facet is meant to catch — and a schema or discipline change
  touches all seven.
- **One monolithic review skill** with seven internal lenses as reference files. Fewest files,
  but the skill balloons, per-facet discovery/compliance testing gets muddy, and it strains
  "one skill, one kind of work."

The sharp point is *where* the hard stops run. If a facet returns every finding and the
orchestrator floors, ranks, and caps afterward, the token spend already happened inside the
facet before any cap applied — the cap trims output, not work, and saves nothing. Token
discipline is only real if each facet stops itself at the source.

## Decision

Build guardtower as one orchestrator skill (`guardtower:reviewing`) plus thin facet skills,
where each facet self-enforces the hard stops — running its relevance gate first and
short-circuiting before lens work, then applying the top-N cap and confidence/severity floor
before it returns — and the orchestrator retains only the facet menu, run-directory,
parallel fan-out, and cross-facet reconciliation.

## Consequences

- Token discipline is behavior at the source, not trimming after the spend: a facet the
  change does not warrant returns before spending lens tokens, satisfying the plugin's
  central budget constraint.
- The orchestrator↔facet boundary is uniform (`{change_ref, spec_ref?, artifact_path, caps}`
  in; `{facet, relevance, findings, artifact_path}` out), so adding an eighth facet is
  "implement the contract + add a menu row" with no orchestrator change, and each facet is
  testable in isolation.
- Cross-facet reconciliation (dedup across facets, one ordered report) stays orchestrator-side
  by design — it genuinely needs all results at once. That is a designed contract, the one
  thing a facet does not own.
- Cost: the orchestrator is a hub that must be kept lean, and the uniform contract constrains
  how idiosyncratic any single facet may be — a facet needing a fundamentally different
  request/result shape would strain this design.
