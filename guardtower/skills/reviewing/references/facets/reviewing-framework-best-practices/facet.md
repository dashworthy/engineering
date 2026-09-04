
# Reviewing — Framework Best Practices facet

Say this first, plainly: `Using the guardtower framework best-practices facet to review this
change.`

## What this guarantees

One thing: given the change under review, this facet looks for stack-specific idiom
violations — conventions particular to a detected framework, not the general principles every
other facet already reasons about — and returns a short, ordered, self-contained list of
findings, capped and floored, with a durable record written to its artifact. It is
**report-only**: it never edits code.

This facet self-limits at the source (see `../../hard-stops.md`), under the
shared `../../facet-contract.md`.

This is a deliberate exception: unlike every other facet, this one's lens is split across
[references/framework-best-practices-index.md](references/framework-best-practices-index.md)
plus one file per stack, not a single checklist — read only the file(s) the matched stack(s) in
the index name. Nine stacks are covered: Laravel, Tailwind, Symfony, OroCommerce, React, Vue,
TypeScript, JavaScript, and Backbone. A stack with no matching row in the index is out of scope
for this facet, not silently approximated by whichever file happens to be closest.

## The workflow

1. **Relevance gate — first, before any lens work.** Run the relevance gate before touching a
   single lens: read the index. Does the diff touch a file matching a listed stack's detection
   signal? No match on any row: short-circuit and return
   `relevance: { skipped: <reason> }`, having spent almost nothing (only the index was read), and
   write an artifact recording the skip.
2. **Apply the lens(es).** For each matched stack, read its reference file and work its classes of
   defect against the diff. A change matching more than one stack (e.g. a Blade template touching
   both Laravel and Tailwind conventions) applies every matched file's lens, not just the first.
3. **Floor, then cap** per hard-stops.md §2–3 — drop below `caps.floor`, keep at most
   `caps.top_n`.
4. **Write the artifact and return** per facet-contract.md's Finding schema, to `findings.md`.

Idiom-specific findings — a convention particular to the detected stack — are this facet's job.
A reinvention of an existing framework capability with no stack-specific placement/shape angle is
the **Novelty** facet's job; a generic inefficiency with nothing stack-specific about it is the
**Technical** facet's job — this facet does not duplicate either. Where a stack's own reference
file draws a further boundary against a sibling facet (Laravel's against Security, for instance),
that boundary is stated there, not repeated here.

## What this does not do

- It does not **cover a stack with no reference file** — a stack outside the index's nine rows is
  out of scope, not silently approximated by whichever file happens to be closest.
- It does not **scan the repository** beyond the diff and the index/stack files it reads — no
  proactive repo-wide audit of every file in a detected stack.
- It does not **enumerate style nits** with no idiom-shape consequence — the cap and floor are
  deliberate, same as every other facet.
