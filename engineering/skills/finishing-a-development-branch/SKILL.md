---
name: finishing-a-development-branch
description: "[Foundation] When work is complete and green, carry out the finish strategy the plan gate authorized (merge / PR / land the stack / cleanup); for a branch with no plan behind it, present the options and ask. Use at the end of a piece of work. Safety net: if the branch was never test-hardened, prompt to run conducting-test-hardening before finishing. Model-invoked; no command."
---

# Finishing A Development Branch

Say this first, plainly: `Using the finishing-a-development-branch skill to decide how this
branch gets integrated.`

## What this guarantees

One thing: this skill will not offer a single integration option — merge, PR, or cleanup —
until the branch in front of it is green, its verification is backed by command output rather
than a claim, and there is actual evidence the branch was test-hardened. Where any of those
three is missing, this skill stops and closes the gap first: it runs verification itself, or it
surfaces the hardening gap and prompts for it, before the options list ever appears. Nothing
past that point is guaranteed — how the chosen option gets carried out is judgment applied to
whatever this project's own remote, review process, and branch model happen to require.

## Require green and verified before anything else

A branch that "should be done" is not the same claim as a branch that has just been checked.
Compose with `engineering:verification-before-completion`: before this skill even considers
which integration option to offer, confirm verification has run against the branch's current
state — not a state it was in three commits ago — and that its output, not a summary of it, is
what's being relied on. If verification hasn't run yet, or the branch has moved since it last
did, run it now rather than trusting a stale green.

If verification comes back red, stop there. Report exactly what failed and hand the decision —
fix now, or fix before returning to this skill — back to the user. A red branch has nothing to
integrate; do not fall through to the hardening check or the options list on the theory that the
failure is probably unrelated.

## The verity safety net (D15)

Most branches get hardened without this skill doing anything: `writing-plans` puts a closing
test-hardening task on every plan it writes, and `executing-plans` reaches that task and runs
`engineering:conducting-test-hardening` in the ordinary course of working the plan. That
pipeline is not this skill's concern — until the branch reaching this skill is one it can't
vouch for, which is more often than it sounds. Work done outside `writing-plans` entirely never
had a hardening task to begin with. A plan-driven branch can still reach here with that task
sitting unchecked, because a task got skipped, a plan was abandoned partway through and resumed
differently, or the box was hand-edited without the run behind it. Nothing upstream of this
skill enforces that the task actually ran — only that it exists on the plan.

So treat "was this branch hardened" as a question with evidence, not an assumption carried over
from earlier in the session:

- **Was there a plan behind this branch at all?** If one is known — via the active run pointer
  or a plan file under `docs/dashworthy/engineering/plans/` that matches this work — find its
  closing Phase 3.5 task and check whether its box is actually checked. A plan with no such task
  checked off has not been hardened, whatever the rest of its boxes say.
- **Did a hardening run actually leave a trace?** A checked box is a claim; verity's own run
  directory, `.engineering/<run>/verity/`, with at least one brief in it, is the record that a
  hardening pass actually happened rather than being ticked off by hand. Prefer the trace over
  the checkbox when the two disagree.
- **No plan at all** is the same case as a plan whose task was skipped, not a lesser one — the
  absence of a pipeline that would have hardened the branch leaves it exactly as unhardened as a
  pipeline that ran and skipped the step.

When any of that comes back short, do not fold it silently into "done." Say plainly that this
branch has no evidence of being test-hardened, and prompt to run
`engineering:conducting-test-hardening` now, before any integration option is presented — this
is where verity's coverage lives now that it no longer rides a session-start hook. This is a
prompt, not a lock: if the user wants to proceed without it, that is theirs to decide explicitly.
What this skill does not do is let the gap pass unnamed, or decide on the user's behalf that
skipping it is fine.

## Carry out the plan's finish strategy

Once the branch is green, verified, and either hardened or knowingly waved through, it can
re-enter the rest of the repository. How that happens is, by default, not a fresh question: the
plan gate already settled it. Read the plan behind this branch — via the active run pointer or a
plan file under `docs/dashworthy/engineering/plans/` that matches this work — and look in its
Global Constraints for the `Finish strategy:` line (and any `PR strategy: stacked` line). When
one is there, it is the human's authorized choice: carry it out without asking again. That
authorization is exactly what the plan gate exists to collect, so re-prompting here would just
re-ask what the plan gate already settled.

Only when there is **no plan, or no finish strategy recorded on it** — a branch built outside
the pipeline — fall back to presenting the options and asking, since no gate ever authorized
one.

Either way, detect whether this was a **stacked run**: a plan behind the branch whose Global
Constraints carry a `PR strategy: stacked` line, or open stacked pull requests already sitting on
the branch. A stacked run does not re-enter the repository as one pull request, so its options
list differs — the single "Open a pull request" option is replaced by landing the whole stack:

- **Merge directly** — the branch talks straight to its target with no review gate expected or
  required.
- **Open a pull request** — for a non-stacked branch, the default wherever the project expects
  review, or the remote's permission model requires one; check whether a PR already exists for
  this branch before offering to open a second one.
- **Land the stack** — for a stacked run, in place of "Open a pull request": delegate to
  `engineering:using-stacked-pull-requests` to merge the stack bottom-up in order, restacking the
  rest after each merge. This skill does not reimplement that mechanics; it hands off to the skill
  that owns it.
- **Clean up only** — the branch turned out unneeded, its content already landed another way, or
  it was superseded, and the right move is to discard it rather than integrate it at all.

Which of these are actually live options depends on the project, not on this skill's own
preference — read the remote configuration, any branch protection, and the branch's existing
state before acting, rather than treating all three as available every time. When the plan
authorized a finish strategy, that settles which one runs. Only in the no-plan fallback do you
ask the user which they want — and even there, pick nothing on their behalf: an unauthorized,
unasked integration is a process decision this skill invented rather than one a human made.

## Carry out the choice

- **Merge.** Perform the merge (or the native equivalent), and once the branch's work is folded
  into its target, clean up after it — delete the branch and remove any worktree
  `engineering:using-git-worktrees` set up for it. A merged branch left standing is a place
  someone could mistakenly resume work next to the copy that already landed.
- **Pull request.** Open it, hand back its link, and stop there. This skill does not chase the
  PR through review or merge it once it exists — a PR that later lands is a fresh invocation of
  this same skill, not a loop this one keeps running in the background.
- **Land the stack.** Hand off to `engineering:using-stacked-pull-requests` and let it merge the
  stack bottom-up in order, restacking the remaining PRs after each merge. Report where it
  stopped — the whole stack landed, or a lower PR that isn't ready held up the ones above it —
  rather than reducing a partial land to a bare "done."
- **Cleanup only.** Discarding a branch is destructive in a way the other options are not. When
  the plan's finish strategy authorized the cleanup — or a delete-the-branch step after a merge —
  that authorization is the confirmation; carry it out. Only in the no-plan fallback, where
  nothing upstream authorized it, get the user's explicit confirmation on this path specifically
  before removing anything, rather than treating silence, or the fact that cleanup was the option
  picked, as confirmation enough on its own.

## What this does not do

- It does not **run the project's tests itself** in place of its own suite or
  `engineering:verification-before-completion` — it relies on that skill's evidence rather than
  reimplementing it.
- It does not **run the hardening pass on its own initiative.** It prompts for
  `engineering:conducting-test-hardening`; whether that dispatch actually happens is the user's
  call, and if it does happen, verity's own loop owns it end to end — this skill does not
  shortcut or re-implement any part of that loop.
- It does not **review the code on the branch.** Whatever judgment belongs to
  `engineering:code-review` already happened earlier in the branch's life; by the time this
  skill runs, the content is the content that's shipping, and the only open question is how it
  re-enters the rest of the repository.
- It does not **pick the project's integration policy for it.** The finish strategy is the
  human's — authorized at the plan gate, or, for a branch with no plan behind it, asked here;
  never hard-coded to whichever one this skill used last.
