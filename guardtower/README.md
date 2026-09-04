# Guardtower

A Claude Code plugin: an in-depth, **opt-in** code-review gate — the heavier escalation you
run deliberately before merging a higher-risk change, on top of whatever everyday review you
already do.

Guardtower reviews a change through a **menu of facets**, each a specialized reviewer with its
own lens. You pick which facets to run; each one relevance-gates itself, caps and floors its own
findings, writes a durable record under `.guardtower/<run>/<facet>/`, and **never edits your
code** — it reports, you decide.

## Install

```
/plugin marketplace add https://github.com/dashworthy/engineering
/plugin install guardtower@dashworthy
```

## Use

```
/guardtower <a diff, branch, or PR to review>
```

You're shown a facet menu (the four core facets pre-checked); guardtower fans out the selected
facets, then returns one reconciled report plus the per-facet artifacts under `.guardtower/`.

## The facets

| Facet | Asks |
|---|---|
| **Security** | OWASP best practices, and is authorization *enforced* rather than assumed? |
| **Novelty** | Did we reinvent something that already exists — a capability the framework, standard library, a depended-on library, or an already-imported module already provides? |
| **Technical** | Inefficient data access (N+1, unbounded queries), correctness-scoped best-practice adherence. |
| **Architectural** | Sustainable architecture — coupling, dependency direction, cohesion, leaky abstractions. |
| **Error Handling & Resilience** | Silent failures, swallowed exceptions, bad fallbacks. |
| **Test Quality** | Do the tests exercise the change and fail if it breaks? |
| **Data & Migration Safety** | Destructive/irreversible operations, data-loss risk. |
| **API & Backward Compatibility** | Breaking changes to public contracts. |
| **Concurrency & Race Safety** | Race conditions and unsafe interleaving — check-then-act, non-atomic read-modify-write, a compound operation missing its lock or transaction. |
| **Idempotency & Retry Safety** | Side effects unsafe to run twice — a consumer or webhook with no idempotency key, a non-idempotent retry, a duplicate on replay. |
| **Numeric Precision & Units** | Precision and unit defects — a binary float for money, silent rounding, a unit mismatch, integer overflow, a lossy cast. |
| **API Consumption** | Remote/HTTP API consumption — over-fetching, over-calling, doing the API's filtering client-side, and 429 rate-limit safety. |
| **Tenant Isolation (shared DB)** | Cross-tenant leaks in a single-database / shared-schema app — a query that lost its tenant scope. |
| **Tenant Isolation (isolated DB)** | Cross-tenant leaks in a database-per-tenant app — an operation on the wrong connection. |
| **Data Presentation** | Identity-ambiguous presentation — distinct records a person cannot tell apart. |
| **Accessibility** | Perceivability & operability for assistive tech — missing alt text or labels, ARIA/semantic misuse, keyboard/focus traps, insufficient contrast, unrespected reduced-motion, unannounced dynamic updates. |
| **Framework Best Practices** | Stack-specific idiom violations — Laravel and Tailwind today, more to follow. |

This release ships **seventeen** facets — the four **core** (**Security**, **Novelty**, **Technical**,
**Architectural**), pre-checked by default, plus **Error Handling & Resilience**, **Test Quality**,
**Data & Migration Safety**, **API & Backward Compatibility**, **Concurrency & Race Safety**,
**Idempotency & Retry Safety**, **Numeric Precision & Units**, and **API Consumption** — on the
shared review spine. The
two **Tenant Isolation** facets are **proposed automatically**: guardtower classifies the repo's
tenancy model once per run and pre-checks the matching facet (shared-DB or database-per-tenant), or
neither when the app is single-tenant — a repo-level menu-proposal gate above each facet's own
per-change relevance check. **Framework Best Practices** is proposed the same way, against a
separate classification of which framework(s) the repo runs — pre-checked when at least one
covered stack (Laravel or Tailwind) is detected, absent from the menu otherwise. **Data
Presentation** and **Accessibility** are always in the menu, opt-in.

## Design principles

- **Token-disciplined by construction.** Each facet decides its own relevance and *skips* before
  spending tokens when a change doesn't warrant it, then reports only its most severe findings
  above a confidence floor — no exhaustive enumeration of nits.
- **Report-only.** Guardtower writes findings, never fixes; applying them is a separate,
  human-decided step.
- **Language-agnostic.** Facets reason from general principles and what they can read; no
  framework or stack is baked in.
- **A durable record.** Every run leaves an inspectable trail under `.guardtower/<run>/`.

The architecture is an orchestrator over self-limiting facets: each facet decides its own
relevance, then caps and floors its own findings before returning, and the orchestrator only
reconciles what they hand back.

## License

MIT. See [LICENSE](../LICENSE).
