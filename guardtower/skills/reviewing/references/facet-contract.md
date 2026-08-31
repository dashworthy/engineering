# The facet contract

The uniform interface between the `reviewing` orchestrator and every facet skill. It is identical
for all facets, so the orchestrator knows nothing facet-specific and a new facet is "implement this
contract + add a menu row."

## Request — orchestrator → facet

```
{
  change_ref:    <git ref / diff / path the review targets>,   // what to review
  spec_ref:      <path to a governing spec> | none,            // an anchor for intent, if one exists
  artifact_path: .guardtower/<run>/<facet-skill>/findings.md,  // where the facet writes its record
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
  artifact_path: <the same path, now written>              // written even when findings == []
}
```

## Finding — the shared schema, every facet

```
{
  severity:   "high" | "med" | "low",
  confidence: "high" | "med" | "low",   // the floor drops anything below caps.floor on the weaker of the two
  location:   <file:line, or a symbol name>,
  claim:      <one sentence: what is wrong>,
  why:        <one sentence: the consequence, or the rule broken>,
  suggestion: <optional: the direction of a fix — never applied; guardtower is report-only>
}
```

`claim` and `why` must read on their own, for a reviewer who did not write the code and holds no
shared context.

## The artifact

Each facet writes its findings to `artifact_path` as a small Markdown document: the facet name, its
relevance verdict, and the findings (or an explicit "no findings above the floor"). The artifact is
the durable record of what the facet examined — it exists even on a clean or skipped run.
