# 0001. Derive or ask verity's configuration fresh each run; persist none of it

## Status

Accepted

## Context

Every run, verity (`engineering:conducting-test-hardening`) needs a set of facts about the
project it is hardening: the baseline branch to diff against, the stack (which test suites
exist, the command that runs each one, the command that emits coverage or mutation, and which
paths count as application code versus tests), the diff scope, the coverage and mutation
thresholds to gate on, and an iteration cap.

An earlier design of verity persisted these facts between runs — a config file, a shell
library, and a session-start hook that carried the suites, paths, commands, thresholds, and
loop limit forward so they would not have to be re-derived each time. That persisted layer
drifted out of sync with the projects it described, and that drift was the source of most of
verity's defects: a run would harden against a suite list that no longer matched, a path that
had moved, a command that no longer existed, or a threshold nobody had re-examined — and report
a confident result built on stale inputs.

The forces in tension: the convenience of not re-asking the same questions every run, against
the correctness of matching the project as it actually is at the moment the run happens.

## Decision

Persist no verity configuration. Everything verity needs is derived from git and the project
itself, or asked of the user, fresh on every run. No config file, shell library, or
session-start hook records suites, paths, commands, thresholds, or a loop limit between runs.

## Consequences

- Configuration can never go stale: every run reflects the project as it currently is, which
  removes the entire class of defects the persisted layer produced.
- The skill body states only the operative rule ("Ask, don't configure") and its present-tense
  rationale; the history of why the rule exists lives here, in this ADR, rather than in the
  skill.
- The cost: the user answers the same preflight questions (baseline, any stack gaps, thresholds,
  cap) on every run, and detection work is repeated each run rather than cached. There is no
  place to record a standing preference between runs — by design.
