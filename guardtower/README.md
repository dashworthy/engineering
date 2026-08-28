# Guardtower

A Claude Code plugin: an in-depth, **opt-in** code-review gate — the heavier escalation you
run deliberately before merging a higher-risk change, on top of whatever everyday review you
already do.

Guardtower reviews a change through a **menu of facets**, each a specialized reviewer with its
own lens. You pick which facets to run; each one relevance-gates itself, caps and floors its own
findings, writes a durable record under `.guardtower/<run>/<facet>/`, and **never edits your
code** — it reports, you decide.

## Install

```
/plugin marketplace add https://github.com/dashworthy/engineering
/plugin install guardtower@dashworthy
```

## Use

```
/guardtower <a diff, branch, or PR to review>
```

You're shown a facet menu (the three core facets pre-checked); guardtower fans out the selected
facets, then returns one reconciled report plus the per-facet artifacts under `.guardtower/`.

## The facets

| Facet | Asks |
|---|---|
| **Security** | OWASP best practices, and is authorization *enforced* rather than assumed? |
| **Technical** | Reuse over reinvention, inefficient queries, best-practice adherence. |
| **Architectural** | Sustainable architecture — coupling, dependency direction, cohesion, leaky abstractions. |
| Error Handling & Resilience | *(coming soon)* Silent failures, swallowed exceptions, bad fallbacks. |
| Test Quality | *(coming soon)* Do the tests exercise the change and fail if it breaks? |
| Data & Migration Safety | *(coming soon)* Destructive/irreversible operations, data-loss risk. |
| API & Backward Compatibility | *(coming soon)* Breaking changes to public contracts. |

This release ships the three **core** facets — **Security**, **Technical**, and
**Architectural** — and the shared review spine; the rest arrive on the same contract in later
releases.

## Design principles

- **Token-disciplined by construction.** Each facet decides its own relevance and *skips* before
  spending tokens when a change doesn't warrant it, then reports only its most severe findings
  above a confidence floor — no exhaustive enumeration of nits.
- **Report-only.** Guardtower writes findings, never fixes; applying them is a separate,
  human-decided step.
- **Language-agnostic.** Facets reason from general principles and what they can read; no
  framework or stack is baked in.
- **A durable record.** Every run leaves an inspectable trail under `.guardtower/<run>/`.

The architecture (an orchestrator over self-limiting facets) is recorded in
[ADR-0003](../docs/adr/0003-guardtower-orchestrator-with-self-limiting-facets.md).

## License

MIT. See [LICENSE](../LICENSE).
