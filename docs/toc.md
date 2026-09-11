# Documentation — table of contents

Every documented feature in this repository, sorted by domain then feature. Click a feature to open
its doc. Rows are keyed by feature and upserted by the `documenting` phase; the **Domain** column is
the coarse grouping (and the top path segment).

| Feature | Description | Domain |
|---|---|---|
| [Diagrams](foundations/diagrams/README.md) | How the pipeline draws one earned-its-place diagram for a data model, flow, or state machine — the format, the rules, and the phases that compose it | foundations |
| [Parallel agents](foundations/parallel-agents/README.md) | Fanning independent work out to concurrent subagents under the independence gate, then reconciling every return whole | foundations |
| [Refusing deferral](foundations/refusing-deferral/README.md) | The pipeline-wide rule that requested work ends done in the diff or surfaced as a visible, revivable decision — never silently deferred | foundations |
| [Skill conventions](foundations/skill-conventions/README.md) | The frontmatter-and-body contract every skill in this plugin is authored to, anchored by the `using-skills` foundation | foundations |
| [Stacked pull requests](foundations/stacked-prs/README.md) | Shipping an approved plan as a linear git+gh stack of one-branch, one-PR-per-task pull requests the pipeline opens but never lands | foundations |
| [Verification](foundations/verification/README.md) | The rule that a branch's "green" must be backed by actual command output, re-run when the branch has moved — composed by build and finish | foundations |
| [Build phase](pipeline/build/README.md) | Executes an approved plan task by task in an isolated workspace, each behavior change test-first and each task's diff gated by an automated three-lens review | pipeline |
| [Code review](pipeline/code-review/README.md) | The deep, opt-in facet-menu review a human runs on a higher-risk change — pick lenses, fan out self-limiting reviewers, reconcile one report, route the findings | pipeline |
| [Design phase](pipeline/design/README.md) | The shared dialogue that turns a shaped brief into an approved spec — brainstorming recommends an approach, using-codebase-design shapes its boundary, and spec holds the first human gate | pipeline |
| [Documentation pipeline](pipeline/documentation/README.md) | How the engineering pipeline writes and consults durable feature docs — the `documenting` phase, the `using-documentation` producer, the brainstorming consult step, and the consumable-markdown conventions | pipeline |
| [Entrances](pipeline/entrances/README.md) | The three doors that shape a raw ask, defect, or review into designable context and hand it to the design dialogue — signal, triage, and receiving-code-review | pipeline |
| [Finish phase](pipeline/finish/README.md) | Reviews the whole green branch once, then opens a pull request or stacked PR set to re-enter the repo; never merges | pipeline |
| [Planning phase](pipeline/planning/README.md) | Turns one approved spec into a single ordered, stacked implementation plan and holds the pipeline's second human gate | pipeline |
| [Run directories](pipeline/run-directories/README.md) | The gitignored per-run directory model — run-context.sh mints or joins a run, each phase owns a subdir, and gates leave marker files as their trace | pipeline |
| [Spec ledger](pipeline/spec-ledger/README.md) | The committed record of every approved spec — a frozen spec.md written at approval and a companion retro.md written at ship, under docs/specs/ with its own index | pipeline |
