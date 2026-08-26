# The first-class-artifact doctrine

A durable-knowledge artifact — a decision record, a glossary, a diagram — is *first-class*
when the suite both **captures** it — an intake trigger — at the moment it is produced and
**consumes** it — active consumption — at the moment it is needed, instead of leaving it as a
file someone might write and someone else might read. An artifact that is only "read when present" is an edge artifact: written
inconsistently, consulted by luck. This doctrine is the shared pattern that makes an artifact
first-class, defined once here and applied by the skills that own each artifact.

## The pattern — three elements

1. **Intake trigger.** A specific moment in a phase where the artifact is captured, wired
   into the skill that reaches that moment — not a standalone scanner the developer must
   remember to run. The trigger names its own bar so it does not flood: it fires only when
   there is genuinely something to record, and the developer can decline.
2. **Index.** A single registry that lists every instance with a **When relevant** match
   column, so a consumer finds the governing instance without opening every file. The index
   and the artifacts move together — written in the same edit, never on a later pass.
3. **Active consumption.** An obligation, wired into the phases that need the artifact, to
   read the index, match the work at hand against the **When relevant** column, and act on
   what it finds — not a passive "read this if it happens to exist."

## The two consumption profiles

How a consumer uses the artifact depends on whether the artifact is a historical trail or a
living current-state view. Every application declares which profile it follows.

- **Trail.** Append-only and historical: entries are added and superseded but never
  rewritten, so the record of *what was decided when* survives. The consumer **cites the
  governing entry by path at the work item**, the way `using-code-conventions` cites a rule,
  and skips entries marked superseded. ADRs follow the trail profile.
- **Lookup.** Living and mutable: the artifact always reflects current reality, edited in
  place as reality changes. The consumer **resolves the current meaning** from it rather than
  citing a point-in-time entry. The glossary (`CONTEXT.md`) follows the lookup profile.

## Applications

- **ADRs** — `recording-adrs` (intake + index + lifecycle), `using-adrs` (consumption).
  Trail profile: append-only, numbered, superseded-by-pointer; cited by path at the work item.
- **Glossary (`CONTEXT.md`)** — `domain-modeling` owns intake at term-introduction points and
  the living file. Lookup profile: the suite-wide sweep resolves current meaning from it.
- **Diagrams** — `using-diagrams` owns the obligation; authoring phases consider a diagram
  when they describe a data model, flow, or state machine (the guard is *consider*, not
  *always draw*).
