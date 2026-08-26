# Plan 01 — Remove `prototype` and `research` (edge-skill cleanup)

**Spec:** docs/dashworthy/engineering/specs/2026-08-26-first-class-adrs.md (Status: Approved)
**Plan set:** 1 of 2 — this plan is independent; finishing it leaves the suite working and green, with plan 02 not yet started.
**Date:** 2026-08-26

## Global Constraints

Copied verbatim from the spec's §4 Constraints; every task below reads "per Global Constraints":

- Markdown-skill plugin (Claude Code / Agent SDK); the deliverable is skill prose, formats, and wiring — **not application code**.
- Mirror the conventions trilogy shape (intake → single-writer → use) plus an index with a match column — but adapt, not copy: an ADR is a point-in-time record, not a standing rule, so it does **not** inherit the convention hardening-interrogation / individual-approval gate.
- Preserve suite discipline: single-writer per artifact, no silent writes.
- Must not flood.
- ADRs are append-only and numbered; the glossary is living and mutable; using/tracking/lifecycle respect both via two consumption profiles.
- The doctrine is defined before it is applied.
- **Large blast radius.** The whole suite must stay working through every change.
- Worktree-first workflow.

**PR strategy:** single PR per plan (one PR opened at the end of this plan). Not stacked; eligible for `executing-plans` subagent parallel mode.
**Finish strategy:** open a pull request against `0.x`; delete the worktree branch after merge (via `engineering:finishing-a-development-branch`).

**Verification gate for every task:** `sh engineering/tests/suite.sh` prints `ALL FOUNDATION CHECKS PASS`, and `sh engineering/tests/acceptance.sh` and `sh engineering/tests/plan03.sh` exit 0 with no `FAIL` line. Removal is not "clean" (thread `removal-cleanliness`) until all three are green — tests are **updated**, never left broken.

## Task 1 — Remove the `research` skill and scrub its references

**Files:**
- Delete: `engineering/skills/research/SKILL.md` (and the `engineering/skills/research/` directory)
- Modify: `engineering/skills/dispatching-parallel-agents/SKILL.md` (drops the `research` reference)
- Modify: `engineering/tests/acceptance.sh` (untagged loop `for name in research resolving-merge-conflicts`)
- Modify: `engineering/tests/plan03.sh` (lines referencing `skills/research`)
- Modify: `engineering/skills/README.md` (drop the `research` entry)

**Steps (red → green):**

- [x] Delete `engineering/skills/research/`.
- [x] Run `sh engineering/tests/acceptance.sh` and `sh engineering/tests/plan03.sh`; **confirm both now FAIL** on the missing `research` frontmatter — this is the failing check that proves the tests guard the skill's presence.
- [x] In `engineering/tests/acceptance.sh`, remove `research` from the untagged loop (`for name in research resolving-merge-conflicts` → `for name in resolving-merge-conflicts`).
- [x] In `engineering/tests/plan03.sh`, remove the `research` frontmatter line and drop `research` from its `for s in research resolving-merge-conflicts` loop.
- [x] In `engineering/skills/dispatching-parallel-agents/SKILL.md`, remove the sentence/clause that references `research` (per Global Constraints, no dangling references).
- [x] In `engineering/skills/README.md`, delete the `research` list entry.
- [x] `grep -rn "research" engineering/skills engineering/tests engineering/commands` returns no reference to the removed skill (matches of the ordinary English word "research" in unrelated prose are acceptable; a path/skill-name reference is not).
- [x] Run the verification gate; **confirm green**.
- [x] Commit: `chore(engineering): remove underutilized research skill`. _(count 36->35 folded in to keep the suite green per removal-cleanliness constraint; root README table row deferred to Task 3.)_

**Verification:** `sh engineering/tests/acceptance.sh && sh engineering/tests/plan03.sh && sh engineering/tests/suite.sh` — all exit 0; `suite.sh` prints `ALL FOUNDATION CHECKS PASS`.

## Task 2 — Remove the `prototype` skill and scrub its references

**Files:**
- Delete: `engineering/skills/prototype/SKILL.md`, `engineering/skills/prototype/LOGIC.md`, `engineering/skills/prototype/UI.md` (and the `engineering/skills/prototype/` directory)
- Modify: `engineering/tests/acceptance.sh` (tagged list entry `prototype:[Design]`)
- Modify: `engineering/tests/plan03.sh` (line `frontmatter.sh "$d/../skills/prototype" "[Design]"`)
- Modify: `engineering/skills/README.md` (drop the `prototype` entry)

**Steps (red → green):**

- [ ] Delete `engineering/skills/prototype/`.
- [ ] Run `sh engineering/tests/acceptance.sh` and `sh engineering/tests/plan03.sh`; **confirm both FAIL** on the missing `prototype` frontmatter.
- [ ] In `engineering/tests/acceptance.sh`, remove the `prototype:[Design]` line from the `tagged` list.
- [ ] In `engineering/tests/plan03.sh`, remove the `prototype` frontmatter line.
- [ ] In `engineering/skills/README.md`, delete the `prototype` list entry.
- [ ] `grep -rn "prototype" engineering/skills engineering/tests engineering/commands` returns no reference to the removed skill.
- [ ] Run the verification gate; **confirm green**.
- [ ] Commit: `chore(engineering): remove underutilized prototype skill`.

**Verification:** same gate as Task 1 — all three test entrypoints exit 0.

## Task 3 — Reconcile the advertised skill count and skill tables

`validate.sh` fails if the root README's `N skills` count differs from `find engineering/skills -name SKILL.md | wc -l`. Removing two skills drops the on-disk count by two, so the README must move with it in the same PR. Set the count to on-disk reality rather than a hard-coded number — the baseline drifts as other PRs land (it was 37, then 36 after the vernacular slim removed `verifying-docblock-claims`), so `find … | wc -l` is the only order-robust source.

**Files:**
- Modify: `README.md` (root) — the `N skills` claim and the per-group skill table (drops `prototype` from Design, `research` from its cross-cutting row)
- Modify: `engineering/README.md` and `laravel/README.md` **only if** either states a skill count or lists the removed skills

**Steps (red → green):**

- [ ] Run `sh engineering/tests/validate.sh`; **confirm it FAILs** on `root README skill count (N) matches disk (N-2)` — the failing check proving the guard is live.
- [ ] In `README.md`, set the `N skills` count to equal `find engineering/skills -name SKILL.md | wc -l` after the removals (do not hard-code; compute it).
- [ ] In `README.md`, remove `prototype` from the Design group row and `research` from the cross-cutting row of the skill table (around line 138–155).
- [ ] `grep -rn "prototype\|research" README.md engineering/README.md laravel/README.md` returns no reference to the removed skills (ignoring the ordinary word "research" in unrelated prose).
- [ ] Run the full verification gate; **confirm green** (`validate.sh` now reports `root README skill count (N-2) matches disk (N-2)`).
- [ ] Commit: `docs(engineering): drop removed skills from README count and tables`.

**Verification:** `sh engineering/tests/suite.sh` prints `ALL FOUNDATION CHECKS PASS`; `sh engineering/tests/acceptance.sh` and `sh engineering/tests/plan03.sh` exit 0.

## Task 4 — Test hardening (closing)

- [ ] Invoke `engineering:conducting-test-hardening` over this plan's diff (the two removals and the README/test reconciliation). Confirm the removal did not silently drop a test that guarded still-present behavior, and that the updated `acceptance.sh` / `plan03.sh` / `validate.sh` assertions still fail if a removed skill were reintroduced or the count drifted. This closing task is mandatory and is this plan's last step.

**Verification:** `conducting-test-hardening` reports no unaddressed gap or breakage on this plan's diff; the full gate remains green.
