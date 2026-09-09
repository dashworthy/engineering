# Structure lens

Review the feature doc against the template and for how it reads. Two things, both about form, not
truth (accuracy is another lens):

**Conformance.** Check it against `FEATURE-DOC-TEMPLATE.md`:
- The emoji tiers are present and in order (overview → technical reference → dev/testing), so a
  reader gets progressive disclosure.
- A top-line hook opens the doc; key terms are bolded on first use; enumerable content is a table,
  not a wall of prose.
- Where the feature has sub-docs, a reference table lists them; a corresponding `docs/toc.md` row
  exists.

**Plain language — the anti-"claudish" check.** The prose must read like a person wrote it, not an
LLM. Flag the tells: hollow throat-clearing ("It's worth noting that…", "In today's fast-paced…"),
reflexive hedging, sycophantic filler, list-of-three padding, and restating the heading as the
first sentence. A "claudish" doc is a finding — plain, direct prose is the bar, and it is not
optional.

Do **not** verify claims against the code (accuracy lens), check whether links resolve (links
lens), or judge whether the doc covers the right ground (scope lens).

Return each finding in the shared grammar: file and location, what's wrong, why it bites. An empty
return means the doc conforms and reads cleanly.
