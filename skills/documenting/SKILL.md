---
name: documenting
description: "The documentation phase: after the branch is green, decide whether the run changed documented behavior and — when it did — produce or surgically update the feature's docs (via using-documentation), then validate them by fanning out independent reviewers (accuracy, structure, links, scope) before handing to finish. Runs between build and finish, on the shipped diff, so docs describe what actually landed. Use once build's last task is done; it adds no new human gate — the plan gate already authorized the run."
---

# Documenting

Say this first, plainly: `Using the documenting skill to document what this run shipped.`

`documenting` is the pipeline's documentation phase. It runs after `build` and before `finish`, on
the green branch, so the documentation it writes describes what actually shipped rather than what
the spec and plan intended. It decides whether documentation is warranted, produces it through
`using-documentation`, validates it through a fan-out of independent reviewers, and hands the
reviewed docs to `finish`.

## What this guarantees

One thing: given a green branch at the end of `build`, this phase either leaves the run's
documentation current — the feature doc written or surgically updated and validated, the
`docs/toc.md` row upserted — or records a one-line reason it did not. It never leaves the docs
silently stale and never leaves what it wrote unvalidated. Independently of that judged call, it
always leaves the run's **retro ledger entry** on disk — `docs/specs/<run-id>/retro.md`, the
companion to the committed spec — so the spec ledger records how the run actually went.

## No new gate

This phase adds no human-approval gate. The **plan gate already** authorized the run; documentation
is produced, validated, and its findings fixed the same way `build`'s per-task review findings are
— in the diff, unattended — then handed on. Do not stop here to ask whether to document or whether
to proceed; deciding is this phase's own judged call, below, and proceeding to `finish` is the next
act.

## Judged — document only what changed behavior

Documentation is **judged**, not automatic. Ask one question of the shipped whole-branch diff: did
this run change behavior a feature doc should describe? A pure refactor, an internal-only change, a
test-only change usually did not.

- **No** → record a one-line **skip** reason (e.g. `Docs: skipped — internal refactor, no behavior
  change`) where the run and the human can see it, and hand to `finish`. A skip is a visible
  decision, never a silent pass (see `engineering:refusing-deferral`).
- **Yes** → mint the identity and produce, below.

## Mint the identity, then produce

When documentation is warranted, settle **which** feature this is. The agent never invents a domain
or feature name: propose one — with a recommended answer drawn from the spec's topic and the change
— as a structured choice (shaped per `engineering:using-questions`), and let the human confirm or
rename (this is `using-documentation`'s minting step; drive it there). Then **invoke `engineering:using-documentation`**, handing it the
run's spec path, plan path, the shipped whole-branch diff, and the confirmed `{domain}/{feature}`
identity. It writes or surgically patches `docs/{domain}/{feature}/README.md` and upserts the
`docs/toc.md` row. Producing the docs is that skill's job; this phase orchestrates and then
validates.

Where a change sat next to an established-but-undocumented feature, `using-documentation` may
**propose** documenting it too — a per-feature opt-in the human accepts or declines, never a doc
written unasked.

## Validate — fan out, reconcile, fix

Once the docs are written, validate them. Load `references/validation-protocol.md` and follow it:
it fans out one independent sub-reviewer per lens — accuracy against the shipped diff, structure and
template conformance (with the plain-language / anti-"claudish" check folded in), link and index
integrity, and scope — reconciles their findings by lens, and hands them back. Resolve every
finding in the docs (a stale claim corrected, a broken link fixed, a bloated section trimmed) and
re-validate the corrected docs, exactly as `build` resolves a review finding in the task's own
diff. The docs do not leave this phase with an open finding.

## Commit the run's retro (unconditional)

Separate from — and not gated by — the judged feature-doc decision above, this phase **always**
writes the run's retro ledger entry: `docs/specs/<run-id>/retro.md`, the companion to the frozen
`docs/specs/<run-id>/spec.md` the `spec` phase committed at approval. `<run-id>` is the **full**
`.engineering/.current-run` value (`<YYYY-MM-DD>-<slug>`, date prefix included) — the same
collision-free directory the `spec` phase used, one per run.

This write is **unconditional**: it happens on every green run, whether or not a feature doc was
warranted — a run that records a docs **skip** still leaves a retro. Compose it per
`references/RETRO-FORMAT.md`, judging the run against its approved spec and the **shipped
whole-branch diff** (the same diff the accuracy validation reads): the front-matter spine, the
per-section accuracy verdicts, and the five cross-cutting axis sections. Keep it terse-by-default —
an axis with nothing notable gets one line — so writing it every run is never a chore.

Reaching this phase on a green branch means the run shipped, so **update the run's row in the
ledger index `docs/specs/toc.md`** in the same step — flip its `Shipped` column from `—` to `yes`
per `references/SPECS-TOC-FORMAT.md` — closing the loop the `spec` phase opened when it wrote the
row with `Shipped: —` at approval. The retro and the row-update ride the tip of the stack as their
own commit, like the feature docs; they add no human gate (the plan gate already authorized the
run).

## Hand off

Once the docs are produced and validated — or the run was skip-recorded — and the retro is
written, **hand off to `engineering:finish` now**. The documentation rides the tip of the stack as its own commit/PR;
`finish` opens or refreshes the stack and never merges. There is no gate at this seam: reaching
`finish` is the next act, take it.

## What this does not do

- It does not **write the docs itself.** Rendering the feature doc and upserting the toc is
  `using-documentation`'s job; this phase decides *whether*, mints the identity with the human, and
  validates the result.
- It does not **judge the code.** Whether the branch is correct and green is `build`'s and
  `finish`'s concern; this phase documents what shipped, it does not re-review it.
- It does not **hold a gate.** No human approval lives here — the plan gate already authorized the
  run.
- It does not **integrate the branch.** Opening pull requests and choosing the finish strategy is
  `finish`'s job, downstream.
