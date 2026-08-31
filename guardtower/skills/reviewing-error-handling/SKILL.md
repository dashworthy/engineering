---
name: reviewing-error-handling
description: "Guardtower's error-handling facet: review a change for silent failures — a swallowed or empty catch, an over-broad catch that hides unrelated faults, a fallback that masks the error instead of surfacing it, dropped error propagation, an ignored rejection or unchecked return-code — returning capped, floored, self-contained findings. Use when an error-handling or resilience review of a diff/branch/PR is requested."
---

# Reviewing — Error Handling & Resilience facet

Say this first, plainly: `Using the guardtower error-handling facet to review this change.`

## What this guarantees

One thing: given the change under review, this facet looks for error handling that hides problems —
a swallowed exception, an over-broad catch, a fallback that masks a fault, dropped propagation, an
ignored rejection or return code — and returns a short, ordered, self-contained list of findings,
capped and floored, with a durable record written to its artifact. It is **report-only**: it never
edits code.

This facet self-limits at the source (see `../reviewing/references/hard-stops.md`), under the shared `../reviewing/references/facet-contract.md`.

Its analysis stays inside a fixed boundary:
the error-handling constructs the diff actually shows, read against the reviewer's knowledge of how
errors are raised and propagated in the language at hand — **no proactive repo-wide scan** for every
place a swallowed error might have mattered. A silent failure the change introduces is in reach; a
pre-existing swallow elsewhere the diff never touches is out of scope, not a defect this facet
chases.

## The workflow

1. **Relevance gate — first, before any lens work.** Does this change touch error handling? A
   `try`/`catch` (or the language's equivalent), an error return or raise path, fallback or retry
   logic, promise-rejection or return-code handling — in scope. A change with no error-handling
   surface at all — pure data, config, docs, or a computation that neither raises nor guards — is
   **not**: short-circuit and return `relevance: { skipped: <reason> }`, having spent almost nothing,
   and write an artifact recording the skip.

2. **Apply the lenses.** For a change that passed the gate, work
   [references/error-handling-checklist.md](references/error-handling-checklist.md), across the
   diff-visible classes:
   - **Swallowed / empty catch** — an error caught and ignored.
   - **Over-broad catch** — a handler so wide it hides unrelated failures.
   - **Masking fallback** — a fallback or default that papers over the error instead of surfacing it.
   - **Dropped propagation** — an error caught and then neither handled nor re-raised.
   - **Ignored rejection / return code** — an unhandled rejected promise or an unchecked
     error-signalling return value.

3. **Floor, then cap.** Drop every candidate weaker than `caps.floor` (on the weaker of its severity
   and confidence). Order what remains most-severe-first and keep at most `caps.top_n`.

4. **Write the artifact and return.** Write the kept findings to `artifact_path` in the Finding
   schema (severity, confidence, location, claim, why, optional suggestion) — each `claim`/`why`
   legible to a reviewer with no shared context. Write the artifact even when nothing survives the
   floor (record "no findings above the floor"). Return the contract result.

## What this does not do

- It does not **fix** anything — report-only; a `suggestion` names a direction, never an edit.
- It does not **scan the repository** — its reach is the error handling the diff shows; it does not
  hunt every place in the codebase where a silent failure could occur.
- It does not **review beyond the error-handling lens** — a security or technical smell it happens to
  notice is out of scope; another facet owns it.
- It does not **enumerate style nits** — the cap and floor are deliberate; a long low-signal list of
  logging preferences is a failure of this facet, not thoroughness.
