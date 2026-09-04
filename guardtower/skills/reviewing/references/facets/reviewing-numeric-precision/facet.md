
# Reviewing — Numeric Precision & Units facet

Say this first, plainly: `Using the guardtower numeric-precision facet to review this change.`

## What this guarantees

One thing: given the change under review, this facet looks for arithmetic that quietly produces a wrong
number — binary floating point standing in for money or an exact value, a silent rounding or truncation,
a unit mismatch, an integer overflow, precision lost on a cast, or arithmetic that mixes scales or
currencies without normalizing — and returns a short, ordered, self-contained list of findings, capped
and floored, with a durable record written to its artifact. It is **report-only**: it never edits code.
Its concern is *the numeric value being wrong* — precision and units — not general computational logic.

This facet self-limits at the source (see `../../hard-stops.md`), under the shared `../../facet-contract.md`.

Its analysis stays inside a fixed boundary:
it reasons about the arithmetic the change **visible in the diff** actually introduces or alters — the
expression, the type of the values, the cast, the unit each quantity carries — read against the
reviewer's knowledge of how numbers lose precision and how units must line up. It does **no proactive**
repo-wide hunt for every unsafe numeric expression in the system; a precision or unit defect the change
introduces is in reach, and a pre-existing one elsewhere the diff never touches is an accepted blind
spot, not a defect this facet chases.

## The workflow

1. **Relevance gate — first, before any lens work, and sharp.** Run the relevance gate before touching
   a single lens. This facet fires **only when the change does arithmetic on a meaningful quantity** — a
   monetary amount, a measured value with a unit (time, size, distance, weight, rate), or a value whose
   exactness matters — computing, converting, rounding, casting, or accumulating it. A change with no
   such arithmetic — string handling, control flow, a plain counter or index whose exact magnitude never
   overflows or converts, config, or docs — is **not** in scope: short-circuit and return
   `relevance: { skipped: <reason> }`, having spent almost nothing, and write an artifact recording the
   skip. This gate is deliberately narrow; it is what keeps most diffs from triggering any
   numeric-precision work at all.

2. **Apply the lenses.** For a change that passed the gate, work
   [references/numeric-precision-checklist.md](references/numeric-precision-checklist.md), across the
   diff-visible classes:
   - **Binary float for an exact value** — money or another value requiring exactness held in a binary
     floating-point type, where representation error accumulates.
   - **Silent rounding or truncation** — a conversion, integer division, or cast that drops a fractional
     part or digits with no explicit, intended rounding policy.
   - **Unit mismatch** — two quantities in different units combined without conversion (cents added to
     dollars, milliseconds compared to seconds, bytes to kilobytes).
   - **Integer overflow** — an accumulation, multiplication, or cast whose result can exceed the range
     of its integer type and wrap or saturate.
   - **Precision lost on a cast** — narrowing a wider or higher-precision number into a smaller type (a
     large integer into a float, a decimal into an int) so significant digits are silently discarded.
   - **Mixed scale or currency without normalization** — arithmetic across values at different scales or
     in different currencies with no normalization to a common basis first.

3. **Floor, then cap** per hard-stops.md §2–3 — drop below `caps.floor`, keep at most
   `caps.top_n`.
4. **Write the artifact and return** per facet-contract.md's Finding schema, to `findings.md`.
   Name the quantity, the operation, and the wrong value it can produce, so the finding stands on
   its own.

## What this does not do

- It does not **scan the repository** — its reach is the arithmetic the diff shows; it does not hunt
  every unsafe numeric expression in code the change leaves untouched.
- It does not **review general computational logic** — a wrong formula that is dimensionally sound and
  precise belongs to a correctness/technical review; this facet is precision and units only.
- It does not **flag display-only formatting** — rounding a value purely for how it is shown, when the
  underlying stored or computed value keeps full precision, is not a finding.
- It does not **flag an already-sound value** — an exact type (a decimal or money type) for money,
  matched units, a range that provably cannot overflow, or an explicit intended rounding policy is not a
  finding; the cap and floor keep this facet to a real precision or unit defect.
