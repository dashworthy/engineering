---
description: Harden the tests around a change — audit coverage and mutation gaps, write the missing tests, verify they catch regressions, and measure against thresholds, reported under .verity/. Writes tests only; never edits application code.
argument-hint: the branch or diff to harden — defaults to the current branch's diff against its base
---

# harden

Run verity's test-hardening over the change described below. This **writes and strengthens
tests**; per the Iron Rule it never modifies application code, and it halts and hands the
decision back to you when code looks wrong.

Steps:

1. **Resolve the change.** If `$ARGUMENTS` names a branch, diff, or path, that is the target;
   otherwise default to the current branch's diff against its base. Because hardening writes
   tests into the suite, it operates on the target branch **in place** — it does not spin up a
   separate worktree; run it on the branch you want the new tests committed to.

2. **Obtain the run directory.** conducting-test-hardening writes this run's briefs and audit
   trail under `.verity/<run>/test-hardening/`; resolve that run directory with
   `sh "${CLAUDE_PLUGIN_ROOT}/scripts/run-context.sh" test-hardening` (it creates `.verity/<run>/`
   and joins an active run if one exists).

3. **Hand off to the orchestrator.** Invoke `verity:conducting-test-hardening` on the resolved
   change. It runs preflight (baseline, stack detection, diff scope, thresholds, iteration cap),
   then the audit → merge → write → verify → measure loop, fanning out `auditing-test-gaps`
   agents in parallel and halting on any breakage finding.

Change to harden: $ARGUMENTS

If no change was given above and no branch diff is resolvable, ask what to harden before
proceeding.
