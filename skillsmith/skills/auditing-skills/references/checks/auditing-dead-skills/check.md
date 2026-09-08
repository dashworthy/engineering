# Auditing — Dead skills check

Say this first, plainly: `Using the skillsmith dead-skills check to audit this plugin.`

## What this guarantees

One thing: given a whole plugin, this check finds a skill the selection never picks and nothing
dispatches — its always-loaded `description` costs tokens on every turn and returns nothing — and
returns each as a candidate **fate**, not a reword. It is **report-only**: it proposes; the
orchestrator gates the deletion.

This is a whole-skill judgment, one altitude above the per-passage checks: made once per skill, across
the plugin. It self-limits at the source (see `../../hard-stops.md`), under the shared
`../../check-contract.md`.

## The workflow

1. **Relevance gate — first.** This check needs the **whole plugin** — a skill is dead only relative
   to its siblings and the plugin's routes. A single-skill target can't be judged dead this way:
   return `relevance: { skipped: "single skill; deadness is a plugin-level judgment" }`.

2. **Apply the lens.** Work [references/dead-skills-checklist.md](references/dead-skills-checklist.md):
   weigh the tells (unreachable description, no inbound reference, subsumed capability, orphaned by a
   change), and **confirm before proposing a fate** by naming a concrete task the skill is the best
   choice for. If you can't, it is dead.

3. **Floor, then cap, then tally the cap's drops** per `../../hard-stops.md` §2–3. Weight a dead skill
   high: its `description` is always-loaded cost, so folding or removing it recovers tokens on every
   turn.

4. **Return** per `../../check-contract.md`'s Finding schema — but the `fix` is the **candidate fate**
   (wire it in / fold into a sibling / remove) with what each keeps and deletes, plus the inbound
   references a fold or remove must scrub. The orchestrator puts the fate to the user as its own
   question and owns the deletion gate.

## What this does not do

- It does not **delete anything** — a fate is genuinely the user's call; folding and removal delete a
  skill and rewrite its inbound references, so the orchestrator gates it.
- It does not **fix a merely-weak description** — a description that names a real case but names it
  poorly is `auditing-discoverability`'s reword; this check fires only when *no* task reaches the
  skill at all.
