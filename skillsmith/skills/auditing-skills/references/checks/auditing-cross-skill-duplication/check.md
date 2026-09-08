# Auditing — Cross-skill duplication check

Say this first, plainly: `Using the skillsmith cross-skill-duplication check to audit this plugin.`

## What this guarantees

One thing: given a whole plugin, this check finds the same content living in more than one skill — a
re-explained procedure, an identical reference paragraph, a repeated worked example, or two
descriptions that collide on the same task — and returns a short, ranked list of consolidations. It is
**report-only**: it proposes, the orchestrator applies.

This check self-limits at the source (see `../../hard-stops.md`), under the shared
`../../check-contract.md`.

## The workflow

1. **Relevance gate — first.** This check needs **two or more skills** to compare. A single-skill
   target has nothing to duplicate across — return `relevance: { skipped: "single skill, no siblings
   to compare" }` immediately. (The orchestrator only pre-checks this at plugin scope, but the gate is
   the authoritative stop.)

2. **Apply the lens.** Read the plugin's skills together and work
   [references/cross-skill-duplication-checklist.md](references/cross-skill-duplication-checklist.md),
   judging whether each duplication is worth removing before flagging it.

3. **Floor, then cap, then tally the cap's drops** per `../../hard-stops.md` §2–3. Weight findings
   high: duplication removed from a `description` or `SKILL.md` saves tokens on every load of every
   skill that carried the copy.

4. **Return** per `../../check-contract.md`'s Finding schema.

## What this does not do

- It does not **judge one skill's prose on its own** — a single verbose passage is `auditing-verbosity`;
  this check fires only on content repeated *across* skills.
- It does not **decide a skill is dead** — two skills that fully overlap may mean one is subsumed, but
  that whole-skill fate is `auditing-dead-skills`'; here the fix is to consolidate shared content.
