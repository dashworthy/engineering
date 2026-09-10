
# Reviewing — API facet

Say this first, plainly: `Using the code-review API facet to review this change.`

## What this guarantees

One thing: given a change that touches an API surface, this facet reviews it across two lenses —
**Compatibility** (breaking changes to a public contract the code *provides*) and **Consumption**
(defects in how the code *consumes* a remote/HTTP API) — and returns a short, ordered,
self-contained list of findings, capped and floored, with a durable record written to its
artifact. It is **report-only**: it never edits code.

These were two adjacent facets that already named each other as siblings. They are one facet now:
the two lenses are orthogonal — providing a contract vs. consuming one — so a given change usually
engages just one, and the relevance gate below fires for either.

This facet self-limits at the source (see `../../hard-stops.md`), under the shared
`../../facet-contract.md`.

Its analysis stays inside a fixed boundary: it reasons about the API surface **visible in the
diff** — the public symbol/endpoint/schema the change alters, or the remote call the change makes —
read against the reviewer's knowledge of what breaks a caller and how HTTP APIs and client
libraries behave. It does **no proactive** scan for every consumer of a changed contract, and **no
proactive** repo-wide call-site index; what the diff does not show is an accepted blind spot, not
work this facet chases.

## The workflow

1. **Relevance gate — first, before any lens work, and sharp.** Run the relevance gate before
   touching a single lens. This facet fires when the change touches an API surface either way:
   - **Compatibility** — the change touches a **public surface it provides**: an exported/public
     symbol (a function, method, type, or constant other code calls), a network endpoint, or a
     published schema/serialization format.
   - **Consumption** — the change **consumes a remote/HTTP API it does not own**: a
     `fetch`/`axios`/SDK client call, a request hook (react-query/SWR or equivalent), a polling
     loop, or a request builder.

   A change touching neither — internal/private code only, pure local computation, a data-layer/DB
   query (the Technical facet owns that), config, docs — is **not** in scope: short-circuit and
   return `relevance: { skipped: <reason> }`, having spent almost nothing, and write an artifact
   recording the skip. This gate is deliberately narrow; it is what keeps most diffs from
   triggering any API work at all.

2. **Apply the lens(es) the surface earns.** A change usually engages one lens; apply each whose
   surface the diff raises. Each lens has its own checklist under `references/`.

   - **Compatibility lens.** Work
     [references/api-compat-checklist.md](references/api-compat-checklist.md): a removed or renamed
     public member; a changed signature (parameters added/removed/reordered, types narrowed); a
     changed response shape or status code; a widened requirement (a narrowed accepted input, or a
     newly-required field callers could omit before); a changed wire/serialization format. It flags
     what **breaks** an existing contract — a new optional field or a new endpoint is additive and
     not a finding.

   - **Consumption lens.** Work
     [references/api-consumption-checklist.md](references/api-consumption-checklist.md):
     over-fetching (requesting more than the caller reads; an unbounded/unpaginated collection);
     client-side work the API offers server-side (pulling everything then filtering/sorting/
     aggregating locally); excessive call volume (redundant calls, no caching/dedup, request
     waterfalls, a call per item — N+1 over HTTP, over-aggressive polling/refetch); rate-limit
     (429) safety, both the *cause* (request storms, per-item calls, no throttle/debounce) and the
     *response* (no retry with backoff, ignoring `Retry-After`, retry storms).

3. **Floor, then cap, then tally the cap's drops** per hard-stops.md §2–3 — drop below
   `caps.floor`, keep at most `caps.top_n`, and report `dropped` (how many genuine above-floor
   findings the cap held back) so nothing real vanishes unseen. The cap spans both lenses.
4. **Write the artifact and return** per facet-contract.md's Finding schema, to `findings.md`.

## What this does not do

- It does not **hunt consumers or scan the repository** — its reach is the contract change or
  remote call the diff shows, plus the API client the change already uses; it does not scan the
  repo for every caller of a changed surface or index every call site to find every waste.
- It does not **flag additive contract changes** — a new optional field or a new endpoint is
  backward compatible and not a finding; the compatibility lens flags what breaks an existing
  contract.
- It does not **review data-layer / database access** — N+1 on an ORM, unbounded SQL, a query in a
  loop belong to the **Technical** facet. The boundary is transport: Technical owns the data layer,
  the consumption lens owns calls over the network.
- It does not **review general error handling** — a swallowed exception or a masking fallback
  belongs to the **Error Handling** facet; the consumption lens owns only the *rate-limit-specific*
  resilience of a 429 (retry/backoff, `Retry-After`).
- It does not **review beyond the API surface** — a security or correctness smell it happens to
  notice is out of scope; another facet owns it.
