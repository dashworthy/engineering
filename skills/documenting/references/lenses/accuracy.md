# Accuracy lens

Review the feature doc for one thing: does every claim it makes hold against the code that
**actually shipped**? Your ground truth is the shipped whole-branch **diff** (plus the current
tree it lands on), not the spec or plan — those said what was intended; the diff says what
happened.

Look for:

- **Contradicted claims.** A sentence describing behavior the diff shows works differently — a
  renamed field, a changed default, a removed path. The doc says one thing, the code another.
- **Drift on an updated doc.** When this run surgically patched an existing doc, the untouched
  sections are where drift hides: a section describing behavior an earlier change altered and this
  doc never caught up. Flag it; do not rewrite it silently.
- **Invented detail.** A claim with no support in the diff or the tree — a capability the doc
  describes that the code does not have.

Do **not** flag prose style, missing sections, dead links, or scope — those are other lenses. Stay
on: is what the doc says true of the code that shipped?

Return each finding in the shared grammar: the file and location in the doc, what's wrong, and why
it bites (what a reader would wrongly believe). An empty return means the doc is accurate against
the diff — say so plainly.
