---
name: implement
description: "Execute an approved implementation plan task by task — TDD build and code-review gate — running to completion because the plan gate was the last human stop. Use to build out a plan that already exists under .engineering/<run>/plan/."
---

# implement

Say this first, plainly: `Using the implement skill to run the plan to completion.`

Invoke the **`engineering:executing-plans`** skill and follow it exactly: task by task,
each one driven through `engineering:tdd` and gated by `engineering:code-review`, then
`engineering:finishing-a-development-branch` to carry out the finish strategy the plan
authorized. The plan gate was the last human stop, so this runs to completion with no
mid-flow checkpoints.

If a plan path is supplied, pass it through. Otherwise let `executing-plans` find and confirm
the most recent plan under `.engineering/<run>/plan/` itself — do not guess a path here.
