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

Seventeen facets exist; each is one lens, defined in a reference file under
[references/facets/](references/facets/) (`references/facets/<facet>/facet.md`), and dispatched as
an independent reviewer — not a standalone skill. The four **core** facets (**Security**,
**Novelty**, **Technical**, **Architectural**) are pre-checked by default; eight additional facets (**Error Handling
& Resilience**, **Test Quality**, **Data & Migration Safety**, **API & Backward Compatibility**,
**Concurrency & Race Safety**, **Idempotency & Retry Safety**, **Numeric Precision & Units**,
**API Consumption**) are
selectable per run; two **tenant-isolation** facets are **core-when-present** — proposed and
pre-checked only when the repo-level detection step finds the matching tenancy model (see the
menu-proposal step in the workflow); the **Framework Best Practices** facet is likewise
**core-when-present** — proposed and pre-checked only when the repo-level stack classification
finds at least one covered framework (Laravel and Tailwind today) — and the **Data Presentation**
and **Accessibility** facets are always in the menu, opt-in and not tenancy- or stack-gated.

| Facet (file) | Lens | Core? |
|---|---|---|
| [`reviewing-security`](references/facets/reviewing-security/facet.md) | OWASP best practices; authorization enforced, not assumed | core |
| [`reviewing-novelty`](references/facets/reviewing-novelty/facet.md) | Reuse over reinvention: reinventing what the framework, standard library, a depended-on library, or an already-imported module already provides | core |
| [`reviewing-technical`](references/facets/reviewing-technical/facet.md) | Inefficient data access (N+1, unbounded queries); correctness-scoped best practice | core |
| [`reviewing-architectural`](references/facets/reviewing-architectural/facet.md) | Sustainable architecture: coupling, dependency direction, cohesion, leaky abstractions | core |
| [`reviewing-error-handling`](references/facets/reviewing-error-handling/facet.md) | Silent failures, swallowed exceptions, bad fallbacks | — |
| [`reviewing-test-quality`](references/facets/reviewing-test-quality/facet.md) | Do tests exercise the change and fail if it breaks? | — |
| [`reviewing-data-safety`](references/facets/reviewing-data-safety/facet.md) | Destructive/irreversible ops, migrations, data loss | — |
| [`reviewing-api-compat`](references/facets/reviewing-api-compat/facet.md) | Breaking changes to public contracts | — |
| [`reviewing-concurrency`](references/facets/reviewing-concurrency/facet.md) | Race conditions and unsafe interleaving: check-then-act, non-atomic read-modify-write, missing lock/transaction | — |
| [`reviewing-idempotency`](references/facets/reviewing-idempotency/facet.md) | Side effects unsafe to run twice: no idempotency key, non-idempotent retry, duplicate on replay | — |
| [`reviewing-numeric-precision`](references/facets/reviewing-numeric-precision/facet.md) | Precision and unit defects: float for money, silent rounding, unit mismatch, overflow, lossy cast | — |
| [`reviewing-api-consumption`](references/facets/reviewing-api-consumption/facet.md) | Remote/HTTP API consumption: over-fetch, doing the API's filtering client-side, excessive call volume, 429 rate-limit safety | — |
| [`reviewing-tenant-isolation-shared-db`](references/facets/reviewing-tenant-isolation-shared-db/facet.md) | Cross-tenant leaks in a single-DB / shared-schema app: a query that lost its tenant scope | core-when-present |
| [`reviewing-tenant-isolation-isolated-db`](references/facets/reviewing-tenant-isolation-isolated-db/facet.md) | Cross-tenant leaks in a database-per-tenant app: an operation on the wrong connection | core-when-present |
| [`reviewing-data-presentation`](references/facets/reviewing-data-presentation/facet.md) | Identity-ambiguous presentation: distinct records a person can't tell apart | — |
| [`reviewing-accessibility`](references/facets/reviewing-accessibility/facet.md) | Accessibility: perceivability & operability — alt text, labels, ARIA/semantics, keyboard/focus, contrast, reduced-motion, live-region announcements | — |
| [`reviewing-framework-best-practices`](references/facets/reviewing-framework-best-practices/facet.md) | Stack-specific idiom violations for the detected framework(s) — Laravel and Tailwind today | core-when-present |

## The workflow

1. **Classify the tenancy model and the stack — the menu-proposal gate.** Before building the
   menu, decide once, at the **repo level**: whether this application is multi-tenant and how it
   isolates tenants, reasoning against
   [references/multi-tenancy-signals.md](references/multi-tenancy-signals.md); and which
   framework(s) it runs, reasoning against
   [references/stack-signals.md](references/stack-signals.md). Both are **agent-driven** (weigh
   the signals in the codebase), never a shell script. Emit the tenancy verdict — `shared`,
   `per-db`, `both`, `none`, or `ambiguous` — and on `ambiguous` ask the human once; separately
   emit the stack verdict as a **set** of matched frameworks (zero or more of `laravel`,
   `tailwind`), never a single mutually-exclusive value, since a repo can run more than one at
   once. The tenancy verdict governs only which tenant facets the menu proposes and pre-checks:
   `shared` → the shared-DB facet, `per-db` → the isolated-DB facet, `both` → both, `none` →
   neither. The stack verdict governs only whether `reviewing-framework-best-practices` is
   proposed and pre-checked: any non-empty set → proposed; an empty set → not on the menu at all.
   This is the upper of guardtower's **two-gate** model: a repo-level menu-proposal gate that sits
   *above* each facet's own per-change relevance gate — a proposed facet still self-skips on a
   change that touches no tenant-scoped or stack-relevant surface, so proposing is not running.
2. **Pick the facets.** Present the facet menu as a structured multi-select choice, using a tool to
   ask it where one is available, with the
   four **core** facets **pre-checked**, plus any tenant-isolation facet the menu-proposal step
   above proposed (pre-checked when proposed), plus `reviewing-framework-best-practices` when the
   stack classification found at least one match (pre-checked when proposed). The **Data
   Presentation** and **Accessibility** facets are always offered, opt-in. The human unchecks or
   adds; only available facets run (a not-yet-available pick is reported as skipped, not failed).
3. **Resolve the change and the run.** Resolve `change_ref` once (the diff/branch/PR under review).
   Create the run directory with `run-context.sh` — the per-facet path is
   `.guardtower/<run>/<facet>/findings.md`, where `<facet>` is the facet's identifier (e.g.
   `reviewing-security`).
4. **Decide fan-out vs. inline.** On a small change — roughly one file, ~20 changed lines or fewer,
   one hunk — reviewing every selected facet inline costs less than spinning up subagents; do it
   inline. Above that floor, **fan out** the selected facets in parallel, following
   `dispatching-parallel-agents` (facets share only a *read* of `change_ref`, so the independence
   gate holds — no facet reads what another writes). Mark each facet's todo `in_progress` as it
   goes out, or as you begin it inline.
5. **Hand each facet the contract.** Each selected facet is defined by its file
   `references/facets/<facet>/facet.md`; dispatch a reviewer by handing it that file to read and
   apply. Pass every facet the same request and expect the same result shape — see
   [references/facet-contract.md](references/facet-contract.md). Each facet enforces the hard stops
   itself, at the source — see [references/hard-stops.md](references/hard-stops.md); the
   orchestrator does not trim findings afterward.
6. **Reconcile.** Gather all results — nothing dropped because it returned last, nothing picked
   because it returned first; mark each facet's todo `completed` as its result lands. Deduplicate
   where two facets flag the same location, order the findings, and present **one** report alongside
   the durable per-facet artifacts. Reconciliation is the one thing a facet does not own; it needs
   every result at once.

## Track each facet as a todo

The fan-out is legible to the human only if they can see what was dispatched and what has come
back. The moment the facet set is fixed (after step 2), seed a todo list from it — **one todo per
selected facet, each seam its own item** — in whatever todo list your harness provides. A pick the
menu reported as unavailable never ran and never becomes a todo; a facet that will self-skip on its
own relevance gate still gets one, and closes when it returns "nothing to review."

Keep the list in lockstep with the dispatch, the way `executing-plans` keeps todos beside a plan:

- **`in_progress` as the facet is dispatched** — in fan-out that is several at once, one per
  reviewer in flight (step 4); inline it is one at a time as you work down the set.
- **`completed` the instant its `findings.md` is written and its result is in hand** (step 6), a
  self-skip included — so a facet that finished with nothing reads as done, never as still running.

Reconciliation is not a facet and takes no todo of its own; it is the step that consumes every
completed item at once.

## Governing principle

Keep the self-enforcement shape (workflow step 5) when changing a facet boundary or adding a facet:
a cap the orchestrator applies after a facet has already done unbounded work saves output, not the
work.

## What this does not do

- It does not **fix what it finds.** Findings are handed back; applying them, and deciding whether
  to, belongs to the caller (engineering's `receiving-code-review` is a natural downstream).
- It does not **decide when a review happens**, and it does not **stand in for sign-off.** A clean
  report is information a human uses to decide whether to merge, not a switch this skill throws.
