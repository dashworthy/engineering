<!--
  Spec — MARKDOWN SKELETON (plain portable GFM)
  ------------------------------------------------------------------------------------------------
  The Markdown twin of references/templates/pdf/spec.pdf.tsx, and the portable form of the Tier-1
  spec format (the full contract is references/spec-format.md). Plain GitHub-Flavored Markdown, no
  build step — copy, fill, done.

  TO USE:
    1. Copy this file to .engineering/<run>/spec/<YYYY-MM-DD>-<topic>.md (or wherever the spec belongs).
    2. Fill the header (Date/Author/Status/Origin) and every section. §0 ELI5 is written LAST, from
       the finished sections, but placed first. Keep the section HEADINGS unchanged — they are the
       parity contract with the PDF template (test/templates/parity.test.ts checks them) and the
       Tier-1 format every downstream phase reads.
    3. Status is `Draft` when written; the spec gate flips it to `Approved` after the human approves.
    4. Never invent content the source material does not support; mark unknowns in §8.
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

<What we are solving and why now.>

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

<The approved approach and the alternatives weighed against it. Where it turned on a module
boundary, name the boundary, its chosen shape, and what a caller must know. Increments, if any, as
one ordered list. Include a mermaid ```mermaid flow where a forked approach needs one.>

## 7. Existing context

<Relevant modules, prior art, and what the work touches. Cite any docs consulted. Include a
```mermaid ER diagram where the work turns on the shape of the data.>

## 8. Open questions

<Anything unresolved that does not block starting. Empty is fine.>
