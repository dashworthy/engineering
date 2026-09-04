
# Reviewing — API & Backward Compatibility facet

Say this first, plainly: `Using the guardtower api-compat facet to review this change.`

## What this guarantees

One thing: given the change under review, this facet looks for breaking changes to a public
contract — a removed or renamed member, a changed signature, a changed response, a widened
requirement, a changed wire format — and returns a short, ordered, self-contained list of findings,
capped and floored, with a durable record written to its artifact. It is **report-only**: it never
edits code.

This facet self-limits at the source (see `../../hard-stops.md`), under the shared `../../facet-contract.md`.

Its analysis stays inside a fixed boundary:
it reasons about the contract change **visible in the diff** — the public symbol, endpoint, or schema
the change alters — read against the reviewer's knowledge of what breaks a caller. It does **no
proactive** scan for every consumer of that surface; whether a given consumer is affected is judged
from the contract change itself, and finding each caller across the repo is an accepted blind spot,
not work this facet does.

## The workflow

1. **Relevance gate — first, before any lens work, and sharp.** Run the relevance gate before touching
   a single lens. This facet fires **only when the
   change touches a public surface** — an exported or public symbol (a function, method, type, or
   constant other code calls), a network endpoint, or a published schema / serialization format. A
   change confined to internal or private code — a private helper, an implementation detail, a
   name the surrounding code marks as non-public — is **not** in scope: short-circuit and return
   `relevance: { skipped: <reason> }`, having spent almost nothing, and write an artifact recording
   the skip. This gate is deliberately narrow; it is what keeps most diffs from triggering any
   compatibility work at all.

2. **Apply the lenses.** For a change that passed the gate, work
   [references/api-compat-checklist.md](references/api-compat-checklist.md), across the diff-visible
   classes:
   - **Removed or renamed public member** — a public function, field, or endpoint deleted or renamed.
   - **Changed signature** — parameters added, removed, reordered, or types narrowed.
   - **Changed response** — a changed response shape or status code.
   - **Widened requirement** — a narrowed accepted input, or a newly-required field callers could
     omit before.
   - **Changed serialization** — a changed wire / serialization format.

3. **Floor, then cap** per hard-stops.md §2–3 — drop below `caps.floor`, keep at most
   `caps.top_n`.
4. **Write the artifact and return** per facet-contract.md's Finding schema, to
   `findings.md`.

## What this does not do

- It does not **hunt consumers** — its reach is the contract change the diff shows; it does not scan
  the repo (or the ecosystem) for every caller of the changed surface.
- It does not **flag additive changes** — a new optional field or a new endpoint is backward
  compatible and not a finding; this facet flags what **breaks** an existing contract.
- It does not **review beyond compatibility** — a security or correctness smell it happens to notice
  is out of scope; another facet owns it.
