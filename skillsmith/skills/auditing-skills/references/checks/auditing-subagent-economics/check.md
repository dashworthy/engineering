# Auditing — Subagent economics check

Say this first, plainly: `Using the skillsmith subagent-economics check to audit this skill.`

## What this guarantees

One thing: given the skill(s) under audit, this check finds subagent dispatches whose fixed cost
exceeds the payload they move out of the main context — and returns a short, ranked list of fixes
(inline it, pass discovery in, slim the dispatch, batch). It is **report-only**: it proposes, the
orchestrator applies.

This check self-limits at the source (see `../../hard-stops.md`), under the shared
`../../check-contract.md`.

## The workflow

1. **Relevance gate — first.** This check applies only where a skill **dispatches subagents**. A skill
   with no dispatch (no Task/subagent/fan-out idiom in its text) has no economics to audit — return
   `relevance: { skipped: "dispatches no subagents" }` immediately, having spent almost nothing.

2. **Apply the lens.** Work the shared model and break-even test in
   [../../subagent-economics.md](../../subagent-economics.md): weigh each dispatch's fixed cost
   (system prompt, re-injected instructions, rediscovery) against what it buys (payload kept out of
   context, compression, parallelism). Flag sub-scale dispatch, no-compression returns, fat
   re-injection, repeated discovery, and serial dispatch with no parallelism gain.

3. **Floor, then cap, then tally the cap's drops** per `../../hard-stops.md` §2–3.

4. **Return** per `../../check-contract.md`'s Finding schema.

## What this does not do

- It does not **flag a dispatch that already pays** — a large payload, a heavily compressed return, or
  a genuine parallel fan-out is not waste; this check confirms the ones that pay and flags only the
  ones that don't.
- It does not **rewrite the subagent's own prose** — verbosity inside a dispatched worker is
  `auditing-verbosity`'s call; this check judges whether the dispatch itself earns its cost.
