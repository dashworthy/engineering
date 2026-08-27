---
name: receiving-code-review
description: "Verify review feedback against this codebase before implementing any of it — act on correct items, meet wrong or unclear ones with a technical question or reasoned refusal, never performative agreement. Use when feedback arrives from code-review, a human, or an external reviewer."
---

# Receiving Code Review

Say this first, plainly: `Using the receiving-code-review skill to work through this feedback.`

## What this guarantees

One thing: every item of received feedback is understood and verified against this codebase
before any of it is implemented. Feedback is evaluated on technical merit and checked against
what the codebase actually does, instead of being agreed with performatively or implemented
blind.

## The reception is technical, not emotional

Code review feedback is a set of technical claims to be evaluated, not a social exchange to be
smoothed over. The core move is the same every time: verify before implementing, ask before
assuming, technical correctness over social comfort. A claim that checks out gets fixed; a
claim that does not gets pushed back on; a claim that is unclear gets a question. None of
those three responses is agreement performed for its own sake.

This rules out a specific and tempting failure. "You're absolutely right," "great point,"
"excellent feedback," and any expression of gratitude are not responses to a technical claim
— they are performances of having received one, and they get skipped entirely. So does "let
me implement that now" said before the claim has been verified. The acknowledgment that a
piece of feedback was correct is the fix itself, shown in the code, optionally with one plain
line naming what changed and where — "Fixed the off-by-one in the range check at
`parser.ts:88`," not "Thanks, good catch." If you notice yourself about to open with thanks
or agreement, that is the signal to delete the opening and state the fix instead.

## Understand the whole set before touching any of it

Read all of the feedback before reacting to the first item. Then, for anything you are not
certain you understand, stop — do not implement the parts you did understand while setting the
unclear ones aside for later. Review items relate to each other; a fix built on a partial
reading of the set can be the wrong fix precisely because it was made before an item that
would have reframed it was understood. Ask about every unclear item first, and implement only
once the set is understood as a whole.

The shape of that is: "I understand items 1, 2, 3, and 6. Before I start, I need clarification
on 4 and 5" — not four fixes landed and two questions raised afterward about work already
built around them.

## Verify each claim against this codebase

A review suggestion is correct in general or correct here, and only the second one matters.
Before implementing any item, check it against what this codebase actually does: is it
technically correct for this stack, does it break something already working, is there a
reason the current code is the way it is, does the suggestion hold across the platforms and
versions this project targets, and does the reviewer have the full context the change sits in.

When a suggestion to "implement this properly" or "build this out" arrives, check first that
the thing is used at all — grep for its callers before adding machinery to it. Unused code
built out to look professional is scope added against YAGNI, and the honest response is
"nothing calls this — remove it, or is there usage I'm missing?" rather than implementing the
buildout.

Feedback carries different default weight by source, and neither default is blind. From a
human partner it is trusted and implemented once understood — still ask when the scope is
unclear, still no performative agreement, but the bias is toward action. From an external
reviewer the bias is toward checking carefully first: be skeptical, verify against the
codebase, and where a suggestion conflicts with a decision the human partner already made,
stop and raise that conflict rather than quietly overriding the earlier decision to satisfy
the newer voice.

## Push back when the feedback is wrong

Pushing back on incorrect feedback is part of receiving it well, not a failure to cooperate.
The conditions are the verify checklist failing: a suggestion that would break existing
functionality, misses context that changes the picture, violates YAGNI, is technically wrong
for this stack, is justified against by a legacy or compatibility reason, or conflicts with an
architectural decision already settled with the human partner.

Push back with technical reasoning, not defensiveness: name the specific thing — the build
target, the failing case, the test that already proves the current behavior — and ask the
specific question. Where the disagreement is architectural, bring the human partner in rather
than settling it silently in the code. If pushing back out loud feels uncomfortable, name the
tension plainly and raise the issue anyway; an honest technical objection is worth more than
comfortable silence that ships a regression.

And when you pushed back and turn out to have been wrong, correct it factually and move on —
"Checked it, you were right, the API does need 13+. Implementing now" — without a long
apology or a defense of why the pushback happened. The correction is the point; the
post-mortem on your own objection is not.

## Implement in an order that stays verifiable

Once the set is understood and each item verified, implement in an order that keeps each fix
checkable on its own: clarify everything unclear first, then take the blocking items — the
breaks and the security issues — then the simple mechanical fixes, then the complex ones that
change logic or structure. Fix one item at a time and confirm each before moving to the next,
rather than landing the whole batch and testing once at the end where a regression cannot be
traced to the change that caused it.

The fixes themselves are implemented under the skills that own that work — a behavior change
driven test-first through `engineering:tdd`, a defect whose cause is not yet understood run
through `engineering:diagnosing-bugs` first. This skill governs how the feedback is received
and ordered; it does not replace the discipline each individual fix is built under.

## Replying to inline comments on a PR

When the feedback lives as inline review comments on a GitHub pull request, a reply belongs
in the comment's own thread, not as a fresh top-level comment on the PR. Reply into the thread
— `gh api repos/{owner}/{repo}/pulls/{pr}/comments/{id}/replies` — so the response stays
attached to the line and the point it answers, instead of detaching into a general comment
that the next reader has to reunite with its context by hand.

## What this does not do

- It does not **produce the feedback.** Reading the change and generating findings is
  `engineering:code-review` or whatever human or external reviewer is the source; this skill
  starts once feedback exists and is in hand.
- It does not **decide a review should have been requested.** Recognizing the review-worthy
  moment and framing the handoff is `engineering:requesting-code-review`; this skill is the
  other end of that exchange, not the trigger for it.
- It does not **decide the work is complete once the feedback is addressed.** A worked-through
  review is not a finished piece of work; confirming the change actually meets its bar is
  `engineering:verification-before-completion`, and integrating the branch is
  `engineering:finishing-a-development-branch`.
