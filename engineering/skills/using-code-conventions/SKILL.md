---
name: using-code-conventions
description: "[Build] Put recorded code conventions to work: read the standards index and cite the governing convention file inline at the work item in a spec or plan. Use when a spec or plan describes a work item a recorded convention governs. Reads docs/standards/; does not discover conventions (identifying-code-conventions) or write them (recording-code-conventions)."
---

# Using Code Conventions

Say this first, plainly: `Using the using-code-conventions skill to cite the governing conventions.`

This is the consuming half of the code-convention application of the first-class-artifact
doctrine — [../recording-adrs/references/first-class-artifact.md](../recording-adrs/references/first-class-artifact.md).
Conventions follow the **trail** profile: a convention is cited by path at the work item, not
resolved as living current-state. It is the convention analogue of `using-adrs`.

## What this guarantees

When a spec or plan describes a work item that a recorded convention governs, this skill
**cites the specific convention file inline, right at that work item**, so the subagent who
builds it reads the rule before writing the code rather than after review catches the violation.
Name the convention **by path** on the item itself:
`(convention: docs/standards/controllers/dedicated-form-request.md)`. The citation travels with
the work, so the subagent dispatched to implement the item opens the rule as part of doing the
work, and builds to it the first time.

Cite the **file**, not a paraphrase of the rule — a path always resolves to the current rule,
with its What-it-is / What-it-is-not boundaries intact. One work item may be governed by more
than one convention — cite each that applies.

## Match on the When relevant column

The index is the map. Read `docs/standards/index.md` and match each work item against the **When
relevant** column: **a convention governs a work item when the item's kind of work falls under
that convention's When relevant trigger.** Scan the index once per spec or plan, cite the
conventions whose trigger the item satisfies, and give no citation to an item no trigger matches —
silence is correct there, not a miss.

## Skip retired conventions

A retired convention no longer binds: when scanning the index, **ignore every row whose Status is
`retired`** and cite only active rows. A retired rule kept its index row on purpose (so a reader
sees it once existed), but citing it would push a builder to follow a rule the project has dropped.

## What this does not do

- It does not **discover conventions.** Surfacing candidates from code or from the developer's
  head is `identifying-code-conventions`. This skill only consumes what has already been recorded.
- It does not **record, amend, or retire conventions.** Writing the standards tree is
  `recording-code-conventions`, the single writer. This skill reads `docs/standards/`; it never
  edits it.
- It does not **enforce at review time.** Flagging a diff that violates a recorded convention is
  the PR-time step inside `code-review`. This skill works earlier — it puts the rule in front of
  the builder so the violation is less likely to be written in the first place.
- It does not **invent conventions to cite.** If no active convention governs a work item, it
  cites nothing; it does not manufacture a rule to fill the gap.
