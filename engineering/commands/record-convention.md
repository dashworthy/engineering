---
description: Record a single code convention dictated from the developer's head — hardened, individually approved, then written to the standards tree.
argument-hint: "the convention to record, e.g. 'money is stored as integer cents'"
---

# record-convention

Record **one** convention the developer already holds in their head — a standing rule they want
written down without waiting for it to be inferred from code. This command is a **thin invoker**:
it holds no logic of its own. The whole job is `engineering:recording-code-conventions`, the
single writer; this command is just the one-convention entry point to it.

`$ARGUMENTS` is the convention to record, stated however the developer phrased it (for example,
"money is stored as integer cents"). It is a rough starting point, not the final rule — the
skill sharpens it.

## What it runs

Invoke `engineering:recording-code-conventions` with the dictated convention as its candidate.
That skill does everything: it runs the **hardening interrogation** (the choice-menu, one-question-per-turn
process that pins what the convention **is**, what it **is not**, and its robustness), takes the
sharpened rule through the **individual approval gate** (with the conflict check against
already-recorded conventions), and only then **writes** the convention document per
`STANDARDS-FORMAT.md` and its index row. Nothing is written without the approver's yes.

If `$ARGUMENTS` is empty, ask the developer which convention they want to record before invoking
the skill — there is nothing to harden or approve otherwise.
