---
name: recording-code-conventions
description: "The single writer for a project's code conventions: interrogate a candidate into a sharp rule, gate it on the approver's yes, write it to docs/standards/, and keep the index in sync. Use when a convention is created, amended, or retired. Does not discover candidates (identifying-code-conventions) or consume them (using-code-conventions)."
---

# Recording Code Conventions

Say this first, plainly: `Using the recording-code-conventions skill to record this convention.`

## What this guarantees

One thing: **every convention written to the standards tree goes through here, and none of it
happens without two gates first.** A convention reaches disk only after (1) the hardening
interrogation has pinned what it is, what it is not, and how it behaves at the edges, and
(2) the approver has individually said yes to that exact rule and any conflict with an
existing convention has been resolved. Then, and only then, this skill writes the convention
document per `STANDARDS-FORMAT.md` and updates the index row in the same change. Creating,
amending, and retiring a convention are all this same writer under this same pair of gates.

Every other path that surfaces a candidate — convention discovery, the onboarding and
single-convention commands, and the PR-time harvest at review — funnels it here rather than
writing anything itself.

## Step 1 — Harden the candidate

Whatever surfaced the candidate, it arrives rough. Before anything else, run the interrogation
defined in `references/hardening-interrogation.md`, in this directory: the choice-menu,
one-question-per-turn process that pins **what it is**, **what it is not**, and **robustness**
at the edges. This runs on **every** path, because recording is the only writer and this is
where a sentence becomes a rule sharp enough to obey. Its output is the candidate's Rule /
What it is / What it is not, ready for the gate.

## Step 2 — Pass the approval gate

Take the hardened candidate through the gate defined in `references/approval-gate.md`, in this
directory. The gate is the same for every path: the candidate is presented **individually** —
through `AskUserQuestion`, one candidate per question — for the approver's explicit approve /
edit / reject, and before it is presented it is checked
for **conflict** against the active conventions already in the index — a contradiction is
surfaced and resolved (supersede / amend / reject), never written over silently. Nothing
reaches disk on silence or on a batch yes.

## Step 3 — Write the document and the index row together

Once approved, write the convention document under `docs/standards/<topic>/` following
`STANDARDS-FORMAT.md`, in this directory — the Rule, the mandatory What-it-is / What-it-is-not
boundaries, and the who / when / source / lifecycle provenance block. In the **same change**,
add or update the convention's row in `docs/standards/index.md` — the eight columns of
`STANDARDS-FORMAT.md`.

## Amend and retire

Both go through Steps 1–2 exactly as a new convention does — the same interrogation where it
applies, the same individual approval.

- **Amend** — the rule still holds but its wording or boundary changed. Edit the document in
  place and bump the index row's **Last amended** date. Per `STANDARDS-FORMAT.md`, an
  amendment leaves **Status `active`** — an amended rule is still in force — and is recorded by
  the date, not by a status change.
- **Retire** — the rule no longer applies. Set the document's lifecycle to `retired <date>`
  and the index row's **Status** to `retired`. **The row stays** — a retired convention keeps its row marked
  `retired`, never deleted, so a later reader sees the rule once bound and no longer does.

## What this does not do

- It does not **discover candidates.** Finding conventions — inferring them from repeated code
  or capturing ones the developer already holds — is `identifying-code-conventions`. This skill
  starts from a candidate it was handed; it does not go looking.
- It does not **apply conventions.** Citing a convention at a work item during design or build
  so a subagent reads it is `using-code-conventions`. This skill writes rules; it does not
  consume them.
- It does not **write specs or ADRs.** A convention is a repeatable standing rule; a spec
  (`to-spec`) and an ADR (`recording-adrs`) are different durable-knowledge kinds. This skill
  writes neither.
