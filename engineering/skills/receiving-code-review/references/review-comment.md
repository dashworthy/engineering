# Writing Review Comments (reference)

> This is a reference the `receiving-code-review` conductor loads when it writes reply text for a
> review thread. It is not a skill and is never discovered on its own; the conductor drives it.

## What this guarantees

One thing: every comment or reply this skill writes reads in plain language a reviewer outside
the team could follow, states what actually happened without performative agreement, and never
names a skill or an internal process step.

## Plain language, not jargon

Write the way you'd explain it to the person who left the comment, assuming they don't know the
codebase's internal names for things. A sentence fails this test if it leans on vocabulary the
reader was never given — a pattern name, an internal component, a library detail that doesn't
matter to what they asked. Say what changed in terms of behavior they can check, not in terms of
the code's internals.

## No performative agreement

Never open with "You're absolutely right," "Great catch," "Good point," or any variant. The
acknowledgment that a comment was correct is the fix itself, shown in the diff — say what
changed, not that the commenter was right to ask for it.

## Three shapes, pick the one that's true

- **Confirmed and fixed** — say plainly what changed and where, in terms the commenter can
  verify without reading code: "This now does X" rather than "Updated the handler." Point at the
  specific change, not a vague "addressed."
- **Pushed back** — when the comment doesn't hold up here, say plainly why, with the actual
  reasoning — what would break, or why the current behavior is intentional. Non-performative:
  state the reasoning, not a soft cushion around disagreeing.
- **Asked** — when what to do genuinely isn't clear, ask the specific question plainly, in terms
  the commenter can answer without first learning the codebase.

## Never name a skill or a process step

The comment describes the change or the reasoning, not the process that produced it. No "per
the code-review gate," no "after running TDD," no "the receiving-code-review skill flagged
this," no skill name at all, quoted or not.

## Never sign it

The comment ends when the point does — the same "Never sign it" policy
`finish/references/pr-description.md` states in full: no sign-off naming Claude, an AI, or any
tool at all, no exception absent a project that has explicitly asked for it. The comment reads
exactly like a person on the team wrote it and stopped when they were done.

## Where this is loaded from

The `receiving-code-review` conductor loads this reference to write the reply text for each
thread's forge tail (`Reply to each ask` in that conductor).

## What this does not do

- It does not **decide whether a comment is correct.** The `receiving-code-review` conductor
  verifies each claim against the codebase before this reference is ever loaded; this only phrases
  what was already decided.
- It does not **decide whether to resolve a thread.** That stays the user's call, per the
  `receiving-code-review` conductor; this reference only supplies the reply text.
- It does not **write the fix.** It describes a fix, a pushback, or a question in plain language;
  the fix itself happens elsewhere.
