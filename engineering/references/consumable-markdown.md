# Consumable markdown (shared conventions)

One reference, cited by everything in this plugin that renders a document a human or an agent
has to *consume* — the Tier-1 spec format and the feature-doc template both point here rather
than each restating a house style that would drift. These are conventions for making a document
scannable and quick to orient in; they are not a document's structure. The structure belongs to
whatever cites this file — its sections, its order, its required fields. This file only says how
to render whatever those sections hold so a reader gets the point fast and finds the detail
without hunting.

The aim is one thing: a reader — person or agent — grasps what a document is about, and reaches
the part they need, in as few seconds as the content allows. Every convention below serves that
and nothing else. Apply the ones a given document earns; a short document earns few.

## The conventions

- **Open with a top-line hook.** Before any section, one sentence — bold — that says what this
  document *is*. Not a table of contents, not a preamble about scope: the single sentence a
  reader could stop after and still know whether to keep going. A document whose first line is a
  heading makes the reader assemble the point from the parts; a hook hands it to them.

- **Order by progressive disclosure.** Lead with the plain-language whole, then the detail, then
  the depths — so a reader descends exactly as far as they need and stops. The layperson summary
  comes first because it is what most readers want; the schema and the edge cases come last
  because the few who need them will read that far. Never make a reader pass the hard material to
  reach the easy overview.

- **Bold key terms on first use.** The first time a domain term that carries weight in this
  document appears, bold it — it doubles as an inline glossary a reader scanning for that concept
  can land on. Bold the term where it is *introduced*, not every time it recurs; a document that
  bolds everything has emphasized nothing.

- **Prefer tables for anything enumerable.** A set of items that share the same fields — success
  criteria and how each is checked, constraints and their limits, options and their trade-offs,
  fields and their types — is a table, not a run of prose or a bullet list a reader has to hold
  in their head to compare across. Give the table a header row that names the columns. Prose is
  for argument and narrative; a table is for anything a reader will want to compare row against
  row.

- **Place diagrams at the point of introduction.** When a data model, a flow, or a state machine
  earns a picture (see `engineering:using-diagrams` for whether it does), put the diagram exactly
  where the concept is introduced — not collected in an appendix a reader has to cross-reference.
  A diagram three sections away from the prose it illustrates is read by no one.

- **Ground every abstraction in a worked example.** A rule stated abstractly is a rule the reader
  has to instantiate themselves; follow it immediately with one concrete case that shows it
  operating. The example is not decoration — it is often the only part a hurried reader trusts,
  because it is the only part that can't hide a vague claim.

## What this is not

- It is not a **structure**. It never says which sections a document has or in what order; that
  is the citing document's own format. This file styles the content those sections hold.
- It is not a **licence to pad**. Every convention here removes reading time; a convention applied
  where it adds none — a table with one row, a hook that restates the title — is noise, and noise
  is the thing these conventions exist to cut.
- It is not **house prose voice**. How formal or plain the language is belongs to the citing
  document (a feature doc opens plain for a layperson; a spec stays precise). This file governs
  layout and orientation, not tone — except the one bar every citing document shares: write like a
  person, not like an LLM.
