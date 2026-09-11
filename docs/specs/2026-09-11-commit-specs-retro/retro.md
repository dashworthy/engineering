---
spec: 2026-09-11-commit-specs-retro
shipped: true
diff: 2c832ed..907f199 (PRs #121, #122, #123, #124)
---
# Retro — commit-specs-retro

## §1 Problem — held
Shipped exactly the problem the spec framed: specs were ephemeral in the gitignored run dir. They are
now committed to `docs/specs/<run-id>/spec.md` with a companion `retro.md`, and a real corpus entry
exists (this run, seeded in task 4).

## §3 Success Criteria — held
All criteria met and test-backed: `spec` writes the frozen copy at approval (task 3), `documenting`
writes `retro.md` unconditionally (task 2), `RETRO-FORMAT.md` governs it (task 1), the ledger is
discoverable via `docs/specs/toc.md` (task 3 + task 4 row). The format test asserts the spine, the
verdict set, and all five Group-B sections.

## §5 Scope — held
Engineering half only; `engineering-retro` stayed deferred (no task touched it). Non-goals held: no
backfill (only this run's spec seeded, by hand as dogfood, not a migration), `SPEC-FORMAT.md`
untouched.

## §6 Approach — drifted
Two refinements landed during build that the approved §6/§8 left open or under-specified:
- **Ledger directory key.** §6 and the plan said `docs/specs/{slug}/` with `{slug}` = the
  date-stripped `<topic>`. Build review caught that a bare slug can collide across days and silently
  overwrite a `spec.md`. Resolved to the **full dated `<run-id>`** (`<YYYY-MM-DD>-<slug>`),
  standardized across `spec`, `documenting`, and `RETRO-FORMAT.md`.
- **Row lifecycle.** `SPECS-TOC-FORMAT.md` promised `Shipped` flips at ship, but nothing implemented
  it. Added the row-update (`Shipped → yes`) to `documenting`, closing the loop `spec` opens with
  `Shipped: —`.

## §8 Open questions — held (both resolved)
Slug-collision → resolved to the dated run-id. `docs/specs/toc.md` row shape → resolved to
`Date | Spec | Shipped | Links`, a dedicated genre (arch-lens-approved over reusing `TOC-FORMAT.md`).

## Process friction & cost
- The `{slug}` vs full-run-id ambiguity was never nailed down in signal/brainstorming/spec/plan — it
  slipped through to the build review, where the collision risk was caught. Suspected fix: when a spec
  introduces a path/id derived from an existing convention, the spec or plan should pin the *resolved*
  literal, not a placeholder, and a design-time check could flag "placeholder key used as a filesystem
  path" before build. [phase: spec / plan]
- Cross-repo scope (the `engineering-retro` half) only surfaced as unworkable in one run *during
  brainstorming*, after the brief had already committed to "both halves." Suspected fix: an
  entrance-time check that flags a multi-repo ask before design commits to it. [phase: signal]

## Rework & churn
- Spec revisited once at the gate (added 4 retro axes) — a clean, cheap correction.
- Task 3 had the largest churn: the build review drove a run-id standardization that reached back into
  task-1 (`RETRO-FORMAT.md`) and task-2 (`documenting/SKILL.md`) files, plus a new `documenting`
  row-update behavior. Documenting-phase edits ended up split across tasks 2 and 3 — a sign the task
  decomposition drew the `documenting`/ledger boundary a task too early.
- Two small review-driven fixes (task 1 ELI5 "six axes"; task 2 non-load-bearing test anchor); both
  caught by the per-task review, neither reached a human.

## Scope fidelity
- Held. In = engineering half; deferred = `engineering-retro`; non-goals held. The run-id refinement
  was resolving an in-scope open question (§8), not creep. No unplanned work pulled in.

## Gate correction load
- Spec gate: 1 "request changes" (retro axes), then Approve. Plan gate: approved first pass. Low human
  correction overall — but the spec-gate change and the two build-time §8 resolutions both trace to the
  same upstream thinness: the retro axes and the ledger dir/row shape were under-explored before the
  spec. A sharper signal/brainstorming pass on "exactly what the retro captures and how the ledger is
  keyed" would have pre-empted all three.

## Assumption & open-question outcomes
- Baseline "`{slug}` = date-stripped topic" (written into the plan's Global Constraints): **bit us** —
  wrong for a collision-free directory key, corrected in build to the dated run id.
- §8 slug-collision: resolved cleanly.
- §8 toc row shape: resolved cleanly.
- Assumption "reaching `documenting` = shipped": adopted as the definition behind `shipped: true` and
  the `Shipped → yes` flip; note it means "shipped as an open PR", not "merged" (the pipeline never
  merges). Worth revisiting if a run can reach documenting yet never land.
