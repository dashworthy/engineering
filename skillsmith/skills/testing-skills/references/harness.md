# The test harness

How to run skill trials so the results mean something, and how to read them.

## Protocol

Run the five method steps from `SKILL.md`, with the rigor rules that make the results mean
something:

- **The NULL baseline is what the skill must beat.** Without it you can't tell whether the skill
  changed anything or the agent would have complied anyway.
- **Run every variant on a fresh subagent** with no memory of the baseline or a prior run. A reused
  agent carries the previous run's context and contaminates the result.
- **Meta-test the failures.** When an agent had the skill and skipped it, ask it directly: "You had
  the skill and didn't use it — why?" and "What wording would have stopped you?" The agent's own
  answer often names the fix faster than you'll guess it.

## Success and failure

**The variant succeeds when**, across the pressure runs, the agent:

- loads the skill unprompted,
- reads it completely before acting,
- follows it even under pressure, and
- can't produce a rationalization that the skill's wording leaves room for.

**It fails when** the agent skips the skill with no pressure at all, "adapts the idea"
without reading it, rationalizes past it under pressure, or treats it as optional reference
rather than the thing to do.

## Recording what survived

Keep a short log per skill: the pressure that broke it, the rationalization verbatim, and the
wording change you made in response. Two reasons. It stops you re-fixing the same hole twice,
and the list of rationalizations that no longer work is the real evidence the skill is
finished — more than a clean read-through, which only shows the skill is plausible, not that
it holds. Stop iterating when a full pass of pressure runs produces no new surviving
rationalization.
