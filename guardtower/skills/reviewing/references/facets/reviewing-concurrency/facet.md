
# Reviewing — Concurrency & Race Safety facet

Say this first, plainly: `Using the guardtower concurrency facet to review this change.`

## What this guarantees

One thing: given the change under review, this facet looks for state that two executions can corrupt
when they interleave — a check-then-act window, a non-atomic read-modify-write, a lost update, shared
mutable state touched without synchronization, a compound operation missing its lock or transaction —
and returns a short, ordered, self-contained list of findings, capped and floored, with a durable
record written to its artifact. It is **report-only**: it never edits code. Its concern is *unsafe
interleaving of concurrent executions* alone, not general correctness of single-threaded logic.

This facet self-limits at the source (see `../../hard-stops.md`), under the shared `../../facet-contract.md`.

Its analysis stays inside a fixed boundary:
it reasons about the concurrency the change **visible in the diff** actually introduces or alters — the
handler, the shared field, the read-then-write, the lock or transaction the change adds or removes —
read against the reviewer's knowledge of how the language and runtime schedule concurrent work. It does
**no proactive** repo-wide hunt for every pre-existing race in the system; a race the change introduces
is in reach, and a pre-existing race elsewhere the diff never touches is an accepted blind spot, not a
defect this facet chases.

## The workflow

1. **Relevance gate — first, before any lens work, and sharp.** Run the relevance gate before touching
   a single lens. This facet fires **only when the change can be reached by more than one execution at
   once** — it touches shared mutable state (a static/global, a cache, a row or record other requests
   also write), a concurrent or async handler, a background job or message consumer, or a
   locking/transaction primitive. A change that is purely sequential and single-owner — a pure
   computation, request-local state no one else observes, config, or docs — is **not** in scope:
   short-circuit and return `relevance: { skipped: <reason> }`, having spent almost nothing, and write
   an artifact recording the skip. This gate is deliberately narrow; it is what keeps most diffs from
   triggering any concurrency work at all.

2. **Apply the lenses.** For a change that passed the gate, work
   [references/concurrency-checklist.md](references/concurrency-checklist.md), across the diff-visible
   classes:
   - **Check-then-act (TOCTOU)** — a value is read or checked, then acted on as if it were unchanged,
     with a window in which another execution can invalidate it between the two.
   - **Non-atomic read-modify-write** — a read, a modification, and a write-back that another execution
     can interleave, so an update is computed from stale state.
   - **Lost update on shared state** — an unguarded increment, append, or accumulation into a shared
     counter, balance, or collection, where concurrent writers overwrite each other.
   - **Missing lock or transaction on a compound operation** — a multi-step operation that must be
     all-or-nothing relative to other executions but runs with no enclosing lock, transaction, or
     atomic primitive.
   - **Shared mutable state without synchronization** — a field, singleton, or container mutated across
     concurrent requests or threads with no guard, so readers observe torn or inconsistent state.

3. **Floor, then cap** per hard-stops.md §2–3 — drop below `caps.floor`, keep at most
   `caps.top_n`.
4. **Write the artifact and return** per facet-contract.md's Finding schema, to `findings.md`.
   Name the two executions and the state they corrupt, so the interleaving is legible without
   rerunning the reasoning.

## What this does not do

- It does not **scan the repository** — its reach is the concurrency the diff shows; it does not hunt
  every pre-existing race in code the change leaves untouched.
- It does not **review single-threaded correctness** — a logic bug that needs no second execution to
  manifest belongs to another facet; this facet is unsafe interleaving only.
- It does not **flag concurrency that is already safe** — state behind an existing lock, an operation
  already atomic or transactional, or state provably reached by one execution at a time is not a
  finding; the cap and floor keep this facet to a real race.
- It does not **demand a specific primitive** — which lock, queue, or CAS to use is a direction at most;
  it flags the unsafe interleaving, not a preferred synchronization style.
