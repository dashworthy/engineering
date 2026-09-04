
# Reviewing — Data Presentation facet

Say this first, plainly: `Using the guardtower data-presentation facet to review this change.`

## What this guarantees

One thing: given the change under review, this facet looks for presentation that makes distinct
records impossible to tell apart — a nested record shown by a name several siblings share with no
path, an identifier that collides shown with no distinguishing key, a list whose options render
identically — and returns a short, ordered, self-contained list of findings, capped and floored, with
a durable record written to its artifact. It is **report-only**: it never edits code. Its concern is
*identity ambiguity* alone, not general UX or accessibility.

This facet self-limits at the source (see `../../hard-stops.md`), under the shared `../../facet-contract.md`.

Its analysis stays inside a fixed boundary:
it reasons about the presentation **visible in the diff** — the template, field list, component, or
control the change actually renders — read against the reviewer's knowledge of when a label fails to
identify its record. It does **no proactive** crawl of the whole UI or the data model to prove that
two records can collide; an ambiguous rendering the diff shows is in reach, and what the diff does not
show is an accepted blind spot, not a defect this facet chases.

## The workflow

1. **Relevance gate — first, before any lens work, and sharp.** Run the relevance gate before
   touching a single lens. This facet fires **only when the change renders records to a person** —
   a view, template, component, API field list, CLI table, or selection control that presents
   hierarchical or collision-prone data. A change with no such presentation surface — pure business
   logic, config, a migration, docs, or a rendering of data that carries no identity-collision risk —
   is **not** in scope: short-circuit and return `relevance: { skipped: <reason> }`, having spent
   almost nothing, and write an artifact recording the skip. This gate is deliberately narrow; it is
   what keeps most diffs from triggering any data-presentation work at all.

2. **Apply the lenses.** For a change that passed the gate, work
   [references/data-presentation-checklist.md](references/data-presentation-checklist.md),
   across the diff-visible classes:
   - **Non-unique label without its disambiguating path** — a nested / hierarchical record shown by a
     name its siblings share, with no breadcrumb or ancestor path (the categories-named-alike case).
   - **Collision-prone identifier without a distinguishing key** — a record labelled by a non-unique
     value (a person's name, a file's base name) with no id, email, timestamp, or other key.
   - **Indistinguishable records in a list or selection** — a list, table, dropdown, or autocomplete
     where two distinct options render identically, so the user picks or acts on the wrong one.
   - **Disambiguator removed by rendering** — a truncation, ellipsis, or responsive layout that cuts
     off or hides distinguishing information the data actually carries, collapsing distinct records
     into one appearance.

3. **Floor, then cap** per hard-stops.md §2–3 — drop below `caps.floor`, keep at most
   `caps.top_n`.
4. **Write the artifact and return** per facet-contract.md's Finding schema, to
   `findings.md`.

## What this does not do

- It does not **review general UX or accessibility** — contrast, spacing, keyboard order, wording,
  responsiveness, and visual design are a different review's job; this facet is identity ambiguity
  only.
- It does not **crawl the UI or the data model** — its reach is the presentation the diff shows; it
  does not enumerate every view of a record or prove from the schema that a collision is possible.
- It does not **review beyond presentation identity** — a security, correctness, or tenant-isolation
  smell it happens to notice is out of scope; another facet owns it.
- It does not **flag an already-unambiguous rendering** — a label unique in its context, or a record
  whose path or key is already shown, is not a finding; the cap and floor keep this facet to a real
  identity ambiguity.
