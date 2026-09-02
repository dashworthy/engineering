---
name: auditing-skills
description: Audit an existing skill or a whole plugin for efficiency and quality problems — anti-patterns, verbosity, confusing logic, cross-skill duplication, costly subagent usage, and dead skills no task ever reaches — then propose each fix, or a dead skill's fate, as an explicit choice put to the user and apply the approved ones. Use when reviewing, optimizing, cutting the token cost of, or pruning a skill or plugin.
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

Six dimensions; detection cues and fix shapes for each are in
[references/audit-checks.md](references/audit-checks.md).

1. **Anti-patterns** — writing-skills' own list (menu-of-options, nested references, Windows paths,
   time-sensitive wording, thin descriptions), plus structural ones it doesn't name — notably a
   **caller back-reference** in a `description`, which is always-loaded cost.
2. **Excessive verbosity** — prose that tells a capable agent what it already knows.
3. **Confusing logic** — control flow an agent can misread under load.
4. **Cross-skill duplication** — the same content across skills; fix with one canonical owner or a
   shared reference.
5. **Subagent economics** — a dispatch whose fixed cost exceeds the payload it moves out of the main
   context (the break-even test is in
   [references/subagent-economics.md](references/subagent-economics.md)).
6. **Dead skills** — a whole skill no task ever reaches; the fix is a fate (wire in / fold into a
   sibling / remove), not a reword.

## Quantify and rank

Attach an estimated token saving to each finding, then rank by saving weighted by how often the
skill pays it. A cut in a `description` beats a cut in `SKILL.md` beats a cut in a reference, because
the description is in context on every turn, the body loads whenever the skill is used, and a
reference loads only when reached. Cheap, high-frequency wins go first.

## Propose fixes — one finding, one question

Put each fixable finding to the user as a structured choice, using a tool to ask it where one is available:

- The options are 2–3 concrete fix variants (reword / cut / extract-to-reference / merge-and-link),
  your recommendation first and marked `(Recommended)`, with the estimated token saving alongside
  each. Include **Skip** as the free-form escape so declining is always
  available.
- Where the fix is a concrete before/after, use a `preview` so the user compares the actual diff,
  not a paraphrase.
- **One finding per question.** A blanket "yes" over a batch waves through a change the user would
  have rejected on its own. The exception is several instances of the *same* mechanical fix (five
  Windows-path corrections) — those may share one question.

**A dead skill is a question of fate, not a fix variant.** When the finding is a whole dead skill
(dimension 6), the options are the three outcomes — **wire it in** (keep the skill,
repair its discovery), **fold into a sibling** (merge its content, then delete it), **remove** (delete
it) — recommendation first and marked `(Recommended)`, each option's description naming what it keeps
and what it deletes. This is genuinely the user's call: folding and removal delete a skill and rewrite
its inbound references, so the question is also the gate — never fold or remove a skill the user did
not approve for it. One dead skill, one question.

## Apply — following writing-skills

On approval, edit the skill directly, following the writing-skills rule for whatever you touched: a
reworded description still carries its triggers; an extracted reference stays one level deep. Change
only what the finding named. A skipped finding stays in the report with its rationale; it is not
applied.

**Folding or removing a dead skill touches more than one file** — deleting the skill directory alone
leaves dangling references. On a **fold**, first merge the kept content into the sibling and confirm
its `description` now carries the folded triggers, *then* delete the dead skill and scrub its name from
`plugin.json`, `README.md`, and any caller or command that routed to it. On a **remove**, delete the
directory and scrub the same references. On **wire it in**, keep the skill and edit only its discovery
surface (its `description`, name, or the forward reference that should reach it). Removal is hard to
reverse, and the user's explicit approval is its only gate.

One rule holds without exception: **a fix preserves what the skill does.** If a proposed cut would
drop a real instruction, it was never verbosity — keep it. Verify the executable parts (any scripts,
frontmatter keys, `name`) are byte-for-byte untouched; the audit moves prose and structure, not
behavior.

## How this fits authoring

`writing-skills` sets the rules; this skill holds an existing skill to them and buys back the tokens.
After a structural fix — an extraction, a merge, a reworded description — run `testing-skills` to
confirm the skill is still discovered and followed.
