# Documentation pipeline

**The engineering pipeline documents what it ships: after a build goes green, it writes or updates
the feature's docs from what actually landed, and before it designs anything new, it reads those
docs to know where to look.**

---

## 🌟 Overview (plain-language)

The pipeline has a phase whose whole job is documentation, plus a step that reads what that phase
produced. Together they form a loop: work gets documented on the way out, and that documentation
guides the next piece of work on the way in.

- **Producing.** After `build` finishes and the branch is green, the **documenting** phase runs. It
  asks one question — did this run change behavior a reader should know about? If no, it records a
  one-line skip reason and moves on. If yes, it writes (or surgically updates) the feature's doc and
  adds it to this table of contents, then checks the doc is right before handing to `finish`.
- **Consuming.** When `brainstorming` starts a new design, it reads `docs/toc.md` *first*, follows
  it to the relevant feature docs, and uses them to aim its reading of the actual code — instead of
  grepping the whole tree blind. The docs it consulted get cited in the spec.

A **feature doc** lives at `docs/{domain}/{feature}/README.md` and follows one template: a
plain-language overview, then a technical reference, then how to develop and test it. `{domain}` is a
coarse, stable grouping (this doc's domain is `pipeline`); the **table of contents** at
`docs/toc.md` lists every feature with a one-line description and its domain.

**Worked example:** this very document. The run that added the documentation pipeline changed
behavior worth documenting, so — dogfooding the phase — its identity was minted as
`pipeline/documentation`, this doc was written from the template, and a row was upserted into
`docs/toc.md` pointing here.

A standing rule runs through all of it: **docs are a guide, the code is the truth.** A doc points a
reader (or an agent) at where to look and what to expect; the files say what is true today. When the
two disagree, the code wins and the drift gets flagged.

## 🛠 Technical reference

Four pieces do the work, split between producing and consuming.

| Area | Unit | Responsibility |
|---|---|---|
| Phase | `skills/documenting/SKILL.md` | Runs `build → documenting → finish` on the green branch. Judges whether to document, mints the feature identity with the human, invokes the producer, then validates. Adds no new human gate. |
| Producer | `skills/using-documentation/SKILL.md` | Writes or surgically patches `docs/{domain}/{feature}/README.md` and upserts the `docs/toc.md` row, from the run's spec, plan, and shipped diff. Composes `using-diagrams`. |
| Validation | `skills/documenting/references/validation-protocol.md` + `lenses/` | Fans out one independent reviewer per lens — accuracy vs. the shipped diff, structure/template conformance (with the anti-"claudish" prose check), link/index integrity, scope — and reconciles their findings. Mirrors `build`'s review-protocol. |
| Consumption | `skills/brainstorming/references/consulting-documentation.md` | Drives brainstorming to read `docs/toc.md` before greps, target its code reading with what it finds, and record the docs consulted so the spec's §7 cites them. |

**Conventions.** Both this genre of doc and the pipeline's Tier-1 spec render per one shared style
reference, `engineering/references/consumable-markdown.md`: a top-line hook, progressive
disclosure, bold key terms on first use, tables for enumerable content, diagrams at the point of
introduction, and worked examples.

**Boundaries & invariants.**
- **Human-only minting.** The agent never invents a domain or feature name; it proposes one and a
  human confirms.
- **Judged, not automatic.** A run that changed no documented behavior records a skip reason rather
  than forcing a doc.
- **Surgical updates.** An existing doc is patched only where the change touched it, then the rest is
  checked for drift against the shipped diff.
- **No new gate.** The plan gate already authorized the run; documentation is produced and validated
  unattended, like any build review finding.

## 🚀 Development & testing

The pipeline is documentation and shell tests, so its "tests" are structural assertions:

```bash
# Run the full foundation suite (what CI runs)
sh engineering/tests/suite.sh

# The checks specific to the documentation pipeline
sh engineering/tests/documenting-phase.sh      # the documenting phase + validation-protocol + lenses
sh engineering/tests/using-documentation.sh    # the producer skill + its three format references
sh engineering/tests/consulting-docs.sh        # the brainstorming consult step + spec §7 citation
sh engineering/tests/consumable-markdown.sh    # the shared conventions reference
```

To change how a feature doc looks, edit `skills/using-documentation/references/FEATURE-DOC-TEMPLATE.md`
(the doc shape), `TOC-FORMAT.md` (the index row), or `REFERENCE-TABLE-FORMAT.md` (a feature's sub-doc
table). To change how docs are validated, edit the lens docs under
`skills/documenting/references/lenses/`.
