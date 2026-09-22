---
name: brainstorming
description: "The design phase: explore context, propose 2-3 approaches with trade-offs, recommend one, and name any boundary the approach turns on. Use once a request has been interrogated into a brief or a defect isolated; hands the recommended design to spec. Weighs approach; does not interrogate requirements (the entrances' job) or shape module interfaces (that is using-codebase-design at plan-review)."
---

# brainstorming

Shape a recommended design here — an approach chosen over its alternatives, with any load-bearing
boundary named (its interface shaped later, at plan-review) — then hand it to the `spec` phase; do not write the spec.

## Starting material

This skill starts from whichever entrance opened the work:

- a **signal** brief, `.engineering/<run>/signal/brief.md` — a request already
  interrogated into requirements, users, success criteria, and constraints.
- a **triage** problem, `.engineering/<run>/triage/…` — a defect isolated far enough to place it at a domain concept and route it here, waiting on a decision about how to fix it.

One of the two is the entry ticket. Starting without either — no brief, no isolated
problem, just a request typed straight at this skill — means the interrogation that
should have come first didn't happen; send it back to `signal` or `triage` rather than
inventing requirements to fill the gap.
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

Put that pick to the human as a structured choice — the 2-3 approaches as selectable options, your
recommendation first — following `engineering:using-questions` for how to shape and ask it and its
degraded-run fallback. Keep it a
working dialogue, not a sign-off: the free-form escape (always present, per `using-questions`) is
where a correction, a hybrid of two
approaches, or "keep talking" lands, so the pick never traps them into one of your framings.

One approach becomes one design, one spec, and one plan — brainstorming never splits the
work across multiple specs or plans, and never proposes doing so. What it *may* do, when a
problem is too large to land in one pass, is break the approach into ordered **increments**
within that single design: an increment is a coherent slice of the work that leaves the system
in a working state, and the increments are sequenced so each builds on the one before.
Breaking the work into increments is the sanctioned way to take a big problem on — it
structures the work *inside* the one spec and the one plan, it does not scatter it across
several.

Reach for increments only when the work genuinely needs them; a change that lands cleanly in
one pass carries none and says so. And breaking the work up this way is not a licence for
unbounded scope: if the approach is so large that even splitting it into increments couldn't
fit it in a single design, that is a signal its *scope* is drawn too wide — narrow the
approach, or raise the scope as a question for your human partner, rather than stretching the
increment list to absorb work that doesn't belong.

## Name the boundary, don't shape it

Some approaches turn on a module boundary — introducing a new seam, or moving an existing
one. When that's the approach's substance, **name** it: say where the seam sits and what
falls on each side, as part of the approach itself. That's a decision you can make now, and
it travels with the recommended design into the spec's §6.

What you do **not** do here is shape that boundary's interface or pick the pattern that fits
it. That judgment needs concrete code to look at — the signatures the work actually
produces — and you don't have it yet: at design time "what a caller must know" is a guess,
and a pattern chosen before you can see the shape it applies to is cargo-culting. Leave the
boundary named and unshaped.

## Recommend the design, then hand off

Walk the human through the approaches and the trade-offs, recommend one, and take
whatever correction they offer on the spot — when part of the design comes back wrong,
fix that part and re-present it. Its output is a recommended design, ready to serialize.

## No gate in the dialogue — approval is the spec gate

Design approval happens at the spec gate, not in the dialogue. Once the design is recommended,
hand off to the **`spec` phase** — **invoke `engineering:spec`** with the recommended design — which
serializes the design into the plugin's one Tier-1 spec format, writes it as a draft, presents it,
and waits for the human's approval before stamping `Approved` and minting the run's spec-approval
marker; nothing downstream builds until that marker exists. The dialogue itself does not write the
spec and does not write into `.engineering/<run>/spec/` — the `spec` phase is the only writer
there.

So the dialogue's job ends at a recommendation, not a ratification: **proceed to the next act
now** — the `spec` phase by default (the right-size decision is below). "Stop" here means stop
*designing*, not a stop to ask the human whether to continue; parking the design with a "want me
to write the spec?" is not an available move — the recommendation is done, proceeding is the next
act, take it.

## Right-size the path — spec by default, plan-direct only by opt-in

Most work takes the full path: invoke `engineering:spec`, and the spec gate takes the
human's approval. Some work is small enough that a separate spec document earns nothing a plan wouldn't —
a change the recommended design already pins down completely. For that case, and only through an
explicit opt-in, this skill may skip the spec-**creation** step and hand straight to the plan
instead.

Judge whether the work is that small. If it might be, put it to the human as a
structured choice, following `engineering:using-questions` for how to shape and ask it and its
degraded-run fallback:

- **Write the full spec (Recommended)** — invoke `engineering:spec`; the spec gate
  takes approval, the default path.
- **Skip the spec, go straight to the plan** — for a small, well-pinned change where a spec
  document adds no decision the plan won't already carry.

On the default pick, invoke `engineering:spec` as above. On the skip pick —
never silently, only on this
explicit choice — mint `.engineering/<run>/to-spec/SPEC-SKIPPED.md` recording who opted in and the
one-line reason, then hand the recommended design straight to `engineering:plan`. That
marker records a **routing choice, not an approval**: it skips only writing a spec, never a human
gate. The plan gate in `plan` still holds exactly as it always does, so there is no
skip-to-build here — approval simply moves to the plan instead of the spec. Design approval
otherwise happens at the spec gate, unchanged.

## What this does not do

- It does not **plan or build.** Nothing past the spec is this phase's to
  touch, including sketching what a plan for the design might look like.
- It is not always required. A triage quick fix with one obvious fix and nothing
  genuinely competing for the choice can go straight from `triage` to the fix itself,
  skipping this skill. But a quick fix with two live options for how to do it belongs
  here after all.
