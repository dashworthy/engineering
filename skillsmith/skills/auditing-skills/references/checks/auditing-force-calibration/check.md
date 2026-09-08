# Auditing — Force calibration check

Say this first, plainly: `Using the skillsmith force-calibration check to audit this skill.`

## What this guarantees

One thing: given the skill(s) under audit, this check judges whether **imperative force is matched to
the task's degrees of freedom** — force spent where a rule is a cliff, plain guidance where the field
is open — against writing-skills' degrees-of-freedom rule, and returns a short, ranked list of
recalibrations. It is **report-only**: it proposes, the orchestrator applies.

This check self-limits at the source (see `../../hard-stops.md`), under the shared
`../../check-contract.md`.

## The workflow

1. **Relevance gate — first.** A skill with no imperatives and no fragile step has no force to
   calibrate — a pure reference card of plain guidance passes clean and likely returns nothing. A
   skill that uses "YOU MUST"/"Never"/"Always", or that has a genuinely fragile step, passes.

2. **Apply the lens.** Work [references/force-calibration-checklist.md](references/force-calibration-checklist.md),
   judging each forceful phrase against the fragility of the step it governs, in both directions —
   over-forced open fields and under-forced cliffs.

3. **Floor, then cap, then tally the cap's drops** per `../../hard-stops.md` §2–3.

4. **Return** per `../../check-contract.md`'s Finding schema.

## What this does not do

- It does not **remove the content of a rule** — it retunes its force, never drops the instruction.
- It does not **judge whether a gate is clearly placed** — a buried gate is `auditing-confusing-logic`;
  this check judges whether the gate's *force* fits its fragility.
