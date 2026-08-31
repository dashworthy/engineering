# verity

Standalone **test-hardening** for Claude Code. Point it at a branch and it hardens the tests
around what changed — auditing coverage and mutation gaps, writing the missing tests, verifying
those tests actually catch regressions, and measuring the result against thresholds you set
fresh each run. It writes application code never; it writes and strengthens *tests*.

verity is the test-hardening discipline extracted from the `engineering` pipeline into its own
plugin, so it can be installed and evolve on its own. It does not depend on `engineering` at
runtime.

## Entry point

```
/harden [the branch or diff to harden — defaults to the current branch's diff]
```

`/harden` resolves the change, obtains a run directory, and hands off to the
`conducting-test-hardening` orchestrator, which drives the loop below.

## The skills

| Skill | Role |
|---|---|
| `conducting-test-hardening` | The orchestrator / phase entry point. Runs preflight, then the audit → merge → write → verify → measure loop, fanning out audit agents in parallel. |
| `auditing-test-gaps` | A dispatched beat: audits one suite/track for coverage and mutation gaps on the branch diff. |
| `verifying-test-integrity` | A dispatched beat: judges whether newly written tests actually test what they claim, structurally, without running the suite. |
| `writing-tests-from-brief` | A dispatched beat: writes tests satisfying brief items for one target test file, appending without altering existing cases. |

## The run record

Every run writes its briefs and audit trail under `.verity/<run>/test-hardening/` in the
project being hardened — never inside the plugin. Nothing is persisted between runs: verity
derives or asks for its configuration (baseline, suites, thresholds, cap) fresh every time.

## Layout

```
verity/
  .claude-plugin/plugin.json
  commands/harden.md
  skills/
    conducting-test-hardening/
    auditing-test-gaps/
    verifying-test-integrity/
    writing-tests-from-brief/
  scripts/run-context.sh
  tests/
```
