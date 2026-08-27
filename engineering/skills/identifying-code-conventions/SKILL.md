---
name: identifying-code-conventions
description: "Surface candidate code conventions two ways — infer from repeated code (with file:line evidence) and capture what the developer already holds — then hand each rough candidate to recording-code-conventions. Use when onboarding a codebase to its conventions. Finds candidates only; never writes or applies them (that is recording-code-conventions / using-code-conventions)."
---

# Identifying Code Conventions

Say this first, plainly: `Using the identifying-code-conventions skill to surface convention candidates.`

## Two ways to surface a candidate

**Inference from code.** Read the codebase for **observed repetition** — the same structural
choice made the same way across several places — and propose it as a candidate, always with
the **file:line** evidence that shows it is real and not imagined, and that becomes the
candidate's `Source` provenance if approved.

**Capture from the developer.** Not every convention is visible in code yet — some are rules
the developer **already holds** in their head and has simply never written down ("we always
put money in integer cents," "handlers never call the database directly"). Capture those by
asking, and treat each as a candidate exactly like an inferred one. A rule the team follows
by habit is as real as one the code repeats; it just has no file:line behind it, so its
`Source` is dictation rather than evidence.

## The inference heuristic — when repetition is worth surfacing

Not every repeated line is a convention. Observed repetition is worth surfacing as a candidate
only when all three hold:

1. **It recurs across independent sites** — several files or modules, not one file used
   several times. A single class that does something three times is one decision, not a
   standard.
2. **It was a real choice.** The pattern is one option among alternatives that a team could
   reasonably have decided differently — not something the language, framework, or compiler
   forces on everyone. A rule everyone must follow regardless is not a convention worth
   recording; a rule this team chose is.
3. **A new contributor could plausibly get it wrong.** If nobody would deviate without being
   told, there is nothing for a convention to protect. The ones worth codifying are exactly
   the ones a newcomer would miss.

A pattern that fails any of the three is noise, not a candidate — surfacing noise trains the
approver to rubber-stamp, the very failure the individual gate exists to prevent.

## Every candidate, individually, to recording

However a candidate surfaced, **hand each one individually — one at a time, never a batch** —
to `recording-code-conventions`, the single writer, still rough — the hardening interrogation
that pins is / is-not / robustness and the individual approval gate both run inside recording,
**before** it writes.

## What this does not do

- It does not **write conventions.** The write — the document, the index row, the provenance —
  is `recording-code-conventions`, the single writer. This skill hands off; it never edits
  `docs/standards/`.
- It does not **apply conventions.** Citing a recorded convention at a work item during design
  or build is `using-code-conventions`. This skill is the intake side, not the consume side.
