# The facet contract

The uniform interface between the `reviewing` orchestrator and every facet skill. It is identical
for all facets, so the orchestrator knows nothing facet-specific and a new facet is "implement this
contract + add a menu row."

## Request — orchestrator → facet

```
{
  change_ref:    <git ref / diff / path the review targets>,   // what to review
  spec_ref:      <path to a governing spec> | none,            // an anchor for intent, if one exists
  artifact_path: .engineering/<run>/<facet-skill>/findings.md,  // where the facet writes its record
  caps: {
    top_n: <int>,                 // report at most this many findings, most severe first
    floor: "low" | "med" | "high" // drop findings weaker than this bar
  }
}
```

The orchestrator resolves `change_ref` once and hands the same one to every facet — a shared read,
no shared writes, so parallel facets stay independent. `caps` are passed in, not hardcoded per
facet, so the discipline is tuned in one place.

## Result — facet → orchestrator

```
{
  facet:         <facet-skill name>,
  relevance:     "ran" | { skipped: <one-line reason> },   // decided FIRST, before any lens work
  findings:      [ Finding, ... ],   // already floored and capped to <= top_n; [] is a valid clean result
  dropped:       <int>,              // genuine above-floor findings the cap held back beyond top_n; 0 when the cap wasn't hit — a count, never silently gone
  artifact_path: <the same path, now written>              // written even when findings == []
}
```

A clean change returns `findings: []`. That is a valid, complete result — not a facet that
gave up or missed something. The failure mode to guard against is the opposite reflex: reaching
for a hedged, sub-floor finding so the list is not empty. Padding a clean result with a finding
whose weaker of {severity, confidence} sits below `caps.floor` is not thoroughness — it is the
over-reporting the floor exists to stop. If the only thing a facet can find is below the floor,
the honest result is `[]`.

## Finding — the shared schema, every facet

```
{
  severity:   "high" | "med" | "low",
  confidence: "high" | "med" | "low",   // the floor drops anything below caps.floor on the weaker of the two
  location:   <file:line, or a symbol name>,
  claim:      <one sentence: what is wrong>,
  why:        <one sentence: the consequence, or the rule broken>,
  suggestion: <optional: the direction of a fix — never applied; code-review is report-only>
}
```

`claim` and `why` must read on their own, for a reviewer who did not write the code and holds no
shared context.

## The artifact

Each facet writes its findings to `artifact_path` as a small Markdown document: the facet name, its
relevance verdict, the findings (or an explicit "no findings above the floor"), and — when the cap
held anything back — the `dropped` count stated in words, e.g. "3 more findings above the floor
were not reported (cap); re-run to see them." The artifact is the durable record of what the facet
examined — it exists even on a clean or skipped run.
