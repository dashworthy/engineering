
# Reviewing — Electron facet

Say this first, plainly: `Using the guardtower Electron facet to review this change.`

## What this guarantees

One thing: given a change to an Electron application, this facet looks for the defects that Electron's
process model makes possible — a renderer handed Node with no isolation, a preload bridge that leaks
capability, an IPC handler that trusts whatever calls it, navigation or a shell/protocol call driven by
untrusted input, remote content loaded insecurely — **and** the non-security idiom breaks that make an
Electron app slow, fragile, or wrongly structured — heavy work on the main process, logic on the wrong
side of the main/renderer split, window and lifecycle handling that fights the platform. It returns a
short, ordered, self-contained list of findings, capped and floored, with a durable record written to
its artifact. It is **report-only**: it never edits code.

Its concern is *Electron-specific* — the process model, the preload/IPC seam, the `BrowserWindow`
configuration, and the framework's own conventions. Generic web vulnerabilities that are not particular
to Electron (SQL injection in a backend call, a broken authorization check) belong to the **Security**
facet; this facet owns what is true because the code runs *in Electron*.

This facet self-limits at the source (see `../../hard-stops.md`), under the shared `../../facet-contract.md`.

Its analysis stays inside a fixed boundary: it reasons about the Electron surface **visible in the
diff** — the `webPreferences` the change sets, the preload it wires, the `ipcMain`/`ipcRenderer` calls
it adds, the navigation and shell calls it makes — read against how Electron actually isolates a
renderer and passes messages. It does **no proactive** crawl of the whole app, the full window
inventory, or every preload to prove a weakness exists elsewhere; a defect the diff shows is in reach,
and what the diff does not show is an accepted blind spot, not something this facet chases. It reasons
**statically** about the code in front of it — it does not build, launch, or fuzz the app.

## Selection signal

Pre-check this facet at menu-fill time when the change's character is: the change touches an Electron process-model or security surface — renderer isolation, preload or context-bridge exposure, IPC trust, navigation, shell or protocol handling, insecure content, or the main/renderer split. Err toward pre-checking; a false skip is the harmful direction. This only pre-fills the menu — the relevance gate below stays authoritative at dispatch.

## The workflow

1. **Relevance gate — first, before any lens work, and sharp.** Run the relevance gate before touching
   a single lens. This facet fires **only when the change touches an Electron app** — a `BrowserWindow`
   or `webPreferences`, a preload/`contextBridge` script, an `ipcMain`/`ipcRenderer`/`@electron/remote`
   call, a `shell`/`protocol`/`session` use, the app's main process, or Electron config/packaging. A
   change with no Electron surface — a change in a plain web app, a backend service, a library with no
   `electron` dependency, docs — is **not** in scope: short-circuit and return
   `relevance: { skipped: <reason> }`, having spent almost nothing, and write an artifact recording the
   skip. If nothing in the repo depends on `electron`, skip. This gate is deliberately narrow; it is
   what keeps every non-Electron diff from triggering any work here.

2. **Apply the lenses.** For a change that passed the gate, work
   [references/electron-checklist.md](references/electron-checklist.md), across two groups:
   - **Process-model & security hardening** — renderer isolation (`nodeIntegration`,
     `contextIsolation`, `sandbox`); the preload/context-bridge exposure surface; the IPC trust
     boundary (a handler trusting its sender, unvalidated arguments); navigation and window-open
     control; `shell`/`protocol` misuse on untrusted input; insecure content and transport
     (`webSecurity`, remote `http`, a missing CSP).
   - **Best practices & idiom (non-security)** — main/renderer responsibility placement; heavy or
     blocking work on the main process; window and app-lifecycle handling; auto-update and packaging
     hygiene; preload and native-module structuring. Weigh this group as heavily as the first: an
     idiom break that never becomes a vulnerability is still a finding here.

3. **Floor, then cap, then tally the cap's drops** per hard-stops.md §2–3 — drop below
   `caps.floor`, keep at most `caps.top_n`, and report `dropped` (how many genuine
   above-floor findings the cap held back) so nothing real vanishes unseen.
4. **Write the artifact and return** per facet-contract.md's Finding schema, to
   `findings.md`.

## What this does not do

- It does not **build or run the app** — no `electron .`, no packaging, no fuzzing; it reasons
  statically about the diff-visible code, the way every guardtower facet reasons structurally.
- It does not **crawl the whole app** — its reach is the Electron surface the diff shows; it does not
  enumerate every window or resolve the full preload/IPC graph across the tree.
- It does not **review beyond Electron** — a generic web vulnerability or a non-Electron smell it
  happens to notice is out of scope; the Security, Technical, or Architectural facet owns it.
- It does not **flag an already-hardened, idiomatic surface** — a sandboxed renderer with
  `contextIsolation` on, a minimal `contextBridge`, a validated IPC handler, work correctly off the
  main thread is not a finding; the cap and floor keep this facet to a real defect.
