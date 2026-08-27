---
name: rewriting-docblock-prose
description: "[Docs] A dispatched docblock-prose beat — or run inline on a small pass — that rewrites one file's docblock prose. Applies the comprehension gate, rewrites only descriptions that fail it, writes in place, returns a receipt of the line ranges replaced. Improves existing docblocks only; never authors one where none existed, never touches an annotation or executable code."
---

# Rewriting Docblock Prose

You are applied against **one file** - dispatched as a subagent on a large run, or run inline by
the conductor on a small one. You read it, decide which docblock descriptions fail the
comprehension gate, rewrite only those, write the file, and return a receipt.

## Your payload

```json
{
  "file":         "<absolute path in the working tree>",
  "hunks":        [{"start": 104, "end": 131}],
  "before_path":  "<absolute path to this file's byte copy>",
  "receipt_path": "<absolute path to write the receipt to>",
  "skill_path":   "<absolute path to this document>",
  "gate_path":    "<absolute path to comprehension-gate.md>",
  "schema_path":  "<absolute path to receipt-schema.md>"
}
```

`hunks` carries **working-tree line numbers** for the ranges this branch changed. Read
`gate_path` and `schema_path` before you start. They are the contract; this document does not
restate them, so that there is one copy to change.

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
honestly.** It is the only evidence anyone has that the gate is still discriminating, and a
guessed number makes a run that rewrote everything indistinguishable from one that judged
carefully.

`flagged` is your one concession to the missing verifier. If you rewrote a description into a
claim you could not fully ground in the code in front of you - a behaviour, precondition,
collaborator, or error path you asserted but could not confirm - add
`{"start": <before-anchor>, "claim": "<the assertion you could not confirm>"}` to `flagged`. You
do **not** revert it; you keep the rewrite and let the human check it against `git diff`. Flag
honestly and sparingly: flag what you genuinely could not confirm, not everything you wrote.

## Your return value

Exactly one line:

```
wrote <N> edits, left <M> alone, flagged <F>, receipt at <receipt_path>
```

You return a receipt path and counts. You never return prose, and you **never return a
description you wrote**. If you find yourself quoting a docblock back to the conductor, the
context firewall has already failed. (The claim text of a flag goes in the receipt's `flagged`
array, where the conductor reads it as a field - never in this return line.)

If the file is unreadable, or you cannot map a hunk to any symbol, write a receipt with an
empty `edits` array and return:

```
wrote 0 edits, left 0 alone, flagged 0, receipt at <receipt_path>  BLOCKED: <one-line reason>
```

## Red flags - STOP

- Editing anything outside a docblock, for any reason - code, whitespace, a typo in adjacent
  code.
- Authoring a docblock on a symbol that had none, adding a tag to a symbol that had none, or
  claiming a range that touches a tag line or its continuation lines because they don't start
  with `@`.
- Anchoring receipt line numbers to the file as you are editing it rather than to `before_path`,
  or estimating `left_alone` instead of counting it.
- Flagging everything, or nothing, instead of the descriptions you genuinely could not ground.
