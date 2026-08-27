---
name: rewriting-docblock-prose
description: "A dispatched docblock-prose beat — or run inline on a small pass — that rewrites docblock prose in the file, or batch of files, it is handed. Applies the comprehension gate, rewrites only descriptions that fail it, writes in place, returns a receipt per file of the line ranges replaced. Improves existing docblocks only; never authors one where none existed, never touches an annotation or executable code."
---

# Rewriting Docblock Prose

You are applied against **one or more files** - dispatched as a subagent carrying a batch on a
large run, or run inline by the conductor on a small one. For each file you read it, decide which
docblock descriptions fail the comprehension gate, rewrite only those, write the file, and return
its receipt. Everything below is the procedure for a single file; on a batch, run it once per file
in `files`, independently, and emit one receipt and one return line per file.

## Your payload

Dispatched, you receive a **batch** - one entry in `files` per file to rewrite, plus the three
paths shared across the whole batch:

```json
{
  "files": [
    {
      "file":         "<absolute path in the working tree>",
      "hunks":        [{"start": 104, "end": 131}],
      "before_path":  "<absolute path to this file's byte copy>",
      "receipt_path": "<absolute path to write this file's receipt to>"
    }
  ],
  "skill_path":   "<absolute path to this document>",
  "gate_path":    "<absolute path to comprehension-gate.md>",
  "schema_path":  "<absolute path to receipt-schema.md>"
}
```

A batch may hold a single file. `hunks` carries **working-tree line numbers** for the ranges this
branch changed. Read `gate_path` and `schema_path` once before you start - they are the contract,
shared across every file in the batch; this document does not restate them, so that there is one
copy to change. Run inline there is no payload: the conductor already holds these paths and writes
each receipt itself.

## Scope

Map each hunk to its **enclosing symbol** - the nearest enclosing documentable unit (function,
method, class, interface, trait, module, or property) whose body or signature the hunk falls
inside. Those symbols are your scope.

- A symbol in scope **with a docblock**: apply the gate to its description. A tag-only docblock
  counts - it exists, so adding a prose line above its tags is in scope.
- A symbol in scope with **no docblock at all**: **out of scope.** You improve existing prose; you
  never author a docblock where none existed. Leave it.
- A symbol the hunks do not reach: **out of scope**, even in this same file. Do not touch it,
  however bad its prose is.

## The three prohibitions

1. **Never write, edit, or delete a structured annotation.** `@param`, `@return`, `@throws`,
   `@var`, generics, Psalm/PHPStan annotations, Sphinx field lists. You write prose, never tags.
   A multi-line annotation (a `@param array{...}` or a wrapped `@throws` description spread over
   several lines) is off-limits in full - its continuation lines do not begin with `@`, so the
   proof does not catch a range that claims them; you are the only guard there. Never claim any
   line at or below a docblock's first tag.
2. **Never claim a range containing an annotation line.** The reconcile check treats this as a
   precondition and halts the whole run on a single violation, so a claimed range that spans a
   tag does not merely lose your edit - it kills every other file's work too.
3. **Never change a line of executable code**, including whitespace on it.

## Whole lines, always

Every edit replaces **whole lines** with whole lines. Never edit part of a line, and never
leave a rewritten description sharing a line with code. A single-line docblock being expanded
into a block comment is a whole-line replacement of one line by several, which is fine; a
description spliced into the middle of an existing line is not representable in a receipt and
will fail reconciliation.

## Writing the receipt

Per `schema_path`. Every anchor is a **before-file** line number and `lines_after` is a count.
Compute anchors against `before_path`, not against the file as you are editing it - your own
earlier edits have already shifted the working tree's numbering, and a receipt anchored to a
moving target is the one bug reconciliation cannot catch for you.

Sort `edits` by `start`. They may not overlap.

`left_alone` counts descriptions you examined and deliberately did not touch. **Count them
honestly** (per `schema_path`) — it is the only evidence the gate is still discriminating.

`flagged` is your one concession to the missing verifier. If you rewrote a description into a
claim you could not fully ground in the code in front of you - a behaviour, precondition,
collaborator, or error path you asserted but could not confirm - add
`{"start": <before-anchor>, "claim": "<the assertion you could not confirm>"}` to `flagged`. You
do **not** revert it; you keep the rewrite and let the human check it against `git diff`. Flag
honestly and sparingly: flag what you genuinely could not confirm, not everything you wrote.

## Your return value

Exactly one line **per file in the batch**:

```
<file>: wrote <N> edits, left <M> alone, flagged <F>, receipt at <receipt_path>
```

You return receipt paths and counts. You never return prose, and you **never return a
description you wrote**. If you find yourself quoting a docblock back to the conductor, the
context firewall has already failed. (The claim text of a flag goes in the receipt's `flagged`
array, where the conductor reads it as a field - never in this return line.)

If a file is unreadable, or you cannot map a hunk to any symbol, write that file's receipt with an
empty `edits` array and return, for that file:

```
<file>: wrote 0 edits, left 0 alone, flagged 0, receipt at <receipt_path>  BLOCKED: <one-line reason>
```

## Red flags - STOP

- Editing anything outside a docblock, for any reason - code, whitespace, an annotation or tag
  line, a typo in adjacent code.
- Anchoring receipt line numbers to the file as you are editing it rather than to `before_path`.
