# Framing for compliance

Getting an instruction followed is partly a matter of how it's framed. Models are trained on
human text, so the framings that move people — authority, consistency, social proof — tend to
move models too. Used honestly, this helps a critical practice survive a distracted moment.
Used to dress up a weak instruction, it just adds noise. This file is about the honest use.

## What the evidence does and doesn't show

You may have seen the claim that persuasion techniques "more than double compliance" in LLMs,
from Meincke et al. (2025), *Call Me A Jerk* — roughly 33% to 72%. Be careful what that
measured. The study persuaded a model to comply with requests it was supposed to **refuse**
(insulting the user, unsafe instructions). It is evidence that framing can erode a model's
guardrails — not evidence that framing makes a *legitimate* instruction stick better. The two
are different phenomena, and the second doesn't follow from the first. Treat these principles
as plausible, mechanism-based heuristics worth testing on your own skill (see the
**testing-skills** skill), not as a proven multiplier. Don't quote the number as proof.

## Principles worth using

- **Authority** — imperative, non-negotiable framing ("Write code before the test? Delete it
  and start over."). Removes the "is this an exception?" deliberation. Governed by the force
  rule: reserve it for cliffs (the *Degrees of freedom* reference states the rule).
- **Commitment** — have the agent state or choose something before acting ("Announce which
  skill you're using"; "Pick A, B, or C"). A stated choice is more likely to be carried
  through than an unstated default.
- **Scarcity / immediacy** — bind an action to a moment ("Immediately after the task, request
  review — before moving on"). Defeats "I'll do it later," which becomes never.
- **Social proof** — name the norm and the failure mode ("Checklists without tracking get
  steps skipped — every time"). Establishes what "done properly" looks like.
- **Unity** — shared-stakes framing ("We're working the same codebase; I need your honest
  read"). Fits collaborative skills where honesty matters more than deference.

## Principles to skip

- **Reciprocity** (implying the agent owes something) and **liking** (ingratiation) buy
  little in a skill and cost something real. Liking in particular pulls toward agreeableness,
  which is the opposite of what a review or honest-feedback skill needs. Leave both out.

## The overuse trap

Every principle above degrades when stacked: a skill where each line is an authoritative, urgent,
norm-invoking imperative reads as uniformly loud, and the agent can't tell the one rule that matters
from the four that don't. This is the same scarce-budget rule as force (see `degrees-of-freedom.md`):
frame the few load-bearing instructions and let the rest be plain. Restraint is what makes the
framing you do use legible.
