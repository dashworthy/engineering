# The Approval Gate

The single rule the whole convention system is built on: **nothing is written to the
standards tree without the approver saying yes to that exact convention, one at a time.**
Every path that would create, amend, or retire a convention passes through this gate before
any file changes, so every caller means the same thing by "approved."

The approver is a single human — the developer running the pipeline. There is no committee
and no delegated reviewer role. "The tests pass" is not approval; "it looks like a
convention" is not approval; only the approver's explicit yes on the specific rule is.

## Individual approval — one candidate at a time

Candidates are never approved in a batch. Present exactly one candidate, wait for a verdict,
then move to the next. Batching invites a blanket "yes" that waves through a rule the
approver would have rejected on its own, which is the precise failure this gate exists to
prevent.

Each candidate is presented with its **Rule**, its **What it is** and **What it is not**
boundaries (already pinned by the hardening interrogation), and its provenance, and the
approver answers with one of three verdicts:

- **Approve** — write it as presented.
- **Edit** — the rule is right but the wording or a boundary is off; the approver states the
  correction and the corrected version is what gets written (and re-shown if the change is
  large enough to re-approve).
- **Reject** — do not write it. A rejected candidate leaves no file and no index row; if it
  came from inference or a PR harvest, it simply does not become a convention.

Silence is not approval. An unanswered candidate is not written.

## Conflict detection — the criterion

Before a candidate is presented for approval, check it against every **active** convention
already in the index. The gate must **flag a contradiction rather than write the new
convention silently.**

The concrete criterion for a contradiction is: **two conventions conflict when a single
piece of code cannot satisfy both at once** — one requires what the other forbids, or the
two prescribe different mandatory forms for the *same* situation (overlapping **When
relevant** triggers with incompatible **Rule** statements).

Two rules that apply to different situations, or that stack without contradicting (one
narrows a case the other leaves open), are **not** a conflict; do not flag those.

## When a conflict is found

Do not write, and do not silently pick a winner. Surface the specific existing convention —
by name and index link — alongside the new candidate and the exact contradiction between
them, and put the resolution to the approver:

- **Supersede** — the new rule replaces the old: approve the new convention and retire the
  old one (its row stays, marked `retired`, per `STANDARDS-FORMAT.md`), with the new
  convention naming the retired one in its `Source`.
- **Amend** — the old rule was nearly right: amend the existing convention in place instead
  of adding a new one.
- **Reject** — the existing convention stands; the candidate is dropped.

Every one of these is itself a gated write: the resolution the approver picks is only
carried out after they approve it, on the same one-at-a-time terms as any other convention.
