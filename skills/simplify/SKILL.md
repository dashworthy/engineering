---
name: simplify
description: "The refactor entrance: interrogate disliked existing code into named target qualities paired with observable checks (via language-neutral quality lenses), write brief.md §1–§6, then hand it to the shared design dialogue. Use when a developer dislikes existing code and wants proposed refactors to accept or reject. One of the pipeline entrances; not the base `simplify` diff-cleanup skill; converges on brainstorming and never invokes another entrance."
---

# simplify

Say this first, plainly: `Using the simplify skill to interrogate the perceived problem into a brief.`

Run the simplify refactor pipeline for the code in hand. simplify is one of the engineering
entrances: it **shapes context** from a piece of existing code the developer dislikes —
interrogating *what* is disliked and *why*, through language-neutral quality lenses, into named
target qualities each paired with an observable check — then hands that context to the shared
design dialogue. It runs the same beats every entrance does — establish a run, shape context, hand
to the design dialogue — and only how it shapes context is particular to simplify. Interrogate the
perceived problem into a brief rather than proposing refactors yourself; proposing the refactor
approaches is the design dialogue's job, not this entrance's.

This is the entrance for *"I don't like this code — make it more to my liking."* It never rewrites
the code, and it is **not** the base `simplify` skill (which reviews the current diff and applies
cleanups); this entrance interrogates a perceived problem and hands off, applying nothing.

Work the beats in order.

## 1. Establish or join a run

Obtain the run directory:

```
sh "${CLAUDE_PLUGIN_ROOT}/scripts/run-context.sh" simplify <slug>
```

`<slug>` is a 2–4 word kebab-case handle you derive from the target (what is disliked, in a word or
two). It prints `.engineering/<run>/simplify/` and creates it if needed; if a run is already active
it joins that one and the slug is ignored. Write `00-request.md` into that directory yourself, with
the request verbatim — including which code the user pointed at — before the first question. If the
directory already holds a `brief.md`, do not overwrite it — ask the user whether to resume that run.

**Target selection.** Work on the code the user explicitly names — a file, function, module, or
region they call out as disliked. When they point at nothing specific, fall back to the
recently-modified code (the current diff or the last touched files) and confirm that is what they
mean before interrogating it.

## 2. Shape context — interrogate the perceived problem

This is the beat particular to simplify, and simplify always runs it. Load
`references/refactoring-lenses.md` and drive it in the main thread (it is interactive; it cannot run
as a dispatched subagent). Supply it the run directory and
the target code. It carries the language-neutral quality lenses and self-drives a lens-guided
interrogation that turns each expressed dislike into a **named target quality paired with an
observable check** — refusing to hand off while "better" is still an unmeasured preference — and,
the moment its gate is met, writes `brief.md` §1–§6 (the disliked code as §1 Problem, the target
qualities and their checks as §3 Success Criteria). That file is the deliverable, and the brief ends
at §6.

Where the interrogation needs generic requirement-mining that the lenses do not cover — an unclear
stakeholder, a success criterion the lenses cannot name — fall back to the shared discovery
reference (`${CLAUDE_PLUGIN_ROOT}/references/interrogating-requirements.md`) and drive it for that
gap. This is this entrance's own discovery leg — it is **not** a hand-off to another entrance; the
entrances are distinct and never invoke one another.

If the request is genuinely trivial — a rename, a one-liner the user could make faster than describe
— the interrogation says so in one sentence and exits with no brief.

## 3. Hand to design

Once `brief.md` §1–§6 is on disk, hand its path to `engineering:brainstorming` — the shared design
dialogue — in the main thread; simplify does not propose refactor approaches, write a spec, or
change any code.

**simplify ends at the brief and hands it to `engineering:brainstorming`.** Once `brief.md` is on
disk, report its path and **invoke `engineering:brainstorming` now.** "Stop" means stop
interrogating and do not design, plan, or build yourself — it is not a stop to ask whether to
proceed. There is no gate at this seam; parking the brief with a "want me to propose refactors?" is
not an available move — design is the next act, take it.

If the request in hand is unclear or empty, ask the user which code they want reshaped before
proceeding.
