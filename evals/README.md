# Engineering pipeline evals

Behavioral eval suite for the `engineering` plugin, run with the native
`claude plugin eval` harness. Each case is a realistic prompt plus graders,
scored against a no-plugin baseline (two-arm ablation) so every number says what
the plugin *adds* over plain Claude.

## What it covers

Three groups, layered from cheap/objective to subtle/qualitative:

| Group | Cases | Measures |
| --- | --- | --- |
| **routing** | 6 | Does the right pipeline *entrance* fire for a request — feature/vague → `signal`, bug → `triage`, review feedback → `receiving-code-review` — and does nothing fire for a plain question? |
| **code-review** | 6 | Does `engineering:code-review` catch planted defects (security, correctness, efficiency, reuse, concurrency), stay report-only, and *not* manufacture findings on a clean diff? |
| **codebase-design** | 4 | Does `using-codebase-design` shape a deep/narrow interface from competing shapes (creation mode) and judge a sketched interface against SOLID/anti-patterns without redesigning it (review mode)? |

## How the scoring is wired

- **Routing** scores on *which skill fired*: the `fired-<entrance>` and
  `no-wrong-entrance` graders are `tool_used: Skill` with `arm: both`, so the
  baseline (no plugin, can't fire a skill) scores 0 and the plugin scores 1 —
  a clean delta. `min:0,max:0` graders assert an entrance must **not** fire.
- **code-review** scores on *review quality*, not just that the skill fired:
  the `fired-code-review` grader is a `with-only` indicator (unscored), and the
  scored graders are an `llm` recall check (does the report name the planted
  defect?) plus a report-only guard (`tool_used: Edit, min:0,max:0`). The
  `cr-clean-control` case inverts recall into a false-positive check.
- **codebase-design** scores design quality/restraint with `llm` graders over
  the `trace` (so the judge sees the reasoning, not just the last message).

## Fixtures are Bash-free for the agent

The agent under test is **not** granted `Bash`: on some machines the Bash
sandbox refuses to start (e.g. a symlink in `~/.docker`), which would block
every case. Instead each `scaffold.sh` runs *unsandboxed, as you* (only with
`--scaffold`): it builds a git repo and captures the change under review as a
`CHANGE.diff` the agent **reads**. The review is faithful without the agent
needing git/Bash of its own.

## Running

Run the suite **per group, at `-j 1`** — routing, code-review, and
codebase-design each as their own pass — never all 16 cases together at `-j 4`.
The code-review cases fan out sub-reviewers, so each one spawns nested agent
sessions; run in parallel across the whole suite, those nested sessions multiply
concurrent usage past the account quota ceiling and cases start erroring on the
session limit rather than failing on their merits. One group at a time, one
concurrent run, keeps usage under that ceiling.

```bash
# Each group as its own pass, one at a time (the batch discipline):
claude plugin eval . --case "routing-*"        --runs 1 --trust-plugin --scaffold -j 1
claude plugin eval . --case "cr-*"             --runs 1 --trust-plugin --scaffold --allow-tools Write Edit -j 1
claude plugin eval . --case "cd-*"             --runs 1 --trust-plugin --scaffold -j 1

# One case, keep the sandbox for debugging:
claude plugin eval . --case cr-reuse-reinvent --runs 1 --trust-plugin \
  --scaffold --allow-tools Write Edit --keep-temp
```

Notes:
- Run **per group at `-j 1`**, not the whole suite at once — see above.
- `--scaffold` runs author-supplied bash; only ever pass it on a suite you trust.
- `--allow-tools Write Edit` lets the report-only / no-implementation guards be
  real tests (the skill *could* edit but must not). Do **not** add `Bash`.
- Default threshold is 1.0; a case passes when its with-arm mean clears it.

## A note on baselines

Plain Claude is strong, so *easy* cases show Δ≈0 (baseline catches an obvious
SQL injection too). The suite earns its keep on cases where the plugin's
discipline matters: routing (baseline has no entrances), the reuse-miss (needs
codebase awareness), the clean-control (false-positive restraint), and the
subtle correctness/concurrency bugs. Read the deltas per case, not just the
pass rate.

## Case inventory

```
routing-feature-signal      feature request      -> signal
routing-vague-signal        vague ask            -> signal
routing-bug-triage          reported defect      -> triage
routing-review-feedback     incoming review      -> receiving-code-review
routing-review-disagree     skeptical of review  -> receiving-code-review (trap: not triage)
routing-plain-question-none conceptual question  -> no entrance fires

cr-security-sqli            SQL injection (PHP)
cr-correctness-subtle       off-by-one date loop (TS)
cr-efficiency-nplus1        N+1 hidden behind a helper (Python)
cr-reuse-reinvent           reinvents the repo's BackoffRetry (PHP)
cr-concurrency-race         check-then-act TOCTOU double-booking (PHP)
cr-clean-control            clean diff — no defect to find (PHP)

cd-design-boundary          shape a notifications interface (creation mode)
cd-design-tenancy           shape a multi-tenant store (creation mode)
cd-review-shape             judge a smelly interface (review mode)
cd-review-nofix             review without redesigning (review mode)
```
