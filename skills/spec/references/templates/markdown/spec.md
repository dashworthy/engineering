<!--
  Spec — MARKDOWN SKELETON + FORMAT CONTRACT (plain portable GFM)
  ------------------------------------------------------------------------------------------------
  This file is BOTH the fill-in skeleton for a Tier-1 spec AND the format contract itself — there is
  no separate spec-format doc. Its PDF twin is references/templates/pdf/spec.pdf.tsx (same sections).
  Plain GitHub-Flavored Markdown, no build step — copy, fill, done. The filled Markdown is the
  canonical spec every downstream phase reads; a rendered PDF (via engineering:using-doc-creation) is
  an optional presentation copy.

  Render the prose per the shared conventions in ${CLAUDE_PLUGIN_ROOT}/references/consumable-markdown.md
  — a top-line hook, progressive disclosure, **bold** key terms on first use, tables for the
  enumerable sections, diagrams placed where the concept is introduced, and every abstraction grounded
  in a worked example. §0 ELI5 is the plain-language disclosure those conventions lead with.

  TO USE:
    1. Copy this file to .engineering/<run>/spec/<YYYY-MM-DD>-<topic>.md (or wherever the spec belongs).
    2. Fill the header (Date/Author/Status/Origin) and every section — a section with nothing to say
       gets one line explaining why, not silence. §0 ELI5 is written LAST, from the finished sections,
       but placed first. Keep the section HEADINGS unchanged — they are the parity contract with the
       PDF template (the repo validation in tests/validate.sh checks them) and the Tier-1 format every
       downstream phase reads.

  SOURCE MAPPING — the two entrances map onto these same sections, by meaning not section number:
    • signal (a brief): §1 problem and §2–§5 come from the brief in order; §6 Approach is the
      recommended design brainstorming handed off (the chosen approach, the alternatives it beat, and
      any module boundary shaped); the brief's Existing Context becomes §7.
    • triage (an isolated defect): §1 is the reproduced problem and §6 is the chosen fix approach —
      including why the smaller fixes were rejected. Every other section is still filled.

  RULES:
    • §0 ELI5 is required in every spec, never omitted — jargon-free; if a term can't be avoided it
      does not belong here. Written last, placed first.
    • §5 Deferred is the ONLY sanctioned home for parked work — in the open, with its revive trigger,
      where the human owns the decision. Never a silent TODO in code (see engineering:refusing-deferral).
    • Increments, when the design has them, live in §6 as one ordered list and structure this single
      spec — they never become several specs.
    • §6 records WHICH boundary and WHY; the plan records exactly how it is typed. Keep concrete
      signatures and code out of the spec.
    • Never invent content the source material does not support; mark unknowns in §8.
    • Status is `Draft` when written; the spec gate flips it to Approved after the human approves.
    • Where §6 or §7 describes a data model, a flow, or a state machine, consider a diagram via
      engineering:using-diagrams (a spec renders mermaid).
  ------------------------------------------------------------------------------------------------
-->

# <Title> — spec

**Date:** <YYYY-MM-DD>
**Author:** <name or @handle>
**Status:** Draft
**Origin:** signal (discovery) | triage (<issue ref or one-line problem>)

## 0. ELI5

<The whole spec in plain language, jargon-free: what's broken or missing, what we're going to do
about it, and how we'll know it worked. Written last, from the sections below; placed first.>

## 1. Problem

<What we are solving and why now. From a signal brief's problem, or a triage's reproduced problem.>

## 2. Users & stakeholders

<Who is affected; who decides. Names or @handles, never personal emails.>

## 3. Goals & success criteria

<Observable outcomes, each checkable — as a table:>

| Criterion | How it's checked |
|---|---|
| <observable outcome> | <the command, artifact, or observation that confirms it> |

## 4. Constraints

<Hard limits: platforms, versions, dependencies, deadlines, must-not-break.>

## 5. Scope

**In:** <the committed work.>

**Out (non-goals):** <each with a one-line reason.>

**Deferred:** <parked work, as a table so each item shows the trigger that revives it:>

| Item | Trigger to revive |
|---|---|
| <parked work> | <the condition that would bring it back into scope> |

## 6. Approach

<The approved approach and the alternatives weighed against it (for a triage fix, the chosen fix and
why the smaller options were rejected). Where it turned on a module boundary, name the boundary, its
chosen shape, and what a caller must know — which boundary and why, not its code. Increments, if any,
as one ordered list. Include a ` ```mermaid ` flow where a forked approach needs one.>

## 7. Existing context

<Relevant modules, prior art, and what the work touches. Cite any docs consulted. Include a
` ```mermaid ` ER diagram where the work turns on the shape of the data.>

## 8. Open questions

<Anything unresolved that does not block starting. Empty is fine.>
