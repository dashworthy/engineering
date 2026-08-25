---
name: brainstorming
description: "[Design] Shape a piece of work into a recommended design through dialogue: explore context, propose 2-3 approaches with trade-offs, and recommend one. Holds no approval gate of its own — design approval is the spec gate in to-spec. Use after signal or triage has gathered material and before to-spec. Weighs how to build it (approach); does not interrogate requirements (signal) or design module internals (codebase-design)."
---

# Brainstorming

Say this first, plainly: `Using the brainstorming skill to shape the design.`

## What this guarantees

One thing: given a signal brief or a triage problem, this skill produces a recommended
design — an approach chosen over its rejected alternatives, with the reasoning laid
out — ready for `to-spec` to serialize. It does not guarantee the first approach
considered is the one that wins, or that the design lands in one sitting.

This skill holds no approval gate of its own. Approval of the design happens at the spec
gate in `engineering:to-spec`, where the written spec is presented and the human either
approves it or sends it back — so a design this skill recommends is a proposal, not a
ratified decision, until the spec clears that gate.

Nothing else is guaranteed. Read `## What this does not do` before assuming this skill
reaches past shaping and recommending the one design in front of it.

## Starting material

This skill starts from whichever entrance opened the work:

- a **signal** brief, `.engineering/<run>/signal/brief.md` — a request already
  interrogated into requirements, users, success criteria, and constraints.
- a **triage** problem, `.engineering/<run>/triage/…` — a defect isolated far enough to place it at a domain concept and route it here, waiting on a decision about how to fix it.

One of the two is the entry ticket. Starting without either — no brief, no isolated
problem, just a request typed straight at this skill — means the interrogation that
should have come first didn't happen; send it back to `signal` or `triage` rather than
inventing requirements to fill the gap.

On the signal path this skill is reached automatically: once the discovery conductor
(`engineering:conducting-discovery`) has a finished brief, it hands that brief straight
here — this is signal's terminal act, the design dialogue every feature passes through, not
a step a human has to remember to invoke. On the triage path, a defect the isolation shows
is spec-worthy is routed straight here. Either way the entry ticket is already on disk
before this skill's first question.

## Explore context

Before sketching anything, read what the codebase already has to say. Skim the files
the work will touch, any docs sitting near them, and recent commits in the area — a
design that ignores how the neighborhood already does things produces an approach that
fights the codebase from day one instead of extending it.

Read `CONTEXT.md` and `docs/adr/`, at the project root, when either exists. A naming
convention or a boundary already settled there constrains which approaches are even
worth proposing — an approach that reopens a decision an ADR already closed isn't a
fresh option, it's litigation. Neither file is required; most designs get shaped with
no `CONTEXT.md` in sight, and that's ordinary, not a shortfall.

## Propose approaches, not one approach

A single approach presented as "the plan" is a decision already made, dressed up as a
choice. Before recommending anything, put 2-3 approaches on the table — genuinely
different ways of solving the problem in front of you, not the same shape with the
variable names changed — each with its real trade-offs stated plainly: what it costs
to build, what it costs to live with, what it makes harder later. Then recommend one,
and say why, so the human is approving a reasoned pick, not refereeing a pile of
options with no author's opinion attached.

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

## No gate here — approval is the spec gate

Design approval happens at the spec gate, not here. Older versions of this skill held a
hard approval gate and walked the design for a stack of small yeses before anything
downstream could run; that gate has moved onto the artifact a reviewer actually reads.
`to-spec` writes the spec as a draft, presents it, and waits for the human's approval
before it stamps `Approved` and mints the run's spec-approval marker — and nothing
downstream builds until that marker exists.

So this skill's job ends at a recommendation, not a ratification. Do not stage a formal
section-by-section sign-off here, and do not treat the human nodding along in the dialogue
as the approval — collecting that approval is the spec gate's job, and staging a second
gate here is exactly the extra stop this model removed. Hand the recommended design to
`to-spec` and let it hold the gate.

## Handoff

Hand the finished design to `engineering:to-spec`, which serializes it into the plugin's
one Tier-1 spec format and then holds the spec gate. This skill does not write the spec
itself and does not write into `docs/dashworthy/engineering/specs/` — `to-spec` is the
plugin's only writer there, and the recommended design is exactly the material it's built
to receive: an approach already chosen and argued out, ready to transcribe rather than
invent. Hand it the design and stop; presenting the spec, collecting the human's approval,
and minting the marker are `to-spec`'s job, not this one's.

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
- It is not always required. A triage quick fix small enough to need no spec at
  all — the isolated problem and its one obvious fix fit in a sentence, with nothing
  genuinely competing for the choice — can go straight from `triage` to the fix
  itself, with no design dialogue in between. Reach for that exception only when there
  is truly nothing to weigh; a quick fix with two live options for how to do it isn't a
  quick fix in this sense, and belongs here after all.
