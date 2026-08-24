# Stacked pull requests — implementation plan

> **For agentic workers:** execute this plan with `engineering:executing-plans` (via
> `/implement`), task by task — each behavior step driven through `engineering:tdd`, gated by
> `engineering:code-review`, pausing at checkpoints, and closing with the Phase 3.5 hardening
> task that invokes `engineering:conducting-test-hardening`. Steps use `- [ ]` checkboxes.

**Goal:** Add opt-in stacked-pull-request support to the engineering pipeline: a new
`using-stacked-pull-requests` skill plus wiring in `writing-plans`, `executing-plans`, and
`finishing-a-development-branch`, so each task in a stacked plan becomes its own PR stacked
on the one before it.

**Architecture:** One new `[Foundation]` skill owns the whole stacked-PR lifecycle
(tool-agnostic: `gt` when the repo has it, else `git`+`gh`). `writing-plans` records
`PR strategy: stacked` in a plan's Global Constraints and emits per-task branch-start /
PR-submit steps. `executing-plans` reads that strategy, runs stacked plans sequentially, and
honors those steps. `finishing-a-development-branch` detects a stacked run and offers "Land
the stack," delegating to the new skill. A new `tests/stacked-prs.sh` pins the required
content of every touched file via `grep_flat` anchors, in the plugin's existing prose-test
idiom.

**Tech Stack:** POSIX sh + python3 (stdlib) for tests, Markdown SKILL.md documents, `git` /
`gh` / optional `gt`. No new runtime dependency; `plugin.json` unchanged.

**Spec:** `docs/dashworthy/engineering/specs/2026-08-22-stacked-pull-requests.md` (Approved).

## Global Constraints

Copied verbatim from the spec's §4 Constraints and §6 decision table. Every task's
requirements implicitly include this section.

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
  `docs/dashworthy/engineering/plans/`.

**Decision table (from the design dialogue):**

| # | Decision | Chosen | Rejected |
|---|----------|--------|----------|
| D1 | Stacking mechanism | Tool-agnostic: `git`+`gh` baseline, `gt` when repo has it | Graphite-only; git+gh-only; spr/ghstack |
| D2 | Skill scope | Full lifecycle; `finishing` delegates landing here, retiring its single-PR option | Create-only; create+restack |
| D3 | Parallel-mode collision | Mutually exclusive per plan — stacked plan runs sequentially | Linearize batch; fan of siblings |
| D4 | How a plan becomes stacked | Opt-in `PR strategy: stacked` in Global Constraints | Always stacked; decided at `/implement` |

**Note — this plan is itself non-stacked.** It builds the stacked-PR feature; the pipeline
cannot execute a stacked plan until this work lands. Execute it with the ordinary
single-branch, hardening-at-the-end flow.

---

## Phase 1 — The new skill

### Task 1: `using-stacked-pull-requests` skill

**Files:**
- Create: `engineering/skills/using-stacked-pull-requests/SKILL.md`
- Create: `engineering/tests/stacked-prs.sh`

**Interfaces:**
- Produces: skill `engineering:using-stacked-pull-requests`, invoked by name from
  `writing-plans` (Task 2), `executing-plans` (Task 3), and `finishing-a-development-branch`
  (Task 4).
- Produces: `tests/stacked-prs.sh`, a `grep_flat`-based content gate later tasks extend.

- [x] **Step 1: Write the failing test.** Create `engineering/tests/stacked-prs.sh` in the
  style of `validate.sh` — a `grep_flat()` helper (`tr '\n' ' ' | tr -s ' ' | grep -qF --`)
  and, for the new skill file `S="$PLUGIN/skills/using-stacked-pull-requests/SKILL.md"`,
  assert each anchor below is present. Make missing anchors fail the script (`exit 1`).
  Anchors for Task 1:
  - `Using the using-stacked-pull-requests skill` (say-this-first line)
  - `## What this guarantees`
  - `one pull request per task`
  - `Graphite` and `gt` and `gh` (tool-agnostic detection)
  - `one branch per task`
  - `base is its parent branch`
  - `restack`
  - `Land the stack`
  - `bottom-up`
  - `## What this does not do`

- [x] **Step 2: Run it to confirm it fails.**
  Run: `sh engineering/tests/stacked-prs.sh`
  Expected: FAIL (SKILL.md does not exist yet / anchors missing).

- [x] **Step 3: Write the skill.** Create
  `engineering/skills/using-stacked-pull-requests/SKILL.md` with frontmatter
  `name: using-stacked-pull-requests` and a `description:` opening with `[Foundation]` that
  states, in one line, that it manages stacked pull requests across a plan's tasks
  (model-invoked, no command — like `using-git-worktrees`). Body in house shape:
  - Say-this-first line: `Using the using-stacked-pull-requests skill to ...`.
  - `## What this guarantees` — one thing: given a task's committed work, put it on its own
    branch stacked on the previous task's, open/update **one pull request per task** based on
    the correct parent, keep the stack current when a lower PR changes, and land the stack in
    order; via `gt` when the repo has it, plain `git`+`gh` otherwise.
  - Body sections: **Detect the tool** (prefer `Graphite`/`gt` when installed and the repo is
    gt-initialized, else `git`+`gh`; mirror `using-git-worktrees`' prefer-better-else-fallback);
    **Branch and base model** (**one branch per task** inside the single worktree; task 1 off
    trunk, task N off task N-1's branch; a PR's **base is its parent branch**; naming
    `<topic>/<NN>-<task-slug>`); **Start a task's branch** (before its commits land);
    **Submit a task's PR** (`gh pr create --base <parent>` / `gt submit`, title/body from the
    task); **Keep the stack current** (**restack** children when a lower PR changes/lands);
    **Land the stack** (merge **bottom-up** in order, restack the rest after each merge — the
    target of `finishing-a-development-branch`'s delegation).
  - `## What this does not do` — does not write plans, decide which tasks exist, run
    tdd/review/hardening, pick stacked-vs-not (the plan header does), or create the worktree.

- [x] **Step 4: Run the tests to confirm green.**
  Run: `sh engineering/tests/stacked-prs.sh && sh engineering/tests/frontmatter.sh engineering/skills/using-stacked-pull-requests "[Foundation]"`
  Expected: both PASS.

- [x] **Step 5: Commit.**
  ```bash
  git add engineering/skills/using-stacked-pull-requests/SKILL.md engineering/tests/stacked-prs.sh
  git commit -m "feat: add using-stacked-pull-requests skill"
  ```

**CHECKPOINT.** Task 1 sets the guarantee, the section shape, and the vocabulary (branch
model, "Land the stack", restack) that Tasks 2–4 reference by name. Stop after this task and
get a second look at the skill's guarantee and section names before three other skills are
wired to them.

---

## Phase 2 — Pipeline wiring

### Task 2: `writing-plans` emits stacked-PR plans

**Files:**
- Modify: `engineering/skills/writing-plans/SKILL.md`
- Modify: `engineering/tests/stacked-prs.sh`

**Interfaces:**
- Consumes: `engineering:using-stacked-pull-requests` (Task 1).
- Produces: the `PR strategy: stacked` Global-Constraints line and the per-task branch-start /
  PR-submit step convention that `executing-plans` (Task 3) and
  `finishing-a-development-branch` (Task 4) read.

- [x] **Step 1: Write the failing test.** Add anchors to `stacked-prs.sh` for
  `W="$PLUGIN/skills/writing-plans/SKILL.md"`:
  - `PR strategy: stacked`
  - `using-stacked-pull-requests`
  - `not eligible for` (the subagent parallel-mode exclusion)
  - `submit the stacked PR`

- [x] **Step 2: Run it to confirm it fails.**
  Run: `sh engineering/tests/stacked-prs.sh`
  Expected: FAIL on the four new `writing-plans` anchors.

- [x] **Step 3: Edit `writing-plans`.** Add a short **PR strategy** section: at plan-writing
  time, learn whether the plan is stacked (ask, or take it from the spec/caller); when it is,
  record `PR strategy: stacked (one PR per task, via engineering:using-stacked-pull-requests)`
  in the plan's Global Constraints, and state that a stacked plan is **not eligible for**
  `executing-plans`' subagent parallel mode (stacking is linear). Extend the task shape so a
  stacked plan's task opens with a step that starts the task's stacked branch off the previous
  task's branch and closes, after the commit step, with a step to **submit the stacked PR**
  for the task via `engineering:using-stacked-pull-requests`. State that in a stacked plan the
  closing Phase 3.5 hardening task also goes up as the top-of-stack PR. Leave non-stacked plans
  exactly as they are. Keep the `[Planning]` tag and valid frontmatter.

- [x] **Step 4: Run the gates to confirm green.**
  Run: `sh engineering/tests/stacked-prs.sh && sh engineering/tests/plan03.sh`
  Expected: both PASS (`plan03.sh` re-checks `writing-plans` frontmatter/tag).

- [x] **Step 5: Commit.**
  ```bash
  git add engineering/skills/writing-plans/SKILL.md engineering/tests/stacked-prs.sh
  git commit -m "feat: writing-plans emits opt-in stacked-PR plans"
  ```

### Task 3: `executing-plans` honors the strategy

**Files:**
- Modify: `engineering/skills/executing-plans/SKILL.md`
- Modify: `engineering/tests/stacked-prs.sh`

**Interfaces:**
- Consumes: the `PR strategy: stacked` line and per-task steps from Task 2; the skill from
  Task 1.

- [x] **Step 1: Write the failing test.** Add anchors to `stacked-prs.sh` for
  `E="$PLUGIN/skills/executing-plans/SKILL.md"`:
  - `PR strategy`
  - `using-stacked-pull-requests`
  - `sequentially` (stacked plans force sequential; no parallel fan-out)

- [x] **Step 2: Run it to confirm it fails.**
  Run: `sh engineering/tests/stacked-prs.sh`
  Expected: FAIL on the three new `executing-plans` anchors.

- [x] **Step 3: Edit `executing-plans`.** Add that it reads **PR strategy** from the plan's
  Global Constraints; when it is stacked, it runs the plan **sequentially** and does not offer
  subagent parallel mode, and it honors the per-task branch-start and PR-submit steps the plan
  carries (invoking `engineering:using-stacked-pull-requests`) — adding no PR logic of its own
  beyond running those steps in order. State the branch-per-task interplay plainly so an
  executor does not commit on the wrong branch. Keep `[Planning]` tag and valid frontmatter.

- [x] **Step 4: Run the gates to confirm green.**
  Run: `sh engineering/tests/stacked-prs.sh && sh engineering/tests/plan03.sh`
  Expected: both PASS.

- [x] **Step 5: Commit.**
  ```bash
  git add engineering/skills/executing-plans/SKILL.md engineering/tests/stacked-prs.sh
  git commit -m "feat: executing-plans honors stacked PR strategy"
  ```

### Task 4: `finishing-a-development-branch` lands the stack

**Files:**
- Modify: `engineering/skills/finishing-a-development-branch/SKILL.md`
- Modify: `engineering/tests/stacked-prs.sh`

**Interfaces:**
- Consumes: the skill from Task 1; the `PR strategy: stacked` marker from Task 2.

- [x] **Step 1: Write the failing test.** Add anchors to `stacked-prs.sh` for
  `F="$PLUGIN/skills/finishing-a-development-branch/SKILL.md"`:
  - `Land the stack`
  - `using-stacked-pull-requests`

- [x] **Step 2: Run it to confirm it fails.**
  Run: `sh engineering/tests/stacked-prs.sh`
  Expected: FAIL on the two new `finishing` anchors.

- [x] **Step 3: Edit `finishing-a-development-branch`.** Add that it detects a stacked run
  (the plan's `PR strategy: stacked` line, or open stacked PRs on the branch); when stacked,
  it offers **Land the stack** — delegating to `engineering:using-stacked-pull-requests` to
  merge bottom-up in order — in place of the single "Open a pull request" option, while
  merge-direct and cleanup remain available per project. Keep `[Foundation]` tag, valid
  frontmatter, and the existing `conducting-test-hardening` reference (acceptance check 7).

- [x] **Step 4: Run the gates to confirm green.**
  Run: `sh engineering/tests/stacked-prs.sh && sh engineering/tests/frontmatter.sh engineering/skills/finishing-a-development-branch "[Foundation]"`
  Expected: both PASS.

- [x] **Step 5: Commit.**
  ```bash
  git add engineering/skills/finishing-a-development-branch/SKILL.md engineering/tests/stacked-prs.sh
  git commit -m "feat: finishing-a-development-branch lands the stack"
  ```

---

## Phase 3 — Index and acceptance gate

### Task 5: Register the skill in the index and acceptance checklist

**Files:**
- Modify: `engineering/skills/README.md`
- Modify: `engineering/tests/acceptance.sh`

**Interfaces:**
- Consumes: the skill dir from Task 1.

- [x] **Step 1: Confirm the gap (failing check).**
  Run: `sh engineering/tests/acceptance.sh`
  Expected: FAIL at check 4 (`skills/README.md missing using-stacked-pull-requests`).

- [x] **Step 2: Add to the index.** In `engineering/skills/README.md`, add
  `` `using-stacked-pull-requests` `` to the **Foundation** row of the by-group table.

- [x] **Step 3: Add to the acceptance tag list.** In `engineering/tests/acceptance.sh`, add
  the line `using-stacked-pull-requests:[Foundation]` to the `tagged` heredoc (alongside the
  other Foundation skills), so the final acceptance checklist validates the new skill's
  frontmatter and tag.

- [x] **Step 4: Wire the content gate into the suite.** In `engineering/tests/suite.sh`, add
  `sh "$d/stacked-prs.sh"` so the new content anchors run as part of the foundation suite
  (which `acceptance.sh` invokes).

- [x] **Step 5: Run the full acceptance to confirm green.**
  Run: `sh engineering/tests/acceptance.sh`
  Expected: `ENGINEERING ACCEPTANCE: ALL CHECKS PASS`.

- [x] **Step 6: Commit.**
  ```bash
  git add engineering/skills/README.md engineering/tests/acceptance.sh engineering/tests/suite.sh
  git commit -m "chore: register using-stacked-pull-requests in index and acceptance"
  ```

---

## Phase 3.5 — Closing hardening

### Task 6: Test-hardening pass

**Files:**
- (No source files — this task runs a hardening skill over the branch's changes.)

- [ ] **Step 1: Run test hardening.** Invoke `engineering:conducting-test-hardening` over the
  branch diff. Report whichever exit it reaches — `pass`, `dry`, `cap`, `halt`, or
  `audit-only` — plainly, without translating it into a bare "done."

- [ ] **Step 2: Address its result.** Apply whatever the hardening pass returns per that
  skill's own loop; do not expand scope beyond the branch's changes.

- [ ] **Step 3: Commit any hardening changes** with a `test:` message if the pass produced any.

---

## Self-review (run by writing-plans, recorded here)

- **Spec coverage.** §3 goals map to tasks: new skill + lifecycle → Task 1; tool-agnostic →
  Task 1; `writing-plans` opt-in + per-task steps → Task 2; `executing-plans` sequential +
  honors steps → Task 3; `finishing` land-the-stack → Task 4; `README` Foundation row → Task
  5; existing tests pass + new frontmatter covered → Tasks 4/5 gates + Phase 3.5. Spec §5
  Deferred items (parallel stacking, `suite.sh` Foundation loop) are intentionally absent;
  `acceptance.sh` registration (Task 5) is included because that file already enumerates every
  Foundation skill and the acceptance checklist should cover the new one — noted as a
  spec-beyond point.
- **Placeholder scan.** No `TBD`/`...`/unnamed files; every task names exact paths and carries
  a run command with an expected result.
- **Type consistency.** Every task uses the same shape (Files / Interfaces where relevant /
  numbered `- [ ]` steps / a closing verification command / a commit). The skill-name
  `engineering:using-stacked-pull-requests`, the marker `PR strategy: stacked`, and the option
  name "Land the stack" are spelled identically across Tasks 1–5 and match the test anchors.
