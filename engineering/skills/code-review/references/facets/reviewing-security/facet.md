
# Reviewing — Security facet

Say this first, plainly: `Using the code-review security facet to review this change.`

## What this guarantees

One thing: given the change under review, this facet looks for security defects — OWASP-class
vulnerabilities, authorization that is assumed rather than enforced, and (when the change touches
an Electron process-model surface) Electron-specific security defects — and returns a short,
ordered, self-contained list of findings, capped and floored, with a durable record written to its
artifact. It is **report-only**: it never edits code.

This facet self-limits at the source (see `../../hard-stops.md`), under the shared `../../facet-contract.md`.

## The workflow

1. **Relevance gate — first, before any lens work.** Run the relevance gate before touching a single
   lens. Does this change plausibly touch a security
   surface? Auth/session/permission code, input handling, queries, file or network I/O, crypto,
   secrets, serialization, access-control checks, an Electron process-model surface (renderer
   `webPreferences`, a preload/`contextBridge`, `ipcMain`/`ipcRenderer`, navigation, `shell`/
   `protocol`), anything user-facing or handling untrusted data — in scope. A pure
   docs/comment/formatting change, or a change to test fixtures only, is **not**: short-circuit and
   return `relevance: { skipped: <reason> }`, having spent almost nothing, and write an artifact
   recording the skip.

2. **Apply the lenses.** For a change that passed the gate, work
   [references/owasp-checklist.md](references/owasp-checklist.md) for the first two lenses:
   - **OWASP-class defects** — the Top-10 categories: access control, injection, cryptographic
     failures, SSRF, insecure deserialization, misconfiguration, and the rest.
   - **Authorization enforced, not assumed** — for every privileged action the change adds or
     touches, find the check that actually enforces it on the server for *this* path. A comment, a
     UI-hidden control, or an assumption that "the caller already checked" is not enforcement. A
     missing or client-only check is a finding.
   - **Electron process-model security** — *only when the change touches an Electron surface.* Work
     [references/electron-security-checklist.md](references/electron-security-checklist.md):
     renderer isolation (`nodeIntegration`, `contextIsolation`, `sandbox`); the preload/
     context-bridge exposure surface; the IPC trust boundary (a handler trusting its sender,
     unvalidated arguments); navigation and window-open control; `shell`/`protocol` misuse on
     untrusted input; insecure remote content/transport (`webSecurity`, remote `http:`, a missing
     CSP). This is the security half of what was the standalone Electron facet; the *non-security*
     Electron idiom (main/renderer split, main-thread work, lifecycle, packaging) is **not** here —
     it is the Framework Best Practices facet's Electron stack.

3. **Floor, then cap, then tally the cap's drops** per hard-stops.md §2–3 — drop below
   `caps.floor`, keep at most `caps.top_n`, and report `dropped` (how many genuine
   above-floor findings the cap held back) so nothing real vanishes unseen.
4. **Write the artifact and return** per facet-contract.md's Finding schema, to
   `findings.md`.

## What this does not do

- It does not **review beyond security** — a non-security smell it happens to notice is out of
  scope; another facet owns it. In particular, **non-security Electron idiom** (heavy work on the
  main process, a wrong-side-of-the-split responsibility, lifecycle/packaging hygiene) belongs to
  the Framework Best Practices facet's Electron stack, not this facet.
- It does not **enumerate every nit** — the cap and floor are deliberate; a long low-signal list is
  a failure of this facet, not thoroughness.
