# Committed-spec ledger index format

**`docs/specs/toc.md` is the index of the committed-spec ledger — one row per run whose spec was
approved, pointing at that run's frozen `spec.md` and its companion `retro.md`.** The `spec` skill
upserts a row here the moment it stamps a spec `Approved`; the row makes the ledger discoverable
without walking the directory tree.

This is a **separate genre** from the feature-doc index `docs/toc.md` (whose format is
`skills/using-documentation/references/TOC-FORMAT.md`, keyed `Feature | Description | Domain`). A
committed spec is a dated, per-run record, so its index carries different columns; the two indexes
are deliberately kept apart rather than sharing one row shape.

## The row

    # Committed specs — ledger index
    | Date | Spec | Shipped | Links |
    |------|------|---------|-------|
    | <YYYY-MM-DD> | <run-id> | <yes / no / —> | [spec](<run-id>/spec.md) · [retro](<run-id>/retro.md) |

| Column | Meaning |
|---|---|
| `Date` | The date the spec was approved (`YYYY-MM-DD`). It repeats the date embedded in the run id on purpose — a plain, uniform sort/scan key so a reader (or a tool) orders the ledger by one column without parsing the id. |
| `Spec` | The **full run id** — `<YYYY-MM-DD>-<slug>` (the whole `.engineering/.current-run` value, date prefix included). This is the row key **and** the `docs/specs/<run-id>/` directory name. The full dated id is used, not the bare slug, so two runs that happen to share a slug on different days never collide on the same directory. |
| `Shipped` | Whether the run shipped: `—` at approval (unknown yet), flipped to `yes` when the run reaches `documenting` and writes `retro.md` on the green branch. |
| `Links` | Relative links to this run's `spec.md` and its `retro.md`. The `retro.md` link is the **predicted path** — the file appears when `documenting` writes it at ship; the link is valid the moment it does. |

## Upsert rule

Rows are **upserted, keyed by the run id (`<YYYY-MM-DD>-<slug>`)** — never blindly appended.
Writing a spec for a run id that already has a row replaces that row rather than adding a duplicate
(a re-approved or revised spec keeps one row). Order rows by `Date` descending (newest first) so
the most recent runs read at the top, matching how a reader scans a ledger.

## Worked example

    # Committed specs — ledger index
    | Date | Spec | Shipped | Links |
    |------|------|---------|-------|
    | 2026-09-11 | 2026-09-11-commit-specs-retro | — | [spec](2026-09-11-commit-specs-retro/spec.md) · [retro](2026-09-11-commit-specs-retro/retro.md) |
