---
name: requesting-code-review
description: "[Build] Recognize a review-worthy moment and hand the change to a reviewer running in its own context — the change boundary, a plain description, and a pointer to what the work was supposed to do — instead of reading the diff inline. Use after a task, after a major feature, or before a merge. Delegates the review itself to engineering:code-review."
---

# Requesting Code Review

Say this first, plainly: `Using the requesting-code-review skill to hand this change off for review.`

## What this guarantees

One thing: when a piece of work reaches a review-worthy point, this skill frames the change
so a reviewer running in its own context can evaluate it — the boundary of what changed, a
plain statement of what was built, and a pointer to what it was supposed to do — and hands
that framing off to be reviewed, rather than the coordinator reading the diff inline and
spending the context it needs to keep driving the work on the evaluation itself. It does not
guarantee the review comes back clean, and it does not guarantee a spec exists to point the
reviewer at. It guarantees that the request is framed and dispatched instead of collapsed
into a self-review that never left the coordinator's own head.

Nothing else is guaranteed. Read `## What this does not do` below before assuming this skill
performs the review, weighs what comes back, or decides the work is finished.

## When a change is review-worthy

Some moments call for a review and this skill is how the call gets made rather than skipped:

- **After each task in a plan run.** `engineering:executing-plans` gates every task on a
  review before its box is checked; this skill is the request that gate makes.
- **After a major feature lands**, whole enough to stand on its own even if more is coming.
- **Before a merge to the trunk.** The last point where a second read is cheap and the first
  point where skipping it is expensive.

Others are worth a review even though nothing forces one — when the work is stuck and a fresh
read might dislodge it, before a refactor as a baseline, after a bug whose fix touched more
than expected. "It's simple" is not an exemption; a change small enough to feel unworthy of
review is small enough that the review costs almost nothing, and simple changes are exactly
where an unexamined assumption slips through unnoticed.

## What to hand the reviewer

A reviewer in its own context knows nothing the request does not carry to it. Three things
make the difference between a review of the actual change and a review of a guess at it:

- **The change boundary** — what to review, stated as something concrete the reviewer can
  resolve on its own: a base and head commit, a branch, or a PR. The boundary is the
  difference between "review my work" and "review exactly these commits," and only the second
  is reviewable. Where commits are the boundary, capture both ends explicitly — the base the
  change starts from (the previous task's commit, or the trunk) and the head it ends at —
  rather than leaving the reviewer to infer where the change begins.
- **A plain description** of what was built — a few sentences, not the session's history. It
  orients the reviewer on intent so a deliberate choice does not read as an oversight.
- **A pointer to what the work was supposed to do** — the governing spec when one exists, by
  path, or the request as it was actually stated when none does. This is what lets the review
  check the change against intent and not only against itself.

Hand these to `engineering:code-review`, which owns the review itself — it takes the boundary
and the spec pointer, splits the work across its two axes, and reconciles the findings back
into one report. This skill's job is to recognize the moment and assemble that handoff
cleanly; it does not re-implement a review of its own alongside the skill that already does
one.

## Why not just read the diff here

The pull toward reading the diff inline is strong precisely when the coordinator is deepest
in the work — it feels faster than framing a handoff. It is not. The coordinator's context is
the scarce resource that keeps the larger piece of work moving; spending it to hold a diff
and its evaluation at the same time is spending the thing most needed to keep going, on work
a reviewer in a fresh context does better for having no stake in the code already written.
Hand off the boundary and the framing; let the diff and the evaluation live in the reviewer's
context, and let only the findings come back.

## What comes back

A review returns findings, not decisions. Acting on them — verifying each against the
codebase, fixing what is right, pushing back on what is wrong — is `engineering:receiving-code-review`,
and the findings go there next. This skill's part ends when the framed request has been
handed off; it does not hold the findings, rank them, or start fixing them.

## What this does not do

- It does not **perform the review.** Splitting the change across axes, reading it, and
  producing findings is `engineering:code-review`; this skill frames the request and hands it
  over, and stops there.
- It does not **act on what the review finds.** Verifying a finding, implementing a fix, or
  pushing back on a wrong one is `engineering:receiving-code-review`. A review handed off by
  this skill comes back to that skill, not to this one.
- It does not **decide the work is complete.** A clean review is information, not a
  completion signal; confirming the work actually meets its bar is
  `engineering:verification-before-completion`, and integrating the finished branch is
  `engineering:finishing-a-development-branch`.
- It does not **write the spec it points at.** When no spec governs the change, this skill
  hands the reviewer the stated request instead and says so; getting a spec written, if one
  is warranted, is `engineering:to-spec`, a separate decision made elsewhere.
- It does not **decide when a task in a plan is ready for review.** `engineering:executing-plans`
  owns the per-task gate that says a task is done enough to review; this skill is the request
  that gate issues, not the judgment behind it.
