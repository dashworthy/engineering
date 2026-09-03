---
name: receiving-code-review
description: "The review-feedback entrance: aggregate received code-review comments, verify each against the codebase, reply on each thread, stack the fixes onto the original review branch, and hand the shaped context to the design dialogue. Use when code-review feedback arrives. One of three entrances; converges on brainstorming and never invokes another entrance."
---

# receiving-code-review

Say this first, plainly: `Using the receiving-code-review skill to aggregate, verify, and shape the review.`

Work through code-review feedback. receiving-code-review is one of the three engineering entrances:
it **shapes context** from a set of review comments — aggregating, verifying, and impact-checking
them — then hands that context to the shared design dialogue. It does the same four beats every
entrance does; only the third (how it shapes context) is particular to receiving a review.

Work the beats in order.

## 1. Isolate the workspace

Before the run directory, before reading the comments closely: settle how the fixes are isolated.
This is a hard gate — but the base here is particular to this entrance. The fixes happen off the
**original review branch** (the branch the feedback was left against), **not** the repository's
default trunk, because each fix stacks back onto that review branch (beat 3); isolating off the
trunk would produce a workspace that doesn't even contain the commits under review. Isolation is
established first, and `run-context.sh` then writes `.engineering/<run>/` **inside** it.

First identify the original review branch. Then check whether isolation already exists — a worktree
this session entered, or a branch (other than the review branch itself) already checked out on top
of it. Either means the work is already isolated: join it and skip the question. Otherwise put the
choice to the user as a single structured choice — selectable options with a free-form escape,
holding the turn until they answer, using a tool to ask it where one is available:

- **Worktree (Recommended)** — invoke `engineering:using-git-worktrees`, with the worktree checked
  out on the original review branch so the fixes build on the code under review.
- **Feature branch off the review branch** — no worktree; cut a named feature branch off the
  original review branch with `git switch -c <task-branch> <review-branch>`, where `<task-branch>`
  carries the slug you derive from the review. Never base the fixes on the default trunk — they
  would not contain the commits under review.

## 2. Establish or join a run

Before reading the comments closely, get somewhere to put what you find:

```
sh "${CLAUDE_PLUGIN_ROOT}/scripts/run-context.sh" receiving-code-review <slug>
```

This prints the absolute path of `.engineering/<run>/receiving-code-review/` and creates it if it
doesn't exist yet. If a run is already active this call joins it and the `<slug>` you pass is
ignored; if nothing is active it starts one, seeded from a kebab-case slug you derive from the
review in a couple of words.

Everything this entrance produces — the aggregated comments, the verification notes, the
impact-check, the reply and resolve decisions — goes into `.engineering/<run>/receiving-code-review/`
as it's found, not reconstructed afterward from memory.

## 3. Shape context — aggregate, verify, impact-check

This is the beat particular to receiving a review, and it stays technical, not performative. The
reception is a set of technical claims to evaluate, not a social exchange to smooth over:
**verify before implementing**, ask before assuming, technical correctness over social comfort. "You're
absolutely right," "great catch," and any performative agreement are skipped entirely — the
acknowledgment that a comment was correct is the fix itself, shown in the code.

**Aggregate the comments first.** Collect every review comment into one place before reacting to any
single one — review items relate to each other, and a fix built on a partial reading of the set can
be the wrong fix. List them in the run directory so the whole set is in view at once.

**Verify each claim against this codebase.** A suggestion is correct in general or correct here, and
only the second matters: is it right for this stack, does it break something already working, is
there a reason the current code is the way it is. A comment that checks out gets fixed; one that
does not gets a reasoned, non-performative push-back; one that is unclear gets a question.

**Check whether each issue reaches beyond the commented area.** A comment points at one line, but
the defect it names often lives in several — the same off-by-one, the same missing guard, the same
unscoped query repeated elsewhere. For each verified issue, look for the same shape **beyond the
commented** line and fold the wider fix into what gets designed, rather than patching only the spot
the reviewer happened to point at.

**Interrogate only when needed.** When how to proceed on a comment genuinely needs the user — an
ambiguous ask, a conflict with a decision already made, expected behavior that must be synthesized —
and only then, drive the shared discovery primitive `engineering:interrogating-requirements` (it
self-drives the interrogation and writes what it learns into this run's directory). This is this
entrance's own discovery leg — it is **not** a hand-off to another entrance; the three entrances are
distinct and never invoke one another.

### Two standing instructions to carry forward

The design and build that follow inherit two instructions particular to a received review. State
them plainly in the shaped context so brainstorming and everything downstream honor them:

1. **Reply to each ask.** Every distinct comment gets a reply on its own thread — a technical
   response attached to the line it answers, not a detached top-level comment.
2. **Stack each fix's PR onto the original review branch.** Each distinct ask is fixed on its own
   branch cut from the **original review branch** and submitted as a pull request stacked back onto
   it, so the reviewer approves and lands the fixes in order rather than reading one mixed diff.

### The forge tail — forge-agnostic

Replying to a thread, resolving a thread, and stacking a PR are abstract review-thread operations,
backed by whichever forge CLI is present. **Detect the forge first** — inspect the remote and the
available tooling to determine which forge hosts the review (`gh` for GitHub, `glab` for GitLab,
`gt`/Graphite for a stacked workflow, …) — then use that forge's equivalent of the three operations.
Do not hard-code one forge's REST calls as the only path; the mechanics are named by what they do
(reply to a thread, resolve a thread, stack a branch onto a named base), not by one vendor's API.

Compose the reply text for each thread with `engineering:writing-review-comments` rather than
drafting it inline — plain language, no performative agreement, no skill or process names.

**Resolving a thread is the user's call, per fixed ask.** When a comment has been fixed, do not
resolve its thread silently. Put it to the user as a structured choice, using a tool to ask it
where one is available, and in the prompt display
both **the full original comment** and **what was done** to address it, so the decision is made with
the whole picture in view. Resolve the thread only on an explicit yes; a comment pushed back on
rather than fixed stays open with the reasoning on its thread.

## 4. Hand to brainstorming

Once the comments are aggregated, verified, and impact-checked — and the two standing instructions
are written into the shaped context — hand it to the shared design dialogue: invoke
`engineering:brainstorming` now. Everything converges there; there is no gate at this seam. Approval
lives downstream — the spec gate in `to-spec`, the plan gate in `writing-plans` — never in this
entrance and never in brainstorming. Reporting the findings and asking whether to proceed is not a
move here: once the context is shaped and written into the run, invoke brainstorming.

If no review is in hand, ask the user for the PR, branch, or comments under review before
proceeding.
