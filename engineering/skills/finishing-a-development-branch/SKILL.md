---
name: finishing-a-development-branch
description: "[Foundation] When work is complete and green, carry out the finish strategy the plan gate authorized (merge / PR / land the stack / cleanup); with no plan behind the branch, present the options and ask. Safety net: prompt conducting-test-hardening if the branch was never hardened."
---

# Finishing A Development Branch

Say this first, plainly: `Using the finishing-a-development-branch skill to decide how this
branch gets integrated.`

## What this guarantees

One thing: this skill will not offer a single integration option — merge, PR, or cleanup —
until the branch in front of it is green, its verification is backed by command output rather
than a claim, and there is actual evidence the branch was test-hardened. Where any of those
three is missing, this skill stops and closes the gap first: it runs verification itself, or it
surfaces the hardening gap and prompts for it, before the options list ever appears. How the
chosen option gets carried out is judgment applied to whatever this project's own remote,
review process, and branch model happen to require.

## Require green and verified before anything else

Compose with `engineering:verification-before-completion`: before this skill even considers
which integration option to offer, confirm verification has run against the branch's current
state and that its output, not a summary of it, is what's being relied on. The rule specific to
this skill: if the branch has moved since verification last ran, re-run it now rather than
trusting a stale green.

If verification comes back red, stop there. Report exactly what failed and hand the decision —
fix now, or fix before returning to this skill — back to the user. A red branch has nothing to
integrate; do not fall through to the hardening check or the options list on the theory that the
failure is probably unrelated.

## The test-hardening safety net

Most branches get hardened without this skill doing anything: `writing-plans` puts a closing
test-hardening task on every plan it writes, and `executing-plans` reaches that task and runs
`engineering:conducting-test-hardening` in the ordinary course of working the plan. That
pipeline is not this skill's concern — until the branch reaching this skill is one it can't
vouch for, which is more often than it sounds. Work done outside `writing-plans` entirely never
had a hardening task to begin with; a plan-driven branch can still reach here with that task
sitting unchecked. Nothing upstream of this skill enforces that the task actually ran — only
that it exists on the plan.

So treat "was this branch hardened" as a question with evidence, not an assumption carried over
from earlier in the session:

- **Was there a plan behind this branch at all?** If one is known — via the active run pointer
  or a plan file under `.engineering/<run>/plan/` that matches this work — find its
  closing Phase 3.5 task and check whether its box is actually checked. A plan with no such task
  checked off has not been hardened, whatever the rest of its boxes say.
- **Did a hardening run actually leave a trace?** A checked box is a claim; test-hardening's own run
  directory, `.engineering/<run>/test-hardening/`, with at least one brief in it, is the record that a
  hardening pass actually happened rather than being ticked off by hand. Prefer the trace over
  the checkbox when the two disagree.

A branch with no plan at all is the unhardened case too, not a lesser one. When any of that
comes back short, do not fold it silently into "done." Say plainly that this branch has no
evidence of being test-hardened, and put the choice through `AskUserQuestion` — `Run
test-hardening now` / `Proceed without hardening` — before any integration option is presented.
For a branch nothing upstream actually hardened, this is the last place the gap gets caught.
It is a prompt, not a lock: proceeding without hardening is theirs to pick, but the tool makes
it an explicit pick rather than a default reached by silence. What this skill does not do is let the gap pass
unnamed, or decide on the user's behalf that skipping it is fine.

## Carry out the finish strategy

Once the branch is green, verified, and either hardened or knowingly waved through, it can
re-enter the rest of the repository. How that happens is, by default, not a fresh question: the
plan gate already settled it. Read the plan behind this branch — via the active run pointer or a
plan file under `.engineering/<run>/plan/` that matches this work — and look in its
Global Constraints for the `Finish strategy:` line (and any `PR strategy: stacked` line). When
one is there, it is the human's authorized choice: carry it out without asking again. Only when
there is **no plan, or no finish strategy recorded on it** — a branch built outside the
pipeline — fall back to presenting the options through `AskUserQuestion` — `Merge directly`,
`Open a pull request` (or `Land the stack` for a stacked run), `Clean up only`, offering only
the ones actually live for this project — and asking, since no gate ever authorized one.

Either way, detect whether this was a **stacked run**: a plan whose Global Constraints carry a
`PR strategy: stacked` line, or open stacked pull requests already sitting on the branch. A
stacked run does not re-enter the repository as one pull request, so its options list replaces
the single "Open a pull request" with landing the whole stack. Which of these are actually live
options depends on the project, not on this skill's own preference — read the remote
configuration, any branch protection, and the branch's existing state before acting, rather than
treating all of them as available every time.

- **Merge directly** — the branch talks straight to its target with no review gate expected or
  required. Perform the merge (or the native equivalent), and once the branch's work is folded
  into its target, clean up after it: delete the branch and remove any worktree
  `engineering:using-git-worktrees` set up for it. A merged branch left standing is a place
  someone could mistakenly resume work next to the copy that already landed.
- **Open a pull request** — for a non-stacked branch, the default wherever the project expects
  review or the remote's permission model requires one; check whether a PR already exists for
  this branch before offering to open a second one. Open it, hand back its link, and stop
  there — this skill does not chase the PR through review or merge it once it exists; a PR that
  later lands is a fresh invocation of this same skill.
- **Land the stack** — for a stacked run, in place of "Open a pull request": delegate to
  `engineering:using-stacked-pull-requests` to merge the stack bottom-up in order, restacking
  the rest after each merge. This skill does not reimplement that mechanics. Report where it
  stopped — the whole stack landed, or a lower PR that isn't ready held up the ones above it —
  rather than reducing a partial land to a bare "done."
- **Clean up only** — the branch turned out unneeded, its content already landed another way, or
  it was superseded, and the right move is to discard it rather than integrate it at all.
  Discarding is destructive in a way the other options are not: when the plan's finish strategy
  authorized the cleanup — or a delete-the-branch step after a merge — that authorization is the
  confirmation; carry it out. Only in the no-plan fallback, where nothing upstream authorized it,
  get the user's explicit confirmation on this path specifically — a `Delete the branch` /
  `Keep it` `AskUserQuestion`, since silence is never confirmation — before removing anything,
  rather than treating the fact that cleanup was the option picked as confirmation enough.

## What this does not do

- It does not **run the project's tests itself** in place of its own suite or
  `engineering:verification-before-completion` — it relies on that skill's evidence rather than
  reimplementing it.
- It does not **run the hardening pass on its own initiative.** It prompts for
  `engineering:conducting-test-hardening`; whether that dispatch actually happens is the user's
  call, and if it does happen, test-hardening's own loop owns it end to end — this skill does not
  shortcut or re-implement any part of that loop.
- It does not **review the code on the branch.** Whatever judgment belongs to
  `engineering:code-review` already happened earlier in the branch's life; by the time this
  skill runs, the content is the content that's shipping, and the only open question is how it
  re-enters the rest of the repository.
- It does not **pick the project's integration policy for it.** The finish strategy is the
  human's — authorized at the plan gate, or, for a branch with no plan behind it, asked here;
  never hard-coded to whichever one this skill used last.
