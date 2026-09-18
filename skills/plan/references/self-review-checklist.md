# Plan self-review checklist

Run this over the plan just written, before the arch-lens review and the plan gate. It checks the
plan *as a document* — coverage, placeholders, consistency — not its design (that is the arch-lens
review's job).

- **Spec coverage.** Walk the spec's goals, constraints, and decision table entries one by
  one and confirm each has a task that addresses it. An item with no task behind it is
  either forgotten or genuinely out of scope for this plan — decide which, and if it's the
  former, add the task rather than note the gap and move on. "Genuinely out of scope" is a
  decision, not a shrug: record it where the human sees it — the spec's Deferred bucket or an
  open question — never drop it silently. Anything less is the punt `engineering:refusing-deferral`
  refuses.
- **No deferred request.** Section-by-section coverage can still miss the subtler drop: a piece of
  work the user actually asked for that ended up *neither* a task *nor* a deferral the spec
  recorded on purpose — just absent, because the plan grew long or the item was awkward to place.
  Requested work has two honest fates in a plan and only two: a task that builds it, or a deferral
  the approved spec already carries (its Deferred bucket, an open question) with the trigger that
  revives it. A third fate — silently gone — is the punt `engineering:refusing-deferral` refuses;
  a plan that drops requested work looks finished and isn't. Restore each missing one as a task.
- **Placeholder scan.** Search the finished plan for anything a task author would have to
  guess at — `TBD`, `...`, "the appropriate file," a step with no file path, a verification
  with nothing to run. A plan with a placeholder in it isn't a draft of a finished plan;
  it's an unfinished one that looks done at a glance.
- **Type consistency.** Confirm every task follows the same shape — a Files block, an
  Interfaces block where the task has one, numbered steps, a closing verification command
  — and that steps describing the same kind of thing (a test, a command, a commit) are
  phrased the same way throughout. A plan that shifts format halfway through reads as two
  plans stitched together, and whoever executes it has to re-learn the pattern partway in.
- **Stacked-PR structure.** Every plan ships as a stack (see PR strategy), and the plan is
  where that structure has to be *in the document* — not left for whoever builds it to
  reconstruct. Confirm all of: the Global Constraints carry the
  `PR strategy: stacked (one PR per task, via engineering:using-stacked-pull-requests)` line;
  **every** task opens with a step that starts its own branch off the previous task's branch —
  the first task off the trunk, since it has no previous — before any of the task's commits;
  and **every** task closes, after its commit, with a step that submits its stacked PR via
  `engineering:using-stacked-pull-requests`. A task missing its branch-start step lands its
  commits on the parent branch and collapses two tasks into one PR; a task missing its
  submit step is a task with no PR of its own. Both are the plan failing to break the work
  up, not the builder's mistake — a task per PR only holds if the plan gave every task both
  ends. Where a step is missing, add it rather than note the gap.
