# Retro format

**Every committed spec earns a companion `retro.md` — written when the run ships, it judges the
finished work against the spec on two fronts (how each spec section held up, plus five cross-cutting
axes) so the spec ledger records not just what we said we'd build but how it actually went.** This
reference is the contract `documenting` composes to write
`docs/specs/<run-id>/retro.md`; it is *read* later by the standalone `engineering-retro` analyzer,
which scans the last several `spec.md` + `retro.md` pairs to find where specs fell short and propose
pipeline improvements. So the format is a **producer/consumer boundary**, shaped to be human-readable
*and* aggregable across runs — without freezing a taxonomy the analyzer is meant to discover.

Render it per the shared conventions in `../../../references/consumable-markdown.md`.

---

## Where it lives

`docs/specs/<run-id>/retro.md`, beside the frozen `docs/specs/<run-id>/spec.md`. `<run-id>` is the
full run id — the `.engineering/.current-run` value `<YYYY-MM-DD>-<slug>`, date prefix included, one
directory per run (see the `spec` skill). `documenting` writes it on the green branch from the run's **approved
spec** plus the **shipped whole-branch diff** — so the retro describes what actually landed, not what
was intended.

## The shape

    ---
    spec: <run-id>
    shipped: <true|false>
    diff: <base>..<tip> (PR #NNN)
    ---
    # Retro — <run-id>

    ## §0 ELI5 — <verdict>
    <prose: the why>
    ## §1 Problem — <verdict>
    <prose>
    ## … one entry per spec section that warrants one …

    ## Process friction & cost
    - <symptom> → <suspected cause> → <candidate capability/feature that would have prevented it> [phase: <phase>]
    ## Rework & churn
    - <re-designs, re-plans, review rejections, mid-build reversals>
    ## Scope fidelity
    - <did §5 In/Out/Deferred hold; non-goals pulled in; deferred dragged forward; creep>
    ## Gate correction load
    - <spec gate + plan gate: rounds and magnitude of human correction>
    ## Assumption & open-question outcomes
    - <§8 open questions + baseline assumptions: resolved / bit us / never revisited>

## Front-matter spine

Three keys — and only these three — because they are the only facts stable and knowable at write
time regardless of who later reads the file. They give the analyzer a machine-readable join without
committing the format to anything speculative.

| Key | Meaning |
|---|---|
| `spec:` | The paired run id (`<YYYY-MM-DD>-<slug>`) — the **join key** to `docs/specs/<run-id>/spec.md`. |
| `shipped:` | Boolean — did the run actually ship. |
| `diff:` | The shipped-diff reference (commit range and/or PR number) the retro was judged against. |

## Group A — per-section accuracy

The body **mirrors the spec's own sections** (§0–§8). SPEC-FORMAT is stable, so the spec's section
structure is the natural, already-existing schema — no invented taxonomy. Each section that warrants
an entry carries a **closed-set verdict** in its heading, then prose for the *why*:

| Verdict | Means |
|---|---|
| `held` | The section matched what shipped. |
| `drifted` | Shipped work diverged from what the section said. |
| `underspecified` | The section was too thin/vague and the gap bit during build or ship. |
| `n-a` | Nothing to say for this section. |

The verdict set stays this **coarse on purpose**: discovering the *kinds* of shortfall is
`engineering-retro`'s job, not this format's. The format supplies a groupable spine; the analysis
stays in the prose.

## Group B — five cross-cutting axes

Five sections, each a different lens on "where we fell short", each its own `##` heading. All stay
**prose with a light per-entry convention** (a symptom, then a suspected cause/fix), so the analyzer
mines recurring patterns across runs rather than the format dictating conclusions.

| Section | Captures | Feeds |
|---|---|---|
| `## Process friction & cost` | Where the run was costly/wasteful ("burned a lot of tokens/effort figuring out X"), each entry naming a **candidate capability/feature that would have prevented it**, optionally phase-tagged. | Pipeline capability gaps — the primary fuel for `engineering-retro`. |
| `## Rework & churn` | Loop-backs: re-designs, re-plans, build-review rejections, mid-build reversals. | Where the spec/plan wasn't stable to build from. |
| `## Scope fidelity` | Whether §5 In/Out/Deferred held: non-goals pulled in, deferred dragged forward, increments that grew. | Scope discipline. |
| `## Gate correction load` | How much the human corrected at the spec and plan gates (rounds, magnitude). | Whether the upstream phase (signal/triage/brainstorming) did its job — the sharpest "improve the entrances" signal. |
| `## Assumption & open-question outcomes` | The spec's §8 open questions and baseline assumptions: which resolved cleanly, which bit us, which were never revisited. | Catches specs shipped on guesses. |

## Terse by default

`documenting` writes `retro.md` on **every** run, so the format must never become a chore that
pressures invented content. An axis with nothing notable gets **one line** ("nothing notable"),
not a manufactured entry. A retro is still worth committing when every Group-A section `held`,
because Group B often carries signal even when the spec was accurate.

## Why this shape (leak note)

The 4-value verdict is a **designed** contract (intentional exposure), not accidental leakage; the
join key is the spec section, stable because SPEC-FORMAT is stable and unchanged. A rigid typed
taxonomy was rejected — it would pre-empt `engineering-retro`'s job of discovering shortfall
categories and over-fit a consumer not yet built; a free-form narrative was rejected — it gives the
analyzer no stable keys to aggregate across runs.

## Worked example

    ---
    spec: 2026-09-11-commit-specs-retro
    shipped: true
    diff: <base>..<tip> (PR #NNN)
    ---
    # Retro — commit-specs-retro

    ## §1 Problem — held
    Matched what shipped: specs were ephemeral, now committed.
    ## §3 Success Criteria — underspecified
    "indexed/discoverable" didn't pin the index format; resolved late during build.
    ## §6 Approach — drifted
    Wrote retro.md in documenting as planned, but the ledger key changed from a bare slug to the full dated run id.

    ## Process friction & cost
    - Burned several rounds re-deriving where docs/ lived and how documenting writes it.
      Suspected fix: a cheaper "map the docs tree" consult primitive up front. [phase: brainstorming]
    ## Rework & churn
    - Retro format revisited once (added four axes at the spec gate). Otherwise stable.
    ## Scope fidelity
    - Held. Non-goals (no backfill, SPEC-FORMAT untouched) held; engineering-retro stayed deferred.
    ## Gate correction load
    - Spec gate: 1 "request changes" (retro axes). Plan gate: nothing notable.
    ## Assumption & open-question outcomes
    - §8 slug-collision: resolved in plan. Baseline "bare slug key": wrong, revised to the full dated run id.
