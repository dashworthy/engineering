# Diagnosing bugs (reference)

> This is a reference the `build` conductor loads when a test fails for a non-obvious reason — find
> the root cause before changing code. It is not a skill and is never discovered on its own; the
> `build` conductor drives it. (Isolating whether a report is even valid is the `triage` entrance's
> job, not this.)

## What this guarantees

One thing: given a defect already worth investigating, this skill produces a root cause
backed by evidence — not the first plausible story, but a mechanism a test or observation
actually confirms. Whatever fix follows is aimed at the thing actually wrong, not at the
symptom that happened to be visible first.

## Reproduce first

A failure you cannot make happen on command is not yet something you can diagnose — it is
a description of one. Before any theory about the cause gets written down, get the
failure to happen again, deliberately, under your own control. A fix aimed at a failure
you never reproduced is aimed at whatever the report's author guessed was wrong, and their
guess is exactly the thing this skill exists to check.

Reproducing is not "it happened once, so the report is probably right." It's steps you can
run again with a failure that shows up each time — or, for something intermittent, a
failure whose rate you can move by changing one thing at a time, so a change in rate
becomes evidence in its own right. A report with no reproduction path yet isn't a dead
end; it's the first thing to build, and nothing past this point starts until it exists.

## Hypothesis, isolation, evidence

With the failure reproducing, form one hypothesis about the cause: a specific, falsifiable
claim about what's going wrong, not "something in that area of the code." A hypothesis
earns the name only if some observation could prove it wrong. A claim nothing could
falsify isn't a hypothesis — it's a suspicion in a hypothesis's clothes.

Then isolate: cut away everything the hypothesis says shouldn't matter. Shrink the
reproduction to the smallest input, the fewest steps, the narrowest code path that still
produces the failure. Isolation does two jobs at once — it makes the failure cheaper to
keep studying, and it tests the hypothesis, because removing something the hypothesis
claims is irrelevant should leave the failure standing. If the failure survives every cut,
the hypothesis is holding up. If a cut you expected to be harmless makes the failure
vanish, the hypothesis was wrong about what mattered — that's a result, not a wasted step,
and it's where the next hypothesis starts.

Confirm with evidence before calling a cause found. A log line that shows the exact bad
value, a minimal test that fails for the reason the hypothesis predicts and passes once the
hypothesis's fix is applied, a debugger break at the moment things go wrong — something a
skeptical second reader could check without taking your word for it. "I changed something
and the symptom went away" is not evidence of cause; plenty of unrelated changes make a
flaky symptom go quiet for a while. Evidence ties one specific mechanism to one specific
failure, not just a change to a better outcome.

When a hypothesis fails its check, retire it and write the next one — don't patch it to
survive the result that just broke it — not even when starting over feels expensive.

## Only then, fix

A cause gets confirmed before a fix gets written, not after. A fix motivated by a hypothesis
that hasn't cleared evidence is still a guess, however well it reads. If you catch yourself
drafting a fix before isolation and confirmation are done, the diagnosis isn't finished — the
fix is a hypothesis wearing an extra step.

## When reproduction needs a human

Some reproductions cannot run unattended: a UI interaction, a physical control, a step only
a person on the other end can perform. For those, `${CLAUDE_PLUGIN_ROOT}/scripts/hitl-loop.template.sh` is a
starting skeleton — it prompts a human for one step, records what they observed, and repeats
until a specific step is pinned to the failure rather than "somewhere in there."

Copy it into the run's own scratch space before editing it, as its header comment says:
editing the shared template in place mixes one investigation's edits into the next one's
starting point. The template only structures the loop — ask, observe, record, decide whether
to narrow further or stop. What each prompt asks, what "pinned down" means for this failure,
and what gets logged at each pass are yours to fill in once it's copied.

## Boundary: diagnosing-bugs finds why, triage decides what

A bug report reaches this skill only after triage — which decides whether a report is real,
whether it's already understood, and what should happen to it (reproduce further, hand to a
human, close as known, or route here for root-cause work). This skill takes a report already
judged worth pursuing and answers the one question triage does not: why does this happen. It
never re-litigates whether the report was worth taking on.

The two also end differently. Triage can end with "not a real defect" or "already known, no
action" — verdicts that need no confirmed mechanism. This skill cannot: it does not stop until
a cause is confirmed with evidence, or until reproduction keeps failing often enough that the
inability to reproduce becomes the finding, handed back rather than papered over with a guess.

## What this does not do

- It does not **choose the fix's design.** Confirming a root cause is not the same as
  choosing how to patch it; a fix substantial enough to need weighing alternatives belongs
  in the design phase or a spec, not tacked onto the end of a diagnosis.
- It does not **keep any external record of the defect.** Everything this skill produces —
  the reproduction steps, the hypothesis log, the evidence that confirmed or killed each
  one — lives as files in the run's own scratch space, nowhere else.
