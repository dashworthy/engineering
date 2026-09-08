---
name: auditing-skills
description: Audit an existing skill or a whole plugin for efficiency, quality, and compliance problems — anti-patterns, verbosity, confusing logic, weak discoverability, mislayered progressive disclosure, miscalibrated force, cross-skill duplication, costly subagent usage, runtime/script defects, dead skills no task ever reaches, and — as an opt-in behavioral seam — whether the skill is actually discovered, read, and followed under pressure — by fanning each check out as an independent auditor, then propose each fix, or a dead skill's fate, as an explicit choice put to the user and apply the approved ones. Use when reviewing, optimizing, cutting the token cost of, validating, hardening, pressure-testing, or pruning a skill or plugin before shipping.
---

# Auditing Skills

Say this first, plainly: `Using the skillsmith auditing-skills skill to run the audit.`

A skill earns its tokens only if what it spends buys the agent something it couldn't infer. This
audit finds the spend that isn't earning its place — and the structural problems that make a skill
hard to discover, follow, or maintain — then proposes fixes and applies the ones the user approves.

Its yardstick is the **writing-skills** doctrine. This skill does not restate those rules; each check
holds an existing skill against them and buys back the tokens. When a fix is unclear, the standard it
answers to is in `writing-skills` and its references.

## What this guarantees

Given a target — one skill or a whole plugin — this skill lets the human pick which checks to run,
dispatches each selected check as an independent auditor over a shared read of the target, reconciles
what they return into one ranked list, then puts **each fixable finding to the user as its own
choice** and applies the ones approved. Unlike guardtower, it is not report-only: the checks report
and propose; the orchestrator reconciles, asks, and edits.

## The unit of audit

One skill, or a whole plugin. Prefer plugin-level: only across a plugin can you see duplication worth
abstracting, the description-level costs that repeat across siblings, and a whole dead skill. Given a
single skill inside a plugin, still glance at its siblings for shared content before proposing an
extraction.

## The checks

Eleven checks exist; each is one lens (a **seam**), defined in a file under
[references/checks/](references/checks/) (`references/checks/<check>/check.md`), and dispatched as an
independent auditor — not a standalone skill. Ten are **static**: they *read* the artifact. One —
**Pressure test** — is **behavioral**: it *runs* the agent through the skill's real scenario under
pressure and reports where compliance broke. Six **core** static checks — **Anti-patterns**,
**Verbosity**, **Confusing logic**, **Discoverability**, **Progressive disclosure**, and **Force
calibration** — are pre-checked on every run: every skill can carry any of these. The other four
static checks are pre-checked only when the target's **scope or character** matches, per the
**Pre-check when…** column below.

The **Pressure test** seam is the deliberate exception to all of that. Because it executes live trials
(spawning fresh subagents), it is the audit's one **expensive** seam, so it inverts the usual "err
toward pre-checking": it is **never pre-checked** and **always dispatched, never inlined**. The human
checks it by hand for a pre-ship or full review — that opt-in is the audit's expensive *track*.

Which static checks arrive **pre-checked** is decided by the **Pre-check when…** column, which the
orchestrator reads at menu-fill time to pre-fill the menu from the target itself — **without opening
any check's file**. A check's own doc is read only once it is dispatched, never merely to guess
whether to run it. Err toward pre-checking the static lenses: a false skip (a lens left off) is the
harmful direction, while a false-positive self-skips cheaply at dispatch — each check's own relevance
gate stays authoritative there — or the human unchecks it. (The expensive Pressure-test seam is the
one place that reasoning flips, above.)

| Check (file) | Lens | Pre-check when… |
|---|---|---|
| [`auditing-anti-patterns`](references/checks/auditing-anti-patterns/check.md) | Named writing-skills anti-patterns + structural ones (menu-of-options, harness-specific tool naming, caller back-reference, phantom gate, unresolvable reference) | **Always** (core) |
| [`auditing-verbosity`](references/checks/auditing-verbosity/check.md) | Prose that tells a capable agent what it already knows | **Always** (core) |
| [`auditing-confusing-logic`](references/checks/auditing-confusing-logic/check.md) | Control flow an agent can misread under load | **Always** (core) |
| [`auditing-discoverability`](references/checks/auditing-discoverability/check.md) | The always-loaded surface: description carries what+when+triggers in third person; gerund name matches the activity | **Always** (core) |
| [`auditing-progressive-disclosure`](references/checks/auditing-progressive-disclosure/check.md) | Content altitude: reference-depth detail in SKILL.md, monolithic bodies, references deeper than one level, eager content that should be lazy | **Always** (core) |
| [`auditing-force-calibration`](references/checks/auditing-force-calibration/check.md) | Imperative force matched to the task's degrees of freedom — over- and under-constraint both | **Always** (core) |
| [`auditing-cross-skill-duplication`](references/checks/auditing-cross-skill-duplication/check.md) | The same content across skills; overlapping descriptions that collide on discovery | scope is **plugin** (2+ skills to compare) |
| [`auditing-dead-skills`](references/checks/auditing-dead-skills/check.md) | A whole skill no task ever reaches; the fix is a fate, not a reword | scope is **plugin** (a sibling can subsume, a caller can orphan) |
| [`auditing-subagent-economics`](references/checks/auditing-subagent-economics/check.md) | A dispatch whose fixed cost exceeds the payload it moves out of context | the target **dispatches subagents** |
| [`auditing-runtime-integrity`](references/checks/auditing-runtime-integrity/check.md) | Ships-executable defects: script correctness/portability, frontmatter validity, name/dir match, execute-vs-read intent, declared deps, fully-qualified MCP names | the target **ships scripts or runtime-affecting frontmatter** |
| [`auditing-pressure-test`](references/checks/auditing-pressure-test/check.md) | **Behavioral** — does the agent discover, read, and follow the skill under time/authority/sunk-cost/familiarity pressure, or rationalize past it? | **Opt-in, never pre-checked** — the one expensive seam (runs live trials on fresh subagents); the human checks it for a pre-ship/full review |

## The workflow

1. **Fix the scope and pre-fill the menu.** Decide once whether the target is a single skill or a
   whole plugin (`scope`), preferring plugin. Then **pre-fill** the menu instead of asking the human
   to pick from scratch: read the **Pre-check when…** column above and reason over the target's scope
   and character to decide which checks arrive pre-checked:
   - the **six core** checks are pre-checked on every run;
   - **cross-skill-duplication** and **dead-skills** pre-check when `scope` is `plugin`;
   - **subagent-economics** pre-checks when any skill in the target dispatches subagents (a quick grep
     for a dispatch/Task/subagent idiom answers this without opening a check doc);
   - **runtime-integrity** pre-checks when any skill ships a script or declares frontmatter beyond
     `name`/`description`.
   - **pressure-test** is **never pre-checked** — it appears on the menu unchecked, and the human opts
     into it for a pre-ship or full review, because it is the one seam that spends real trial tokens.

   Err toward inclusion for the static lenses; when the character can't be read, fall back to the six
   core checks plus the scope-gated pair (pressure-test stays off unless asked). Present the pre-filled
   set as a structured **multi-select choice**, using a tool
   to ask it where one is available; where none exists, fall back to the same set as a plain-text
   menu (still a list to check off, not open prose) and say the run is degraded. The human unchecks or
   adds; each check's own relevance gate stays authoritative at dispatch, so a pre-checked check the
   target doesn't warrant self-skips there rather than producing a hollow finding.

2. **Decide fan-out vs. inline.** On a small target — a single skill, its references included, small
   enough to hold in one context — running every selected check inline costs less than spinning up
   auditors; do it inline. Above that floor, **fan out** the selected checks in parallel, following
   `dispatching-parallel-agents` (checks share only a *read* of the target, so the independence gate
   holds — no check reads what another writes). Before dispatching, apply this skill's own break-even
   test ([references/subagent-economics.md](references/subagent-economics.md)) — do not spawn an
   auditor whose payload is smaller than the auditor's fixed cost; batch such checks inline instead.
   **The pressure-test seam is exempt from this floor:** it runs live trials on its own fresh
   subagents, so it is always dispatched as its own auditor, never inlined — even on a one-file target.

3. **Hand each check the contract.** Each selected check is defined by its file
   `references/checks/<check>/check.md`; dispatch an auditor by handing it the **absolute path** to
   that file to read and apply — not a pasted copy, so its `references/<checklist>.md` and `../../`
   citations resolve from the check's own directory. Pass every check the same request and expect the
   same result shape — see [references/check-contract.md](references/check-contract.md). Each check
   enforces the hard stops itself, at the source — see [references/hard-stops.md](references/hard-stops.md);
   the orchestrator does not trim findings afterward.

4. **Reconcile and rank.** Gather all results — nothing dropped because it returned last, nothing
   picked because it returned first. Deduplicate where two checks flag the same location (keep the
   sharper claim). Then **rank by estimated token saving weighted by how often the skill pays it**: a
   cut in a `description` beats a cut in `SKILL.md` beats a cut in a reference, because the
   description is in context on every turn, the body loads whenever the skill is used, and a reference
   loads only when reached. Cheap, high-frequency wins go first. Carry each check's `dropped` count
   into the summary: where any check hit its cap, say how many genuine findings wait behind it (e.g.
   "Verbosity: 3 more above the floor — re-run after these").

5. **Propose — one finding, one question.** Put each fixable finding to the user as a structured
   choice, using a tool to ask it where one is available:
   - The options are the finding's 2–3 concrete fix variants (reword / cut / extract-to-reference /
     merge-and-link), your recommendation first and marked `(Recommended)`, with the estimated token
     saving alongside each. Include **Skip** as the free-form escape so declining is always available.
   - Where the fix is a concrete before/after, use a `preview` so the user compares the actual diff,
     not a paraphrase.
   - **One finding per question.** A blanket "yes" over a batch waves through a change the user would
     have rejected on its own. The exception is several instances of the *same* mechanical fix (five
     Windows-path corrections) — those may share one question.

   **A dead skill is a question of fate, not a fix variant.** When the finding is a whole dead skill,
   the options are the three outcomes — **wire it in** (keep the skill, repair its discovery), **fold
   into a sibling** (merge its content, then delete it), **remove** (delete it) — recommendation first
   and marked `(Recommended)`, each option's description naming what it keeps and what it deletes.
   This is genuinely the user's call: folding and removal delete a skill and rewrite its inbound
   references, so the question is also the gate — never fold or remove a skill the user did not
   approve for it. One dead skill, one question.

6. **Apply — following writing-skills.** On approval, edit the skill directly, following the
   writing-skills rule for whatever you touched: a reworded description still carries its triggers; an
   extracted reference stays one level deep. Change only what the finding named. A skipped finding is
   reported with its rationale; it is not applied.

## Track each check as a todo

The fan-out is legible to the human only if they can see what was dispatched and what has come back.
The moment the check set is fixed (after step 1), seed a todo list from it — **one todo per selected
check** — in whatever todo list your harness provides. A check the menu reported as unavailable never
ran and never becomes a todo; a check that will self-skip on its own relevance gate still gets one,
and closes when it returns "nothing to audit."

- **`in_progress` as the check is dispatched** — in fan-out that is several at once; inline it is one
  at a time as you work down the set.
- **`completed` the instant its result is in hand** (step 4), a self-skip included — so a check that
  finished with nothing reads as done, never as still running.

Reconciliation, proposing, and applying are the orchestrator's own work, not checks, and take no
todos of their own; they consume every completed result at once.

## Applying — the rules that hold across every fix

**Folding or removing a dead skill touches more than one file** — deleting the skill directory alone
leaves dangling references. On a **fold**, first merge the kept content into the sibling and confirm
its `description` now carries the folded triggers, *then* delete the dead skill and scrub its name
from `plugin.json`, `README.md`, and any caller or command that routed to it. On a **remove**, delete
the directory and scrub the same references. On **wire it in**, keep the skill and edit only its
discovery surface (its `description`, name, or the forward reference that should reach it). Removal is
hard to reverse, and the user's explicit approval is its only gate.

One rule holds without exception: **a fix preserves what the skill does.** If a proposed cut would
drop a real instruction, it was never verbosity — keep it. Verify the executable parts (any scripts,
frontmatter keys, `name`) are byte-for-byte untouched; the audit moves prose and structure, not
behavior.

## Governing principle

Keep the self-enforcement shape (workflow step 3) when changing a check boundary or adding a check: a
cap the orchestrator applies after a check has already done unbounded work saves output, not the
work. Each check runs its relevance gate, floor, and cap at the source.

## How this fits authoring

`writing-skills` sets the rules; each check holds an existing skill to them and buys back the tokens.
After a structural fix — an extraction, a merge, a reworded description — check the **pressure-test
seam** to confirm the skill is still discovered, read, and followed; that behavioral pass is the
evidence a clean static read can't give. The pressure-test seam owns its close-and-re-run loop through
this orchestrator: apply an approved wording fix, then re-dispatch the seam until no new rationalization
survives.
