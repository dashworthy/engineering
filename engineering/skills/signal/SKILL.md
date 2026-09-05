---
name: signal
description: "The discovery entrance: interrogate a feature or vague request into a brief (brief.md §1–§6), then hand it to the shared design dialogue. Use when a feature or a vague ask enters the pipeline. One of three entrances; converges on brainstorming and never invokes another entrance."
---

# signal

Say this first, plainly: `Using the signal skill to interrogate the request into a brief.`

Run the signal discovery pipeline for the request in hand. signal is one of the three engineering
entrances: it **shapes context** from a vague ask — interrogating it into a brief — then hands that
context to the shared design dialogue. It does the same four beats every entrance does; only the
third (how it shapes context) is particular to signal. Interrogate the request into a brief rather
than jumping straight to design.

Work the beats in order.

## 1. Isolate the workspace

Before the run directory and the first question, settle how this work is isolated. This is a hard
gate: do not create the run directory or ask the first interrogation question until it is settled.
Whichever isolation signal establishes — worktree or feature branch — is the one every later phase
inherits.

First check whether isolation already exists — a worktree this session entered, or a branch other
than the repository's default branch already checked out. Either means the work is already
isolated: join it and skip the question. When it is ambiguous whether the current checkout is
already a linked worktree, confirm it: inside a work tree, `git rev-parse --git-dir
--git-common-dir` printing two different paths while `git rev-parse
--show-superproject-working-tree` prints nothing is a linked worktree (already isolated); equal
paths are the repository's one shared checkout, and a non-empty superproject path is a submodule —
treat neither as isolation. Otherwise put the choice to the user as a single structured choice —
selectable options with a free-form escape, holding the turn until they answer, using a tool to ask
it where one is available:

- **Worktree (Recommended)** — create a linked worktree on a new task branch carrying the run
  slug: prefer the harness's native worktree tool if it has one, else `git worktree add -b
  <task-branch> <path>`. Change into it, run the project's setup, and note the baseline test
  result before the first question.
- **Feature branch in this checkout** — no worktree; cut a named feature branch off the base with
  `git switch -c <task-branch>`, where `<task-branch>` carries the same slug you derive for the run.
  Never leave the work sitting on the default branch.

No such tool: present the same options as plain text and say the run is degraded.

## 2. Establish or join a run

Then obtain the run directory:

```
sh "${CLAUDE_PLUGIN_ROOT}/scripts/run-context.sh" signal <slug>
```

`<slug>` is a 2–4 word kebab-case handle you derive from the request. It prints
`.engineering/<run>/signal/` and creates it if needed; if a run is already active it joins that one
and the slug is ignored. Write `00-request.md` into that directory yourself, with the request
verbatim, before the first question. If the directory already holds a `brief.md`, do not overwrite
it — ask the user whether to resume that run.

## 3. Shape context — interrogate the request

This is the beat particular to signal, and signal always runs it. Load
`${CLAUDE_PLUGIN_ROOT}/references/interrogating-requirements.md` and drive it in the main thread (it
is interactive; it cannot run as a dispatched subagent). Supply it the run directory. Probe as structured questions — one
question at a time, its options led by the conventional default (first, marked Recommended) and
mining the correction, a free-form escape carrying the open answer — keeping
`open-threads.md` current as you go. Do not advance until the gate is met: at least 3 rounds AND all
six coverage dimensions filled. **The moment it is met, it writes `brief.md` §1–§6** — the whole
brief, in the main thread, so the interrogation is durable. That file is the deliverable, and the
brief ends at §6. If the request is genuinely trivial, the interrogation says so in one
sentence and exits with no brief.

## 4. Hand to design

Once `brief.md` §1–§6 is on disk, hand its path to `engineering:brainstorming` — the shared design
dialogue — in the main thread; signal does not write a spec.

**signal ends at the brief and hands it to `engineering:brainstorming`.** Once `brief.md` is on
disk, report its path and **invoke `engineering:brainstorming` now.** "Stop" means stop
interrogating and do not design, plan, or build yourself — it is not a stop to ask whether to
proceed. There is no gate at this seam; parking the brief with a "want me to start design?" is not
an available move — design is the next act, take it.

If the request in hand is unclear or empty, ask the user what they want built before proceeding.
