---
spec: 2026-09-11-commit-specs-retro
shipped: true
diff: 2c832ed..task-5 tip (PRs #121–#124, #126)
---
# Retro — commit-specs-retro

## §1 Problem — held
Shipped exactly the problem the spec framed: specs were ephemeral in the gitignored run dir. They are
now committed to `docs/specs/<run-id>/spec.md` with a companion `retro.md`, and a real corpus entry
exists (this run, seeded in task 4).

## §3 Success Criteria — drifted
Most criteria met and test-backed: `spec` writes the frozen copy at approval (task 3), `documenting`
writes `retro.md` unconditionally (task 2), `RETRO-FORMAT.md` governs it (task 1). The format test
asserts the spine, the verdict set, and all five Group-B sections. **The drifted criterion:** the spec
called for discoverability via a browsable `docs/specs/toc.md` index; after the branch shipped, the
human judged the index didn't earn its upkeep and cut it (task 5). Discovery is now by listing the
date-prefixed `docs/specs/<run-id>/` directories, which sort chronologically on their own.

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
- **Ledger index, then no index.** The run built a browsable `docs/specs/toc.md` index — a
  `SPECS-TOC-FORMAT.md` row format and a `Shipped: —` → `yes` lifecycle split across the two writers —
  then cut it entirely in a follow-on (task 5) once the human judged the dated directories were a
  sufficient, lower-maintenance ledger. Built and removed inside the same unmerged stack.

## §8 Open questions — drifted (one resolved, one obsoleted)
Slug-collision → resolved to the dated run-id. `docs/specs/toc.md` row shape → resolved to
`Date | Spec | Shipped | Links` (a dedicated genre, arch-lens-approved over reusing `TOC-FORMAT.md`) —
then **obsoleted**: the index that row shape served was cut post-ship (task 5), so the whole second
open question dissolved rather than resolving. That the pipeline spent a gate-question and an arch-lens
pass shaping an index later judged unnecessary is itself the signal.

## Process friction & cost
- The `{slug}` vs full-run-id ambiguity was never nailed down in signal/brainstorming/spec/plan — it
  slipped through to the build review, where the collision risk was caught. Suspected fix: when a spec
  introduces a path/id derived from an existing convention, the spec or plan should pin the *resolved*
  literal, not a placeholder, and a design-time check could flag "placeholder key used as a filesystem
  path" before build. [phase: spec / plan]
- Cross-repo scope (the `engineering-retro` half) only surfaced as unworkable in one run *during
  brainstorming*, after the brief had already committed to "both halves." Suspected fix: an
  entrance-time check that flags a multi-repo ask before design commits to it. [phase: signal]
- The browsable index was designed, specced, built, and tested — then cut — without ever validating
  that a flat directory listing was insufficient. Suspected fix: for a convenience layered on a core
  store (an index over a directory, a cache over a source), the spec should state the concrete
  access need it solves, so "the dated directories already sort" is caught at design time, not after
  ship. [phase: brainstorming / spec]

## Rework & churn
- Spec revisited once at the gate (added 4 retro axes) — a clean, cheap correction.
- Task 3 had the largest churn: the build review drove a run-id standardization that reached back into
  task-1 (`RETRO-FORMAT.md`) and task-2 (`documenting/SKILL.md`) files, plus a new `documenting`
  row-update behavior. Documenting-phase edits ended up split across tasks 2 and 3 — a sign the task
  decomposition drew the `documenting`/ledger boundary a task too early.
- Two small review-driven fixes (task 1 ELI5 "six axes"; task 2 non-load-bearing test anchor); both
  caught by the per-task review, neither reached a human.
- The largest churn landed *after* the branch was declared finished: the whole ledger-index subsystem
  (index file, format ref, spec upsert step, documenting flip step, and their assertions) was built
  across tasks 3–4 and then removed in task 5, on the human's call that a browsable index wasn't worth
  its upkeep over the dated directories. Late, but caught before merge.

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
- §8 toc row shape: resolved cleanly at the gate, then **obsoleted** when the index it shaped was cut
  post-ship (see the browsable-index baseline below) — a resolution spent on a feature later removed.
- Assumption "reaching `documenting` = shipped": adopted as the definition behind the retro's
  `shipped: true` front-matter; note it means "shipped as an open PR", not "merged" (the pipeline never
  merges). Worth revisiting if a run can reach documenting yet never land.
- Baseline "a browsable index makes the ledger discoverable": **bit us** — cut post-ship (task 5) once
  the dated directories proved to sort on their own. An index over a naturally-ordered store was
  solving a problem the store didn't have.
