# Behavioral evals

_Stub — finalized in Task 6 with the full case list and the Task 1 findings._

These are **behavioral** evals: they run a model against a realistic prompt and check that the
`engineering` plugin makes it *behave* correctly. They complement — they do not replace — the
static `tests/` suite, which checks that the skill *files* are shaped right (frontmatter, prose
anchors) but never runs a model.

## Run

```
claude plugin eval . --trust-plugin --no-publish \
  --model claude-sonnet-5 --judge-model claude-haiku-4-5 \
  --allow-tools Bash Write Edit
```

Add `--case <name>` for one case, `--scaffold` for cases that need a fixture project, `--json
out.json` for machine-readable results. Runs are **local and manual** — there is no CI job.

## Pass bar

Each case runs **two-arm** (with the plugin and without it). A case passes when the **with-arm
mean ≥ 0.80** AND the **delta `(with − without) > 0`** on the scored graders — proving the
plugin, not the base model, produced the behavior.

## Case grammar

Each `evals/<case>/` has a `prompt.md` (a natural prompt that tempts the *wrong* behavior) and a
`graders/` trio. Two archetypes:

- **behavior-outcome** — `skill-fired` (`tool_used`, `arm: with-only`, out of the delta) +
  `outcome` (a behavioral signal — `tool_order`/`file_exists`/`regex`/`llm` — scored both arms) +
  `anti-behavior` (`arm: both`).
- **invocation-outcome** — the behavior *is* the invocation (routing, code-review, stacked-PR):
  `outcome` is `tool_used: Skill` for the right skill, scored both arms; the wrong-door/no-edit
  guard is the `anti-behavior`.

A case names its archetype in a comment atop its `prompt.md`.
