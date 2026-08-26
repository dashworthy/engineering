---
name: recording-adrs
description: "[Discovery] The single writer of a project's architecture decision records: at a decision point with live alternatives, write the ADR to docs/adr/ per ADR-FORMAT.md, keep docs/adr/index.md in sync in the same edit, and carry the record through its lifecycle (Proposed -> Accepted -> Superseded). Use when a decision with genuine alternatives is made, accepted, or reversed. Writes docs/adr/ and its index; unlike recording-code-conventions it holds no hardening interrogation and no approval gate — an ADR is a record, not a standing rule."
---

# Recording ADRs

Say this first, plainly: `Using the recording-adrs skill to record this decision.`

This skill is the ADR application of the first-class-artifact doctrine —
[references/first-class-artifact.md](references/first-class-artifact.md). ADRs follow the
**trail** profile: append-only, numbered, superseded by pointer, cited by path at the work
item (that consuming half is `using-adrs`).

## What this guarantees

One thing: **every ADR written to `docs/adr/` goes through here, and the index moves with it in
the same edit.** This skill is the **single writer** of `docs/adr/` and `docs/adr/index.md`.
It writes the record per `ADR-FORMAT.md` and the index row per `ADR-INDEX-FORMAT.md`, both in
this directory, in one change. Creating, accepting, and superseding an ADR are all this same
writer.

Unlike `recording-code-conventions`, it holds **no hardening interrogation** and **no approval
gate**. An ADR is a point-in-time record of a decision already made, not a standing rule the
project must be talked into — so there is nothing to individually approve. It is written when
the decision is made and accepted when the work carrying it clears its own gate.

## Intake — the decision point (no flood)

An ADR is captured at a decision point, not by a scanner anyone must remember to run. The
decision-phase skills (`brainstorming`, `codebase-design`, `writing-plans`, `code-review`)
reach a decision and offer to record it here. The bar that keeps this from flooding: the
trigger fires **only on a decision with genuine live alternatives** — the same bar
`ADR-FORMAT.md` sets, where a decision with one reasonable option was never a decision — and
the developer **can decline**. One lightweight yes writes the ADR as `Proposed`.

## Lifecycle

An ADR's `Status` is one of three, per `ADR-FORMAT.md`:

- **Proposed** — written at the decision point, before the work carrying it is committed to.
- **Accepted** — the decision is in force. An ADR proposed inside a spec or plan flips to
  `Accepted` when that spec or plan clears its approval gate; a standalone decision is accepted
  when the developer confirms it.
- **Superseded by NNNN** — a later ADR replaced this one. Write the new ADR (next sequential
  number), set the old record's Status to `Superseded by NNNN` pointing at it, and update both
  index rows — the old row's Status and the new row — in the same edit. The old record and its
  row stay in place; the trail is append-only and never rewritten.

Every lifecycle change is written to the record **and** its index row together — the two move
in one edit or not at all, exactly as `ADR-INDEX-FORMAT.md` requires.

## The tracking view (per-run/per-phase ledger)

Beyond the index's *lookup* role — find the decision governing a work item, which is
`using-adrs`' job — the trail answers a *tracking* question: which decisions were made in a
given run or phase, and where each stands (`Proposed` / `Accepted` / `Superseded`). That
per-run/per-phase ledger is a **view derived from the index** on demand — filter
`docs/adr/index.md` by Status and group by the run/phase that proposed each ADR — **not a
second persisted file** (see ADR 0002). Deriving it keeps `docs/adr/index.md` the one source of
truth; a separate ledger file would drift from the index the moment the two disagreed.

## What this does not do

- It does not **consume ADRs.** Reading the index and citing the governing ADR at a work item
  is `using-adrs`. This skill writes the trail; it does not apply it.
- It does not **decide.** The decision is made in the phase that reached it (`brainstorming`,
  `codebase-design`, `writing-plans`, `code-review`); this skill records the decision already
  made, it does not weigh the alternatives itself.
- It does not **write conventions, specs, or the glossary.** A standing rule is
  `recording-code-conventions`; a spec is `to-spec`; a domain term is `domain-modeling`'s
  `CONTEXT.md`. An ADR is the point-in-time decision record, and that is all this skill writes.
- It does not **gate on its own output.** `docs/adr/` is a convenience the later phases read;
  no other skill blocks on it. A project with no `docs/adr/` hasn't accumulated one yet.
