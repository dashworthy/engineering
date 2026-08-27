---
name: auditing-skills
description: Audit an existing skill or a whole plugin for efficiency and quality problems — anti-patterns, verbosity, confusing logic, cross-skill duplication, and subagent usage whose fixed token cost outruns its payload — then propose each fix through AskUserQuestion and apply the approved ones. Use when reviewing, optimizing, or cutting the token cost of a skill or plugin.
---

# Auditing Skills

A skill earns its tokens only if what it spends buys the agent something it couldn't infer. This
audit finds the spend that isn't earning its place — and the structural problems that make a skill
hard to discover, follow, or maintain — then proposes fixes and applies the ones the user approves.

Its yardstick is the **writing-skills** doctrine. This skill does not restate those rules; it holds
an existing skill against them and buys back the tokens. When a fix is unclear, the standard it
answers to is in `writing-skills` and its references.

## The unit of audit

One skill, or a whole plugin. Prefer plugin-level: only across a plugin can you see duplication
worth abstracting, and the description-level costs that repeat across siblings. Given a single skill
inside a plugin, still glance at its siblings for shared content before proposing an extraction.

## Sizing the run

- **Small plugin** (a handful of skills, references included): read every `SKILL.md` and reference
  inline. You need the whole set in one context to judge duplication anyway, and the read is cheap.
- **Large plugin**: one inline pass over the descriptions and `SKILL.md` headings for the
  cross-skill and duplication view, then a per-skill deep-read subagent for the verbosity and logic
  checks, then a synthesis pass. Before dispatching, apply this skill's own break-even test
  ([references/subagent-economics.md](references/subagent-economics.md)) — do not spawn a reader for
  a skill smaller than the reader's fixed cost.

## What to audit

Five dimensions; detection cues and fix shapes for each are in
[references/audit-checks.md](references/audit-checks.md).

1. **Anti-patterns** — measured against writing-skills' own list (menu-of-options, nested
   references, Windows paths, time-sensitive wording, thin descriptions) plus structural ones the
   list doesn't name, notably a **caller back-reference**: a skill that names the skill(s) that
   invoke it, which is redundant, brittle, and — in a `description` — always-loaded cost.
2. **Excessive verbosity** — prose that tells a capable agent what it already knows: explained
   common formats, defined ordinary terms, throat-clearing about why the topic matters, onboarding
   tone. Every cut is tokens saved on every load.
3. **Confusing logic** — control flow an agent can misread: unordered prose for an ordered task, an
   ambiguous conditional, a gate buried mid-paragraph, a step that depends on one three sections
   away.
4. **Cross-skill duplication** — the same guidance or reference content repeated across skills in
   the plugin. A candidate for one canonical owner the others link, or a shared reference — the same
   abstraction move you'd make in code.
5. **Subagent economics** — where a skill dispatches a subagent, weigh its fixed cost (the
   subagent's system prompt, the skill instructions re-injected, and the discovery it must redo cold)
   against the payload moved out of the main context. Dispatch that saves less than it costs is the
   inefficiency. The model and the break-even test are in
   [references/subagent-economics.md](references/subagent-economics.md).

## Quantify and rank

Attach an estimated token saving to each finding, then rank by saving weighted by how often the
skill pays it. A cut in a `description` beats a cut in `SKILL.md` beats a cut in a reference, because
the description is in context on every turn, the body loads whenever the skill is used, and a
reference loads only when reached. Cheap, high-frequency wins go first.

## Propose fixes — one finding, one question

Put each fixable finding to the user through `AskUserQuestion`:

- The options are 2–3 concrete fix variants (reword / cut / extract-to-reference / merge-and-link),
  your recommendation first and marked `(Recommended)`, with the estimated token saving in its
  description. `AskUserQuestion` supplies **Skip** — the "Other" choice — so declining is always
  available.
- Where the fix is a concrete before/after, use a `preview` so the user compares the actual diff,
  not a paraphrase.
- **One finding per question.** A blanket "yes" over a batch waves through a change the user would
  have rejected on its own. The exception is several instances of the *same* mechanical fix (five
  Windows-path corrections) — those may share one question.

## Apply — following writing-skills

On approval, edit the skill directly, following the writing-skills rule for whatever you touched: a
reworded description still carries its triggers; an extracted reference stays one level deep. Change
only what the finding named. A skipped finding stays in the report with its rationale; it is not
applied.

One rule holds without exception: **a fix preserves what the skill does.** If a proposed cut would
drop a real instruction, it was never verbosity — keep it. Verify the executable parts (any scripts,
frontmatter keys, `name`) are byte-for-byte untouched; the audit moves prose and structure, not
behavior.

## How this fits authoring

`writing-skills` sets the rules; this skill holds an existing skill to them and buys back the tokens.
After a structural fix — an extraction, a merge, a reworded description — run `testing-skills` to
confirm the skill is still discovered and followed.
