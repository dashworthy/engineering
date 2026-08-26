# ADR Index Format

One index for the whole ADR trail, at `docs/adr/index.md`, in table form. It is the map a
reader (or `using-adrs`) scans to find the decision governing a piece of work without opening
every record. Every ADR under `docs/adr/` has exactly one row; a superseded ADR keeps its row
with its **Status** updated, never deleted — the trail is append-only.

This is the ADR analogue of the standards index in `STANDARDS-FORMAT.md`: same idea, adapted
for a point-in-time trail rather than a set of standing rules. The load-bearing columns are the
same two a consumer matches and filters on — a **When relevant** trigger and a **Status**.

## Shape

```markdown
# ADR Index

| Number | Title | When relevant | Status | Link |
|--------|-------|---------------|--------|------|
| 0001 | Derive verity configuration fresh each run | Configuring test-hardening / verity behavior | Accepted | [0001](0001-derive-verity-configuration-fresh-each-run.md) |
```

The five columns are fixed:

| Column | Holds |
|--------|-------|
| **Number** | The ADR's four-digit number, matching its filename and its `# NNNN.` title. |
| **Title** | The decision's title — matches the ADR's `# NNNN. <Title>` heading. |
| **When relevant** | The work situation that makes this decision bear on the task at hand — the trigger a reader matches their work against. This is the column `using-adrs` reads to decide what to cite. |
| **Status** | `Proposed`, `Accepted`, or `Superseded by NNNN`, mirroring the record's own Status. A consumer skips `Superseded` rows. |
| **Link** | Relative path from the index to the ADR file. |

## How to keep it current

The index and the records move together. An ADR written, accepted, or superseded is not
finished until its index row reflects the same Status on the same edit — an index that says
`Accepted` for a decision the record marks `Superseded by 0007` is worse than no index, because
a reader trusts it. Update the row in the same change that writes or changes the record, never
on a later pass. Because the trail is append-only, a new ADR **adds** a row and a supersede
**edits the Status** of the old row and adds the new one; a row is never removed.
