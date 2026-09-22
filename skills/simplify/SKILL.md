---
name: simplify
description: "The refactor entrance: interrogate disliked existing code into named target qualities paired with observable checks (via language-neutral quality lenses), write brief.md §1–§6, then hand it to the shared design dialogue. Use when a developer dislikes existing code and wants proposed refactors to accept or reject. One of four entrances; not the base `simplify` diff-cleanup skill; converges on brainstorming and never invokes another entrance."
---

# simplify

Use this on existing code a developer dislikes — *"I don't like this code, make it more to my
liking."* Interrogate *what* they dislike and *why* through language-neutral quality lenses, into
named target qualities each paired with an observable check, then hand that to the design dialogue.
Don't propose the refactors yourself — that is the design dialogue's job.

This is **not** the base `simplify` skill (which reviews the current diff and applies cleanups): it
interrogates a perceived problem and hands off, changing no code.

Work the beats in order.

## 1. Establish or join a run

Obtain the run directory:

```
sh "${CLAUDE_PLUGIN_ROOT}/scripts/run-context.sh" simplify <slug>
```

`<slug>` is a 2–4 word kebab-case handle you derive from the target (what is disliked, in a word or
two); see `${CLAUDE_PLUGIN_ROOT}/references/establishing-run.md` for what the call prints and how it
joins an active run. Write `00-request.md` into that directory yourself, with the request verbatim —
including which code the user pointed at — before the first question. If the directory already holds
a `brief.md`, do not overwrite it — ask the user whether to resume that run.

**Target selection.** Work on the code the user explicitly names — a file, function, module, or
region they call out as disliked. When they point at nothing specific, fall back to the
recently-modified code (the current diff or the last touched files) and confirm that is what they
mean before interrogating it.

## 2. Shape context — interrogate the perceived problem

Load `references/refactoring-lenses.md` and drive it in the main thread (it is interactive; it
cannot run as a dispatched subagent), supplying the run directory and the target code. It carries
the language-neutral quality lenses and drives a lens-guided interrogation that turns each expressed
dislike into a **named target quality paired with an observable check** — refusing to hand off while
"better" is still an unmeasured preference — and, once its gate is met, writes `brief.md` §1–§6 (the
disliked code as §1 Problem, the target qualities and their checks as §3 Success Criteria). The
brief is the deliverable and ends at §6.

Where the interrogation needs generic requirement-mining the lenses do not cover — an unclear
stakeholder, a success criterion the lenses cannot name — fall back to the shared discovery
skill (`engineering:interrogating-requirements`) for that gap. That is
your own discovery leg, not a hand-off — never invoke another entrance.

If the request is genuinely trivial — a rename, a one-liner the user could make faster than describe
— say so in one sentence and exit with no brief.

## 3. Hand to design

Once `brief.md` §1–§6 is on disk, report its path and **invoke `engineering:brainstorming` now** —
the shared design dialogue, in the main thread. Propose no refactor approaches, write no spec, and
change no code; that is downstream. "Stop" here means stop interrogating, not stop to ask whether to
proceed — there is no gate at this seam, and handing off is the next act.

If the request in hand is unclear or empty, ask the user which code they want reshaped before
proceeding.
