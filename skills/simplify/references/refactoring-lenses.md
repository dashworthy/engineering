# Refactoring lenses (simplify entrance reference)

> Interactive and main-thread only — this cannot run as a dispatched subagent. It is loaded when a
> developer points the `simplify` entrance at existing code they dislike.

## Overview

Turn a subjective *"I don't like this code"* into hard, checkable refactor goals **before** any
design work. The developer's distaste is the starting signal, not the specification: a dislike
named but not made concrete is a refactor nobody can tell succeeded. This reference supplies the
refactor-specific vocabulary — a fixed set of **language-neutral quality lenses** — and the
obligation each dislike must meet; the interrogation itself runs through the shared skill (see
*Run the interrogation through the shared skill*, below).

## Core principle

**Taste in, taste out.** "Nicer", "cleaner", "less ugly", "more elegant" are directions, not
destinations. Every one of them has to land on a quality that can be named and a check that can be
run, or the design phase downstream is proposing refactors against a target only the developer can
feel. A refactor whose success is unmeasurable is a refactor that will be argued about forever.

## The lenses

The lenses are the vocabulary. They are **language-neutral** — every one describes a shape a
program can take in any language, and none names a language, a framework, or a library idiom. Each
lens names a recurring dissatisfaction, the smell that triggers it, and the **target quality** a
refactor toward it produces. Use them to name what the developer is reacting to, and to probe for
dissatisfactions they feel but have not articulated.

| Lens | The smell it names | Target quality it yields |
|---|---|---|
| **Nesting** (nesting depth) | Deeply indented control flow; the eye has to hold many conditions at once to read one branch | Shallow flow — early returns, guard clauses, flattened branches |
| **Duplication** | The same logic or shape repeated in several places, drifting out of sync | One source of truth — the repeated shape named once and reused |
| **Naming** | Names that mislead, abbreviate past recognition, or force the reader to the definition to know what a thing is | Names that state intent — a reader knows what a symbol is without chasing it |
| **Dead code** | Code no path reaches, options no caller passes, branches no input triggers | Only live code — nothing the reader must consider that never runs |
| **Over-abstraction** | Indirection with one caller; a layer, hook, or parameter added for a generality that never arrived | Abstraction that earns its keep — a seam exists only where more than one thing uses it |
| **Over-cleverness** | Terse or ingenious code that reads as a puzzle; correctness that has to be reverse-engineered | Obvious-first code — the plain form a reader trusts on sight |
| **Single-responsibility** | A unit doing several unrelated jobs; a reason to change it for each of them | One responsibility per unit — a change has one obvious home |
| **Cohesion** | Related things scattered apart, or unrelated things bundled together | Things that change together live together |

The lenses overlap by design — a tangled unit often trips nesting, single-responsibility, and
cohesion at once. That is fine: the point is to name *which* dissatisfactions are present, not to
sort each into exactly one bucket.

## Run the interrogation through the shared skill

The mechanics of the interrogation — reading the code first, offering a recommended-first menu
instead of an open question, mining the correction, taking one dissatisfaction at a time, the stop
discipline, and the red flags that keep the gate open — are the generic requirement-gathering
methodology; drive them through `engineering:using-requirements-gathering`, which owns them and
writes `brief.md` §1–§6 when its gate is met. It is also where you fall back for the generic
requirement dimensions the lenses do not cover — who owns the code and signs off, a success
criterion the lenses cannot name, a constraint from outside the code. That is your own discovery
leg, not a hand-off to another entrance.

This reference adds only what is **particular to a refactor**:

- **The menu options are lenses.** Offer the two or three dissatisfactions you actually see in the
  code, most-prominent first, each named by its lens.
- **Each confirmed dissatisfaction must reach a named target quality and an observable check.** A
  pick names the *what*; the design phase needs the *how-we'll-know*. Drive each one to:
  - a **named target quality** (from the lens, or the developer's own words), and
  - an **observable check** — something that can actually be looked at after a refactor to say it
    landed: a measurable property (maximum nesting depth falls; the duplicated block exists once),
    a behavior that must stay identical (the same inputs produce the same outputs; the test suite
    stays green), or a concrete reader-judgeable statement the developer commits to.
- **Refuse unmeasured "better".** A target quality with no observable check is not a target, and it
  does not go in the brief as one. Keep probing, offering candidate checks, rather than recording
  an aspiration that reads like a criterion.
- **Name the behavior boundary.** A refactor is defined as much by what must *not* change as by
  what should. Establish early what has to stay identical — the public surface, the observable
  behavior, the passing tests — so "better" is bounded to everything inside that line.

Hand off only when every dissatisfaction the developer confirmed has a named target quality **and**
an observable check, and the behavior boundary is on the record — the two refactor-specific
conditions the shared skill's own gate does not know to hold.

## Writing the brief — the refactor §-mapping

The shared skill writes `brief.md` §1–§6, the standard brief the whole pipeline consumes. The six
dimensions mean something particular for disliked existing code; map them like this:

| § | Heading | For a disliked-code refactor |
|---|---|---|
| 1 | **Problem** | The disliked code (named precisely — file, unit, region) and *why* — which lenses it trips |
| 2 | **Users & Stakeholders** | Who owns and maintains this code; who signs off on reshaping it |
| 3 | **Success Criteria** | The named target qualities, **each paired with its observable check** — measurable or checkable only |
| 4 | **Constraints** | The behavior boundary (what must stay identical), plus any outside limits |
| 5 | **Scope** | Which code is in scope to reshape; what is explicitly left alone, and why |
| 6 | **Existing Context** | The code's current shape, its callers, and the tests that pin its behavior |

**§3 is measurable or observable only.** A target quality that reached no check does not belong in
§3 — say so to the developer rather than softening an aspiration into prose that then passes as a
criterion.

The brief ends at §6. Propose no refactor approaches and change no code — hand `brief.md` to
`engineering:brainstorming`, where the approaches are proposed for the developer to accept or
reject.
