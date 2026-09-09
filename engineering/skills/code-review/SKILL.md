---
name: code-review
description: "Run code-review's in-depth, opt-in review of a change through a menu of specialized facets (security, and more) fanned out as self-limiting reviewers, then reconcile their findings into one report. Use when asked for a deep/code-review review of a diff, branch, or PR, or a security review, before merging a higher-risk change. Accepts an optional effort level (low/medium/high/max) and an optional target (a PR/MR link or number, branch, diff, or path)."
---

# Code Review (orchestrator)

Say this first, plainly: `Using the code-review skill to run the deep review.`

## What this guarantees

One thing: given a change — a diff, a branch, a PR, whatever the caller points at — this skill
lets the human pick which review facets to run, dispatches each selected facet as an independent
reviewer, and reconciles what they return into a single report, with every facet's findings also
written to a durable per-facet artifact under `.engineering/<run>/`. It is **report-only**: it
states what each facet found and never edits the code.

This is the heavier, opt-in escalation — not an everyday pass, and not an automatic gate. Someone
decides a change is worth a deep look and runs it; nothing here watches for changes on its own.

## Arguments

The skill accepts two optional arguments, in either order; both have sensible defaults, so it also
runs with none.

- **effort** — `low` | `medium` | `high` | `max` (default `medium`). One dial that sets the `caps`
  the orchestrator hands every facet (`top_n`, `floor` — see
  [references/facet-contract.md](references/facet-contract.md)), trading breadth for signal in one
  place rather than per facet. Lower effort returns fewer, higher-confidence findings; higher effort
  widens coverage and admits less-certain ones:

  | effort | `top_n` | `floor` | character |
  |---|---|---|---|
  | `low` | 2 | `high` | only the few strongest findings per facet |
  | `medium` | 3 | `med` | the default balance |
  | `high` | 5 | `low` | broad coverage, admits lower-confidence findings |
  | `max` | 8 | `low` | the widest pass; report may run long |

  effort tunes only the caps — it never changes which facets are selected (that is the menu, workflow
  steps 1–2). The floor still applies to the *weaker* of a finding's severity and confidence.

- **target** — an optional pointer to what to review, resolved into `change_ref`: a PR/MR link or
  number, a branch name, a diff, or a path. When omitted, `change_ref` falls back to the working
  diff / current branch as before. A PR/MR target is also what makes the **Post to the PR** route
  (workflow step 7) available.

Parse whatever the caller passed: a bare `low`/`medium`/`high`/`max` token is the effort; anything
that looks like a URL, `#`-number, branch, path, or ref is the target. When either is absent, use
its default. If a token is genuinely ambiguous, ask once rather than guess.

## The facets

Nineteen facets exist; each is one lens, defined in a reference file under
[references/facets/](references/facets/) (`references/facets/<facet>/facet.md`), and dispatched as
an independent reviewer — not a standalone skill. Eight **core** facets — **Security**, **Novelty**,
**Technical**, **Architectural**, **Error Handling & Resilience**, **Test Quality**, **Concurrency &
Race Safety**, and **Numeric Precision & Units** — are **always** pre-checked, whatever the change.
The remaining opt-in facets are pre-checked only when the change's character matches, per the
**Pre-check when the change…** column of the facet list below. Two **tenant-isolation** facets and
the **Framework Best Practices** facet are **core-when-present** — pre-checked only when the
repo-level menu-proposal step (workflow step 1) proposes them: the matching tenancy model, or at
least one covered framework (Laravel and Tailwind today). **Data Presentation**, **Accessibility**,
**Internationalization (translations)**, and **Electron** are opt-in, pre-checked by the same
character match as the other opt-in facets.

Which of these arrive **pre-checked** on a given run is not a fixed default: it is decided by the
**Pre-check when the change…** column of the facet list below, which the orchestrator reads at
menu-fill time (workflow step 2) to pre-fill the menu from the character of the change under review.
Keeping the pre-check condition in the facet list itself — the orchestrator's own doc, already
loaded — lets the pre-fill decide **without opening any facet's file**; a facet's own doc is read
only once that facet is actually dispatched (step 5), never merely to guess whether to run it, so a
review does not pay to load seventeen facet docs to choose the ones it will use. The condition names
the **character of the change** — *what the change does* — never a path, file type, directory, or
glob, since that would falsely skip a facet the moment a repo is laid out or named unexpectedly. Err
toward pre-checking: a false skip (a lens left off) is the harmful direction, while a false-positive
self-skips cheaply at dispatch — each facet's own relevance gate stays authoritative there — or the
human unchecks it. The human still confirms or overrides the pre-filled set.

| Facet (file) | Lens | Pre-check when the change… |
|---|---|---|
| [`reviewing-security`](references/facets/reviewing-security/facet.md) | OWASP best practices; authorization enforced, not assumed | **Always** (core) |
| [`reviewing-novelty`](references/facets/reviewing-novelty/facet.md) | Reuse over reinvention: reinventing what the framework, standard library, a depended-on library, or an already-imported module already provides | **Always** (core) |
| [`reviewing-technical`](references/facets/reviewing-technical/facet.md) | Inefficient data access (N+1, unbounded queries); correctness-scoped best practice | **Always** (core) |
| [`reviewing-architectural`](references/facets/reviewing-architectural/facet.md) | Sustainable architecture: coupling, dependency direction, cohesion, leaky abstractions | **Always** (core) |
| [`reviewing-error-handling`](references/facets/reviewing-error-handling/facet.md) | Silent failures, swallowed exceptions, bad fallbacks | **Always** (core) |
| [`reviewing-test-quality`](references/facets/reviewing-test-quality/facet.md) | Do tests exercise the change and fail if it breaks? | **Always** (core) |
| [`reviewing-data-safety`](references/facets/reviewing-data-safety/facet.md) | Destructive/irreversible ops, migrations, data loss | alters stored-data structure or performs a destructive or irreversible data operation — a migration, a bulk update/delete, a drop |
| [`reviewing-api-compat`](references/facets/reviewing-api-compat/facet.md) | Breaking changes to public contracts | alters a public contract others consume — an exported signature, a response shape or status, or a serialized form |
| [`reviewing-concurrency`](references/facets/reviewing-concurrency/facet.md) | Race conditions and unsafe interleaving: check-then-act, non-atomic read-modify-write, missing lock/transaction | **Always** (core) |
| [`reviewing-idempotency`](references/facets/reviewing-idempotency/facet.md) | Side effects unsafe to run twice: no idempotency key, non-idempotent retry, duplicate on replay | performs a side effect that may run more than once — a retry, a queued/at-least-once handler, or a replayable operation — with no guard against duplication |
| [`reviewing-numeric-precision`](references/facets/reviewing-numeric-precision/facet.md) | Precision and unit defects: float for money, silent rounding, unit mismatch, overflow, lossy cast | **Always** (core) |
| [`reviewing-api-consumption`](references/facets/reviewing-api-consumption/facet.md) | Remote/HTTP API consumption: over-fetch, doing the API's filtering client-side, excessive call volume, 429 rate-limit safety | consumes a remote/HTTP API it does not own — issuing calls, fetching, filtering, or paging over a service |
| [`reviewing-tenant-isolation-shared-db`](references/facets/reviewing-tenant-isolation-shared-db/facet.md) | Cross-tenant leaks in a single-DB / shared-schema app: a query that lost its tenant scope | When **step 1 proposed it** (a `shared`/`both` tenancy verdict) — on the proposal, not further gated on the change |
| [`reviewing-tenant-isolation-isolated-db`](references/facets/reviewing-tenant-isolation-isolated-db/facet.md) | Cross-tenant leaks in a database-per-tenant app: an operation on the wrong connection | When **step 1 proposed it** (a `per-db`/`both` tenancy verdict) — on the proposal |
| [`reviewing-data-presentation`](references/facets/reviewing-data-presentation/facet.md) | Identity-ambiguous presentation: distinct records a person can't tell apart | alters how records are labeled or identified to a person — a list, selection, or display where distinct records could become indistinguishable |
| [`reviewing-accessibility`](references/facets/reviewing-accessibility/facet.md) | Accessibility: perceivability & operability — alt text, labels, ARIA/semantics, keyboard/focus, contrast, reduced-motion, live-region announcements | alters user-facing rendered output — markup, components, or interactions affecting perceivability or operability (labels, alt text, focus, contrast, motion) |
| [`reviewing-i18n`](references/facets/reviewing-i18n/facet.md) | Internationalization (translations): user-facing text hard-coded instead of routed through the translation layer; untranslatable message shapes (concatenation, plurals, word order); locale-blind date/number/currency formatting | introduces or alters text shown to a person — a label, message, button, error, or notification body — where the project localizes such text (or plainly should) |
| [`reviewing-electron`](references/facets/reviewing-electron/facet.md) | Electron: process-model & security hardening (renderer isolation, preload/context-bridge exposure, IPC trust, navigation, shell/protocol, insecure content) plus non-security best practices (main/renderer split, main-thread blocking, lifecycle, packaging) | touches an Electron process-model or security surface — renderer isolation, preload/context-bridge, IPC, navigation, shell/protocol, packaging, or the main/renderer split |
| [`reviewing-framework-best-practices`](references/facets/reviewing-framework-best-practices/facet.md) | Stack-specific idiom violations for the detected framework(s) — Laravel and Tailwind today | When **step 1 proposed it** (at least one covered stack detected) — on the proposal |

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
   This is the upper of code-review's **two-gate** model: a repo-level menu-proposal gate that sits
   *above* each facet's own per-change relevance gate — a proposed facet still self-skips on a
   change that touches no tenant-scoped or stack-relevant surface, so proposing is not running.
2. **Resolve the change, then pre-fill the facet menu.** First resolve `change_ref` (the
   diff/branch/PR under review) — from the **target** argument when one was passed (a PR/MR link or
   number, branch, diff, or path), otherwise the working diff / current branch — so the pre-fill can
   read what the change actually does. Then
   **pre-fill** the menu instead of asking the human to pick from scratch: read the **Pre-check when
   the change…** column of the facet list above and reason over the change's character (*what it
   does*, never its file paths or types) together with the step-1 tenancy/stack verdicts, to decide
   which facets arrive pre-checked:
   - the **core** facets (the eight marked **Always** in the list) are **pre-checked** on every run,
     whatever the change;
   - each **opt-in** facet whose list entry matches the change's character is pre-checked,
     erring toward inclusion — a false skip (a lens left off) is the harmful direction, while a
     false-positive self-skips cheaply at dispatch or is unchecked by the human here;
   - each **core-when-present** facet (the two tenant-isolation facets and
     `reviewing-framework-best-practices`) is pre-checked when the step-1 menu-proposal gate
     proposed it — the proposal is its list entry, so it is *not* further gated on the change's
     character; a proposed facet pre-checks exactly as it did before auto-assignment.

   When no opt-in entry clearly matches, or the change cannot be read, **fall back** to the
   original defaults — the core facets plus any core-when-present facet step 1 proposed. This
   floor is a genuine guarantee, not just the fallback's: because core and step-1-proposed
   core-when-present facets are always pre-checked and auto-assignment only ever *adds* matched
   opt-in facets on top, a run is **never pre-filled with fewer** facets than it would have been
   before auto-assignment.
   Present the pre-filled set as a structured **multi-select choice**, using a tool to ask it where
   one is available; the human unchecks or adds, and only available facets run (a not-yet-available
   pick is reported as skipped, not failed). The facet list only pre-fills the menu — each facet's
   own per-change relevance gate **stays authoritative** at dispatch, so a pre-checked facet the
   change never touches self-skips there rather than producing a hollow review. The orchestrator
   opens no facet's own doc to pre-fill; a facet's file is read only when it is dispatched (step 5).
3. **Create the run directory.** With `change_ref` already resolved in step 2, create the run
   directory with `run-context.sh` — the per-facet path is `.engineering/<run>/<facet>/findings.md`,
   where `<facet>` is the facet's identifier (e.g. `reviewing-security`).
4. **Decide fan-out vs. inline.** On a small change — roughly one file, ~20 changed lines or fewer,
   one hunk — reviewing every selected facet inline costs less than spinning up subagents; do it
   inline. Above that floor, **fan out** the selected facets in parallel, following
   `dispatching-parallel-agents` (facets share only a *read* of `change_ref`, so the independence
   gate holds — no facet reads what another writes). Mark each facet's todo `in_progress` as it
   goes out, or as you begin it inline.
5. **Hand each facet the contract.** Each selected facet is defined by its file
   `references/facets/<facet>/facet.md`; dispatch a reviewer by handing it that file to read and
   apply. Pass every facet the same request and expect the same result shape — see
   [references/facet-contract.md](references/facet-contract.md). Set the request's `caps` (`top_n`,
   `floor`) from the **effort** argument per the table in **Arguments** — the same caps to every
   facet, so the discipline is tuned in one place. Each facet enforces the hard stops
   itself, at the source — see [references/hard-stops.md](references/hard-stops.md); the
   orchestrator does not trim findings afterward.
6. **Reconcile.** Gather all results — nothing dropped because it returned last, nothing picked
   because it returned first; mark each facet's todo `completed` as its result lands. Deduplicate
   where two facets flag the same location, order the findings, and present **one** report alongside
   the durable per-facet artifacts. Reconciliation is the one thing a facet does not own; it needs
   every result at once. Carry each facet's `dropped` count through into the report: where any facet
   hit its cap, the report states how many genuine findings wait behind it (e.g. "Security: 3 more
   above the floor — re-run to see them"). The cap keeps the report short; it does not get to make
   the report *look* complete when it isn't. A reader deciding whether to re-run needs to know work
   was held back, not discover it by accident.
7. **Route the findings — the human's call.** The reconciled report is in hand; where it travels
   from here is a choice put to the human, using a tool to ask it where one is available (plain
   text otherwise). Present the routes and act on the pick:
   - **Report locally** — the reconciled report and the durable per-facet artifacts under
     `.engineering/<run>/` are the whole deliverable; nothing leaves the machine. This is the
     default when no route is chosen.
   - **Post to the PR** — post the reconciled findings back onto the pull request under review as
     review comments, each on the line it references. This route is forge-agnostic: **detect the
     forge first** (inspect the remote and the available tooling — `gh` for GitHub, `glab` for
     GitLab, …) and use its equivalent. Offer it only when the reviewed change is a pull/merge
     request; otherwise it is unavailable.
   - **Hand off to `receiving-code-review`** — invoke `engineering:receiving-code-review` with the
     reconciled findings as the review under consideration, so they flow into that skill's
     aggregate → verify → design → fix pipeline. code-review still never edits code; the hand-off
     only shapes the findings into the pipeline that does.

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

- It does not **fix what it finds.** Even when the human routes the findings onward — posting them
  to the PR or handing them to `engineering:receiving-code-review` (workflow step 7) — code-review
  itself never edits code; a downstream owns applying them.
- It does not **decide when a review happens**, and it does not **stand in for sign-off.** A clean
  report is information a human uses to decide whether to merge, not a switch this skill throws; and
  the route the findings take onward is the human's pick, not this skill's.
