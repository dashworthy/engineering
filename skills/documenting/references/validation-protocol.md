# Validation protocol (reference)

Validates a feature doc the `documenting` phase just wrote or patched, through **four independent
lenses** — Accuracy, Structure, Links, and Scope — each looked at by its own sub-reviewer
dispatched in parallel, then reconciled into one report. This file is the **orchestrator**: it
slices what each lens needs, fans out one subagent per lens, and merges the returns. The judgement
each lens applies lives in its own lens doc under `lenses/`, not here. It mirrors
`build/references/review-protocol.md` — same fan-out-and-reconcile shape, applied to a doc instead
of a code diff.

## What this guarantees

One thing: given the doc(s) the phase produced and the change they describe, this protocol reviews
them through four separate lenses and returns findings grouped by which lens raised each one,
produced by independent sub-reviewers and reconciled into a single report. No lens is dropped
because its sub-reviewer came back empty; an empty return is a clean lens, not an absent one.

## The four lenses

Each lens is a self-contained reference under `lenses/`. A sub-reviewer is handed exactly one of
them plus only the material that lens needs (below).

- **`lenses/accuracy.md`** — does every claim in the doc hold against the code that actually
  shipped? Checked against the shipped whole-branch **diff**; a claim the diff contradicts, or a
  section describing behavior the change removed, is drift to flag.
- **`lenses/structure.md`** — does the doc conform to the feature-doc template and read well? Tiers
  present, reference table and toc row well-formed — and the prose is plain and human, not
  "claudish". The plain-language / anti-"claudish" check lives here.
- **`lenses/links.md`** — do the `docs/toc.md` row and every reference-table entry resolve to a
  file that exists? Dead links waste the reader (and the agent) this doc exists to save.
- **`lenses/scope.md`** — does the doc cover what this run changed, without ballooning into
  unrelated territory or duplicating another feature's doc?

Keep the four separate in the report — a reader trusting the Links findings should know nothing
about accuracy is hiding in them, and so on.

## The inline floor

On a trivial doc change — a single small doc, a handful of changed lines — four subagent spin-ups
plus a reconcile cost more than the review does. Below that floor, **apply all four lenses
yourself, inline**, reading each lens doc and judging the doc against it in one pass. Above it, fan
out.

## Dispatching the sub-reviewers

Above the floor, dispatch **one sub-reviewer per lens, in parallel**, following
`engineering:using-parallel-agents` for how the fan-out and the return are structured — that skill
owns the mechanics; this file supplies the split (one lens each) and the slice each needs, named by
absolute path so a cold subagent can resolve it:

| Lens | Gets |
|---|---|
| accuracy | the doc path(s) + the shipped whole-branch diff |
| structure | the doc path(s) + `FEATURE-DOC-TEMPLATE.md` |
| links | the doc path(s) + the `docs/` tree + `docs/toc.md` |
| scope | the doc path(s) + the run's spec and plan paths |

Each sub-reviewer returns findings scoped to its own lens, in the **shared finding grammar the
review-protocol already uses**: file and location, what's wrong, and why it bites. A reviewer that
notices a problem belonging to another lens hands it across as that lens's observation.

## Reconciling

Merge the four returns into one report: group findings by the lens that raised them, drop no lens
that came back empty (report it clean), carry no duplicate across lenses. The `documenting` phase
reads that report, fixes each finding in the doc, and re-validates the corrected doc.

## What this does not do

- It does not **fix what it finds.** A finding is a statement handed back to the `documenting`
  phase, which resolves it in the doc — this protocol judges, it does not edit.
- It does not **write the doc.** Producing the doc is `using-documentation`'s job, upstream of this
  validation.
- It does not **decide whether to document.** That judged call is the `documenting` phase's, before
  a doc exists to validate.
