---
name: prototype
description: "[Design] Build a small throwaway model to validate a risky assumption before committing to a design. Use when a decision hinges on something cheaper to test than to argue. Document the validated decision in the brief/spec (file-based), not a tracker. Covers logic prototypes (LOGIC.md) and UI prototypes (UI.md)."
---

# Prototype

Say this first, plainly: `Using the prototype skill to test this before committing to a design.`

## What this guarantees

One thing: given an assumption a design decision is resting on, this skill produces an
answer that came from building something small and disposable, not from further
argument — and it leaves behind a validated decision recorded where the design lives,
after the thing that produced it is gone. A prototype that disproves the assumption is as
much a result as one that confirms it; the guarantee is that the decision stops resting
on opinion, not that the assumption holds.

## When to prototype

Not every open question needs a prototype. Most get settled by reading the code,
checking a doc, or five minutes of back-and-forth about tradeoffs everyone already
understands. Reach for this skill only when arguing costs more than testing does — when
the thing actually in question is a fact about the world, not a matter of judgment, and
the design conversation keeps circling: the same two positions restated with different
words, no new information showing up on either side. "Will this API let us page results
without missing rows under concurrent writes" is a fact waiting to be observed. "Should
this endpoint be a GET or a POST" is not — that's a judgment call brainstorming can
settle in a sentence. When talking has stopped being productive, building a small
throwaway model answers in an hour what another hour of talking would not.

## Keep it throwaway

The whole value of a prototype is that it costs less than getting the answer any other
way — the moment it starts costing as much as the real thing, it has stopped being a
prototype and started being an early, worse draft of the implementation. Build the
smallest thing that can fail or succeed at the one question asked of it. Skip error
handling the question doesn't depend on, skip the parts of the system that aren't under
test, skip making it look finished.

Discard it once it has answered the question — delete the branch, close the scratch
file, throw away the sketch. Do not refactor a spike into production code, and do not
leave it half-merged where the next person mistakes it for something that was meant to
last. The code was never the deliverable; the decision it produced is, and that
decision is what gets kept.

## Two shapes

The risky assumption is either about whether something works or about whether someone
understands it, and the two questions need different kinds of throwaway model:

- **`LOGIC.md`**, in this same directory, covers prototypes for a risk in an algorithm,
  a data path, or an external dependency's actual behavior — anything settled by
  running code and reading what comes out.
- **`UI.md`**, in this same directory, covers prototypes for a risk in an interaction,
  a layout, or whether a person confronted with the thing can tell what it's asking of
  them — anything settled by putting something in front of a person and watching what
  they do with it.

Read whichever one matches the assumption on the table before building anything; each
covers how to size the artifact to the question instead of over- or under-building it.

## Record the decision, not the artifact

Once the prototype has answered its question, the artifact is done — but the answer
isn't recorded until it's written down somewhere the design can point back to. Record
the validated decision in the brief or the spec, not a tracker: a sentence stating what
was uncertain, what the prototype showed, and what the design now assumes as settled.
It's file-based on purpose — sitting next to the decision it justifies, in the same
document a reviewer or a future maintainer is already reading, rather than in a separate
system they'd have to go open and might never find. A prototype that leaves no trace
anywhere didn't save any time; the next person who hits the same uncertainty rebuilds it
from scratch.

## What this does not do

- It does not **choose the approach.** Weighing competing designs and picking one is
  `brainstorming`'s job; this skill answers one factual question a design under
  discussion there depends on. A prototype's result is an input to that discussion, not
  a replacement for having it.
- It does not **shape an interface.** A prototype that happens to touch a module's
  boundary is not `codebase-design`'s two-competing-shapes discipline done informally;
  once the assumption is validated and it's time to shape how callers actually use the
  thing, that's a separate pass, done properly, on real, non-throwaway code.
- It does not **become the implementation.** Nothing a prototype produces ships. Once
  the decision is validated and recorded, building the real thing is ordinary
  implementation work — `writing-plans` and `tdd`, downstream — starting clean rather
  than growing out of whatever the spike happened to leave behind.
- It does not **write the spec.** Recording the validated decision in the brief or the
  spec is a small addition to a document that already exists; producing that document
  in the first place is `to-spec`'s job, not this skill's.
- It does not **run without a real question.** "Let's see what this looks like," with
  no specific uncertainty behind it, is exploration, not a prototype — if nothing would
  change anyone's mind depending on the result, this skill has nothing to validate.
