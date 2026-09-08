# Auditing — Pressure-test seam (behavioral)

Say this first, plainly: `Using the skillsmith pressure-test seam to audit whether this skill is actually followed.`

## What this guarantees

One thing: given a skill under audit, this seam runs the agent through the real situation the skill
exists for — with the skill and without it, unhurried and under pressure — and returns each surviving
**rationalization** (the excuse that let the agent skip or half-follow the skill) as a finding, with
the wording change that would close it. It is **report-only**: it proposes the closure; the
orchestrator applies it through the same one-finding-one-question gate as every other seam.

A skill that *reads* well can still fail in use: the agent doesn't load it, loads it and skims, or
follows it until pressure makes skipping tempting. The static checks read the artifact; this seam is
the only one that **executes** — it watches what the agent actually does. That makes it the audit's
one **expensive** seam.

This seam self-limits at the source (see `../../hard-stops.md`), under the shared
`../../check-contract.md`, with two seam-specific rules:

- **Always dispatched, never inlined.** It spawns trial runs on fresh subagents, so the orchestrator's
  "fan-out vs. inline" floor does not apply — even for a tiny skill this seam runs as its own
  dispatch, and its trials are their own subagents (see [references/harness.md](references/harness.md)).
- **Opt-in, never pre-checked.** It is the one exception to the audit's "err toward pre-checking": a
  false include here burns real trial tokens, so it is off by default and the human checks it for a
  pre-ship or full review. This is the audit's expensive track.

## The workflow

1. **Relevance gate — first.** This seam needs a **runnable target scenario** — a concrete decision
   the skill governs, where an agent could be tempted to do it the quick, wrong way. A skill with no
   such decision (a pure data or lookup reference nothing *follows*) has nothing to pressure-test —
   return `relevance: { skipped: "no runnable governed scenario" }`. Otherwise pick the real scenario;
   vague scenarios produce vague results.

2. **Run it NULL — no skill loaded.** Let a fresh agent work the scenario without the skill. Record
   the choice and, verbatim, its stated reasoning. Those rationalizations are the target: they are
   what the skill must overcome.

3. **Run it with the skill.** Same scenario, skill available, fresh agent. Watch three distinct
   things — does it **discover** the skill (load it unprompted), **read** it (completely, not a skim),
   and **follow** it (do what it says)? Each failure is a different finding with a different fix: a
   discovery failure is a `description` problem (hand its fix toward that surface), a follow failure is
   a force/framing problem. Where the skill ends by handing control onward at a **no-gate** seam,
   *follow* means taking that onward act; an invented "want me to proceed?" stop is a follow-failure
   (scenario 5 in [references/pressure-scenarios.md](references/pressure-scenarios.md)).

4. **Apply pressure.** Re-run on fresh agents with the forces that make agents cut corners — time
   cost, sunk cost, an authority hurrying them, plain familiarity. See
   [references/pressure-scenarios.md](references/pressure-scenarios.md) for ready archetypes.
   Compliance that holds unhurried and collapses under pressure is the common failure, and the one
   worth finding before a user does.

5. **Return the surviving rationalizations as findings** per `../../check-contract.md`'s Finding
   schema, floored and capped per `../../hard-stops.md` §2–3. For each excuse that got the agent past
   the skill: `claim` is the behavior (skipped / skimmed / parked / rationalized past), `why` is the
   rationalization verbatim and what it costs, `fix` is the wording change that leaves the excuse no
   room — a sharper trigger, an objection answered inline, force added on the one rule that needed it.
   Severity tracks how easily it broke: skipped **with no pressure** outranks broke-only-under-pressure.

The **close-and-re-run loop lives at the orchestrator**, not inside this seam: the seam reports and
proposes; the orchestrator applies the approved wording change, then re-dispatches this seam to
confirm the rationalization is closed. Iterate until a full pass of pressure runs surfaces no new
surviving rationalization — that clean pass, not a plausible read-through, is the evidence the skill
is finished (see [references/harness.md](references/harness.md)).

## What this does not do

- It does not **edit the skill itself** — like every seam it proposes; the orchestrator's gate applies
  the wording fix, so a compliance change goes through the same approval as a token cut.
- It does not **judge static structure** — a buried gate, verbose prose, or a mislayered reference is
  another seam's finding; this one reports only what the *running* agent did.
