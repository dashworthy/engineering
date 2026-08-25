# The test harness

How to run skill trials so the results mean something, and how to read them.

## Protocol

1. **Establish the NULL baseline.** Run the scenario with no skill present. Record the choice
   and the verbatim reasoning. This is what the skill must beat — without it you can't tell
   whether the skill changed anything or the agent would have complied anyway.

2. **Run the skill variant.** Same scenario, skill available, on a **fresh agent** with no
   memory of the baseline run. Record discovery (did it load the skill unprompted?), reading
   (completely or skimmed?), and following (did it act as the skill says?).

3. **Layer pressure.** Re-run the variant with each pressure archetype. Note the exact point
   where compliance breaks — which pressure, and what the agent said as it broke.

4. **Meta-test the failures.** When an agent had the skill and skipped it, ask it directly:
   "You had the skill and didn't use it — why?" and "What wording would have stopped you?"
   The agent's own answer often names the fix faster than you'll guess it.

Use fresh subagents for every trial. A reused agent carries the previous run's context and
contaminates the result; independent runs keep each trial honest.

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
