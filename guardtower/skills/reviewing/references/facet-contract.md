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
  dropped:       <int>,              // genuine above-floor findings the cap held back beyond top_n; 0 when the cap wasn't hit — a count, never silently gone
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

## The `## Selection signal` section — menu pre-fill

Every facet file (`references/facets/<facet>/facet.md`) carries one `## Selection signal` section,
near the top, immediately above `## The workflow` — so the signal sits directly beside the
relevance gate it predicts (workflow step 1). It is part of this uniform contract: the orchestrator
reads every facet's section once, at the menu-fill step, to decide which facets to **pre-check** on
the menu before the human confirms or overrides. It is a cheap predictor, not a second gate.

The rules the section obeys:

- **Generic character only.** It describes the *character of the change* that warrants the facet —
  what the change is doing, conceptually — and **never a path**, file type, extension, directory
  name, or glob. Any such specificity would falsely skip the facet the moment a repo lays out or
  names its files unexpectedly.
- **Bias toward inclusion — a false skip is the harmful direction.** A facet left *off* the menu
  means a lens never runs; a facet pre-checked that the change doesn't really touch is cheap — it
  self-skips at dispatch, or the operator unchecks it. So the wording errs toward pre-checking when
  a change's character plausibly warrants the lens.
- **Pre-fill only; the relevance gate stays authoritative.** The signal decides only what the menu
  arrives pre-checked with. The facet's own per-change relevance gate (workflow step 1) still runs
  at dispatch and is the authoritative decision on whether the facet actually reviews — a
  pre-checked facet the change never touches self-skips there.

Two variants of the section:

- **Core facets** state, in place of a character description: `Core — pre-checked on every run
  regardless of the change's character.`
- **Core-when-present facets** add to their character description: `…and only when step 1's
  classification proposed this facet.` (The upper menu-proposal gate still governs whether they are
  on the menu at all.)

## The artifact

Each facet writes its findings to `artifact_path` as a small Markdown document: the facet name, its
relevance verdict, the findings (or an explicit "no findings above the floor"), and — when the cap
held anything back — the `dropped` count stated in words, e.g. "3 more findings above the floor
were not reported (cap); re-run to see them." The artifact is the durable record of what the facet
examined — it exists even on a clean or skipped run.
