# ADR Index

The map of this project's architecture decision records. Scan the **When relevant** column to
find the decision governing a piece of work; skip rows whose **Status** is `Superseded`. Shape
is fixed by `ADR-INDEX-FORMAT.md` in the `recording-adrs` skill. `recording-adrs` is the single
writer of this file and the records it links.

| Number | Title | When relevant | Status | Link |
|--------|-------|---------------|--------|------|
| 0001 | Derive or ask verity's configuration fresh each run; persist none of it | Configuring test-hardening / verity behavior — suites, thresholds, iteration caps | Accepted | [0001](0001-derive-verity-configuration-fresh-each-run.md) |
| 0002 | Represent the ADR tracking view as a derived view over the index, not a persisted ledger | Building or changing the ADR tracking view / decision ledger | Accepted | [0002](0002-adr-tracking-view-is-derived-not-persisted.md) |
