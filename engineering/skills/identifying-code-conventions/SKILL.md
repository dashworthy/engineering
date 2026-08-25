---
name: identifying-code-conventions
description: "[Discovery] Surface candidate code conventions two ways — infer them from repeated code (with file:line evidence) and capture the ones the developer already holds — then present each candidate individually and hand the approved ones to recording-code-conventions. Use when onboarding a codebase to its conventions or whenever a standing rule is worth capturing. Finds candidates only; it never writes them (recording-code-conventions) or applies them (using-code-conventions)."
---

# Identifying Code Conventions

Say this first, plainly: `Using the identifying-code-conventions skill to surface convention candidates.`

## What this guarantees

One thing: this skill **surfaces candidate conventions and hands them onward — it codifies
nothing itself.** It finds candidates two ways and hands each one, individually and still
rough, to `recording-code-conventions`, the single writer, which runs the hardening
interrogation and the individual approval gate before it writes. This skill never hardens,
approves, or writes anything. Nothing about "I found a pattern" becomes a convention without
the approver's yes at that gate — and a candidate the approver rejects leaves no trace.

Nothing else is guaranteed. Read `## What this does not do` before assuming this skill writes
or applies anything.

## Two ways to surface a candidate

**Inference from code.** Read the codebase for **observed repetition** — the same structural
choice made the same way across several places — and propose it as a candidate, always with
the **file:line** evidence that shows it is real and not imagined. The evidence is not
decoration: it is what lets the approver judge whether the pattern is a deliberate standard or
an accident of history, and it becomes the candidate's `Source` provenance if approved.

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

A pattern that fails any of the three is noise, not a candidate. Surfacing noise trains the
approver to rubber-stamp, which is the failure the individual gate exists to prevent — so the
heuristic protects the gate by keeping what reaches it worth judging.

## Every candidate, individually, to recording

However a candidate surfaced, do not batch. It **hands each candidate individually — one at a
time, never a batch** — to `recording-code-conventions`, the single writer, and hands it off
**still rough**. Recording is where the funnel every path shares actually runs: the hardening
interrogation that pins is / is-not / robustness, and the individual approval gate (the shared
`../recording-code-conventions/references/approval-gate.md`) with its conflict check, both run
inside recording **before** it writes. This skill does none of that — it does not harden, does
not gate, does not write, and never touches the standards tree. Its whole job ends at handing a
rough candidate, one at a time, to the writer.

## What this does not do

- It does not **write conventions.** The write — the document, the index row, the provenance —
  is `recording-code-conventions`, the single writer. This skill hands off; it never edits
  `docs/standards/`.
- It does not **apply conventions.** Citing a recorded convention at a work item during design
  or build is `using-code-conventions`. This skill is the intake side, not the consume side.
- It does not **approve on its own authority.** Surfacing a candidate is not accepting it; only
  the approver's individual yes, at the gate, does that. A confident inference is still just a
  candidate.
- It does not **auto-codify a whole codebase.** It surfaces candidates for individual approval;
  it never batch-writes what it found on the theory that repetition equals consent.
