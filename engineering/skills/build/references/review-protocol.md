# Review protocol (reference)

Reviews a change on two axes — Standards (meets engineering norms) and Spec (does what was asked) —
via parallel sub-reviewers, at a per-task gate and again in a whole-branch pass. A deeper, opt-in
review is guardtower's job, not this.

## What this guarantees

One thing: given a change — a diff, a branch, a PR, whatever the caller points at — this
skill reviews it on two separate axes and returns findings organized by which axis raised
each one, produced by independent sub-reviewers dispatched in parallel and reconciled into a
single report. When a spec exists the change is checked against it; when none does, that gap
is stated in the report rather than quietly skipped.

## The two axes

**Standards** asks whether the code is good on its own terms, spec or no spec: is it
correct, is it clear to the next person who opens the file, does it carry tests that would
actually catch a regression, does it avoid the security mistakes that show up over and over
(unvalidated input, secrets in the wrong place, an authorization check that's assumed rather
than enforced), and does it follow the conventions already established around it rather than
inventing a local dialect. A change can be Standards-clean and still be the wrong change —
that's what the second axis is for.

**Spec** asks a narrower, sharper question: does this change do what was actually asked,
against the approved spec if one exists, or against the request as the person making it
actually stated it when none does. A Spec finding is never "this could be written better" —
that's a Standards finding wearing a disguise. A Spec finding is "the spec says X and the
change does Y," or "nothing on record says this scope was in bounds."

Keep the two separate in the report. A caller reading only the Standards findings should be
able to trust that nothing about scope or intent is hiding in them, and the reverse.

## Where the Spec axis looks

The Spec axis needs something concrete to check the change against, not a recollection of
what the conversation probably meant. It looks in one place first: the active run's spec dir,
`.engineering/<run>/spec/` (resolved from `.engineering/.current-run`),
for whichever document plausibly governs the change under review — matched by feature area
and, when more than one candidate fits, by recency. A path handed to this skill directly
overrides the directory search outright and is never second-guessed against what the scan
would have picked.

When neither turns anything up — the directory has nothing that fits, or the caller supplied
no path and none exists — the Spec axis has no document to check against, and this skill does
not go looking elsewhere to fill the gap. It reviews Standards-only and says so plainly, as a
complete outcome: a change with nothing filed for it still gets the full Standards review it's
owed, labeled as missing the second axis.

## Dispatching the sub-reviewers

The two axes are looked at by two different reviewers, not one reviewer switching hats
partway through — a single pass that tries to hold "is this good code" and "is this the
right code" in mind at once tends to let the louder question crowd out the quieter one.

**There is a floor, though.** On a small diff — a single file, roughly twenty changed lines or
fewer, one hunk — two subagent spin-ups plus a reconcile cost more than the review itself does.
Below that floor, look at both axes yourself inline and skip the fan-out; both still get their
full review, just in one pass. Above it, fan out:

Dispatch at least one sub-reviewer per axis, in parallel, following `using-parallel-agents`
for how the fan-out and the return are structured — that skill owns the mechanics; this skill
supplies the split itself, plus what each sub-reviewer needs: the diff and the matched spec
document (or the plain statement that none was found).

Each sub-reviewer returns findings scoped to its own axis and nothing else — a Standards
reviewer that notices a scope problem hands it back as a Spec-shaped observation rather than
folding it into its own findings, and vice versa. Reconciling the two returns into one
report — no duplicate findings, no axis silently dropped because its sub-reviewer came back
empty — is this skill's job, not something pushed downstream.

## What this does not do

- It does not **fix what it finds.** A finding on either axis is a statement of what's wrong
  and why, handed back to whoever asked for the review. Applying the fix, deciding whether
  to apply it at all, and deciding whether a finding is worth blocking on belong to the
  caller, not to this skill.
- It does not **write the spec it's missing.** When the Spec axis comes up empty, that's the
  end of this skill's involvement with the gap — it reports Standards-only and stops. Getting
  a spec written, if one is warranted, is a separate decision made by someone else, not a step
  this skill takes on the review's behalf.
- It does not **decide when a review happens.** Something else — a person, or whatever is
  driving a larger piece of work — decides a change is ready and calls this skill at that
  moment. It does not watch for changes on its own or insist on being run.
- It does not **stand in for sign-off.** A clean report on both axes is information a human
  or a downstream process uses to decide whether to proceed, not a merge switch this skill
  throws itself.
