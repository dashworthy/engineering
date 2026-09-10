
# Reviewing — Technical facet

Say this first, plainly: `Using the code-review technical facet to review this change.`

## What this guarantees

One thing: given the change under review, this facet looks for technical defects across two
lenses — **Efficiency & correctness** (inefficient data access and correctness-scoped
best-practice lapses) and **Reuse over reinvention** (new code that rebuilds a capability the
stack already provides) — and returns a short, ordered, self-contained list of findings, capped
and floored, with a durable record written to its artifact. It is **report-only**: it never edits
code.

The two lenses share the same reach — the diff plus the modules the change already imports — and
run under one relevance gate as a single dispatched reviewer.

This facet self-limits at the source (see `../../hard-stops.md`), under the shared
`../../facet-contract.md`.

Its analysis stays inside a fixed boundary: the diff, the reviewer's knowledge of the framework in
use / the standard library / well-known depended-on libraries, and a glance at the public surface
of the modules the change already imports — **no proactive repo-wide scan or function index**. An
N+1 or unbounded load visible in the changed code, or a hand-rolled duplicate of something an
already-imported module provides, is in reach; a pre-existing inefficiency or a bespoke helper
elsewhere in the repository that the change never touches is an accepted blind spot, not a defect
this facet chases.

## The workflow

1. **Relevance gate — first, before any lens work.** Run the relevance gate before touching a
   single lens. Does this change contain logic worth a technical review — new or changed functions,
   data-access code, loops over collections, comparison/date/string handling, non-trivial
   computation, hand-rolled utilities, or framework wiring that could duplicate an existing
   capability? A pure config, docs, or formatting change, or a trivial constant edit, is **not**:
   short-circuit and return `relevance: { skipped: <reason> }`, having spent almost nothing, and
   write an artifact recording the skip.

2. **Apply the lenses.** For a change that passed the gate, work
   [references/technical-checklist.md](references/technical-checklist.md) and
   [references/novelty-checklist.md](references/novelty-checklist.md):

   - **Efficiency & correctness lens.** Inefficient data access — N+1 patterns, queries inside
     loops, unbounded or unpaginated loads, repeated identical queries. Correctness-scoped best
     practices — only defects with a correctness or maintainability consequence; never style.

   - **Reuse over reinvention lens.** New code that rebuilds a capability the stack already
     provides — a maintenance surface for a problem already solved. For each capability the change
     *newly introduces*, ask whether something already provides it: a **framework idiom** exposed
     as a first-class feature; a **standard-library** built-in (dates, collections, strings, math,
     I/O); a documented API of a **well-known/depended-on library**; or the public surface of an
     **already-imported module** the change duplicates with a private helper. Name what was
     reinvented and what already provides it. The finding is *duplication of an existing
     capability*, never newness for its own sake — new code for a problem the stack does not solve
     is the job, not a finding.

3. **Floor, then cap, then tally the cap's drops** per hard-stops.md §2–3 — drop below
   `caps.floor`, keep at most `caps.top_n`, and report `dropped` (how many genuine above-floor
   findings the cap held back) so nothing real vanishes unseen. The cap spans both lenses.
4. **Write the artifact and return** per facet-contract.md's Finding schema, to `findings.md`.

## What this does not do

- It does not **scan the repository** — its reach is the diff plus already-imported modules and the
  reviewer's knowledge of the framework and well-known libraries; it does not build a function
  index to find every possible reuse or every bespoke helper elsewhere.
- It does not **own stack-specific idiom placement/shape** — a reinvention whose real angle is
  where or how it sits within a detected framework's conventions is the **Framework Best
  Practices** facet's; this facet owns generic reuse and generic efficiency/correctness, not
  stack-specific idiom.
- It does not **review beyond the technical and reuse lenses** — a security or architectural smell
  it happens to notice is out of scope; another facet owns it.
- It does not **enumerate style nits** — the cap and floor are deliberate; a long low-signal list
  of formatting and naming preferences is a failure of this facet, not thoroughness.
