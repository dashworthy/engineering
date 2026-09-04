---
name: brainstorming
description: "Shape a piece of work into a recommended design: explore context, propose 2-3 approaches with trade-offs, recommend one. Use after signal or triage, before to-spec. Weighs approach; does not interrogate requirements (signal) or design module internals (codebase-design)."
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

## Propose approaches, not one approach

A single approach presented as "the plan" is a decision already made, dressed up as a
choice. Before recommending anything, put 2-3 approaches on the table — genuinely
different ways of solving the problem in front of you, not the same shape with the
variable names changed — each with its real trade-offs stated plainly: what it costs
to build, what it costs to live with, what it makes harder later. Then recommend one,
and say why, so the human is approving a reasoned pick, not refereeing a pile of
options with no author's opinion attached.

Put that pick to the human as a structured choice, using a tool to ask it where one is available:
the 2-3 approaches as selectable options, your
recommendation first and marked `(Recommended)` with its rationale carried alongside it. This keeps
the choice a selection rather than a wall of prose the human has to answer freehand — but it stays a
working dialogue, not a sign-off: a free-form escape is where a correction, a hybrid of two
approaches, or "keep talking" lands, so the pick never traps them into one of your framings. No such
tool: present the same options as plain text and say the run is degraded.

If the work is too large to fit one spec once an approach is chosen, say so before
presenting it, and decompose along the same line a plan set would later split
along — the test is the one `plan` uses for a plan set: does finishing the
first piece alone leave something working, with the second piece not yet started. A
design that can't answer that question hasn't found its seams yet, and it isn't ready
to present as one design.

## Shape the interface when the approach turns on a boundary

Some approaches are settled the moment one is picked. Others turn on a module
boundary — a new interface, or an existing seam the approach reshapes — where the
load-bearing decision isn't *which* approach but *what the interface looks like*. When the
recommended approach is that second kind, shape that interface here, before handing off, by
invoking `engineering:codebase-design` on the boundary: it designs the interface from at
least two competing shapes and judges them on what a caller has to know. Invoke it once per
boundary the approach introduces — a design that stands up three modules calls it three
times — and let the shaped interfaces travel with the recommended design into the spec,
where they become part of §6's Approach.

Shaping the interface here, not later, is deliberate: the spec gate in
`engineering:to-spec` is the first human approval, and an interface is usually the
highest-leverage decision in a design. Deferring it past that gate would mean the human
approved an approach whose real shape was still open. An approach with no new or reshaped
boundary — a behavior change on an existing path, a config move, most quick fixes — has
nothing for `codebase-design` to shape and skips it; this is a call the approach earns, not
a step every design takes.

## Recommend the design, then hand off

Walk the human through the approaches and the trade-offs, recommend one, and take
whatever correction they offer on the spot — when part of the design comes back wrong,
fix that part and re-present it. This is a working dialogue, not a sign-off ceremony: its
output is a recommended design, ready to serialize.

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
duplicate it. So hand the recommended design onward — **invoke the next act now** (which act,
`to-spec` by default, is the right-size decision below). "Stop" here means stop *designing* and
stop trying to collect approval; it is not a stop to ask the human whether to continue. There is
no gate at this seam, so parking the design with a "want me to write the spec?" is not an
available move — the recommendation is done, handing it onward is the next act, take it.

## Right-size the path — spec by default, plan-direct only by opt-in

Most work takes the full path: hand the design to `to-spec`, and the spec gate takes the human's
approval. Some work is small enough that a separate spec document earns nothing a plan wouldn't —
a change the recommended design already pins down completely. For that case, and only through an
explicit opt-in, this skill may skip the spec-**creation** step and hand straight to the plan
instead.

Judge whether the work is that small. If it might be, put it to the human as a
structured choice, using a tool to ask it where one is available:

- **Write the full spec (Recommended)** — hand the design to `engineering:to-spec`; the spec gate
  takes approval, the default path.
- **Skip the spec, go straight to the plan** — for a small, well-pinned change where a spec
  document adds no decision the plan won't already carry.

No such tool: present the same options as plain text and say the run is degraded.

On the default pick, hand to `to-spec` as above. On the skip pick — never silently, only on this
explicit choice — mint `.engineering/<run>/to-spec/SPEC-SKIPPED.md` recording who opted in and the
one-line reason, then hand the recommended design straight to `engineering:plan`. That
marker records a **routing choice, not an approval**: it skips only writing a spec, never a human
gate. The plan gate in `plan` still holds exactly as it always does, so there is no
skip-to-build here — approval simply moves to the plan instead of the spec. Design approval
otherwise happens at the spec gate, unchanged.

## What this does not do

- It does not **decide what to build.** Requirements, users, success criteria, and
  constraints are `signal`'s job — or `triage`'s, for a defect — and are settled before
  this skill's first question. This skill starts once there's a problem worth designing
  a solution for; it does not go find one.
- It does not **shape interfaces itself.** Designing a module's interface — narrow versus
  leaky, one boundary at a time — is `codebase-design`'s work, not this skill's; this skill
  weighs how to build at the level of approach, not a single interface's method signatures.
  When the approach turns on a boundary it *invokes* `codebase-design` (see above) rather
  than shaping the interface itself.
- It does not **write the spec.** Serializing the recommended design into the standard
  document is `to-spec`'s one job. This skill produces the recommendation; `to-spec`
  produces the record of it and holds the gate on it.
- It does not **plan or build.** Nothing past the recommendation is this skill's to
  touch, including sketching what a plan for the design might look like.
- It is not always required. A triage quick fix with one obvious fix and nothing
  genuinely competing for the choice can go straight from `triage` to the fix itself,
  skipping this skill. But a quick fix with two live options for how to do it belongs
  here after all.
