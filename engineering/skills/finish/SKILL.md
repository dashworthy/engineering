---
name: finish
description: "The finish phase: when work is complete and green, carry out the finish strategy the plan gate authorized (merge / PR / land the stack / cleanup); with no plan behind the branch, present the options and ask."
---

# Finish

Say this first, plainly: `Using the finish skill to decide how this branch gets integrated.`

## What this guarantees

One thing: this skill will not offer a single integration option — merge, PR, or cleanup —
until the branch in front of it is green and its verification is backed by command output rather
than a claim. Where either is missing, this skill stops and closes the gap first: it runs
verification itself before the options list ever appears. How the chosen option gets carried out
is judgment applied to whatever this project's own remote, review process, and branch model
happen to require.

## Require green and verified before anything else

Compose with `engineering:using-verification`: before this skill even considers
which integration option to offer, confirm verification has run against the branch's current
state and that its output, not a summary of it, is what's being relied on. The rule specific to
this skill: if the branch has moved since verification last ran, re-run it now rather than
trusting a stale green.

If verification comes back red, stop there. Report exactly what failed and hand the decision —
fix now, or fix before returning to this skill — back to the user. A red branch has nothing to
integrate; do not fall through to the options list on the theory that the failure is probably
unrelated.

## Review the whole branch once, as a unit

The per-task gates in `build` each saw one task's diff. Before the branch
re-enters the repository, review it once more as a whole — the complete change, base at the
trunk the branch forks from and head at the branch tip — so an issue that only shows up across
tasks (a seam two tasks share, a pattern that drifted over the branch's life) gets one read no
per-task gate had the scope to catch. Load the build phase's review protocol
(`skills/build/references/review-protocol.md`) and apply it to that whole-branch
boundary now, in addition to the per-task gates that already ran. (A deeper, opt-in review is
guardtower's job, not this one.)

This is a review, **not a new approval gate**: findings are addressed in the code before
integrating, the same as any other review's are, and the branch does not wait on a fresh human
sign-off here — the plan gate already authorized how it finishes. A clean read lets the finish
strategy proceed; a read with findings gets them fixed and re-verified green first.

## Carry out the finish strategy

Once the branch is green, reviewed, and verified, it can re-enter the rest of the repository. How that happens is, by default, not a fresh question: the
plan gate already settled it. Read the plan behind this branch — via the active run pointer or a
plan file under `.engineering/<run>/plan/` that matches this work — and look in its
Global Constraints for the `Finish strategy:` line (and any `PR strategy: stacked` line). When
one is there, it is the human's authorized choice: carry it out without asking again. Only when
there is **no plan, or no finish strategy recorded on it** — a branch built outside the
pipeline — fall back to presenting the options as a structured choice — `Merge directly`,
`Open a pull request` (or `Land the stack` for a stacked run), `Clean up only`, offering only
the ones actually live for this project — and asking, since no gate ever authorized one, using a
tool to ask it where one is available. No such tool: present the same options as plain text and say
the run is degraded.

Either way, detect whether this was a **stacked run**: a plan whose Global Constraints carry a
`PR strategy: stacked` line, or open stacked pull requests already sitting on the branch. A
stacked run does not re-enter the repository as one pull request, so its options list replaces
the single "Open a pull request" with landing the whole stack. Which of these are actually live
options depends on the project, not on this skill's own preference — read the remote
configuration, any branch protection, and the branch's existing state before acting, rather than
treating all of them as available every time.

Whenever this skill writes a pull-request body — opening one, or opening each PR in a stacked
land — load `references/pr-description.md` and follow it to compose the body rather than drafting
it inline. A commit or merge message this skill writes directly follows the same spirit: about the
change, what it does, why, and how it was verified — and the same "Never sign it" policy
`references/pr-description.md` states in full: no self-promotion for Claude or any
AI/LLM vendor, no AI-authorship attribution, no exception absent a project that has explicitly
asked for it.

- **Merge directly** — the branch talks straight to its target with no review gate expected or
  required. Perform the merge (or the native equivalent), and once the branch's work is folded
  into its target, clean up after it: delete the branch and remove any worktree the entrance
  set up for it (`git worktree remove`, or the harness's native equivalent). A merged branch left standing is a place
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
  `Keep it` choice, since silence is never confirmation — before removing anything,
  rather than treating the fact that cleanup was the option picked as confirmation enough.

## What this does not do

- It does not **run the project's tests itself** in place of its own suite or
  `engineering:using-verification` — it relies on that skill's evidence rather than
  reimplementing it.
- It does not **adjudicate the whole-branch review it runs.** The final whole-branch review
  pass above surfaces findings; addressing them is ordinary fix work
  under the skills that own it, and this skill does not turn that review into a human approval
  gate or hold the branch for a fresh sign-off — the plan gate already authorized how the branch
  finishes. Its own remaining job is only how the reviewed, green branch re-enters the repository.
- It does not **pick the project's integration policy for it.** The finish strategy is the
  human's — authorized at the plan gate, or, for a branch with no plan behind it, asked here;
  never hard-coded to whichever one this skill used last.
