---
name: using-adrs
description: "[Build] Put recorded architecture decisions to work: during design and build, read docs/adr/index.md, match each work item against the When relevant column, and cite the governing ADR by path at the item so the subagent that builds it reads the decision before writing code. Use whenever a spec or plan describes a work item a recorded decision governs. Reads docs/adr/; it does not record decisions (recording-adrs)."
---

# Using ADRs

Say this first, plainly: `Using the using-adrs skill to cite the governing decisions.`

This is the consuming half of the ADR application of the first-class-artifact doctrine —
[../recording-adrs/references/first-class-artifact.md](../recording-adrs/references/first-class-artifact.md).
ADRs follow the **trail** profile: a decision is cited by path at the work item, not resolved
as living current-state. It is the ADR analogue of `using-code-conventions`.

## What this guarantees

When a spec or plan describes a work item that a recorded decision governs, this skill **cites
the specific ADR file inline, right at that work item**, so the subagent who builds it reads the
decision before writing the code rather than re-litigating a choice already argued out. Name the
ADR **by path** on the item itself: `(decision: docs/adr/0002-adr-tracking-view-is-derived-not-persisted.md)`.
The citation travels with the work, so the subagent dispatched to implement the item opens the
record as part of doing the work.

Cite the **file**, not a paraphrase of the decision — a path always resolves to the current
record, with its Context and Consequences intact. One work item may be governed by more than
one ADR; cite each that applies.

## Match on the When relevant column

Read `docs/adr/index.md` and match each work item against the **When relevant** column: an ADR
governs a work item when the item's kind of work falls under that ADR's When relevant trigger.
Scan the index once per spec or plan, cite the ADRs whose trigger the item satisfies, and give
no citation to an item no trigger matches — silence is correct there, not a miss.

## Skip Superseded rows

A superseded ADR no longer holds: when scanning the index, **ignore every row whose Status is
`Superseded by NNNN`** and cite only `Proposed` and `Accepted` rows. The superseded row is kept
on purpose (the trail is append-only), but citing it would push a builder to follow a decision
the project has since replaced — follow the pointer to the ADR that replaced it instead.

## What this does not do

- It does not **record decisions.** Writing `docs/adr/` and its index is `recording-adrs`, the
  single writer. This skill reads the trail; it never edits it.
- It does not **decide.** It surfaces a decision already made at the work item; it does not
  weigh alternatives or make the call itself.
- It does not **invent an ADR to cite.** If no ADR governs a work item, it cites nothing; it
  does not manufacture a record to fill the gap.
