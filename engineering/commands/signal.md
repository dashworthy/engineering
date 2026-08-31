---
description: Run the signal discovery pipeline (interrogate a request into a brief) and hand it to the design dialogue.
argument-hint: what you want built (a feature / build / change request)
---

# signal

Run the signal discovery pipeline for the request below. signal is opt-in: it runs here because the user asked for it, so interrogate the request into a brief rather than jumping straight to design.

Before the run directory and the first question, isolate the workspace: invoke `engineering:using-git-worktrees` (it detects existing isolation and no-ops if a worktree this session already entered is in place). signal is an entrance, so the worktree it creates is the one every later phase inherits.

Then obtain the run directory: run `sh "${CLAUDE_PLUGIN_ROOT}/scripts/run-context.sh" signal <slug>`, where `<slug>` is a 2–4 word kebab-case handle you derive from the request. It prints `.engineering/<run>/signal/` and creates it if needed; if a run is already active it joins that one and the slug is ignored. Write `00-request.md` into that directory yourself, with the request verbatim, before the first question. If the directory already holds a `brief.md`, do not overwrite it — ask the user whether to resume that run.

The pipeline is a single interactive stage plus a hand-off:

1. **Interrogate** — invoke `engineering:interrogating-requirements` in the main thread (it is interactive; it cannot run as a dispatched subagent). Supply it the run directory. Probe through the `AskUserQuestion` tool — one question per call, its options led by the conventional default (first, marked Recommended) and mining the correction, the tool's automatic "Other" carrying the open escape — keeping `open-threads.md` current as you go. Do not advance until the gate is met: at least 3 rounds AND all six coverage dimensions filled. **The moment it is met, it writes `brief.md` §1–§6** — the whole brief, in the main thread, so the interrogation is durable. That file is the deliverable, and the brief ends at §6. If the request is genuinely trivial, interrogating-requirements says so in one sentence and exits with no brief.

2. **Hand off** — once `brief.md` §1–§6 is on disk, hand its path to `engineering:brainstorming` — the shared design dialogue — in the main thread; signal does not write a spec. Brainstorming recommends a design and hands it to `to-spec`, which holds the spec-approval gate and renders the Tier-1 spec under `.engineering/<run>/spec/` once the human approves.

**signal ends at the brief and hands it to `engineering:brainstorming`.** Once `brief.md` is on disk, report its path and **invoke `engineering:brainstorming` now.** "Stop" means stop interrogating and do not design, plan, or build yourself — it is not a stop to ask whether to proceed. There is no gate at this seam; parking the brief with a "want me to start design?" is not an available move — brainstorming is the next act, take it.

Begin now.

Request: $ARGUMENTS

If no request was provided above, ask the user what they want built before proceeding.
