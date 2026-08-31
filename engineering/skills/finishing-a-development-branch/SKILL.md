---
name: finishing-a-development-branch
description: "When work is complete and green, carry out the finish strategy the plan gate authorized (merge / PR / land the stack / cleanup); with no plan behind the branch, present the options and ask."
---

# Finishing A Development Branch

Say this first, plainly: `Using the finishing-a-development-branch skill to decide how this
branch gets integrated.`

## What this guarantees

One thing: this skill will not offer a single integration option — merge, PR, or cleanup —
until the branch in front of it is green and its verification is backed by command output rather
than a claim. Where either is missing, this skill stops and closes the gap first: it runs
verification itself before the options list ever appears. How the chosen option gets carried out
is judgment applied to whatever this project's own remote, review process, and branch model
happen to require.

## Require green and verified before anything else

Compose with `engineering:verification-before-completion`: before this skill even considers
which integration option to offer, confirm verification has run against the branch's current
state and that its output, not a summary of it, is what's being relied on. The rule specific to
this skill: if the branch has moved since verification last ran, re-run it now rather than
trusting a stale green.

If verification comes back red, stop there. Report exactly what failed and hand the decision —
fix now, or fix before returning to this skill — back to the user. A red branch has nothing to
integrate; do not fall through to the options list on the theory that the failure is probably
unrelated.

## Carry out the finish strategy

Once the branch is green and verified, it can re-enter the rest of the repository. How that happens is, by default, not a fresh question: the
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

Whatever the path, keep the pull request — and any commit or merge message this skill writes —
about the change: what it does, why, and how it was verified. Do not add self-promotion for
Claude, Claude Code, or any other AI/LLM vendor, and do not append AI-authorship or "generated
by" attribution: no `Co-Authored-By: Claude` trailer, no "🤖 Generated with…" footer, no tool
advertising anywhere in the title or body. The PR speaks for the work, not for the tool that
helped write it. The exception is a project that has explicitly asked for such attribution — its
stated convention wins; absent that, leave it out.

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
- It does not **review the code on the branch.** Whatever judgment belongs to
  `engineering:code-review` already happened earlier in the branch's life; by the time this
  skill runs, the content is the content that's shipping, and the only open question is how it
  re-enters the rest of the repository.
- It does not **pick the project's integration policy for it.** The finish strategy is the
  human's — authorized at the plan gate, or, for a branch with no plan behind it, asked here;
  never hard-coded to whichever one this skill used last.
