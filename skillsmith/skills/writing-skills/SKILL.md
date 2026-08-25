---
name: writing-skills
description: Author and edit Claude skills that agents reliably discover and follow — concise structure, gerund naming, trigger-bearing descriptions, progressive disclosure, degrees of freedom, workflows, and evaluation-first iteration. Use when creating or revising any skill.
---

# Writing Skills

A skill is instructions an agent loads mid-task to do one kind of work better. It earns
its place only if an agent finds it when it's relevant and follows it once found. Most of
the craft below serves those two outcomes: discovery and compliance.

## Concise is key

The context window is shared by the system prompt, the conversation, every other skill's
metadata, and the actual request. Every token your skill spends once loaded competes with
all of that. Spend them on what the agent doesn't already know.

Assume a capable agent. Before keeping a sentence, ask whether it tells the agent something
it couldn't infer. Cut explanations of common formats, definitions of ordinary terms, and
throat-clearing about why the topic matters. A skill that reads like onboarding for a new
hire is too long; a skill reads like a reference card for an expert.

## Naming

Name a skill for the activity it supports, in gerund form: `processing-pdfs`,
`analyzing-spreadsheets`, `writing-skills`. Gerunds read as capabilities and stay
consistent across a library. Avoid vague names (`helper`, `utils`, `tools`) and bare nouns
(`documents`, `data`) — they tell an agent nothing about when to reach for them.

## Descriptions carry discovery

The `description` field is the whole basis on which an agent decides to load your skill —
it's the one part always in context, alongside every other skill's. Write it in the third
person, and make it say both **what the skill does** and **when to use it**, with concrete
trigger terms an agent's task would actually contain.

- Good: `Extract text and tables from PDFs, fill forms, merge documents. Use when working with PDF files, forms, or document extraction.`
- Too thin: `Helps with documents.`
- Wrong voice: `I can help you process PDFs.` / `You can use this to process PDFs.`

A precise description is worth more than a precise body: a skill never read because its
description didn't match is a skill that did nothing.

## Progressive disclosure

Treat `SKILL.md` as an overview — a table of contents that gets the agent oriented and
points to depth it loads only when the task needs it. Put detail in sibling files under
`references/` and link each one from `SKILL.md`.

- Keep references **one level deep** — every reference links directly from `SKILL.md`, not
  from another reference. Agents preview nested files with partial reads and miss content.
- Give a reference file over ~100 lines a short table of contents at the top, so a partial
  read still reveals its full scope.

This skill's own references:

- **[references/degrees-of-freedom.md](references/degrees-of-freedom.md)** — how much to
  constrain the agent, and the one rule for how forceful your language should be.
- **[references/framing-for-compliance.md](references/framing-for-compliance.md)** — the
  psychology of getting instructions followed, scoped honestly.
- **[references/scripts-and-runtime.md](references/scripts-and-runtime.md)** — authoring
  skills that ship executable scripts.

## Degrees of freedom

Match how tightly you constrain the agent to how fragile the task is. Open-ended tasks with
many valid paths get high-level direction; fragile tasks with one safe sequence get exact
steps. This choice also governs how forceful your wording should be — see
[references/degrees-of-freedom.md](references/degrees-of-freedom.md), which holds the single
rule on imperative force.

## Workflows and feedback loops

For a multi-step task, give ordered steps, and for a long one give a checklist the agent can
copy and tick off — it keeps a distractible agent from skipping a step. Where output quality
can be checked, build a loop: run the validator, fix what it flags, run it again, and only
proceed when it's clean. The validator can be a script or a rubric the agent reads and
compares against; either way the loop catches errors the agent wouldn't catch by re-reading
its own work.

## Evaluate first

Write the evaluation before the prose. Run the agent on a real task *without* the skill and
note where it actually fails — those failures are the only thing the skill needs to fix.
Then write the least content that closes them and check the agent now succeeds. A skill
written from imagined failures documents problems no one has; a skill written from observed
failures earns every line. To pressure-test a finished skill — does the agent still follow
it when rushed or second-guessing? — use the **testing-skills** skill.

## Anti-patterns

- **Windows-style paths.** Always forward slashes (`references/guide.md`), which work
  everywhere.
- **A menu of options.** Give one default with an escape hatch, not five libraries to
  choose from. Choice is cognitive load the agent pays every time.
- **Assuming tools are installed.** State the dependency and how to get it before using it.
- **Time-sensitive wording.** "The new API" and "as of last month" rot. Describe the
  current way plainly and park deprecated approaches in a clearly labelled "old patterns"
  section.

## Provenance

Synthesized and corrected from Anthropic's skill-authoring best practices and the
superpowers persuasion material (2026-08); this plugin's own prose, not a copy.
