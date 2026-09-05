# Receipt schema

One receipt per file, written by the rewriter - whether dispatched or applied inline by the
conductor on a small run.

```json
{
  "file": "/abs/path/in/the/working/tree/src/Billing.php",
  "before": "/abs/path/to/.engineering/<run>/vernacular/<NNN>/before/src/Billing.php",
  "edits": [
    {"start": 108, "end_before": 110, "lines_after": 9},
    {"start": 240, "end_before": 239, "lines_after": 7}
  ],
  "left_alone": 4,
  "flagged": [
    {"start": 108, "claim": "states it retries three times; could not find a retry in the method"}
  ]
}
```

## Every anchor is a before-file line number

`start` and `end_before` index the **before** file. `lines_after` is a **count**, not a
position.

This is not cosmetic: with before-anchors plus a count, `reconcile.py` derives after-file
positions by walking the edits in ascending `start` and accumulating the drift. Anchoring to
after-file lines instead would let a bad range silently invalidate every edit below it, and
Proof 1 would compare the wrong ranges — failing a clean run, or worse, passing a dirty one.

## Insertions

`end_before = start - 1` is a zero-length before-range. It arises when a tag-only docblock gains
a prose line above its tags - the same arithmetic covers it, no special case. It does **not**
arise from authoring a docblock on a symbol that had none: that is out of scope.

## The `flagged` array

`flagged` is written by the rewriter. Each entry names a claim the rewriter wrote but could not
fully ground in the code — a behaviour, precondition, collaborator, or error path it asserted
without confirming. The edit stays in `edits`; the rewrite is **kept**, not reverted. The array
is the human's checklist under the report's **Verify these yourself**, standing in for the
independent verifier vernacular no longer runs. It may be empty, and usually is.

## Constraints

- Edits are sorted by `start` and **may not overlap**. `reconcile.py` exits 2 on an overlap.
- `left_alone` counts descriptions the gate examined and deliberately did not touch. It is
  reported on every run and must not be omitted or estimated.
- `flagged` is advisory and never changes what reconcile checks; reconcile validates `edits`
  against the before/after bytes regardless of what is flagged.
