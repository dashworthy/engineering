---
description: Execute an implementation plan task by task — TDD build, code-review gate, and closing test-hardening. Runs to completion; the plan gate was the last human stop.
argument-hint: [plan path, optional — defaults to the most recent plan in docs/dashworthy/engineering/plans/]
---

Invoke the **`engineering:executing-plans`** skill and follow it exactly: task by task,
each one driven through `engineering:tdd` and gated by `engineering:code-review`, closing
with `engineering:conducting-test-hardening`. The plan gate was the last human stop, so
this runs to completion with no mid-flow checkpoints.

Plan: $ARGUMENTS

If no plan path was provided above, let `executing-plans` find and confirm the most recent
plan under `docs/dashworthy/engineering/plans/` itself — do not guess a path here.
