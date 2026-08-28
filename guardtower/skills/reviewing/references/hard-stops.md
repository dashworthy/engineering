# The hard stops

Three stops keep a facet from spending tokens on low-value work. All three run **inside the facet,
at the source** — before it returns — never as trimming the orchestrator does afterward. That
placement is the whole point (ADR-0003): a cap applied after the facet has already scanned
everything saves output, not tokens; a gate the facet runs first saves the scan.

There is deliberately **no numeric token ceiling.** Discipline comes from what is worth doing and
reporting, not from a blunt cutoff mid-thought.

## 1. Relevance gate — decided first

Before any lens work, the facet asks: *does this change even warrant me?* A docs-only diff does not
warrant the Security facet; a three-line copy change does not warrant the Architectural facet. If
the answer is no, the facet returns `relevance: { skipped: <reason> }` immediately, having spent
almost nothing, and writes an artifact recording the skip. This is the single largest saver — it
skips whole reviews.

## 2. Top-N severity cap

When the facet runs, it reports at most `caps.top_n` findings, most severe first, then stops. It
does not enumerate every nit it could name. If there are more than `top_n` genuine findings, the
`top_n` most severe are the ones that matter first; the rest can surface on a re-run after those
are addressed.

## 3. Confidence / severity floor

The facet drops any finding weaker than `caps.floor` — low-confidence guesses and cosmetic nits do
not reach the report. The floor applies to the *weaker* of a finding's severity and confidence, so
a high-severity but low-confidence hunch is held, not asserted. Fewer, higher-signal findings beat
a long list a reader has to triage.

## Together

A facet that self-enforces all three returns quickly when it is not needed, and returns a short,
high-signal, ordered list when it is — which is exactly the budget the plugin promises.
