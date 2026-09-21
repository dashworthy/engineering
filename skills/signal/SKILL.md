---
name: signal
description: "The discovery entrance: interrogate a feature or vague request into a brief (brief.md §1–§6), then hand it to the shared design dialogue. Use when a feature or a vague ask enters the pipeline. One of four entrances; converges on brainstorming and never invokes another entrance."
---

# signal

Say this first, plainly: `Using the signal skill to interrogate the request into a brief.`

Interrogate the request in hand into a brief, then hand that brief to the shared design dialogue —
rather than jumping straight to design.

Work the beats in order.

## 1. Establish or join a run

Obtain the run directory:

```
sh "${CLAUDE_PLUGIN_ROOT}/scripts/run-context.sh" signal <slug>
```

`<slug>` is a 2–4 word kebab-case handle you derive from the request; see
`${CLAUDE_PLUGIN_ROOT}/references/establishing-run.md` for what the call prints, how it joins an
active run, and the shared setup steps that follow — seed `00-request.md` verbatim before the first
question, resume-guard on an existing `brief.md`, and persist findings as found.

## 2. Shape context — interrogate the request

This is the beat particular to signal, and signal always runs it. Invoke
`engineering:interrogating-requirements` and drive it in the main thread (it
is interactive; it cannot run as a dispatched subagent). Supply it the run directory. It self-drives the interrogation and, the moment its gate is met, writes `brief.md` §1–§6 — the
whole brief, in the main thread, so it is durable. That file is the deliverable, and the brief ends
at §6. If the request is genuinely trivial, the interrogation says so in one
sentence and exits with no brief.

## 3. Hand to design

Once `brief.md` §1–§6 is on disk, hand its path to `engineering:brainstorming` — the shared design
dialogue — in the main thread; signal does not write a spec.

**signal ends at the brief and hands it to `engineering:brainstorming`.** Once `brief.md` is on
disk, report its path and hand off per the shared entrance contract
(`${CLAUDE_PLUGIN_ROOT}/references/entrance-contract.md`) — invoke `engineering:brainstorming` now.

If the request in hand is unclear or empty, ask the user what they want built before proceeding.
