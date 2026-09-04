
# Reviewing — API Consumption facet

Say this first, plainly: `Using the guardtower API-consumption facet to review this change.`

## What this guarantees

One thing: given the change under review, this facet looks for defects in how the change
**consumes a remote / HTTP API** — over-fetching, doing the API's filtering work in the client,
excessive call volume, and unsafe behaviour around rate limits (429s) — and returns a short,
ordered, self-contained list of findings, capped and floored, with a durable record written to
its artifact. It is **report-only**: it never edits code.

This facet self-limits at the source (see `../../hard-stops.md`), under the
shared `../../facet-contract.md`.

Its analysis stays inside a fixed boundary: the diff, the reviewer's knowledge of how HTTP APIs
and common client libraries behave, and a glance at the public surface of the API client the
change already uses — **no proactive repo-wide scan or call-site index**. An over-fetch or a
per-item call *visible in the diff* is in reach; a wasteful call that lives
elsewhere in the codebase and the change never touches is an accepted blind spot, not a defect
this facet chases. The surface is transport-general: any code that calls a remote API this way
counts — a browser/front-end client and a backend service calling a third-party API alike.

## The workflow

1. **Relevance gate — first, before any lens work.** Run the relevance gate before touching a
   single lens. Does this change actually consume a remote/HTTP API — a `fetch`/`axios`/SDK
   client call, a request hook (react-query/SWR or equivalent), a polling loop, a request
   builder? If it does, the facet is in scope. A change that touches no remote-API call — pure
   local computation, a data-layer/DB query (the Technical facet owns that), config, docs, or
   formatting — is **not**: short-circuit and return `relevance: { skipped: <reason> }`, having
   spent almost nothing, and write an artifact recording the skip.

2. **Apply the lenses.** For a change that passed the gate, work
   [references/api-consumption-checklist.md](references/api-consumption-checklist.md) across its
   four classes:
   - **Over-fetching payload** — requesting more than the caller reads: every field when a few
     are used, or an unbounded/unpaginated collection where a page, a count, or an existence
     check would do.
   - **Client-side work the API offers server-side** — pulling everything and then filtering,
     sorting, searching, or aggregating in the client, when the API supports doing it via
     parameters.
   - **Excessive call volume** — redundant/duplicate calls, no caching or dedup, request
     waterfalls that could batch or parallelize, a call per item (N+1 over HTTP), and
     over-aggressive polling or refetch-on-render.
   - **Rate-limit (429) safety** — both the *cause* (request storms, aggressive polling,
     per-item calls, no throttle/debounce on user-driven bursts) and the *response* (no retry
     with backoff, ignoring `Retry-After`, retry storms).

3. **Floor, then cap** per hard-stops.md §2–3 — drop below `caps.floor`, keep at most
   `caps.top_n`.
4. **Write the artifact and return** per facet-contract.md's Finding schema, to
   `findings.md`.

## What this does not do

- It does not **scan the repository** — its reach is the diff plus the API client the change
  already uses; it does not index every call site to find every possible waste.
- It does not **review data-layer / database access** — N+1 on an ORM, unbounded SQL, a query
  in a loop belong to the **Technical** facet. The boundary is transport: Technical owns the
  data layer, this facet owns calls over the network.
- It does not **review general error handling** — a swallowed exception or a masking fallback
  belongs to the **Error Handling** facet; this facet owns only the *rate-limit-specific*
  resilience of a 429 (retry/backoff, `Retry-After`).
- It does not **review the API's own contract** — a breaking change to a public contract
  belongs to the **API & Backward Compatibility** facet; this facet judges consumption, not the
  contract being consumed.
