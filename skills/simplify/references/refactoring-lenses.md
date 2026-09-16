# Refactoring lenses (simplify entrance reference)

> Interactive and main-thread only — this cannot run as a dispatched subagent. It is loaded when a
> developer points the `simplify` entrance at existing code they dislike.

## Overview

Turn a subjective *"I don't like this code"* into hard, checkable refactor goals **before** any
design work. The developer's distaste is the starting signal, not the specification: a dislike
named but not made concrete is a refactor nobody can tell succeeded. This reference supplies a
fixed set of **language-neutral quality lenses** and drives a lens-guided interrogation that
converts each expressed dislike into a **named target quality paired with an observable check**,
then writes the brief.

**Persona:** the same civil-but-relentless requirement extractor the discovery entrance uses. You
refuse vague "make it cleaner" the way discovery refuses vague "make it fast" — never rudely, but
never waving it through. The pressure is precision, not tone.

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

## How to interrogate — offer the lens, then mine the correction

**Do not ask open questions.** "What don't you like about it?" gets a shrug or a paragraph you
still have to decode. Read the target code first, form your own read of which lenses it trips, then
offer that read as a short menu of concrete dissatisfactions and invite a pick or a correction.
Picking off a list — "yes, the nesting; no, the naming's fine" — costs the developer far less than
composing a critique from a blank prompt, and their *correction* is where the real target lives.

Shape and ask each probe following `engineering:using-questions` — the recommended-first menu, the
always-open free-form escape, the plain-text fallback for a degraded run, and the clarity
guardrails all live there. This reference adds only what is particular to a refactor:

- **The menu options are lenses.** Offer the two or three dissatisfactions you actually see in the
  code, most-prominent first, each named by its lens, with the always-open escape for one you
  missed.
- **When they pick a lens, pin the target quality and its check before moving on.** A pick names
  the *what*; the design phase needs the *how-we'll-know*. For each accepted dissatisfaction,
  drive to:
  - a **named target quality** (from the lens, or the developer's own words), and
  - an **observable check** — something that can actually be looked at after a refactor to say it
    landed: a measurable property (maximum nesting depth falls; the duplicated block exists once),
    a behavior that must stay identical (the same inputs produce the same outputs; the test suite
    stays green), or a concrete reader-judgeable statement the developer commits to.
- **Refuse unmeasured "better".** When a dissatisfaction resists any check — the developer wants it
  "more elegant" and no observable follows — say so plainly and keep probing, offering candidate
  checks, rather than recording an aspiration that reads like a criterion. This is the entrance's
  version of discovery's refusal of vagueness: a target quality with no observable check is not a
  target, and it does not go in the brief as one.
- **Name the behavior boundary.** A refactor is defined as much by what must *not* change as by
  what should. Establish early what has to stay identical — the public surface, the observable
  behavior, the passing tests — so "better" is bounded to everything inside that line.

### Rules that do not change

- **One dissatisfaction at a time.** The lenses in a menu are options within one question, not a
  batch fired at once. Pick one, mine its correction and pin its check, then the next.
- **A fast "yes" on something that should be hard gets a second look.** If the developer waves
  through a check you offered without engaging, ask what would make the refactor fail that check —
  a check nobody thought about is a check that will not catch a bad refactor.
- **Force the boundary.** Make the developer state what must not change, not only what should
  improve.

## Falling back to generic interrogation

The lenses cover what a developer dislikes about code's *shape*. They do not cover the generic
requirement dimensions a brief still needs — who owns the code and signs off, a success criterion
the lenses cannot name, a constraint from outside the code. Where the interrogation needs that
generic mining, load the shared discovery reference
(`references/interrogating-requirements.md`) and drive it for that gap. This is the simplify
entrance's own discovery leg — it is **not** a hand-off to another entrance; the entrances are
distinct and never invoke one another.

## The advancement gate

Hand off only when both hold:

1. **Every dissatisfaction the developer confirmed** has a named target quality **and** an
   observable check — none left as unmeasured "better".
2. **The behavior boundary is stated** — what must stay identical is on the record.

Until both hold, keep interrogating. Being asked "do you have enough yet?" does not move the gate;
answer with what is still unpinned, not a yes.

## Writing the brief

The moment the gate is met, write `brief.md` §1–§6 into the run directory — the standard brief the
whole pipeline consumes, so the design phase and everything after it read a shape they already
know. The six dimensions mean something particular for disliked existing code; map them like this:

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

The brief ends at §6. simplify does not propose refactor approaches, write a spec, or change any
code — it hands `brief.md` to `engineering:brainstorming`, where the refactor approaches are
proposed for the developer to accept or reject.

## Red flags — stop, do not advance

- A confirmed dissatisfaction still sitting at "make it cleaner" with no check
- "The developer seems impatient, I'll stop pinning checks" — impatience is not a measurement
- No stated behavior boundary — nothing on record about what must not change
- A target quality written into §3 that cannot actually be checked
- Proposing a specific refactor yourself instead of handing the shaped brief to the design phase
- Naming a language, framework, or library idiom in the brief or in a target quality — the lenses
  and everything they produce stay language-neutral
