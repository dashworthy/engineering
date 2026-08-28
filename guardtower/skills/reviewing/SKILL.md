---
name: reviewing
description: "Run guardtower's in-depth, opt-in review of a change through a menu of specialized facets (security, and more) fanned out as self-limiting reviewers, then reconcile their findings into one report. Use when asked for a deep/guardtower review of a diff, branch, or PR, or a security review, before merging a higher-risk change."
---

# Reviewing (guardtower orchestrator)

Say this first, plainly: `Using the guardtower reviewing skill to run the deep review.`

## What this guarantees

One thing: given a change — a diff, a branch, a PR, whatever the caller points at — this skill
lets the human pick which review facets to run, dispatches each selected facet as an independent
reviewer, and reconciles what they return into a single report, with every facet's findings also
written to a durable per-facet artifact under `.guardtower/<run>/`. It is **report-only**: it
states what each facet found and never edits the code.

This is the heavier, opt-in escalation — not an everyday pass, and not an automatic gate. Someone
decides a change is worth a deep look and runs it; nothing here watches for changes on its own.

## The facets

Seven facets exist; each is a thin skill owning one lens. This release wires all three **core**
facets — **Security**, **Technical**, and **Architectural**; the rest are listed but not yet
available.

| Facet (skill) | Lens | Core? |
|---|---|---|
| `reviewing-security` | OWASP best practices; authorization enforced, not assumed | core |
| `reviewing-technical` | Reuse over reinvention; inefficient queries; best practice | core |
| `reviewing-architectural` | Sustainable architecture: coupling, dependency direction, cohesion, leaky abstractions | core |
| `reviewing-error-handling` *(coming soon)* | Silent failures, swallowed exceptions, bad fallbacks | — |
| `reviewing-test-quality` *(coming soon)* | Do tests exercise the change and fail if it breaks? | — |
| `reviewing-data-safety` *(coming soon)* | Destructive/irreversible ops, migrations, data loss | — |
| `reviewing-api-compat` *(coming soon)* | Breaking changes to public contracts | — |

## The workflow

1. **Pick the facets.** Present the facet menu through `AskUserQuestion` (multi-select), with the
   three **core** facets **pre-checked**. The human unchecks or adds; only available facets run
   (a not-yet-available pick is reported as skipped, not failed).
2. **Resolve the change and the run.** Resolve `change_ref` once (the diff/branch/PR under review).
   Create the run directory with `run-context.sh` — the per-facet path is
   `.guardtower/<run>/<facet-skill>/findings.md`.
3. **Decide fan-out vs. inline.** On a small change — roughly one file, ~20 changed lines or fewer,
   one hunk — reviewing every selected facet inline costs less than spinning up subagents; do it
   inline. Above that floor, **fan out** the selected facets in parallel, following
   `dispatching-parallel-agents` (facets share only a *read* of `change_ref`, so the independence
   gate holds — no facet reads what another writes).
4. **Hand each facet the contract.** Pass every facet the same request and expect the same result
   shape — see [references/facet-contract.md](references/facet-contract.md). Each facet enforces
   the hard stops itself, at the source — see [references/hard-stops.md](references/hard-stops.md);
   the orchestrator does not trim findings afterward.
5. **Reconcile.** Gather all results — nothing dropped because it returned last, nothing picked
   because it returned first. Deduplicate where two facets flag the same location, order the
   findings, and present **one** report alongside the durable per-facet artifacts. Reconciliation
   is the one thing a facet does not own; it needs every result at once.

## Governing decision

The orchestrator-plus-self-limiting-facets shape, and why each facet enforces its own hard stops
rather than the orchestrator trimming afterward, is recorded in
`docs/adr/0003-guardtower-orchestrator-with-self-limiting-facets.md`. Read it before changing the
facet boundary or adding a facet.

## What this does not do

- It does not **fix what it finds.** Findings are handed back; applying them, and deciding whether
  to, belongs to the caller (engineering's `receiving-code-review` is a natural downstream).
- It does not **trim a facet's findings.** The relevance gate, the top-N cap, and the confidence
  floor all run inside each facet, before it returns. The orchestrator only reconciles.
- It does not **decide when a review happens**, and it does not **stand in for sign-off.** A clean
  report is information a human uses to decide whether to merge, not a switch this skill throws.
