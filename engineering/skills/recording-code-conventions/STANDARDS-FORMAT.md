# Standards Format

A **convention** is a repeatable standing rule this project holds itself to — "controllers
get a dedicated form request," "money is stored in integer cents," "public functions carry
a return type." It is not a one-time decision (that is an ADR). This file fixes two shapes: the shape of a single convention
document, and the shape of the index that lists them all. Every skill that writes a
convention writes this shape; every skill that reads one binds to it.

The standards tree is a **per-app runtime artifact**, rooted at `docs/standards/` in the
target repo — a sibling of `docs/adr/`, never shipped inside the plugin.

## Filename

`docs/standards/<topic>/<kebab-title>.md`

`<topic>` groups related conventions (`controllers/`, `persistence/`, `naming/`) and is the
same value that fills the index's **Topic/category** column. `<kebab-title>` is a short,
lowercase, hyphenated name for the rule — `dedicated-form-request.md`,
`money-as-integer-cents.md`. One convention per file; a file is the unit the index links to.

## Convention document shape

Everything in `<angle brackets>` below is a placeholder to replace, here and throughout.

```markdown
# <Title — the rule in a few words>

## Rule

<The standing rule, stated once, as an imperative a builder can follow without
interpretation. "Every controller action that accepts input binds to a dedicated form
request class; the controller never reads the request bag directly.">

## What it is

<The positive boundary. Concrete cases the rule governs, and — where it sharpens the
rule — one worked example of code that satisfies it. This field is mandatory: a
convention with no stated "what it is" is a slogan, not a rule.>

## What it is not

<The negative boundary. The adjacent cases this rule does NOT govern, and the near-misses
it is most likely to be over-applied to. This field is mandatory: the is-not boundary is
what stops a rule from being stretched to cover work it was never meant to.>

## Provenance

- **Who:** <who approved this convention — the sole approver, by name or handle>
- **When:** <YYYY-MM-DD it was first approved>
- **Source:** <the evidence behind it — observed repetition with file:line, a dictated
  standing rule, or the PR the convention was harvested from at review time (`PR #NNN`).
  This is where a harvesting PR is named.>
- **Lifecycle:** active | retired <YYYY-MM-DD>
```

The `Provenance` sub-fields are defined by their placeholder comments above. `Lifecycle` is
the one field that says whether a rule still binds: **`active` means the rule binds, `retired
<date>` means it no longer does — there is no separate `amended` state.** An amendment leaves
the rule `active` and is recorded only by the index's **Last amended** date. A reader asking
"does this rule bind today?" treats every non-`retired` row as binding, which is the test
`using-code-conventions` applies when it skips retired rows.

## Lifecycle — amend vs. retire

The process for amending versus retiring a convention — which document and index edits each
requires — belongs to `recording-code-conventions`'s `SKILL.md`. At the format level, an amend
edits the document in place and bumps **Last amended** with Status unchanged; a retire sets both
`Lifecycle:` and the index **Status** to `retired <date>` and keeps the row rather than deleting
it, so a reader can still see the rule once existed.

## The standards index

One index for the whole tree, at `docs/standards/index.md`, in table form. It is the map a
reader (or `using-code-conventions`) scans to find the governing rule for a piece of work
without opening every document. Every convention document has exactly one row; a retired
convention keeps its row with **Status** `retired`.

```markdown
# Standards Index

| Name | Topic/category | When relevant | Status | Date created | Last amended | Link | Source/provenance |
|------|----------------|---------------|--------|--------------|--------------|------|-------------------|
| Dedicated form request | controllers | Adding or editing a controller action that accepts input | active | 2026-08-24 | — | [link](controllers/dedicated-form-request.md) | Observed in 7 controllers (app/Http/...) |
```

The eight columns are fixed:

| Column | Holds |
|--------|-------|
| **Name** | The convention's short name — matches its document title. |
| **Topic/category** | The `<topic>` group, matching the document's directory. |
| **When relevant** | The work situation that makes this rule apply — the trigger a reader matches their task against. This is the column `using-code-conventions` reads to decide what to cite. |
| **Status** | `active` or `retired`, mirroring the document's `Lifecycle` (defined above). An amendment bumps **Last amended** rather than changing it. |
| **Date created** | `YYYY-MM-DD` of first approval. |
| **Last amended** | `YYYY-MM-DD` of the most recent amendment, or `—` if never amended. |
| **Link** | Relative path from the index to the convention document. |
| **Source/provenance** | One-line origin — the evidence, dictation, or PR the `Provenance` block records in full. |

## How to keep it current

The index and the documents move together. A convention written, amended, or retired is not
finished until its index row reflects the same state on the same edit — an index that says
`active` for a rule whose document says `retired` is worse than no index, because a reader
trusts it. Update the row in the same change that writes the document, never on a later pass.
