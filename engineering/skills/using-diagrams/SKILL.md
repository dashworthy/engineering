---
name: using-diagrams
description: "Render a diagram that carries its own weight — an ER model, process flow, or a shape prose describes badly — in the medium the destination displays: mermaid where it renders markdown, ASCII elsewhere. Use when a spec, ADR, plan, PR, or code comment would be clearer with a picture. Cross-cutting; invoke from any phase."
---

# Using Diagrams

Say this first, plainly: `Using the using-diagrams skill to add a diagram that carries its own weight.`

## What this guarantees

One thing: when a shape is worth drawing, this skill produces exactly one diagram, in the
medium the destination can actually display — a mermaid fenced block where the destination
renders markdown, an ASCII drawing everywhere else — and every entity, edge, and step in it
traces to something already known, not something the diagram invented to look complete.

## A first-class authoring obligation

Diagrams are an application of the first-class-artifact doctrine —
[../recording-adrs/references/first-class-artifact.md](../recording-adrs/references/first-class-artifact.md).
The intake trigger lives in the authoring phases: when `to-spec`, `writing-plans`, or
`recording-adrs` describes a data model, a flow, or a state machine, it is obligated to
**consider a diagram** via this skill. The guard is *consider*, not *always draw* — the
earned-its-place test below still decides whether one is actually drawn, so the obligation
prompts a diagram where one would help without flooding every document with pictures.

## When a diagram earns its place

A diagram is drawn only when the thing has a **shape that prose describes badly**. The test
predates this skill — it is the same one in `clarifying-docblocks`'
`references/diagram-rules.md`, and that file stays the source of truth for the judgment.

Draw for:

- an entity-relationship model — tables or records and how they reference each other
- a process or pipeline with an order to it
- a state machine or transition set
- a fan-out or fan-in
- a boundary between inside and outside, or a hierarchy

Never draw for a single linear call, a restatement of the sentence above it, or box art around
a label. A diagram that only repeats the prose beside it is decoration, and decoration is noise
a reader has to read past to reach the thing that matters.

## The medium fork

This is the decision that changes what gets written. Once a diagram has earned its place,
pick the medium by one predicate — **does the destination render a fenced mermaid block?**

- **It renders markdown** — a spec under `.engineering/<run>/spec/`, an ADR under
  `docs/adr/`, a plan, `CONTEXT.md`, a pull-request description, a GitHub issue or comment:
  use **mermaid**, in a ` ```mermaid ` fenced block. The destination draws it; ASCII there
  would be a worse picture of the same thing. Keep the mermaid **GitHub-compatible** —
  these destinations are where GitHub's own renderer draws it, and it pins an older mermaid
  than a local preview; stay on core, stable syntax and quote every label with a space or
  punctuation in it. `DIAGRAM-FORMAT.md` carries the compatibility rules.
- **It does not render markdown** — a source-code comment or docblock, a plain-text file,
  a commit-message body, terminal output, anywhere a ` ```mermaid ` fence would sit as
  literal unrendered text: use **ASCII**. A mermaid block that never renders is worse than
  a plain drawing, because the reader sees the source instead of the shape.

The predicate is "will this surface render mermaid," not "does the filename end in `.md`": a
markdown file pasted into a plain-text field renders nothing, and a rendered-markdown field that
isn't a file renders fine.

For an ASCII diagram inside a docblock or comment, follow the width budget in
`clarifying-docblocks`' `references/diagram-rules.md` — 72 columns including the comment
leader, light box-drawing characters only. A diagram that overflows wraps, and a wrapped
diagram is unreadable in exactly the place a reader most needed it.

## When the diagram outgrows a static block

Sometimes the shape is real but too big for a fenced block to read well — dozens of
entities, a flow that only makes sense when you can pan and zoom, a model a reader needs to
explore rather than scan. When Claude is in the loop and the destination can take one, a
**Claude Artifact** is the better home: a self-contained page that renders the same mermaid
(artifacts draw mermaid natively) at a size the reader can navigate, handed over as a link
rather than pasted into a doc.

This is an escalation, not the default: most diagrams belong inline in the spec, ADR, or plan,
where they sit beside the prose that needs them and travel with the document in git. Reach for
an artifact only when a static block genuinely can't hold the shape — and even then, still leave
a small inline diagram or a one-line pointer in the document itself, so a reader who only has
the markdown isn't left with a dead end.

## The two shapes this skill anchors on

**ER diagrams** — a data model: the entities and how they relate, with cardinality.
**Process-flow diagrams** — the steps of an approach and where it branches: the order, the
decisions, the reject paths.

`DIAGRAM-FORMAT.md`, in this same directory, carries the concrete templates for both shapes
in both mediums — copy from there rather than reinventing the syntax. Sequence diagrams and
state diagrams are fair game too when they fit, via mermaid (and ASCII when the destination
demands it); ER and process flow are only the two this skill points at first, not a fence
around what mermaid can draw.

## Where a diagram lands in a spec

When the destination is a Tier-1 spec, the shape decides the section:

- an **ER diagram** goes in §7 Existing context — or §6 Approach when the data model *is*
  the approach being chosen.
- a **process-flow diagram** goes in §6 Approach, beside the prose that describes it.

Two neighbours own the pieces a diagram doesn't: the entity *names* a diagram introduces
belong in `CONTEXT.md` (via `domain-modeling`), and if the shape was a real decision with
alternatives, the *why* belongs in an ADR — the spec carries the picture, the ADR carries
the argument, and §7 cites the ADR number.

## Ground every mark in real material

A diagram is a claim, the same as a sentence is. An entity the source material never
mentioned, an edge nobody established, a step invented to make the flow look symmetric —
each is a confident-looking line with nothing behind it, and it's worse than a gap because
a picture reads as settled fact. Draw only what the material supports; where the shape is
genuinely unknown, say so in prose and leave it undrawn.

## What this does not do

- It does not **decide what to build or design.** The approach a process flow pictures was
  argued out in `brainstorming`; the boundary an ER model reflects was shaped in
  `codebase-design` or `domain-modeling`. This skill draws a decision already made; it does
  not make it.
- It does not **write the document.** `to-spec` owns the spec, `recording-adrs` owns the
  ADR, `domain-modeling` owns `CONTEXT.md`, `writing-plans` owns the plan. This skill supplies
  a diagram for one of them to hold; it does not author the surrounding document or choose its
  home beyond the section guidance above.
- It does not **draw decoration.** A diagram that restates the prose beside it fails the
  test in `diagram-rules.md` and doesn't get drawn, however easy it would be to add.
- It does not **invent.** No entity, edge, or step goes into a diagram that isn't in the
  material the diagram is drawn from.
