---
name: testing-skills
description: Test whether a skill is actually discovered, read, and followed — before shipping it — by running its target scenario with and without the skill and under time, sunk-cost, and authority pressure, then closing the rationalizations that break compliance. Use when validating or hardening a skill.
---

# Testing Skills

A skill that reads well can still fail in use: the agent doesn't load it, loads it and skims,
or follows it until the moment pressure makes skipping it tempting. The only way to know is to
run the agent through the situation the skill exists for and watch what it does. This skill is
that test.

## The method

1. **Pick the real scenario.** Choose a concrete task the skill is meant to govern — the kind
   of moment where an agent would be tempted to do it the quick, wrong way. Vague scenarios
   produce vague results.

2. **Run it NULL — no skill loaded.** Let the agent work the scenario without the skill.
   Record the choice it makes and, in its own words, the reasoning it gives. Those
   rationalizations are the target: they are exactly what the skill has to overcome.

3. **Run it with the skill.** Same scenario, skill available. Watch three distinct things:
   does the agent **discover** it (load it unprompted), **read** it (completely, not a skim),
   and **follow** it (do what it says)? A failure at any of the three is a different problem
   with a different fix — a discovery failure is a description problem, a follow failure is a
   force or framing problem.

4. **Apply pressure.** Re-run with the pressures that make agents cut corners in real work —
   time cost, sunk cost, an authority telling them to hurry, plain familiarity. See
   [references/pressure-scenarios.md](references/pressure-scenarios.md) for ready archetypes.
   Compliance that holds when unhurried and collapses under pressure is the common failure,
   and the one worth finding before a user does.

5. **Close the rationalizations.** For each excuse that let the agent skip the skill, change
   the wording so that excuse no longer has room — a sharper trigger in the description, an
   anticipated objection answered inline, force added on the one rule that needed it. Then
   re-run. Iterate until the rationalizations stop getting through.

Run trials through fresh subagents so each starts without the memory of the last; see
[references/harness.md](references/harness.md) for the protocol, the meta-test, and how to
record which rationalizations survive.

## How this fits authoring

This is the evaluation-first loop from the **writing-skills** skill, carried out concretely.
Writing tells you the skill reads correctly; testing tells you it works. Ship on the second,
not the first.

## Provenance

Adapted from the superpowers CLAUDE.md skill-testing material (2026-08); this plugin's own
prose.
