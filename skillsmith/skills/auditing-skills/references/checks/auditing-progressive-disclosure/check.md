# Auditing — Progressive disclosure check

Say this first, plainly: `Using the skillsmith progressive-disclosure check to audit this skill.`

## What this guarantees

One thing: given the skill(s) under audit, this check judges **content altitude** — whether each
piece of content sits in the layer that loads it only when needed — against writing-skills' rule that
`SKILL.md` is an overview pointing to depth loaded on demand. It returns a short, ranked list of
relayering fixes. It is **report-only**: it proposes, the orchestrator applies.

This check self-limits at the source (see `../../hard-stops.md`), under the shared
`../../check-contract.md`.

Its boundary: progressive disclosure asks *is this content in the right layer* — needed content sits.
Whether the content is needed *at all* is `auditing-verbosity`'s call. The two are handed cleanly:
verbosity deletes, this check relocates.

## The workflow

1. **Relevance gate — first.** A single-file skill with no references and a short body has no layering
   to get wrong — skip it unless its `SKILL.md` is long enough to carry down-layerable depth. A skill
   with references, or a long body, passes.

2. **Apply the lens.** Work [references/progressive-disclosure-checklist.md](references/progressive-disclosure-checklist.md)
   against the `SKILL.md`/`references/` split and the reference tree.

3. **Floor, then cap, then tally the cap's drops** per `../../hard-stops.md` §2–3.

4. **Return** per `../../check-contract.md`'s Finding schema. An extracted reference **stays one level
   deep** — the fix never creates a nested reference to solve a layering problem.

## What this does not do

- It does not **delete content** — if a detail is unneeded, that is verbosity's cut, not a relayer.
- It does not **judge the description** — the always-loaded surface is `auditing-discoverability`'s.
