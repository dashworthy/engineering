---
description: Run the signal discovery pipeline (interrogate → sequence) on a request and produce a dependency-ordered brief.
argument-hint: what you want built (a feature / build / change request)
---

# signal

Run the full signal discovery pipeline for the request below by invoking the **`engineering:conducting-discovery`** skill and following it exactly. signal is opt-in: it runs here because the user asked for it, so run the whole discovery pipeline — interrogate and sequence first — rather than jumping straight to design.

Before the run directory and the first question, isolate the workspace: invoke `engineering:using-git-worktrees` (it detects existing isolation and no-ops if a worktree this session already entered is in place). signal is an entrance, so the worktree it creates is the one every later phase inherits.

The pipeline you are conducting:

There is **one artifact, `brief.md`, with two writers.** Stage 1 writes §1–§6 in the main thread; stage 2 appends §7 and §8 from a subagent. Neither rewrites the other's sections.

1. **Interrogate** — `engineering:interrogating-requirements` in the main thread. Probe through the `AskUserQuestion` tool — one question per call, its options led by the conventional default (first, marked Recommended) and mining the correction, the tool's automatic "Other" carrying the open escape — keeping `open-threads.md` current as you go. Do not advance until the gate is met: at least 3 rounds AND all six coverage dimensions filled. **The moment it is met, write `brief.md` §1–§6** — before any dispatch, so the interrogation is durable. Then run the expansion beat: dispatch `engineering:expanding-scope` with those requirements inline, relay its candidates through `AskUserQuestion` (one question per candidate: In-scope / Non-goal / Defer), and rewrite §1–§6 in full with every disposition in §5. Stop at §6.
2. **Sequence** — dispatch `engineering:sequencing-requirements` with the path to `brief.md` and the path to `open-threads.md`. It appends §7 (the work, in dependency order) and §8 (the handoff pointer), and never edits §1–§6. You receive a path; you do not read the file. On `OK`, hand `brief.md` to `engineering:brainstorming` — the shared design dialogue — in the main thread; signal does not write a spec. Brainstorming recommends a design and hands it to `to-spec`, which holds the spec-approval gate and renders the committed Tier-1 spec under `docs/dashworthy/engineering/specs/` once the human approves.

**signal ends at the brief and hands it to `engineering:brainstorming`.** Report the brief path and stop. Do not design, plan, or build — brainstorming takes it from there.

Invoke `engineering:conducting-discovery` now and begin.

Request: $ARGUMENTS

If no request was provided above, ask the user what they want built before proceeding.
