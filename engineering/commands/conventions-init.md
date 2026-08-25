---
description: Onboard an existing codebase to code conventions — surface candidates, approve each, and record the approved ones into a standards tree.
argument-hint: "(optional) a path or area to scope the pass to, e.g. app/Http"
---

# conventions-init

Onboard the codebase to a **standards tree**: bootstrap `docs/standards/` from the conventions
the code already follows and the ones the developer already holds. This command is a **thin
invoker** — it holds no decision logic of its own; approval and every convention write belong to
the skills. The work is the identify → approve-each → record loop, run by the skills below; the
command's only action outside them is the one-time first-run scaffold described below.

`$ARGUMENTS`, if given, scopes the pass to a path or area (for example `app/Http`); with no
argument, scan the codebase as a whole.

## What it runs

Invoke `engineering:identifying-code-conventions` to surface candidate conventions — inference
from observed repetition in the code (with file:line evidence) and capture of rules the developer
already holds. Each candidate is handed, one at a time, to `engineering:recording-code-conventions`,
which runs the hardening interrogation and the individual approval gate before it writes. **Every
convention is individually approved before it is written** — this command never batch-writes what
identification found. The convention writes are entirely those two skills; the command decides
nothing about them.

## First run vs. re-run

- **First run** — when `docs/standards/` does not exist yet, scaffold it: create the tree and an
  empty table-format index at `docs/standards/index.md` per `STANDARDS-FORMAT.md` (in the
  `recording-code-conventions` skill directory), then run the loop to populate it. The scaffold is
  the empty container only — it holds **no conventions**; every convention row is written later by
  `recording-code-conventions`, through the gate.
- **Re-run** — when a standards tree already exists, the pass **augments** it: surface further
  candidates and route each through the loop as usual. A re-run **never clobbers** already-approved
  conventions or their index rows: the approval gate's conflict check compares each candidate
  against the recorded set, so a rule that is already captured is flagged rather than silently
  rewritten. It only adds newly-approved conventions, leaving the existing tree intact. Onboarding
  a growing codebase is expected to run more than once.

Report where the standards tree lives and what was added when the loop is done.
