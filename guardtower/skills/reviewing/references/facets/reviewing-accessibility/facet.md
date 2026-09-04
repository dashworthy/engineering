
# Reviewing — Accessibility facet

Say this first, plainly: `Using the guardtower accessibility facet to review this change.`

## What this guarantees

One thing: given the change under review, this facet looks for markup a person using assistive
technology cannot perceive or operate — an image with no text alternative, a control with no
name, a keyboard trap, a color that carries meaning nobody colorblind can read, motion that
never yields to a reduced-motion preference, a dynamic update no screen reader announces — and
returns a short, ordered, self-contained list of findings, capped and floored, with a durable
record written to its artifact. It is **report-only**: it never edits code. Its concern is
*perceivability and operability* — whether the rendered surface works for people with diverse
abilities — not identity ambiguity, which is the data-presentation facet's job.

This facet self-limits at the source (see `../../hard-stops.md`), under the shared `../../facet-contract.md`.

Its analysis stays inside a fixed boundary: it reasons about the presentation **visible in the
diff** — the template, component, control, or style the change actually renders — read against
the reviewer's knowledge of what assistive technology needs to convey and operate it. It does
**no proactive** crawl of the whole UI, the component tree, or the design system to prove a
barrier exists; an inaccessible rendering the diff shows is in reach, and what the diff does not
show is an accepted blind spot, not a defect this facet chases. It reasons **statically** about
the markup in front of it — it does not run axe-core, a browser, a linter, or any scanner.

## The workflow

1. **Relevance gate — first, before any lens work, and sharp.** Run the relevance gate before
   touching a single lens. This facet fires **only when the change renders a user-facing surface
   to a person** — a view, template, component, page, or interactive control (HTML, Blade,
   JSX/React, Vue, a native view, whatever the change renders). A change with no such surface —
   pure business logic, config, a migration, a server-only API with no rendered output, docs — is
   **not** in scope: short-circuit and return `relevance: { skipped: <reason> }`, having spent
   almost nothing, and write an artifact recording the skip. This gate is deliberately narrow; it
   is what keeps most diffs from triggering any accessibility work at all.

2. **Apply the lenses.** For a change that passed the gate, work
   [references/accessibility-checklist.md](references/accessibility-checklist.md), across the
   diff-visible classes:
   - **Structural & naming** — a missing text alternative on an image/icon; a form control with
     no associated label; non-semantic markup or ARIA misuse; a custom widget missing its
     name/role/state; a keyboard operability gap or focus trap; an image of text; a missing or
     wrong `lang`.
   - **Color & contrast** — insufficient contrast between text and its background, or meaning
     conveyed by color alone — flagged when the diff shows the actual values to reason from.
   - **Motion & timing** — auto-playing or looping motion with no reduced-motion respect; a time
     limit with no way to extend it.
   - **Dynamic announcements** — a status or live-region update not exposed to assistive tech;
     focus not managed after a route change, a modal open, or a dynamic content swap.

3. **Floor, then cap** per hard-stops.md §2–3 — drop below `caps.floor`, keep at most
   `caps.top_n`.
4. **Write the artifact and return** per facet-contract.md's Finding schema, to
   `findings.md`.

## What this does not do

- It does not **run a scanner** — no axe-core, no browser, no linter; it reasons statically about
  the diff-visible markup, the way every guardtower facet reasons structurally.
- It does not **crawl the UI or the design system** — its reach is the presentation the diff
  shows; it does not enumerate every view or resolve a themed color variable across the tree.
- It does not **review identity ambiguity** — "can't tell two distinct records apart" belongs to
  the data-presentation facet; this facet owns perceivability and operability, not which record a
  label points at.
- It does not **flag an already-accessible rendering** — a labelled control, an image with a real
  `alt`, a semantic element used correctly is not a finding; the cap and floor keep this facet to
  a real accessibility barrier.
