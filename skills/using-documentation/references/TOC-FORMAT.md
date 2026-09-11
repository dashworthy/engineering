# Table-of-contents format

`docs/toc.md` is the one central index of every documented feature. It renders to this shape:

    # Documentation — table of contents

    <One line: what this index is and how to use it.>

    | Feature | Description | Domain |
    |---|---|---|
    | [<Feature name>](<domain>/<feature>/README.md) | <one-line what-it-is> | <domain> |

- **Feature** links to the feature's `README.md` — the name is the link text, so the table reads
  as a directory a reader clicks through.
- **Description** is one line: what the feature is, not how it works. Enough to decide whether to
  open it.
- **Domain** is the coarse, stable grouping bucket (the top path segment). It is the one grouping
  axis in the path; finer tags, if any, belong in this column too, comma-separated — grouping is a
  view here, cheap to change, not a filesystem move.

## Upsert, never duplicate

A row is keyed by its feature. Adding a feature inserts one row; changing a feature updates its
row in place. Running the producer twice on the same feature must never leave two rows. Keep the
table sorted by Domain then Feature, so it reads in a stable order rather than in the order rows
were written.

## Minting a new domain

A domain new to `toc.md` is minted by the human, not invented by the agent — the producer proposes
one and the human confirms (see the `using-documentation` skill). The set of domains this file
carries is the canonical list; a new one is a visible addition, not a silent one.
