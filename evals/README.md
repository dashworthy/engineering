# Behavioral evals

These are **behavioral** evals: they run a model against a realistic prompt and check that the
`engineering` plugin makes it *behave* correctly. They complement — they do not replace — the
static `tests/` suite, which checks that the skill *files* are shaped right (frontmatter, prose
anchors) but never runs a model.

## Run

```
claude plugin eval . --trust-plugin --no-publish \
  --model claude-sonnet-5 --judge-model claude-haiku-4-5 \
  --allow-tools Write Edit --scaffold
```

- `--case <name>` runs one case; omit to run all.
- `--scaffold` is required for cases with a `scaffold.sh` (`code-review-no-edits`); it runs that
  script as you to seed the working dir.
- `--json out.json` writes machine-readable results.
- Runs are **local and manual** — there is no CI job (a deliberate choice this run).

**Do not grant `Bash`** on this machine: a symlink in `~/.docker` defeats the eval's OS sandbox,
so a `Bash`-granting run aborts. All shipped cases work with `Write Edit` only.

**Do not run these in a git worktree.** A worktree-isolated session hard-blocks the `eval`
subcommand. Run from a normal checkout.

## Pass bar

Each case runs **two-arm** (with the plugin and without it). A case passes when the **with-arm
mean ≥ 0.80** AND the **delta `(with − without) > 0`** on the scored graders — proving the
plugin, not the base model, produced the behavior.

## Cases

Every shipped case is **invocation-outcome**: the behavior proven is that the plugin reaches a
distinctive skill the base model has no access to. All five discriminate at **with 1.0 / without
0.5 / delta +0.5**.

| Case | Proves | Scaffold |
|---|---|---|
| `routing-defect` | a reported defect routes through `triage` (not `signal`) | — |
| `routing-feature` | a vague feature ask routes through `signal` (not `triage`) | — |
| `code-review-no-edits` | `engineering:code-review` fires and edits no source | `report.py` (buggy) |
| `stacked-pr` | `using-stacked-pull-requests` fires for a dependent stack | — |
| `documenting-judgment` | `documenting`/`using-documentation` fires for a user-visible change | — |

## Case grammar

Each `evals/<case>/` has a `prompt.md` (a natural prompt that tempts the *wrong* behavior) and a
`graders/` trio, plus an optional `case.yaml` + `scaffold.sh`. Two archetypes:

- **invocation-outcome** (all shipped cases) — the behavior *is* the invocation: `outcome` is
  `tool_used: Skill` for the right skill, scored both arms; the without-plugin arm can't fire it,
  so the delta is the proof. An `anti-behavior` (`arm: both`) guards the wrong door / a broken
  contract.
- **behavior-outcome** — `skill-fired` (`tool_used`, `arm: with-only`, out of the delta) +
  `outcome` (a behavioral signal: `tool_order`/`file_exists`/`regex`/`llm`, scored both arms) +
  `anti-behavior`. See "What this suite can't isolate" for why none shipped.

A case names its archetype in a comment atop its `prompt.md`.

## Two mechanics that matter (learned the hard way)

1. **Namespace a skill that collides with a base skill.** Some engineering skills share a name
   with a built-in (`code-review`, `brainstorming`, `receiving-code-review`,
   `test-driven-development`, `writing-plans`, …). For those, the `outcome` grader must match
   `"skill":\s*"engineering:<name>"` exactly — a bare `(?:[\w-]+:)?<name>` pattern also matches
   the *base* skill, which the without-plugin arm can fire, collapsing the delta. Engineering-only
   skills (`signal`, `triage`, `spec`, `plan`, `build`, `documenting`,
   `using-stacked-pull-requests`, …) are safe with the optional-namespace pattern.
2. **`tool_used: Skill` graders with `arm: both` DO score and carry the delta.** They are only
   treated as a non-scored "plugin-fired indicator" when marked `arm: with-only`.

## What this suite can't isolate (the finding)

The plugin's **discipline** behaviors — the spec/plan approval gates holding, refusing to defer
work, strict test-before-code TDD order, a review lens catching a planted defect — could not be
turned into a discriminating two-arm eval here, for two compounding structural reasons:

1. **The frontier base model already has the discipline.** Told to "just build it now" or "just
   leave a TODO and ship it," `claude-sonnet-5` *without the plugin* mostly declines to misbehave
   on its own. Careful adversarial cases (`spec-gate-holds`, `refusing-deferral` — each with a
   scaffold and explicit pressure) both scored **delta 0**: the without-plugin arm did the right
   thing too.
2. **The discipline lives behind an interactive pipeline unreachable in a solo eval.** TDD lives
   inside `build`, gated behind spec→plan→build; a cold prompt routes to `signal` and stops at the
   first (unanswerable) interrogation question. Reaching `build`/`plan` needs a faked run context,
   and forcing the base arm to fail needs leading/coercive prompts — which inflate the delta
   dishonestly, exactly what a fair eval forbids.

So the discipline behaviors are **not shipped as green cases** (a delta-0 case is not proof), and
were **not faked** with coercive prompts. They remain guarded by the static `tests/` suite's
gate-and-discipline prose anchors. Isolating them behaviorally would need a different harness —
one that can drive the interactive pipeline turn by turn, or grade against a weaker base model.

Depth (more cases per phase) grows over time; this is the skeleton.
