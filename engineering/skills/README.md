# Skills, by process group

Skills live flat in this directory (the plugin loader scans one level deep). This index is the
human map of which skill belongs to which process.

The pipeline is carried by a small set of conductors, not a skill per step: each phase conductor
drives its substages from reference files under its own `references/` directory (and the shared
`references/` at the plugin root), dispatching to subagents where a context firewall or parallelism
earns it. A directory earns a `SKILL.md` only when it must be discovered on its own, where no
conductor is already driving.

| Group | Skills |
|---|---|
| Bootstrap | `using-skills` |
| Entrances | `signal`, `triage`, `receiving-code-review` |
| Phase conductors | `brainstorming`, `spec`, `plan`, `build`, `document`, `finish` |
| Cross-cutting | `using-codebase-design`, `using-stacked-pull-requests`, `using-diagrams`, `using-verification`, `using-parallel-agents` |

Reference files (not skills) that a conductor loads:

| Owner | References |
|---|---|
| `spec` | `references/SPEC-FORMAT.md` |
| `using-codebase-design` | `references/SHAPE-REVIEW.md`, `references/DESIGN-IT-TWICE.md`, `references/PATTERN-MATRIX.md`, `references/DEEPENING.md`, `references/TENANCY-ISOLATED-DB.md`, `references/TENANCY-SHARED-DB.md` |
| `plan` | `references/arch-lens.md` |
| `build` | `references/establishing-workspace.md`, `references/tdd-loop.md` (+ `mocking.md`, `tests.md`), `references/review-protocol.md` |
| `document` | `references/comprehension-gate.md`, `references/receipt-schema.md`, `references/rewrite-beat.md` |
| `finish` | `references/pr-description.md` |
| `triage` | `references/diagnosing.md` |
| `receiving-code-review` | `references/review-comment.md` |
| shared (plugin `references/`) | `interrogating-requirements.md` (loaded by all three entrances) |
