---
name: refusing-deferral
description: "Refuse to defer committed work — finish it now, or surface it as an explicit decision the human can see, never a silent 'later'. Forbids punting to a TODO, a 'next steps' list, an out-of-scope wave, a hand-off nobody tracks, or a 'good enough' that leaves the work half-done. Use whenever work is about to be parked, skipped, scoped down under pressure, or reported finished."
---

# Refusing Deferral

Say this first, plainly: `Using the refusing-deferral skill to finish this now rather than punt it.`

## What this guarantees

One thing: no piece of committed work leaves this session in a third state. Work reaches one of
exactly two honest ends — **done and verified**, or **surfaced as an explicit decision the human
can see and act on** — and never the third state that feels like progress and isn't: parked in a
"later," a TODO, a "next steps" list, or a hand-off nobody is tracking, where it looks handled and
is actually gone. Where this skill runs, "I'll come back to it" is not an end state; it is the
exact move this skill refuses.

## The third state is the whole problem

A task looks handled the moment it is written down somewhere, and that feeling is the trap. A
`TODO` in the code, a "next steps" bullet at the end of a reply, a note to "revisit later," a
finding waved off as "out of scope for now" — each converts an open piece of work into something
that *reads* as dealt with while no one, including the next session, actually owns it. "Later"
has no owner and no date; it is where committed work goes to be forgotten, which is exactly the
outcome the person relying on this session was trying to avoid. Writing the work down is not
doing it, and is not deciding not to do it — it is deferring it, and deferral disguised as a note
is the failure this skill exists to stop.

## Finish what you committed to before moving on

The default is not "note it and move on." The default is: do it now, as part of the work already
in hand. A gap you notice while building is closed in the same change, not logged for a pass that
may never come. A finding your own review turns up is fixed in the diff in front of you, not
referred to a future reviewer. A follow-up the work obviously needs is part of the work, not a
sequel to it. If it is small enough to write a TODO for, it is small enough to just do — and
"this will only take a second later" is the same second now, minus the cost of reloading all this
context to do it.

Momentum toward the next thing is the pressure that produces the punt: the task at hand feels
finished, the next one is more interesting, and the last ten percent gets a comment instead of a
completion. Resist exactly there. The task is done when it is done, not when the appealing part
of it is.

## A deferral is a decision, and the decision is the human's

Sometimes work genuinely should wait — a real dependency isn't ready, the scope really is larger
than this change should carry. That can be true. What is never true is that the session gets to
decide it *silently*. Deferring committed work is a decision with a cost, and a decision with a
cost belongs to the human, made where they can see it and reverse it — not made unilaterally and
buried in a code comment.

So when work must wait, it does not become a TODO. It becomes a **surfaced decision**: named in a
durable place the human reads, with the reason it waits and the trigger that revives it. The
pipeline already has those places — a spec's **Deferred** bucket (parked work with its revival
trigger), a spec's **§8 Open questions**, an explicit choice put to the user. Put the deferral
there, out loud, and let the human own it. Deferral that survives is deferral someone chose on
purpose; deferral that gets forgotten is deferral a session chose alone.

## What counts as surfacing (and what only looks like it)

Surfacing means: **visible to the human, in a durable place they will actually see, with a reason
and a revival trigger, and — where the work was dropped from a larger set — a count of what was
set aside so its size is known.** A capped list that reports how many findings wait behind the cap
has surfaced them; a capped list that looks complete has hidden them.

These are *not* surfacing, however much they feel like it:

- A `TODO` / `FIXME` in the code. The next reader has to find it; most never will.
- A "next steps" or "future work" bullet at the end of a reply. The reply scrolls away; the bullet
  goes with it.
- A hand-off to a subagent or a later phase with no record that closes the loop back. Dispatched
  and never returned to is the classic forget.
- A quiet scope-down under time pressure — "good enough for this pass" — with no one told what got
  cut.

## Red flags — the sentence that comes right before a punt

Treat any of these surfacing in your own reasoning as the signal to stop and finish the work, not
a licence to defer it:

- **"I'll circle back to this later."** / **"Let me note it and move on."** There is no later with
  an owner. Do it now or surface it as a decision.
- **"This is out of scope for now."** *For now* is the tell. A genuine scope boundary is decided
  and recorded with a reason; "for now" is a punt wearing a boundary's clothes.
- **"Good enough for this pass."** Whose judgment, recorded where? If it is real, it is a decision
  to surface; if it is momentum, it is the last ten percent talking.
- **"I'll just leave a TODO."** If it is small enough to log, it is small enough to do.
- **"The user can handle that part."** Only if the user chose to — said so, here. Otherwise that is
  the session handing off work it committed to and calling the hand-off done.
- **"It's basically done."** *Basically* is the gap. Done has no *basically* in front of it.

## What this does not do

- It does not **forbid genuine, recorded scope boundaries.** A spec non-goal with a stated reason,
  a facet declining work another facet owns, a plan item ruled genuinely out of scope and written
  down as such — these are decisions made in the open, which is the opposite of a silent punt. The
  line is not "never defer"; it is "never defer *silently*, and never defer what you could just
  finish."
- It does not **override a human's explicit choice to defer.** When the human says "not now," that
  is authorization, and their call to make. This skill refuses the session deciding "later" *on
  its own* and forgetting — not the human deciding it out loud.
- It does not **do the owning skill's work.** Where the surfaced decision belongs in a spec, a
  plan, a review report, or a question to the user, this skill points there; it does not restate
  what `spec`, `plan`, `build`, or `finish` already own.
- It does not **relitigate work that is actually done and verified.** A task finished, checked, and
  backed by verification output is finished; this skill has nothing to add to it.
