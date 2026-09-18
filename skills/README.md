# Skills

Every skill in this plugin, grouped by role. Skills live flat in `skills/` — the loader scans one
level deep — and each directory listed here carries its own `SKILL.md`. For the pipeline overview and
the run flow, see the [root README](../README.md).

## Entrances

Shape a request into context, then converge on the shared design dialogue.

- `signal` — interrogate a feature or vague ask into a brief.
- `triage` — isolate a reported bug or defect with minimal effort.
- `receiving-code-review` — aggregate, verify, and shape incoming code-review feedback.
- `simplify` — interrogate a perceived problem in existing code into named target qualities.

## Phase conductors

The main pipeline, in order.

- `brainstorming` — shape a recommended design from the entrance's material.
- `spec` — write the one Tier-1 spec and hold the spec-approval gate.
- `plan` — turn an approved spec into an ordered, TDD-wired plan and hold the plan gate.
- `build` — execute the plan task by task in an isolated workspace.
- `finish` — review the whole branch and carry out the authorized finish strategy.

## Cross-cutting

Composed by the phases above; not a phase of their own.

- `interrogating-requirements` — the shared requirement-interrogation drive.
- `using-codebase-design` — design a module boundary from competing shapes.
- `using-stacked-pull-requests` — one PR per task, each based on the branch below.
- `using-diagrams` — author mermaid diagrams to the shared diagram rules.
- `using-questions` — the single source of the ask-a-human mechanics and guardrails.
- `using-verification` — run and evidence a branch's verification.
- `using-parallel-agents` — fan work out across subagents.
- `refusing-deferral` — refuse silent deferral; surface parked work as an explicit decision.
- `using-doc-creation` — the document rendering toolkit (PDF + Markdown); owning skills hand it their templates.
- `feature-doc` — author a feature / architecture document from the real code.

## Deep review

- `code-review` — opt-in, report-only deep review across selectable facets.
