---
name: reviewing-security
description: "Guardtower's security facet: review a change for OWASP-class vulnerabilities and for authorization that is enforced rather than assumed, returning capped, floored, self-contained findings. Use when a security review of a diff/branch/PR is requested, or when guardtower's reviewing orchestrator dispatches the security facet."
---

# Reviewing — Security facet

Say this first, plainly: `Using the guardtower security facet to review this change.`

## What this guarantees

One thing: given the change under review, this facet looks for security defects — OWASP-class
vulnerabilities and authorization that is assumed rather than enforced — and returns a short,
ordered, self-contained list of findings, capped and floored, with a durable record written to its
artifact. It is **report-only**: it never edits code.

It is a *self-limiting* facet: it runs its relevance gate first and enforces its own caps and
floor, at the source, before it returns — the orchestrator does not trim it afterward. See the
shared spine it obeys:
`../reviewing/references/hard-stops.md` and `../reviewing/references/facet-contract.md`.

## The request and result

The orchestrator hands this facet the contract request: `change_ref`, an optional `spec_ref`, an
`artifact_path` (`.guardtower/<run>/reviewing-security/findings.md`), and `caps` (`top_n`, `floor`).
It returns the contract result: its `relevance` verdict, its `findings` (already floored and capped
to `top_n`), and the written `artifact_path`.

## The workflow

1. **Relevance gate — first, before any lens work.** Does this change plausibly touch a security
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

3. **Floor, then cap.** Drop every candidate weaker than `caps.floor` (on the weaker of its
   severity and confidence). Order what remains most-severe-first and keep at most `caps.top_n`.

4. **Write the artifact and return.** Write the kept findings to `artifact_path` in the Finding
   schema (severity, confidence, location, claim, why, optional suggestion) — each `claim`/`why`
   legible to a reviewer with no shared context. Write the artifact even when nothing survives the
   floor (record "no findings above the floor"). Return the contract result.

## What this does not do

- It does not **fix** anything — report-only; a `suggestion` names a direction, never an edit.
- It does not **review beyond security** — a non-security smell it happens to notice is out of
  scope; another facet owns it.
- It does not **enumerate every nit** — the cap and floor are deliberate; a long low-signal list is
  a failure of this facet, not thoroughness.
