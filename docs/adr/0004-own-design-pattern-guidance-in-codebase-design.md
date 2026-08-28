# 0004. Own design-pattern guidance in codebase-design, split selectable matrix from evaluative lens

## Status

Accepted

## Context

`codebase-design` shapes a module's interface from at least two competing shapes
(`DESIGN-IT-TWICE.md`) and judges them on depth and misuse resistance, but it never prompts
the designer to consult the catalog of named design solutions — the Gang-of-Four patterns,
the SOLID principles, common anti-patterns — that a seasoned designer reaches for at exactly
that moment. Adding that guidance forced two decisions with genuine live alternatives.

**Where it lives.** The guidance could sit in `brainstorming` (which weighs approaches, but
explicitly defers interface shape to `codebase-design`), in a new standalone skill (a 32nd
skill and a new cross-cutting concept for both phases to invoke), in both phases (two homes
for one matrix), or in `codebase-design` alone. Because `brainstorming` already invokes
`codebase-design` once per boundary an approach introduces, placing the guidance in
`codebase-design` reaches it from the approach path without editing `brainstorming`.

**How the three concerns organize.** GoF patterns are *selectable* — "adopt this named shape
here" — and belong in an `AskUserQuestion` proposal. SOLID and anti-patterns are *evaluative*
— "does the shape I sketched violate a principle or smell?" — and belong as a lens run over
the two shapes `DESIGN-IT-TWICE.md` already produces. A single combined file mixes those two
modes against the one-file-one-job grain of the existing companions; three separate files
split the heavy overlap between a code smell and the SOLID principle it breaks (a fat
interface simply *is* an ISP violation) across two documents.

Two constraints bound the answer: the developer's instruction to *trust the model* — the
artifacts carry decision content only, never prose explaining what a pattern is, never code —
and refactoring.guru's own warning that patterns are routinely over-applied, forcing
complexity where a plain shape would do.

## Decision

Design-pattern, SOLID, and anti-pattern guidance is owned by the `codebase-design` skill as
companion files, split by use: a selectable GoF pattern matrix (`PATTERN-MATRIX.md`) whose
triggers feed an `AskUserQuestion` proposal that defaults to "plain shape, no pattern" unless a
named trigger fires, and an evaluative shape-review lens (`SHAPE-REVIEW.md`) applying the SOLID
principles and anti-patterns over the two competing `DESIGN-IT-TWICE.md` shapes, each smell's
remedy pointing back into the matrix.

## Consequences

- **Reached on both paths without new surface elsewhere.** Because `brainstorming` invokes
  `codebase-design` per boundary, the guidance fires on the approach path and on direct entry,
  and `brainstorming`'s dialogue is left untouched.
- **Each file keeps one job.** The matrix and the review lens match how the existing
  `DEEPENING.md` / `DESIGN-IT-TWICE.md` companions are organized, and the propose-vs-evaluate
  split mirrors how the two are actually used.
- **The SOLID↔smell overlap stays local.** Keeping SOLID and anti-patterns in one file means
  the place where "fat interface" and "ISP violation" name the same thing is written once, not
  reconciled across two documents.
- **Over-application is guarded by default.** The "no pattern" default means a pattern is
  proposed only when a named trigger genuinely fires, honoring the source's warning.
- **`codebase-design` accretes surface.** Two more companion files and a new `SKILL.md` section
  sit on top of an already substantial skill.
- **The guidance is prose-only.** Trusting the model means no test asserts that a pattern was
  correctly proposed or a smell correctly flagged; the guidance can drift from the model's
  actual behavior with nothing mechanical to catch it.
