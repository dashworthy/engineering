# Plan 02 — First-class edge artifacts (doctrine, ADRs, glossary, diagrams, sweep)

**Spec:** docs/dashworthy/engineering/specs/2026-08-26-first-class-adrs.md (Status: Approved)
**Plan set:** 2 of 2. **Base:** builds on plan 01 (removals). Sequenced after it so the skill-count reconciliation chains cleanly; the count task below matches the README to on-disk reality rather than hard-coding a number, so it is order-robust regardless.
**Date:** 2026-08-26

## Global Constraints

Copied verbatim from the spec's §4 Constraints; every task reads "per Global Constraints":

- Markdown-skill plugin (Claude Code / Agent SDK); the deliverable is skill prose, formats, and wiring — **not application code**.
- Mirror the conventions trilogy shape (intake → single-writer → use) plus an index with a match column — but adapt, not copy: an ADR is a point-in-time record, not a standing rule, so it does **not** inherit the convention hardening-interrogation / individual-approval gate.
- Preserve suite discipline: single-writer per artifact, no silent writes.
- **Must not flood.** The ADR intake trigger fires only on decisions with genuine live alternatives; the developer can decline.
- ADRs are append-only and numbered (superseded by pointer, never rewritten); the glossary is living and mutable. Using / tracking / lifecycle respect both via two consumption profiles (trail vs lookup).
- **The doctrine is defined before it is applied** — Phase 1 lands the doctrine before any phase wires to it.
- **Large blast radius.** The suite-wide sweep touches every "when present" consumer; the whole suite must stay working.
- Worktree-first workflow.

**Skill-authoring standard:** every task that creates or edits a `SKILL.md` or a `references/` file follows `skillsmith:writing-skills` — concise reference-card body, gerund naming, a trigger-bearing third-person `description`, progressive disclosure (SKILL.md overview → one-level-deep `references/`), and degrees-of-freedom matched to task fragility. New skills are pressure-tested with `skillsmith:testing-skills` before the plan closes.

**PR strategy:** single PR per plan (one PR opened at the end). Not stacked; eligible for `executing-plans` subagent parallel mode — but note the phases below are largely sequential (the doctrine and the ADR writer are prerequisites for most later phases), so parallel fan-out is limited to genuinely independent tasks.
**Finish strategy:** open a pull request against `0.x`; delete the worktree branch after merge (via `engineering:finishing-a-development-branch`).

**Verification gate for every task:** `sh engineering/tests/suite.sh` prints `ALL FOUNDATION CHECKS PASS`, and `sh engineering/tests/acceptance.sh` + `sh engineering/tests/plan03.sh` exit 0 with no `FAIL` line. TDD for this markdown suite = a structural assertion (a `grep_flat`/frontmatter check in `validate.sh` or `acceptance.sh`) written and seen to **fail** before the prose that satisfies it is written.

---

## Phase 1 — The doctrine and the ADR single writer

### Task 1.1 — Author the first-class-artifact doctrine (defined before applied)

**Files:**
- Create: `engineering/skills/recording-adrs/references/first-class-artifact.md`

**Steps:**
- [x] Add a `grep_flat` assertion block to `engineering/tests/validate.sh` for the doctrine reference: it exists, names the three pattern elements (`intake trigger`, `index`, `active consumption`), and names the two profiles (`trail`, `lookup`). Run `sh engineering/tests/validate.sh`; **confirm FAIL** (file absent).
- [x] Write `first-class-artifact.md` per Global Constraints skill-authoring standard: the pattern (intake trigger + index + active-consumption obligation), and the two consumption profiles — *trail* (append-only historical; consumer cites by path at the work item) and *lookup* (living current-state; consumer resolves current meaning). Keep it a concise reference; declare ADRs, glossary, and diagrams as its applications.
- [x] Run `sh engineering/tests/validate.sh`; **confirm green**.
- [x] Commit: `feat(engineering): define the first-class-artifact doctrine`.

**Verification:** `sh engineering/tests/validate.sh` reports the doctrine checks `ok`; `sh engineering/tests/suite.sh` passes.

### Task 1.2 — Author the `recording-adrs` single-writer skill

**Files:**
- Create: `engineering/skills/recording-adrs/SKILL.md`
- Create: `engineering/skills/recording-adrs/ADR-FORMAT.md` (move ADR record shape here — the canonical copy formerly in `domain-modeling`)
- Create: `engineering/skills/recording-adrs/ADR-INDEX-FORMAT.md` (the index shape, mirroring `STANDARDS-FORMAT.md`'s index section: a **When relevant** match column + a **Status** column of `Proposed | Accepted | Superseded by NNNN`)

**Interfaces:** `recording-adrs` is the single writer of `docs/adr/` and `docs/adr/index.md`. It owns ADR lifecycle (Proposed → Accepted on the carrying spec/plan's gate; Superseded by NNNN) and keeps the index in sync in the same edit. It has **no** hardening interrogation and **no** individual-approval gate (per Global Constraints — an ADR is a record, not a rule).

**Steps:**
- [x] Add to `engineering/tests/acceptance.sh` the tagged-skill entry `recording-adrs:[Discovery]` in the `tagged` list. Run `sh engineering/tests/acceptance.sh`; **confirm FAIL** (skill dir/frontmatter absent).
- [x] Add `grep_flat` assertions to `validate.sh`: `recording-adrs/SKILL.md` names itself in frontmatter, states it is the single writer of `docs/adr/`, states the no-flood intake ("live alternatives", "the developer can decline"), states the lifecycle (`Proposed`, `Accepted`, `Superseded`), and states it carries **no** approval gate. Run; **confirm FAIL**.
- [x] Write `ADR-FORMAT.md` (record shape, moved from domain-modeling) and `ADR-INDEX-FORMAT.md` (index shape).
- [x] Write `recording-adrs/SKILL.md` per the skill-authoring standard, referencing `first-class-artifact.md`, `ADR-FORMAT.md`, and `ADR-INDEX-FORMAT.md` by relative path (progressive disclosure).
- [x] Run `sh engineering/tests/acceptance.sh` and `sh engineering/tests/validate.sh`; **confirm green**. _(count 34->35 + skills/README entry folded in to keep the gate green; root README grouped-table row deferred to Task 7.1.)_
- [x] Commit: `feat(engineering): add recording-adrs single-writer skill`.

**Verification:** acceptance + validate exit 0; `recording-adrs` frontmatter/tag check passes.

### Task 1.3 — Seed the ADR index with the existing record

**Files:**
- Create: `docs/adr/index.md`

**Steps:**
- [x] Add a `validate.sh` assertion: `docs/adr/index.md` exists and contains a row linking `0001-derive-verity-configuration-fresh-each-run.md` with Status `Accepted`. Run; **confirm FAIL**.
- [x] Write `docs/adr/index.md` per `ADR-INDEX-FORMAT.md`, with the header row and one data row for ADR 0001 (When relevant: verity/test-hardening configuration; Status: Accepted; link: `0001-derive-verity-configuration-fresh-each-run.md`).
- [x] Run `sh engineering/tests/validate.sh`; **confirm green**.
- [x] Commit: `feat(adr): seed docs/adr/index.md with ADR 0001`.

**Verification:** validate exits 0; the index row for 0001 resolves to the on-disk ADR.

### Task 1.4 — The ADR tracking view (per-run/per-phase decision ledger)

Success criterion 8: a tracking view distinct from the index's lookup role. The spec (§8) leaves the *form* — a distinct file vs. a filtered view over `docs/adr/index.md` — to `codebase-design` during build; this task guarantees the view exists and is described.

**Files:**
- Modify: `engineering/skills/recording-adrs/SKILL.md` (state that it produces/maintains a per-run/per-phase decision ledger — decisions and their Proposed/Accepted status — derived from the index, distinct from lookup)
- Reference: invoke `engineering:codebase-design` to shape whether the ledger is a separate file or a derived view before writing it.

**Steps:**
- [x] Add a `validate.sh` assertion: `recording-adrs/SKILL.md` describes a tracking ledger keyed by run/phase and status, and states it is derived from the index (not a second source of truth). Run; **confirm FAIL**.
- [x] Invoke `engineering:codebase-design` to decide the ledger's shape (file vs. derived view); record the decision as an ADR via `recording-adrs` (dogfooding the intake). _(codebase-design discipline applied inline: narrowest interface, no second source of truth → derived view. Dogfooded as ADR 0002 — record + index row written in one edit.)_
- [x] Write the tracking-view section into `recording-adrs/SKILL.md` per the chosen shape and the skill-authoring standard.
- [x] Run validate; **confirm green**.
- [x] Commit: `feat(engineering): add the ADR tracking ledger to recording-adrs`.

**Verification:** validate exits 0; the tracking-view assertion passes.

---

## Phase 2 — The ADR using side

### Task 2.1 — Author the `using-adrs` skill

**Files:**
- Create: `engineering/skills/using-adrs/SKILL.md`

**Interfaces:** reads `docs/adr/index.md`, matches each work item against the **When relevant** column, cites the governing ADR by path at the work item, and **skips Superseded rows** — the ADR analogue of `using-code-conventions` under the *trail* profile.

**Steps:**
- [x] Add `using-adrs:[Build]` to the `tagged` list in `acceptance.sh`. Run; **confirm FAIL**.
- [x] Add `validate.sh` assertions: `using-adrs/SKILL.md` names itself, states it matches the **When relevant** column, states by-path citation at the work item, and states it skips `Superseded` rows. Run; **confirm FAIL**.
- [x] Write `using-adrs/SKILL.md` per the skill-authoring standard, referencing `first-class-artifact.md` (trail profile) and `ADR-INDEX-FORMAT.md`.
- [x] Run acceptance + validate; **confirm green**. _(count 35->36 + skills/README Build entry folded in; root README grouped-table row deferred to Task 7.1.)_
- [x] Commit: `feat(engineering): add using-adrs skill`.

**Verification:** acceptance + validate exit 0.

---

## Phase 3 — Glossary first-class and the spawn-bridge removal

### Task 3.1 — Shrink `domain-modeling` to the glossary single-writer; remove its ADR half and the spawn bridge

**Files:**
- Modify: `engineering/skills/domain-modeling/SKILL.md` (remove the `docs/adr/` sections and the "Spawning a convention from an ADR" section; keep `CONTEXT.md` glossary role; point ADR concerns at `recording-adrs`)
- Delete: `engineering/skills/domain-modeling/ADR-FORMAT.md` (moved to `recording-adrs` in Task 1.2)
- Modify: `engineering/skills/recording-code-conventions/SKILL.md` (scrub the "ADR-spawn seam" reference and the ADR-spawned `Source` provenance path)
- Modify: `engineering/skills/recording-code-conventions/STANDARDS-FORMAT.md` (scrub the "the ADR that spawned it (`docs/adr/NNNN-...`)" provenance option if present)

**Steps:**
- [x] Add `validate.sh` assertions: `domain-modeling/SKILL.md` no longer contains `docs/adr` or `Spawning a convention from an ADR`; `recording-code-conventions/SKILL.md` no longer contains `ADR-spawn` / `spawn`. Run; **confirm FAIL** (the strings still present).
- [x] Edit `domain-modeling/SKILL.md`: remove the ADR sections and spawn bridge; update its frontmatter `description` so it no longer claims to write `docs/adr/` (per skill-authoring standard — the description carries discovery). Update its "does not" list to point ADR recording at `recording-adrs`.
- [x] Delete `domain-modeling/ADR-FORMAT.md`.
- [x] Edit `recording-code-conventions/SKILL.md` and `STANDARDS-FORMAT.md` to remove the spawn-bridge references.
- [x] `grep -rn "Spawning a convention from an ADR\|ADR-spawn\|spawn" engineering/skills/domain-modeling engineering/skills/recording-code-conventions` returns nothing.
- [x] Run the full gate (`suite.sh` runs `conventions.sh` and `validate.sh`); **confirm green**. _(conventions.sh "Task 8" spawn-seam guards removed with the behavior per removal-cleanliness; validate.sh now positively asserts the spawn refs are absent.)_
- [x] Commit: `refactor(engineering): shrink domain-modeling to the glossary; remove ADR half and spawn bridge`.

**Verification:** `sh engineering/tests/suite.sh` passes (`conventions.sh` still green after the spawn-bridge scrub); no spawn references remain.

### Task 3.2 — Make glossary consumption active (intake at term-introduction; lookup profile)

**Files:**
- Modify: `engineering/skills/domain-modeling/SKILL.md` (state the intake obligation: update `CONTEXT.md` at term-introduction points; declare it a *lookup*-profile application of the doctrine)

**Steps:**
- [x] Add a `validate.sh` assertion: `domain-modeling/SKILL.md` references `first-class-artifact.md` and states the lookup profile. Run; **confirm FAIL**.
- [x] Edit `domain-modeling/SKILL.md` to reference the doctrine and state the term-introduction intake + lookup consumption.
- [x] Run validate; **confirm green**.
- [x] Commit: `feat(engineering): make CONTEXT.md a first-class lookup artifact`.

**Verification:** validate exits 0.

---

## Phase 4 — Diagrams first-class

### Task 4.1 — Wire a "consider a diagram" intake obligation into authoring phases

**Files:**
- Modify: `engineering/skills/using-diagrams/SKILL.md` (state that authoring phases are obligated to *consider* a diagram; declare it a doctrine application)
- Modify: `engineering/skills/to-spec/SKILL.md`, `engineering/skills/writing-plans/SKILL.md`, `engineering/skills/recording-adrs/SKILL.md` (each: when a data model / flow / state machine is described, consider a diagram via `engineering:using-diagrams` — guard: *consider*, not *always draw*)

**Steps:**
- [x] Add `validate.sh`/`acceptance.sh` assertions: each of the three authoring skills references `using-diagrams` with a "consider" obligation. Run; **confirm FAIL**.
- [x] Edit `using-diagrams/SKILL.md` to state the obligation and reference the doctrine. _(Also fixed stale "domain-modeling owns the ADR" → recording-adrs.)_
- [x] Add the "consider a diagram" clause to `to-spec`, `writing-plans`, and `recording-adrs` (per skill-authoring standard — minimal, one clause each, not a lecture).
- [x] Run the gate; **confirm green**.
- [x] Commit: `feat(engineering): make using-diagrams a first-class authoring obligation`.

**Verification:** validate + acceptance exit 0; the three authoring skills name `using-diagrams`.

---

## Phase 5 — ADR intake obligations in the decision phases

### Task 5.1 — Wire the decision-point prompt into the skills that make decisions

**Files:**
- Modify: `engineering/skills/brainstorming/SKILL.md`, `engineering/skills/codebase-design/SKILL.md`, `engineering/skills/writing-plans/SKILL.md`, `engineering/skills/code-review/SKILL.md` (each gains an intake clause: on reaching a decision with genuine live alternatives, offer to record an ADR via `engineering:recording-adrs`; write `Proposed`; the developer may decline — the non-flood guard)

**Steps:**
- [x] Add `acceptance.sh`/`validate.sh` assertions: each of the four skills references `recording-adrs` and states the "live alternatives" / "may decline" non-flood guard. Run; **confirm FAIL**.
- [x] Add the intake clause to each of the four skills per the skill-authoring standard — one clause, pointing at `recording-adrs`, stating the live-alternatives bar and the decline path (per Global Constraints, must not flood).
- [x] Run the gate; **confirm green**.
- [x] Commit: `feat(engineering): wire ADR intake into the decision phases`.

**Verification:** the four skills name `recording-adrs`; gate green.

---

## Phase 6 — The suite-wide passive→active sweep

### Task 6.1 — Convert every "read when present" reference to an active obligation

**Files:**
- Modify: every skill/command whose body still carries the passive idiom. Enumerate at execution time — do not trust a stale list:
  `grep -rln "when present\|read .* when\|if present" engineering/skills engineering/commands` (expected set from the spec: `code-review`, `codebase-design`, `writing-plans`, `tdd`, `triage`, `diagnosing-bugs`, `improve-codebase-architecture`, and the `handoff` / `wait-what` commands — re-derive the live list).

**Steps:**
- [ ] Add a `validate.sh` assertion that **no** `SKILL.md` or command file matches the passive idiom `read CONTEXT.md/docs/adr when present` (the guard that keeps the rot from returning). Run; **confirm FAIL** (matches still present).
- [ ] For each file the grep returns, rewrite the passive reference into an active obligation per the doctrine and the correct profile (ADRs → trail: consult `using-adrs`; glossary → lookup: consult `CONTEXT.md`), citing the governing skill by name. Keep edits minimal per the skill-authoring standard.
- [ ] Re-run the grep; confirm zero passive matches remain.
- [ ] Run the full gate; **confirm green**.
- [ ] Commit: `refactor(engineering): convert passive artifact reads to active obligations`.

**Verification:** the passive-idiom grep returns nothing; `sh engineering/tests/suite.sh` passes.

---

## Phase 7 — Reconcile enumerations and advertised counts

### Task 7.1 — Update the skill index and advertised skill count

`validate.sh` fails unless the root README's `N skills` count equals `find engineering/skills -name SKILL.md | wc -l`, and `acceptance.sh` check #4 fails unless `skills/README.md` lists every skill dir. This plan adds `recording-adrs` and `using-adrs`.

**Files:**
- Modify: `engineering/skills/README.md` (add `recording-adrs`, `using-adrs`)
- Modify: `README.md` (root) — the `N skills` count and the per-group skill table (add the two new skills under their groups)

**Steps:**
- [ ] Run `sh engineering/tests/validate.sh` and `sh engineering/tests/acceptance.sh`; **confirm FAIL** on the count guard and/or the README-lists-every-skill check.
- [ ] Add `recording-adrs` and `using-adrs` entries to `engineering/skills/README.md`.
- [ ] Set the root README's skill count to equal on-disk reality: `find engineering/skills -name SKILL.md | wc -l` (order-robust — do not hard-code), and add the two skills to the grouped table.
- [ ] Run validate + acceptance; **confirm green** (`root README skill count (N) matches disk (N)`).
- [ ] Commit: `docs(engineering): register recording-adrs and using-adrs in the READMEs`.

**Verification:** `sh engineering/tests/validate.sh` and `sh engineering/tests/acceptance.sh` exit 0.

---

## Phase 8 — Pressure-test the new skills, then harden

### Task 8.1 — Pressure-test discovery and compliance of the new skills

**Steps:**
- [ ] Invoke `skillsmith:testing-skills` against `recording-adrs`, `using-adrs`, and the intake-clause edits: confirm each is discovered when relevant and followed under time/authority pressure, and close any rationalization that lets an agent skip recording a real decision or citing a governing ADR. Record adjustments as ordinary skill edits (re-running the verification gate after each).

**Verification:** `skillsmith:testing-skills` reports the target scenarios pass with the skills present and fail without them.

### Task 8.2 — Test hardening (closing)

- [ ] Invoke `engineering:conducting-test-hardening` over this plan's whole diff. Confirm the new `validate.sh` / `acceptance.sh` assertions genuinely fail if the doctrine, a new skill, the ADR index, an intake clause, or the passive-idiom guard were reverted — i.e., the tests would catch the regression. This closing task is mandatory and is this plan's last step.

**Verification:** `conducting-test-hardening` reports no unaddressed gap or breakage; the full gate (`suite.sh` + `acceptance.sh` + `plan03.sh`) remains green.
