---
name: brainstorming
description: "[Design] Shape a piece of work into a recommended design: explore context, propose 2-3 approaches with trade-offs, recommend one. Use after signal or triage, before to-spec. Weighs approach; does not interrogate requirements (signal) or design module internals (codebase-design)."
---

# Brainstorming

Say this first, plainly: `Using the brainstorming skill to shape the design.`

## What this guarantees

One thing: given a signal brief or a triage problem, this skill produces a recommended
design — an approach chosen over its rejected alternatives, with the reasoning laid
out — ready for `to-spec` to serialize.

## Starting material

This skill starts from whichever entrance opened the work:

- a **signal** brief, `.engineering/<run>/signal/brief.md` — a request already
  interrogated into requirements, users, success criteria, and constraints.
- a **triage** problem, `.engineering/<run>/triage/…` — a defect isolated far enough to place it at a domain concept and route it here, waiting on a decision about how to fix it.

One of the two is the entry ticket. Starting without either — no brief, no isolated
problem, just a request typed straight at this skill — means the interrogation that
should have come first didn't happen; send it back to `signal` or `triage` rather than
inventing requirements to fill the gap.

On the signal path, signal hands its finished brief straight
here once discovery is done; on the triage path, a defect isolated as
spec-worthy is routed here. Either way the entry ticket is already on disk before this
skill's first question.

## Explore context

Before sketching anything, read what the codebase already has to say. Skim the files
the work will touch, any docs sitting near them, and recent commits in the area — a
design that ignores how the neighborhood already does things produces an approach that
fights the codebase from day one instead of extending it.

Actively consult the project's first-class artifacts before proposing: surface governing
decisions with `engineering:using-adrs`, which matches the ADR trail against the work at
hand. A boundary already settled there constrains which approaches are even worth
proposing — an approach that reopens a decision an ADR already closed isn't a fresh option,
it's litigation. A project that has accumulated no ADR trail surfaces nothing, and that is a
clean result — the obligation is to consult, not a requirement that the files exist.

## Propose approaches, not one approach

A single approach presented as "the plan" is a decision already made, dressed up as a
choice. Before recommending anything, put 2-3 approaches on the table — genuinely
different ways of solving the problem in front of you, not the same shape with the
variable names changed — each with its real trade-offs stated plainly: what it costs
to build, what it costs to live with, what it makes harder later. Then recommend one,
and say why, so the human is approving a reasoned pick, not refereeing a pile of
options with no author's opinion attached.

Put that pick through the `AskUserQuestion` tool: the 2-3 approaches as its options, your
recommendation first and marked `(Recommended)` with its rationale in the option's
description. This keeps the choice a selection rather than a wall of prose the human has to
answer freehand — but it stays a working dialogue, not a sign-off: the tool's automatic
"Other" is where a correction, a hybrid of two approaches, or "keep talking" lands, so the
pick never traps them into one of your framings.

If the work is too large to fit one spec once an approach is chosen, say so before
presenting it, and decompose along the same line a plan set would later split
along — the test is the one `writing-plans` uses for a plan set: does finishing the
first piece alone leave something working, with the second piece not yet started. A
design that can't answer that question hasn't found its seams yet, and it isn't ready
to present as one design.

## Recommend the design, then hand off

Walk the human through the approaches and the trade-offs, recommend one, and take
whatever correction they offer on the spot — when part of the design comes back wrong,
fix that part and re-present it. This is a working dialogue, not a sign-off ceremony: its
output is a recommended design, ready to serialize.

## Offer to record the decision as an ADR

When the design turns on a decision with genuine live alternatives, offer to record it as an
ADR via `engineering:recording-adrs`, written `Proposed` (it flips to `Accepted` when the spec
carrying it clears the spec gate). The bar is real live alternatives — a design with one
reasonable shape was never a decision — and the developer may decline; declining is what keeps
ADR intake from flooding.

## No gate here — approval is the spec gate

Design approval happens at the spec gate, not here. Hand the recommended design to
`engineering:to-spec`, which serializes it into the plugin's one Tier-1 spec format,
writes it as a draft, presents it, and waits for the human's approval before stamping
`Approved` and minting the run's spec-approval marker; nothing downstream builds until
that marker exists. This skill does not write the spec and does not write into
`.engineering/<run>/spec/` — `to-spec` is the plugin's only writer there.

So this skill's job ends at a recommendation, not a ratification. Don't stage a
section-by-section sign-off here or treat the human nodding along as approval —
collecting that approval is the spec gate's job, and another gate here would only
duplicate it. Hand off the design and stop.

## What this does not do

- It does not **decide what to build.** Requirements, users, success criteria, and
  constraints are `signal`'s job — or `triage`'s, for a defect — and are settled before
  this skill's first question. This skill starts once there's a problem worth designing
  a solution for; it does not go find one.
- It does not **design module internals.** Shaping a class's or a module's interface —
  narrow versus leaky, one boundary at a time — is `codebase-design`, and it runs
  later, once an approach from this skill has a spec and an actual module in front of
  it to shape. This skill weighs how to build the work at the level of approach, not at
  the level of a single interface's method signatures.
- It does not **write the spec.** Serializing the recommended design into the standard
  document is `to-spec`'s one job. This skill produces the recommendation; `to-spec`
  produces the record of it and holds the gate on it.
- It does not **plan or build.** Nothing past the recommendation is this skill's to
  touch, including sketching what a plan for the design might look like — and it does not
  gate: approval is the spec gate's, downstream in `to-spec`.
- It is not always required. A triage quick fix with one obvious fix and nothing
  genuinely competing for the choice can go straight from `triage` to the fix itself,
  skipping this skill. But a quick fix with two live options for how to do it belongs
  here after all.
