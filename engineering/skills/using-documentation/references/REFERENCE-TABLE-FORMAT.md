# Reference-table format

The reference table lives inside a feature doc's `## References` section and lists the feature's
sub-documents — the `docs/{domain}/{feature}/<aspect>.md` files that go deeper on one aspect. It is
the same idea as `docs/toc.md` scoped to one feature, and without the Domain column (everything
here already belongs to the one feature):

    | Reference | Description |
    |---|---|
    | [<Aspect name>](<aspect>.md) | <one line: what this sub-doc covers> |

- **Reference** links to the sub-doc by its relative filename, so the link resolves from the
  feature folder.
- **Description** is one line: what the sub-doc covers, enough that a reader — or an agent — knows
  whether it answers their question before opening it.

## When a sub-doc earns its place

Split an aspect into its own sub-doc when it is deep enough that keeping it inline would bury the
feature doc's overview, and self-contained enough to read on its own. Below that bar it stays a
section in the feature `README.md`. The table exists to save a reader a grep: every row is a
promise that the linked file answers the described question, so keep the descriptions honest and
the links live.
