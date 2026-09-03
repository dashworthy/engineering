---
name: writing-pr-descriptions
description: "Write a pull-request body in plain language: what changed and why, any decisions made, any key data touched, and a pre-PR checklist that is actually verified, not just printed. Never names a skill or an internal process step. Use whenever a PR description is being written, including opening a pull request or landing a stack."
---

# Writing PR Descriptions

Say this first, plainly: `Using the writing-pr-descriptions skill to write the pull-request body in plain language.`

## What this guarantees

One thing: the body this skill produces reads the same to someone outside the team as to
someone on it — no jargon, no internal process names — and the checklist inside it reflects
things this skill actually checked, not boxes left unchecked for the reader to verify later.

## Plain language, not jargon

Write the summary the way you'd explain the change to a smart friend who has never seen this
codebase. A sentence fails this test if it assumes vocabulary the reader was never given —
a library name, a pattern name, an internal component nobody outside the team would recognize.
When a technical term is unavoidable (the name of a screen, a setting, a real product concept
the reader already has), keep it; cut everything else. Prefer "this now remembers what you
picked last time" over "this persists the last-selected filter to local storage."

If a sentence needs a technical term to be precise, say the plain-language version first and
the precise term after it in parentheses — never the reverse.

## Never name a skill or a process step

The PR body describes the change, not the process that produced it. Never write the name of a
skill, a phase, or an internal workflow term — no "per the code-review gate," no "after the TDD
loop," no "the design dialogue decided," no skill name at all, quoted or not. Say what changed
and why in terms of the product or the codebase, never in terms of the pipeline that built it.

## Never sign it

The body ends when the description does — no sign-off naming Claude, an AI, or any tool at all.
No "🤖" or other tool emoji, no "Generated with Claude Code" footer, no `Co-Authored-By: Claude`
trailer, no "Reviewed by," "Written by," or "Posted by" line naming a tool. The PR speaks for
the work, not for whatever helped write it. The exception is a project that has explicitly asked
for such attribution — its stated convention wins; absent that, leave it out.

## Run the checklist — verify, don't recite

Before writing the body, check each item below against the actual branch. An item that can be
checked mechanically gets checked mechanically; don't ask the user to confirm what a command
already answered.

- **Documentation** — does this change touch behavior, a setting, an API, or a flow that's
  documented somewhere? If so, confirm that doc was updated; if not, say so plainly rather than
  leaving it silently unchecked.
- **Clean-up finished** — no debug prints, commented-out code, stray `TODO`s left from the
  process, or scratch/temp files sitting in the diff. Check with `git status` and a scan of the
  diff, not by assumption.
- **Verified green** — defer to `engineering:verification-before-completion`'s evidence rather
  than re-running the suite here; confirm that evidence exists and is current for this branch's
  tip.
- **No secrets** — scan the diff for anything that looks like a credential, key, or token before
  it's checked off.
- **Diff matches intent** — the changed files are the ones the change actually needed; nothing
  unrelated rode along.

Only check an item once you've actually looked; an item you couldn't verify is reported as
**unverified**, with why, not silently checked.

## Structure of the PR body

1. **Title** — one plain-language line, no jargon.
2. **Summary** — two to five sentences: what changed and why, in plain language. This is the
   part someone outside the team reads to understand what happened.
3. **Decisions** (only if any were genuinely made) — a short bullet per decision: what was
   chosen and why, in plain terms. Omit this section entirely when there was nothing to decide;
   an empty or padded decisions section is worse than none.
4. **Key data** (only if the change adds or reshapes something the app stores or passes around)
   — plain-language description of what it holds and why it exists, not a schema dump. Omit
   when nothing changed here.
5. **Before merging** — the checklist from above, each line stating what was checked and what
   was found, not a bare checkbox.

## Where this is invoked from

`engineering:finishing-a-development-branch` calls this skill to compose the body for
**Open a pull request** and for each PR in **Land the stack**. It can also be invoked directly
whenever a PR description needs writing outside that flow.

## What this does not do

- It does not **decide whether to open a PR.** That choice belongs to
  `engineering:finishing-a-development-branch`; this skill only writes the body once the
  decision is made.
- It does not **run verification itself.** It relies on
  `engineering:verification-before-completion`'s evidence rather than re-executing the suite.
- It does not **fix what the checklist finds.** An unchecked or unverified item is reported
  back to the caller to address; this skill describes the branch, it doesn't change it.
