---
description: Compact this conversation into a handoff document for the next session, written to the OS temp directory.
argument-hint: "What will the next session be used for?"
---

# handoff

Write a handoff document for whoever picks this work up next — a fresh session for you,
or a different person on the team. $ARGUMENTS says what that next session will be used
for; open the document by restating it in your own words, so the reader knows this was
written with that goal in mind.

## Where it goes

Write to a file in the OS temp directory, not the repository. A handoff bridges two
sessions of the same work; it is not a project artifact, and it should never show up in
`git status`, get reviewed, or outlive the session it was written for. Name the file so
it says what it is and when it was made (something like
`handoff-<slug>-<timestamp>.md`), and once it's written, tell the user the exact path —
the file has no other way of being found.

## What to compact

Read back over the conversation and reduce it to what a cold-start reader actually
needs:

- The goal this session was working toward, and how far it got.
- Decisions made along the way, and why — the landing, not the discussion that produced
  it.
- Open threads: what's unresolved, what's blocked, and what was deferred — but read the
  next section before you write the word "deferred" anywhere.
- The concrete next step — the first thing the next session should do, not a survey of
  everything that could be done.

## A handoff never decides that anything is deferred

This is an absolute rule, not a guideline, and it has no exceptions. The handoff step has
**zero authority** to classify anything as deferred, parked, or out of scope. It may only
*record* a deferral the user has already opted into through an explicit `AskUserQuestion`
prompt. Nothing else grants that status.

The single gate for writing "deferred" — or "parked," "for later," "out of scope,"
"separate change," or any synonym — about any item:

> The user was shown that specific item in an `AskUserQuestion` prompt and chose to defer
> it, and you can point to that prompt.

If that gate is not met, you may not mark the item deferred. Not because "it obviously is
a separate concern," not because "the user implied it," not because "it came up and nobody
pursued it," not because "it's out of scope for this piece of work." Every one of those is
*you* deciding to defer — and deciding to defer is the one act this step is forbidden to
perform. You do not have the authority; only an `AskUserQuestion` opt-in does.

So, for any adjacent or unresolved item you are tempted to park:

- **Ask, then record.** Put it to the user with `AskUserQuestion` (in scope / defer / drop)
  before you finish the handoff, and record their actual answer. This is the *only* route
  to a "deferred" label.
- **Or leave it open.** If you do not ask, record it as an **open question the reader still
  owes an answer on** — plainly not decided, not deferred, not out of scope. An open
  question is honest; a "deferral" the user never made is a fabricated decision.

There is no "Explicitly out of scope" section, no parking lot, populated by your own
judgment — it does not exist in a handoff. An unresolved thread is an open question. Label
it as one.

Do not restate material that already lives somewhere durable. If this session touched a
document under `.engineering/<run>/spec/` or `.engineering/<run>/plan/`,
point at that path instead of copying its contents. The
handoff's job is to say what changed and what's left, not to duplicate a document that
already says what's true.

## Redact secrets

Before writing the file, scan everything you are about to include for anything that
looks like a credential, API key, token, password, or a URL carrying embedded auth —
whether it surfaced in code, in command output, or in pasted text during the
conversation. Redact it: swap the value for a placeholder such as `[REDACTED]`, and,
where it helps the reader, note what kind of secret it was so the next session knows
something was removed rather than simply missing. Never write a live secret into a file
in the temp directory — it is not a secure location, and the entire point of this
command is a handoff that's safe to read later without re-exposing anything.

## Suggested skills

Close with a **suggested-skills** section: a short list of `engineering:` skills the
next session will likely need, given where this one left off, each with one line on why.
Name them by their real skill id — for example `engineering:writing-plans` if a spec
exists but no plan has been produced from it yet, `engineering:executing-plans` if a
plan exists and the next step is to run it, or `engineering:finishing-a-development-branch`
if the work is implemented and green and the next step is to integrate the branch. Only
suggest a skill that genuinely fits what this session did; a short, accurate list is more
useful than an exhaustive one.

If no argument was given, ask what the next session will be used for before writing
anything — the handoff reads differently depending on whether the next session
continues this exact work, hands it to someone else, or starts something adjacent to
it.
