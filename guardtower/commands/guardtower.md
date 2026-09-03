---
description: Run guardtower's in-depth, opt-in review of a change through a menu of specialized facets, reported to .guardtower/ (read-only; never edits code).
argument-hint: the change to review (a diff, branch, PR, or path) — defaults to the current branch's diff
---

# guardtower

Run guardtower's deep, opt-in review over the change described below. This is the heavier
escalation, run deliberately — not the everyday pass. It is **read-only**: it reports findings and
never edits code, so there is no workspace to isolate.

Steps:

1. **Resolve the change.** If `$ARGUMENTS` names a diff, branch, PR, or path, that is the review
   target; otherwise default to the current branch's diff against its base. Establish this
   `change_ref` once — every facet reviews the same one.

2. **Obtain the run directory.** The reviewing skill writes each facet's record under
   `.guardtower/<run>/<facet>/`; resolve that run directory with
   `sh "${CLAUDE_PLUGIN_ROOT}/scripts/run-context.sh" <facet-skill>` (it creates `.guardtower/<run>/`
   and joins an active run if one exists).

3. **Hand off to the reviewing orchestrator.** Invoke `guardtower:reviewing` with the resolved
   change. It presents the facet menu (the four core facets pre-checked), dispatches the selected
   facets as self-limiting reviewers, and reconciles their findings into one report alongside the
   durable per-facet artifacts.

Do not fix what the review finds — guardtower reports; applying the findings is a separate,
human-decided step (engineering's `receiving-code-review` is a natural downstream).

Change to review: $ARGUMENTS

If no change was given above and no branch diff is resolvable, ask what change to review before
proceeding.
