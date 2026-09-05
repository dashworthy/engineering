---
name: signal
description: "The discovery entrance: interrogate a feature or vague request into a brief (brief.md §1–§6), then hand it to the shared design dialogue. Use when a feature or a vague ask enters the pipeline. One of three entrances; converges on brainstorming and never invokes another entrance."
---

# signal

Say this first, plainly: `Using the signal skill to interrogate the request into a brief.`

Run the signal discovery pipeline for the request in hand. signal is one of the three engineering
entrances: it **shapes context** from a vague ask — interrogating it into a brief — then hands that
context to the shared design dialogue. It runs the same beats every entrance does — establish a run, shape
context, hand to the design dialogue — and only how it shapes context is particular to signal.
Interrogate the request into a brief rather than jumping straight to design.

Work the beats in order.

## 1. Establish or join a run

Obtain the run directory:

```
sh "${CLAUDE_PLUGIN_ROOT}/scripts/run-context.sh" signal <slug>
```

`<slug>` is a 2–4 word kebab-case handle you derive from the request. It prints
`.engineering/<run>/signal/` and creates it if needed; if a run is already active it joins that one
and the slug is ignored. Write `00-request.md` into that directory yourself, with the request
verbatim, before the first question. If the directory already holds a `brief.md`, do not overwrite
it — ask the user whether to resume that run.

## 2. Shape context — interrogate the request

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

## 3. Hand to design

Once `brief.md` §1–§6 is on disk, hand its path to `engineering:brainstorming` — the shared design
dialogue — in the main thread; signal does not write a spec.

**signal ends at the brief and hands it to `engineering:brainstorming`.** Once `brief.md` is on
disk, report its path and **invoke `engineering:brainstorming` now.** "Stop" means stop
interrogating and do not design, plan, or build yourself — it is not a stop to ask whether to
proceed. There is no gate at this seam; parking the brief with a "want me to start design?" is not
an available move — design is the next act, take it.

If the request in hand is unclear or empty, ask the user what they want built before proceeding.
