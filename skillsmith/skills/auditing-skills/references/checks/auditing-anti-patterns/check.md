# Auditing — Anti-patterns check

Say this first, plainly: `Using the skillsmith anti-patterns check to audit this skill.`

## What this guarantees

One thing: given the skill(s) under audit, this check looks for the named writing-skills anti-patterns
and the structural ones that doctrine doesn't list — and returns a short, ranked, self-contained list
of findings, each with a proposed fix and an estimated token saving. It is **report-only**: it
proposes, the orchestrator applies.

This check self-limits at the source (see `../../hard-stops.md`), under the shared
`../../check-contract.md`.

Its boundary is sharp — three concerns belong to dedicated checks, not here:

- The **description** and the **name** (thin, wrong-voice, vague, bare-noun) → `auditing-discoverability`.
- **Imperative-force inflation** ("YOU MUST" everywhere) → `auditing-force-calibration`.
- **References nested more than one level deep** → `auditing-progressive-disclosure`.

## The workflow

1. **Relevance gate — first, before any lens work.** Every skill can carry an anti-pattern, so this
   gate rarely skips; a target that is a single tiny prose skill with no scripts, links, gates, or
   tool references still passes. Skip only a target that is not a skill at all.

2. **Apply the lens.** Work [references/anti-patterns-checklist.md](references/anti-patterns-checklist.md)
   against every `SKILL.md` and reference in the target, flagging each violation with its location and
   a proposed fix.

3. **Floor, then cap, then tally the cap's drops** per `../../hard-stops.md` §2–3 — drop below
   `caps.floor`, keep at most `caps.top_n`, report `dropped`.

4. **Return** per `../../check-contract.md`'s Finding schema, each finding carrying its `saving` and
   `fix` variants.

## What this does not do

- It does not **judge the description or name** — discoverability owns those.
- It does not **re-flag force, layering, or verbosity** — dedicated checks own each; a smell it
  notices there is theirs to report.
