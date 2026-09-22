
# Reviewing — Readability facet

Say this first, plainly: `Using the code-review readability facet to review this change.`

## What this guarantees

One thing: given the change under review, this facet looks for the readability defects a diff can
actually show — unearned abstraction that costs more to follow than it returns, and defensive code
guarding conditions that cannot or realistically will not happen — and returns a short, ordered,
self-contained list of findings, capped and floored, with a durable record written to its artifact.
It is **report-only**: it never edits code.

This facet self-limits at the source (see `../../hard-stops.md`), under the shared `../../facet-contract.md`.

Its analysis stays inside a fixed boundary: the logic the diff adds or reshapes, read against the
invariants visible in the change and the modules it already touches — **no proactive repo-wide scan**.
Complexity the change neither introduces nor worsens is an explicit non-goal, not a defect this facet
chases.

## The workflow

1. **Relevance gate — first, before any lens work.** This facet fires when the change **adds or
   substantively reshapes executable logic** — a new function, class, branch, guard, wrapper, or
   abstraction. A change that ships no such logic — a pure config/data/doc/formatting edit, a
   dependency bump, a rename, a test-fixture-only change — has no readability surface to weigh:
   short-circuit and return `relevance: { skipped: <reason> }`, having spent almost nothing, and
   write an artifact recording the skip.

2. **Apply the lenses.** Work
   [references/readability-checklist.md](references/readability-checklist.md), across the two classes:
   - **Unearned abstraction** — indirection or generalization whose cognitive cost outweighs its
     value *even after counting tests and reuse*: single-use indirection that only forwards, a
     premature interface/generic with one implementation, parameterization for a value that never
     varies, speculative flexibility nothing uses.
   - **Over-defensive programming** — a guard, validation, `try`/`catch`, or fallback for a condition
     the code's own invariants make impossible or vanishingly unlikely, or that buries the happy path
     under defense the problem does not warrant.

3. **Floor, then cap, then tally the cap's drops** per hard-stops.md §2–3 — drop below `caps.floor`,
   keep at most `caps.top_n`, and report `dropped` (how many genuine above-floor findings the cap held
   back) so nothing real vanishes unseen. Readability is more subjective than a correctness lens, so
   hold the floor hard: a finding must name the specific cost and the simpler shape it points to, not
   merely a stylistic preference.

4. **Write the artifact and return** per facet-contract.md's Finding schema, to `findings.md`.

## What this does not do

- It does not **flag earned complexity** — an abstraction with real reuse or that genuinely simplifies
  the change's tests, and defense at a real trust boundary (external, untrusted, or network input),
  are not findings. The cost must exceed the value the diff itself shows.
- It does not own **silent or wrong error handling** — a swallowed exception or a bad fallback is the
  Error Handling facet's; this facet owns defense that is *unnecessary*, not defense done badly.
- It does not own **boundary-level abstraction** — needless indirection that creates a new seam the
  architecture must hold is the Architectural facet's call; this facet owns unearned complexity
  *inside* the logic the diff adds or edits, boundary or not.
- It does not **audit pre-existing code** — complexity the change neither introduces nor worsens is
  not a finding; the cap and floor keep this facet to what the diff actually creates.
