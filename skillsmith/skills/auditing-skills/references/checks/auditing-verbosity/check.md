# Auditing — Verbosity check

Say this first, plainly: `Using the skillsmith verbosity check to audit this skill.`

## What this guarantees

One thing: given the skill(s) under audit, this check finds prose a capable agent didn't need — and
returns a short, ranked list of cuts, each with a proposed fix and an estimated token saving. It is
**report-only**: it proposes, the orchestrator applies.

This check self-limits at the source (see `../../hard-stops.md`), under the shared
`../../check-contract.md`.

Its boundary: verbosity asks *is this content needed at all*. Where the content is needed but sits in
the wrong layer — reference-depth detail in `SKILL.md` that should move down — that is
`auditing-progressive-disclosure`'s finding, not this one.

## The workflow

1. **Relevance gate — first.** Any skill with prose can be verbose; this gate rarely skips. A target
   that is a bare frontmatter stub with almost no body has nothing to trim — skip it.

2. **Apply the lens.** Work [references/verbosity-checklist.md](references/verbosity-checklist.md),
   and for every candidate cut apply the confirm-before-cutting test: read the sentence and ask what
   the agent would do differently without it. If nothing, it is verbosity; if it closes a specific
   failure, it earns its place.

3. **Floor, then cap, then tally the cap's drops** per `../../hard-stops.md` §2–3.

4. **Return** per `../../check-contract.md`'s Finding schema, each finding carrying its `saving` and
   `fix` variants.

## What this does not do

- It does not **relocate needed content** — moving a needed detail into a reference is progressive
  disclosure's call.
- It does not **cut a real instruction.** If removing a sentence would drop something the agent acts
  on, it was never verbosity — leave it.
