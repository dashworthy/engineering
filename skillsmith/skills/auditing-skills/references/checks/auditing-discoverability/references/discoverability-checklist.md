# Discoverability checklist — the always-loaded surface

The lens for the discoverability check. The `description` is the whole basis on which an agent decides
to load a skill; the `name` is how a library stays legible. Both are always in context, so both are
paid every turn. Contents:

- The description: what + when + triggers
- Voice
- The name

## The description: what + when + triggers

A description must say both **what the skill does** and **when to use it**, in concrete trigger terms
an agent's task would actually contain. Flag:

- **Thin.** "Helps with documents." Names no capability and no trigger — nothing for a task to match.
  **Fix:** state the capability and the cases: "Extract text and tables from PDFs, fill forms, merge
  documents. Use when working with PDF files, forms, or document extraction."
- **What without when.** Describes the capability but names no triggering situation, so the agent
  can't tell when it applies. **Fix:** add the "Use when…" clause with the terms a real task carries.
- **When without what.** Names situations but not what the skill actually does. **Fix:** add the
  capability.
- **Missing trigger terms.** The description is abstract where the task is concrete — it says "assists
  with authoring" where a task says "write a skill", "gerund name", "progressive disclosure". **Fix:**
  fold the concrete nouns a matching task contains into the description.

**A reworded description must keep every trigger it had.** Cutting words is not the goal if it costs a
match — the goal is a description that still fires on every real task and wastes nothing.

## Voice

The description is written in the **third person**, describing the skill. Flag first- or second-person
voice:

- Wrong: "I can help you process PDFs." / "You can use this to process PDFs."
- Right: "Extract text and tables from PDFs…"

**Fix:** rewrite in the third person, preserving the what/when/triggers.

## The name

Name a skill for the **activity it supports, in gerund form** — `processing-pdfs`,
`analyzing-spreadsheets`, `auditing-skills`. Flag:

- **Vague name** — `helper`, `utils`, `tools`: tells an agent nothing about when to reach for it.
- **Bare noun** — `documents`, `data`: names a topic, not an activity.
- **Non-gerund** where a gerund reads better across the library — a name that breaks the consistent
  "-ing" shape siblings use.

**Fix:** rename to the gerund of the activity. A rename touches the directory name and every inbound
reference (`plugin.json`, `README.md`, callers) — flag those as part of the fix so the orchestrator's
apply step scrubs them together; a half-done rename orphans the skill.
