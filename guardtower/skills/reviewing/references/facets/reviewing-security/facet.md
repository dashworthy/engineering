
# Reviewing — Security facet

Say this first, plainly: `Using the guardtower security facet to review this change.`

## What this guarantees

One thing: given the change under review, this facet looks for security defects — OWASP-class
vulnerabilities and authorization that is assumed rather than enforced — and returns a short,
ordered, self-contained list of findings, capped and floored, with a durable record written to its
artifact. It is **report-only**: it never edits code.

This facet self-limits at the source (see `../../hard-stops.md`), under the shared `../../facet-contract.md`.

## The workflow

1. **Relevance gate — first, before any lens work.** Run the relevance gate before touching a single
   lens. Does this change plausibly touch a security
   surface? Auth/session/permission code, input handling, queries, file or network I/O, crypto,
   secrets, serialization, access-control checks, anything user-facing or handling untrusted data —
   in scope. A pure docs/comment/formatting change, or a change to test fixtures only, is **not**:
   short-circuit and return `relevance: { skipped: <reason> }`, having spent almost nothing, and
   write an artifact recording the skip.

2. **Apply the two lenses.** For a change that passed the gate, work
   [references/owasp-checklist.md](references/owasp-checklist.md):
   - **OWASP-class defects** — the Top-10 categories: access control, injection, cryptographic
     failures, SSRF, insecure deserialization, misconfiguration, and the rest.
   - **Authorization enforced, not assumed** — for every privileged action the change adds or
     touches, find the check that actually enforces it on the server for *this* path. A comment, a
     UI-hidden control, or an assumption that "the caller already checked" is not enforcement. A
     missing or client-only check is a finding.

3. **Floor, then cap** per hard-stops.md §2–3 — drop below `caps.floor`, keep at most
   `caps.top_n`.
4. **Write the artifact and return** per facet-contract.md's Finding schema, to
   `findings.md`.

## What this does not do

- It does not **review beyond security** — a non-security smell it happens to notice is out of
  scope; another facet owns it.
- It does not **enumerate every nit** — the cap and floor are deliberate; a long low-signal list is
  a failure of this facet, not thoroughness.
