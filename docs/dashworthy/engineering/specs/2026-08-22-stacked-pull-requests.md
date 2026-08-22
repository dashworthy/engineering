# Stacked pull requests — spec

**Date:** 2026-08-22
**Author:** Andrew Leach
**Status:** Approved
**Origin:** brainstorming (design dialogue)

## 1. Problem

The engineering pipeline currently produces one branch per plan: each task adds a
commit, and the whole branch is integrated once at the end through
`finishing-a-development-branch`, which offers a single merge / PR / cleanup choice. Review
therefore lands as one large pull request covering every task, even though the plan already
decomposed the work into independently testable, independently committable tasks. Reviewers
lose the task boundaries the plan worked to establish, and a change late in the plan cannot
be reviewed or merged until everything before it is also ready.

A stacked-pull-request workflow restores those boundaries at review time: each task becomes
its own pull request, stacked on the task before it, so each unit is reviewed and landed on
its own while still respecting the order the plan encodes.

## 2. Users & stakeholders

- **Plugin users** running the engineering pipeline who want per-task review instead of one
  large PR. They decide, per plan, whether to use stacked PRs.
- **Reviewers** of the resulting PRs, who get task-sized units with the plan's boundaries
  intact.
- **Decision owner:** the plugin author (Andrew Leach).

## 3. Goals & success criteria

- A new skill `engineering:using-stacked-pull-requests` exists, passes the plugin's
  frontmatter validation with the `[Foundation]` group tag, and follows the house SKILL.md
  shape (Say-this-first / What this guarantees / body / What this does not do).
- The skill covers the full stacked-PR lifecycle: detect tool, branch-and-base model, start
  a task's branch, submit a task's PR, keep the stack current (restack), land the stack in
  order.
- The skill is tool-agnostic: it uses `gt` (Graphite) when the repo already has it, and
  falls back to plain `git` + `gh` otherwise — no hard dependency on `gt`.
- `writing-plans` can mark a plan as stacked, records `PR strategy: stacked` in the plan's
  Global Constraints, and emits per-task branch-start and PR-submit steps for stacked plans
  only. Non-stacked plans are unchanged.
- `executing-plans` reads the strategy, runs stacked plans sequentially (no parallel
  subagent fan-out), and honors the branch-start / PR-submit steps the plan carries.
- `finishing-a-development-branch` detects a stacked run and offers "Land the stack"
  (delegating to the new skill) in place of the single "Open a pull request" option.
- `skills/README.md` lists the new skill under Foundation.
- Every existing test in `engineering/tests/` still passes; the new skill's frontmatter is
  covered by `frontmatter.sh`.

## 4. Constraints

- **House style.** The new skill and all edits follow the existing SKILL.md shape and voice
  already used across the plugin; no new document conventions.
- **Frontmatter.** `name` must equal the skill directory name; `description` must open with
  `[Foundation]` (enforced by `tests/frontmatter.sh`).
- **Skill placement.** Skills live flat, one level under `engineering/skills/`; the loader
  scans one level deep.
- **No hard external dependency.** `gt` is used when present, never required; `gh` is the
  baseline and is already implied by `finishing-a-development-branch`.
- **No `plugin.json` change.** It does not enumerate skills.
- **Portability.** The skill must work in an arbitrary user repo; it cannot assume `gt` is
  installed or that the repo is `gt`-initialized.
- **Non-stacked stays the default.** Stacked mode is opt-in per plan; the current
  single-PR-at-end behavior is unchanged when the strategy is not set.
- **Paths.** Specs at `docs/dashworthy/engineering/specs/`, plans at
  `docs/dashworthy/engineering/plans/`, per the existing pipeline.

## 5. Scope

**In:**
- New skill `engineering/skills/using-stacked-pull-requests/SKILL.md`.
- Edits to `writing-plans` (opt-in header, per-task steps, sequential-only note, hardening
  task on the stack).
- Edits to `executing-plans` (read strategy, force sequential, honor per-task PR steps).
- Edits to `finishing-a-development-branch` (detect stacked, "Land the stack" option).
- `skills/README.md` Foundation row update.

**Out (non-goals):**
- `spr` / `ghstack` (commit-rewriting tools) — rejected; fight the worktree + exact-commit
  model.
- Parallel + stacked in the same plan — rejected; the two are mutually exclusive per plan.
- Issue-tracker integration — the plugin is file-based by design.
- A slash command for the skill — it is model-invoked, like `using-git-worktrees`.

**Deferred:**
- Parallel stacking (fan / linearize a parallel batch into a stack). Revived if users find
  the sequential-only constraint on stacked plans too limiting.
- Adding Foundation skills to the `suite.sh` frontmatter loop. Revived if Foundation
  frontmatter coverage is wanted (current precedent omits them).

## 6. Approach (from the design dialogue)

Four decisions were settled in the design dialogue; the decision table below carries them
verbatim into planning.

| # | Decision | Chosen | Rejected alternatives |
|---|----------|--------|-----------------------|
| D1 | Stacking mechanism | Tool-agnostic: `git` + `gh` baseline, use `gt` when the repo already has it (mirrors `using-git-worktrees`' prefer-better-else-fallback) | Graphite-only (hard dep); git+gh-only (no auto-restack); spr/ghstack (rewrite history) |
| D2 | Skill scope | Full lifecycle — create per task, restack, land the stack in order; `finishing-a-development-branch` delegates landing here, retiring its single-PR option | Create-only (landing left undocumented); create+restack (landing a loose end) |
| D3 | Parallel-mode collision | Mutually exclusive per plan — a stacked plan runs sequentially; parallelism requires a non-stacked plan | Linearize parallel batch into stack (re-parenting mess); fan of siblings (complex on gh) |
| D4 | How a plan becomes stacked | Opt-in, recorded as `PR strategy: stacked` in the plan's Global Constraints; `executing-plans` and `finishing-a-development-branch` read it there | Always stacked (forces host integration on every plan); decided at `/implement` time (conflicts with writing-plans emitting the step) |

**Branch and base model.** One branch per task, all inside the single worktree
`using-git-worktrees` created — the skill switches branches, it does not spawn a worktree
per task. Task 1 branches off trunk; task N branches off task N-1's branch. A PR's base is
its parent branch. Branch naming: `<topic>/<NN>-<task-slug>`.

**Where branch and PR steps sit in a task.** In stacked mode, `writing-plans` opens each
task with a step that starts the task's branch off the previous task's branch (so the TDD
commits land on the right branch) and closes the task, after the commit step, with a step
that submits the stacked PR via `engineering:using-stacked-pull-requests`. `executing-plans`
runs these as ordinary plan steps; it adds no PR logic of its own beyond honoring them and
forcing sequential execution.

**Hardening task on the stack.** The closing Phase 3.5 hardening task, in a stacked plan,
goes up as the top-of-stack PR like any other task — its own branch, its own PR.

**Landing.** `finishing-a-development-branch`, when it detects a stacked run, replaces its
"Open a pull request" option with "Land the stack," which delegates to the new skill:
merge bottom-up in order, restacking the remainder after each merge. Merge-direct and
cleanup remain available where the project allows them.

## 7. Existing context

- `engineering/skills/writing-plans/SKILL.md` — task shape, Global Constraints,
  closing hardening task, plan sets.
- `engineering/skills/executing-plans/SKILL.md` — per-task loop, checkpoints,
  subagent-driven parallel mode, closing hardening (D15).
- `engineering/skills/finishing-a-development-branch/SKILL.md` — merge / PR / cleanup
  options, verity safety net.
- `engineering/skills/using-git-worktrees/SKILL.md` — the prefer-native-tool-else-fallback
  pattern the new skill mirrors; establishes the single worktree the stack lives in.
- `engineering/skills/README.md` — the by-group skill index (Foundation row).
- `engineering/tests/frontmatter.sh`, `engineering/tests/suite.sh` — validation surface.

## 8. Open questions

None blocking. (Deferred items are recorded in §5.)
