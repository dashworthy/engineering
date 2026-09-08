# The test harness

How to run skill trials so the results mean something, and how to read them. This is the seam's
protocol — the depth behind `check.md`'s five steps.

## Protocol

Run the five method steps from `check.md`, with the rigor rules that make the results mean something:

- **The NULL baseline is what the skill must beat.** Without it you can't tell whether the skill
  changed anything or the agent would have complied anyway.
- **Run every variant on a fresh subagent** with no memory of the baseline or a prior run. A reused
  agent carries the previous run's context and contaminates the result. (These trial subagents are
  the seam's own — separate from the audit's dispatch of the seam itself.)
- **Meta-test the failures.** When an agent had the skill and skipped it, ask it directly: "You had
  the skill and didn't use it — why?" and "What wording would have stopped you?" The agent's own
  answer often names the fix faster than you'll guess it — and that fix is what the finding's `fix`
  field carries back to the orchestrator.

## Success and failure

**The skill passes when**, across the pressure runs, the agent:

- loads the skill unprompted,
- reads it completely before acting,
- follows it even under pressure, and
- can't produce a rationalization the skill's wording leaves room for.

**It fails when** the agent skips the skill with no pressure at all, "adapts the idea" without reading
it, rationalizes past it under pressure, or treats it as optional reference rather than the thing to
do. Each failure becomes a finding.

## The close-and-re-run loop is the orchestrator's

This seam does not edit the skill. It reports each surviving rationalization and the wording change
that would close it; the orchestrator applies the approved change and **re-dispatches this seam** to
confirm the hole is shut. Keep a short log per skill across those passes: the pressure that broke it,
the rationalization verbatim, and the wording change made in response. Two reasons — it stops the same
hole being re-fixed twice, and the list of rationalizations that no longer work is the real evidence
the skill is finished, more than a clean read-through (which only shows the skill is plausible, not
that it holds). Stop iterating when a full pass of pressure runs produces no new surviving
rationalization.
