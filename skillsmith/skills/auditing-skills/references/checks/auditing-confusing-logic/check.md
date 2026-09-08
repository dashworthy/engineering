# Auditing — Confusing logic check

Say this first, plainly: `Using the skillsmith confusing-logic check to audit this skill.`

## What this guarantees

One thing: given the skill(s) under audit, this check finds control flow an agent can misread under
load — ordering, conditionals, and gates that read wrong when attention is thin — and returns a
short, ranked list of clarifications, each with a proposed fix. It is **report-only**: it proposes,
the orchestrator applies.

This check self-limits at the source (see `../../hard-stops.md`), under the shared
`../../check-contract.md`.

## The workflow

1. **Relevance gate — first.** A skill with no multi-step procedure, conditional, or gate has no
   control flow to misread — skip it. A skill with even one ordered sequence or stop condition passes.

2. **Apply the lens.** Work [references/confusing-logic-checklist.md](references/confusing-logic-checklist.md)
   against the procedures, conditionals, and gates in the target.

3. **Floor, then cap, then tally the cap's drops** per `../../hard-stops.md` §2–3.

4. **Return** per `../../check-contract.md`'s Finding schema.

## What this does not do

- It does not **shorten prose** — a clear-but-long procedure is verbosity's call, not this one.
- It does not **judge whether force is calibrated** — a buried gate is confusing *structure* (this
  check); an over-shouted one is miscalibrated *force* (`auditing-force-calibration`).
