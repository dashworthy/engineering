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

Thirteen facets exist; each is a thin skill owning one lens. The three **core** facets (**Security**,
**Technical**, **Architectural**) are pre-checked by default; seven additional facets (**Error Handling
& Resilience**, **Test Quality**, **Data & Migration Safety**, **API & Backward Compatibility**,
**Concurrency & Race Safety**, **Idempotency & Retry Safety**, **Numeric Precision & Units**) are
selectable per run; two **tenant-isolation** facets are **core-when-present** — proposed and
pre-checked only when the repo-level detection step finds the matching tenancy model (see the
menu-proposal step in the workflow); and the **Data Presentation** facet is always in the menu,
opt-in and not tenancy-gated.

| Facet (skill) | Lens | Core? |
|---|---|---|
| `reviewing-security` | OWASP best practices; authorization enforced, not assumed | core |
| `reviewing-technical` | Reuse over reinvention; inefficient queries; best practice | core |
| `reviewing-architectural` | Sustainable architecture: coupling, dependency direction, cohesion, leaky abstractions | core |
| `reviewing-error-handling` | Silent failures, swallowed exceptions, bad fallbacks | — |
| `reviewing-test-quality` | Do tests exercise the change and fail if it breaks? | — |
| `reviewing-data-safety` | Destructive/irreversible ops, migrations, data loss | — |
| `reviewing-api-compat` | Breaking changes to public contracts | — |
| `reviewing-concurrency` | Race conditions and unsafe interleaving: check-then-act, non-atomic read-modify-write, missing lock/transaction | — |
| `reviewing-idempotency` | Side effects unsafe to run twice: no idempotency key, non-idempotent retry, duplicate on replay | — |
| `reviewing-numeric-precision` | Precision and unit defects: float for money, silent rounding, unit mismatch, overflow, lossy cast | — |
| `reviewing-tenant-isolation-shared-db` | Cross-tenant leaks in a single-DB / shared-schema app: a query that lost its tenant scope | core-when-present |
| `reviewing-tenant-isolation-isolated-db` | Cross-tenant leaks in a database-per-tenant app: an operation on the wrong connection | core-when-present |
| `reviewing-data-presentation` | Identity-ambiguous presentation: distinct records a person can't tell apart | — |

## The workflow

1. **Classify the tenancy model — the menu-proposal gate.** Before building the menu, decide once,
   at the **repo level**, whether this application is multi-tenant and how it isolates tenants —
   reasoning against [references/multi-tenancy-signals.md](references/multi-tenancy-signals.md).
   This is **agent-driven** (weigh the signals in the codebase), never a shell script. Emit one
   verdict — `shared`, `per-db`, `both`, `none`, or `ambiguous` — and on `ambiguous` ask the human
   once. The verdict governs only which tenant facets the menu proposes and pre-checks: `shared` →
   the shared-DB facet, `per-db` → the isolated-DB facet, `both` → both, `none` → neither. This is
   the upper of guardtower's **two-gate** model: a repo-level menu-proposal gate that sits *above*
   each facet's own per-change relevance gate — a proposed facet still self-skips on a change that
   touches no tenant-scoped surface, so proposing is not running.
2. **Pick the facets.** Present the facet menu through `AskUserQuestion` (multi-select), with the
   three **core** facets **pre-checked**, plus any tenant-isolation facet the menu-proposal step
   above proposed (pre-checked when proposed). The **Data Presentation** facet is always offered,
   opt-in. The human unchecks or adds; only available facets run (a not-yet-available pick is
   reported as skipped, not failed).
3. **Resolve the change and the run.** Resolve `change_ref` once (the diff/branch/PR under review).
   Create the run directory with `run-context.sh` — the per-facet path is
   `.guardtower/<run>/<facet-skill>/findings.md`.
4. **Decide fan-out vs. inline.** On a small change — roughly one file, ~20 changed lines or fewer,
   one hunk — reviewing every selected facet inline costs less than spinning up subagents; do it
   inline. Above that floor, **fan out** the selected facets in parallel, following
   `dispatching-parallel-agents` (facets share only a *read* of `change_ref`, so the independence
   gate holds — no facet reads what another writes).
5. **Hand each facet the contract.** Pass every facet the same request and expect the same result
   shape — see [references/facet-contract.md](references/facet-contract.md). Each facet enforces
   the hard stops itself, at the source — see [references/hard-stops.md](references/hard-stops.md);
   the orchestrator does not trim findings afterward.
6. **Reconcile.** Gather all results — nothing dropped because it returned last, nothing picked
   because it returned first. Deduplicate where two facets flag the same location, order the
   findings, and present **one** report alongside the durable per-facet artifacts. Reconciliation
   is the one thing a facet does not own; it needs every result at once.

## Governing principle

Keep the self-enforcement shape (workflow step 5) when changing a facet boundary or adding a facet:
a cap the orchestrator applies after a facet has already done unbounded work saves output, not the
work.

## What this does not do

- It does not **fix what it finds.** Findings are handed back; applying them, and deciding whether
  to, belongs to the caller (engineering's `receiving-code-review` is a natural downstream).
- It does not **decide when a review happens**, and it does not **stand in for sign-off.** A clean
  report is information a human uses to decide whether to merge, not a switch this skill throws.
