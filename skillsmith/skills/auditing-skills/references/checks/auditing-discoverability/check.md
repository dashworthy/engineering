# Auditing — Discoverability check

Say this first, plainly: `Using the skillsmith discoverability check to audit this skill.`

## What this guarantees

One thing: given the skill(s) under audit, this check judges the **always-loaded discovery surface** —
the `description` and the `name` — against writing-skills' rule that a skill is only as useful as its
odds of being found, and returns a short, ranked list of fixes. It is **report-only**: it proposes,
the orchestrator applies.

This is the highest-leverage lens in the audit: a skill whose description never matches a real task
is a skill that does nothing, and the description is paid on every turn. This check self-limits at the
source (see `../../hard-stops.md`), under the shared `../../check-contract.md`.

## The workflow

1. **Relevance gate — first.** Every skill has a `description` and a `name`, so this check runs on
   every skill; it only skips a target that is not a skill.

2. **Apply the lens.** Work [references/discoverability-checklist.md](references/discoverability-checklist.md)
   against each skill's frontmatter, judging the description's coverage of *what + when + triggers*
   and the name's fit to the activity.

3. **Floor, then cap, then tally the cap's drops** per `../../hard-stops.md` §2–3. Weight findings
   high: a description fix changes an always-loaded surface and whether the skill is ever selected.

4. **Return** per `../../check-contract.md`'s Finding schema. A reworded description **must still
   carry its triggers** — the fix variants preserve discovery, never trade it for brevity.

## What this does not do

- It does not **flag two descriptions that collide** on the same task — that cross-skill overlap is
  `auditing-cross-skill-duplication`'s call (it needs both skills at once); this check judges one
  description on its own merits.
- It does not **decide a skill is dead** — an unreachable description that names no real case is a
  tell `auditing-dead-skills` weighs at the whole-skill altitude; here it is a fix to the description.
