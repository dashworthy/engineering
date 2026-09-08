# The hard stops

Three stops keep a check from spending tokens on low-value work. All three run **inside the check,
at the source** — before it returns — never as trimming the orchestrator does afterward. That
placement is the whole point: a cap applied after the check has already scanned every skill saves
output, not tokens; a gate the check runs first saves the scan.

There is deliberately **no numeric token ceiling.** Discipline comes from what is worth finding and
proposing, not from a blunt cutoff mid-thought.

## 1. Relevance gate — decided first

Before any lens work, the check asks: *does this target even warrant me?* A single skill does not
warrant the cross-skill-duplication or dead-skills check; a prose-only skill that ships no scripts
does not warrant the runtime-integrity check; a skill that dispatches no subagents does not warrant
the subagent-economics check; a skill with no runnable governed scenario does not warrant the
pressure-test seam. If the answer is no, the check returns `relevance: { skipped: <reason> }`
immediately, having spent almost nothing. This is the single largest saver — it skips whole lenses,
and it matters most for the expensive pressure-test seam, whose gate spares a full trial run.

The orchestrator's menu pre-check (see `SKILL.md`) is a *coarse* first gate that keeps most checks
off the menu when scope or character rules them out. This per-check relevance gate stays
**authoritative** underneath it: a check the human left checked still self-skips here if the target
turns out not to warrant it, so a pre-checked lens never produces a hollow finding list.

## 2. Top-N severity cap

When the check runs, it reports at most `caps.top_n` findings, most severe first, then stops. It
does not enumerate every nit it could name. If there are more than `top_n` genuine findings, the
`top_n` most severe are the ones to fix first; the rest can surface on a re-run after those are
applied.

But "can surface on a re-run" is only honest if the reader knows they exist. The cap orders and
defers; it must never *hide*. So a check that hits the cap reports **`dropped`** — the count of
genuine, above-floor findings it held back beyond `top_n` — alongside its findings. `dropped` is `0`
when the cap wasn't reached. A capped list that looks complete is the cap lying: a user who cannot
see that four more real findings wait behind it cannot choose to re-run for them. (The floor's drops
in §3 are low-confidence or cosmetic noise excluded by design, not deferred work; `dropped` counts
what the *cap* set aside, not what the floor excluded.)

## 3. Confidence / severity floor

The check drops any finding weaker than `caps.floor` — low-confidence guesses and cosmetic nits do
not reach the report. The floor applies to the *weaker* of a finding's severity and confidence, so a
high-severity but low-confidence hunch is held, not asserted. Fewer, higher-signal findings beat a
long list a user has to triage.

The floor is measured against the finding's estimated **token saving** as well as its severity: a
cut worth three tokens in a reference loaded once is below the floor even when you are sure of it,
because it is not worth a question. Weight the saving by where it lands — a description cut outranks a
`SKILL.md` cut outranks a reference cut.

## Together

A check that self-enforces all three returns quickly when it is not needed, and returns a short,
high-signal, ranked list of fixable findings when it is — which is exactly the budget the audit
promises before the orchestrator ever puts a question to the user.
