---
name: reviewing-idempotency
description: "Guardtower's idempotency facet: review a change for side effects that are unsafe to run twice — a webhook or queue consumer that creates or charges with no idempotency key, a retried operation that duplicates its effect, at-least-once delivery treated as exactly-once, a create/POST that duplicates on replay, a partial-completion re-run with no checkpoint — returning capped, floored, self-contained findings. Use when an idempotency or retry-safety review of a diff/branch/PR is requested."
---

# Reviewing — Idempotency & Retry Safety facet

Say this first, plainly: `Using the guardtower idempotency facet to review this change.`

## What this guarantees

One thing: given the change under review, this facet looks for a side-effecting operation that does the
wrong thing when it runs more than once — a consumer or webhook handler with no idempotency key, a
retried operation that duplicates its effect, delivery that is at-least-once treated as if exactly-once,
a create that duplicates on replay, a re-run that redoes already-completed work — and returns a short,
ordered, self-contained list of findings, capped and floored, with a durable record written to its
artifact. It is **report-only**: it never edits code. Its concern is *safety under re-execution* alone,
not the correctness of a single successful run.

This facet self-limits at the source (see `../reviewing/references/hard-stops.md`), under the shared `../reviewing/references/facet-contract.md`.

Its analysis stays inside a fixed boundary:
it reasons about the side effect the change **visible in the diff** actually introduces or alters — the
handler, the write, the external call, the retry or delivery contract the change touches — read against
the reviewer's knowledge of how retries, redeliveries, and replays happen in the runtime at hand. It
does **no proactive** repo-wide hunt for every non-idempotent path in the system; an operation the
change makes unsafe to repeat is in reach, and a pre-existing one elsewhere the diff never touches is an
accepted blind spot, not a defect this facet chases.

## The workflow

1. **Relevance gate — first, before any lens work, and sharp.** Run the relevance gate before touching
   a single lens. This facet fires **only when the change performs a side effect that something can
   trigger again** — a message or queue consumer, a webhook or callback handler, a retried job or task,
   an outbound call or write that a client or infrastructure can replay (a payment, an email, a record
   creation). A change with no repeatable side effect — a pure read, an in-memory computation, a
   naturally idempotent write, config, or docs — is **not** in scope: short-circuit and return
   `relevance: { skipped: <reason> }`, having spent almost nothing, and write an artifact recording the
   skip. This gate is deliberately narrow; it is what keeps most diffs from triggering any idempotency
   work at all.

2. **Apply the lenses.** For a change that passed the gate, work
   [references/idempotency-checklist.md](references/idempotency-checklist.md), across the diff-visible
   classes:
   - **Side effect with no idempotency key** — a handler that creates, charges, or emits with no
     dedupe key, so a redelivery produces a second effect.
   - **Non-idempotent retry** — a retry wrapper around an operation whose effect compounds on each
     attempt, so a retried transient failure doubles the effect.
   - **At-least-once treated as exactly-once** — a consumer of a queue, stream, or webhook that assumes
     each message arrives once, when the transport guarantees only at-least-once.
   - **Duplicate on replay** — a create or POST-style operation with no natural or enforced uniqueness,
     so replaying the same request yields a duplicate record.
   - **Partial-completion re-run** — a multi-effect operation with no checkpoint or guard, so a re-run
     after a mid-way failure redoes the effects that already succeeded.

3. **Floor, then cap** per hard-stops.md §2–3 — drop below `caps.floor`, keep at most
   `caps.top_n`.
4. **Write the artifact and return** per facet-contract.md's Finding schema, to `findings.md`.
   Name what triggers the repeat (a redelivery, a retry, a client replay) and the duplicated effect,
   so the finding stands on its own.

## What this does not do

- It does not **scan the repository** — its reach is the side effect the diff shows; it does not hunt
  every non-idempotent path in code the change leaves untouched.
- It does not **review single-run correctness** — whether the operation is right when it runs exactly
  once belongs to another facet; this facet is safety under re-execution only.
- It does not **flag a naturally idempotent operation** — a PUT to a fixed key, a set-to-value, a
  delete-if-exists, or a write already guarded by a unique constraint or dedupe key is not a finding;
  the cap and floor keep this facet to a real duplicate-effect risk.
- It does not **overlap the concurrency facet** — two executions racing on shared state is a
  concurrency finding; the same operation *replayed* producing a second effect is this facet's. Name
  which one the finding is.
