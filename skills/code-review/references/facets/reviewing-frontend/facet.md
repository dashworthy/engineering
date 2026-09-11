
# Reviewing — Frontend facet

Say this first, plainly: `Using the code-review frontend facet to review this change.`

## What this guarantees

One thing: given a change that renders a user-facing surface, this facet reviews that surface
across three lenses — **Accessibility** (perceivability & operability), **Data presentation**
(identity ambiguity), and **Internationalization** (translatability) — and returns a short,
ordered, self-contained list of findings, capped and floored, with a durable record written to
its artifact. It is **report-only**: it never edits code.

The three lenses share one relevance gate — *does the change render a surface a person sees?* —
and run as one dispatched reviewer. Each owns a distinct concern, and the boundaries between them
tell this facet which lens owns a given finding; the workflow below draws each line where it
matters.

This facet self-limits at the source (see `../../hard-stops.md`), under the shared
`../../facet-contract.md`.

Its analysis stays inside a fixed boundary: it reasons about the presentation **visible in the
diff** — the template, component, control, string, or style the change actually renders — read
against the reviewer's knowledge of what assistive technology needs, when a label fails to
identify its record, and what the surrounding code's translation mechanism expects. It does
**no proactive** crawl of the whole UI, the component tree, the data model, or the message
catalogs to prove a defect exists elsewhere; a defect the diff shows is in reach, and what the
diff does not show is an accepted blind spot, not something this facet chases. It reasons
**statically** about the markup and strings in front of it — it runs no axe-core, browser,
linter, extractor, or scanner.

## The workflow

1. **Relevance gate — first, before any lens work, and sharp.** Run the relevance gate before
   touching a single lens. This facet fires **only when the change renders a user-facing surface
   to a person** — a view, template, component, page, interactive control, API field list, CLI
   table, or selection control (HTML, Blade, JSX/React, Vue, a native view, whatever the change
   renders), **or** introduces/alters user-facing text (a label, message, button, error,
   email/notification body) in a project that localizes such text (or plainly should). A change
   with no such surface — pure business logic, config, a migration, a server-only API with no
   rendered output, internal logs, developer-only CLI diagnostics, test fixtures, docs — is
   **not** in scope: short-circuit and return `relevance: { skipped: <reason> }`, having spent
   almost nothing, and write an artifact recording the skip. This gate is deliberately narrow; it
   is what keeps most diffs from triggering any frontend work at all.

2. **Apply the lenses that the surface earns.** A change touches one, two, or all three lenses;
   apply each whose concern the diff-visible surface actually raises. Each lens has its own
   checklist under `references/`.

   - **Accessibility lens** — perceivability & operability. Work
     [references/accessibility-checklist.md](references/accessibility-checklist.md): a missing
     text alternative on an image/icon; a form control with no associated label; non-semantic
     markup or ARIA misuse; a custom widget missing its name/role/state; a keyboard operability
     gap or focus trap; an image of text; a missing/wrong `lang`; insufficient contrast or meaning
     conveyed by color alone (when the diff shows the values); auto-playing/looping motion with no
     reduced-motion respect; a time limit with no extension; a status/live-region update not
     exposed to assistive tech, or focus not managed after a route change, modal open, or content
     swap.

   - **Data-presentation lens** — identity ambiguity, *only*. Work
     [references/data-presentation-checklist.md](references/data-presentation-checklist.md): a
     nested/hierarchical record shown by a name its siblings share with no path; a collision-prone
     identifier (a person's name, a file's base name) shown with no distinguishing key; a list,
     table, dropdown, or autocomplete where two distinct options render identically; a truncation
     or responsive layout that cuts off the disambiguating information the data carries.

   - **Internationalization lens** — whether user-facing text is *translatable*. Work
     [references/i18n-checklist.md](references/i18n-checklist.md): a hard-coded user-facing string
     written inline instead of routed through the translation mechanism the surrounding code uses;
     an untranslatable message shape (a sentence concatenated from fragments, a count with no
     plural handling, an interpolation that assumes English word order); locale-blind date/number/
     currency formatting; a new translation key left defined only in the source locale where the
     project's convention is to add it across catalogs.

3. **Floor, then cap, then tally the cap's drops** per hard-stops.md §2–3 — drop below
   `caps.floor`, keep at most `caps.top_n`, and report `dropped` (how many genuine above-floor
   findings the cap held back) so nothing real vanishes unseen. The cap spans all three lenses:
   the `top_n` most severe findings across the whole surface are what matter first.
4. **Write the artifact and return** per facet-contract.md's Finding schema, to `findings.md`.

## What this does not do

- It does not **run a scanner, extractor, or linter** — no axe-core, browser, i18n-lint, or
  catalog diff tool; it reasons statically about the diff-visible markup and strings, the way
  every code-review facet reasons structurally.
- It does not **crawl the UI, the data model, or the message catalogs** — its reach is the surface
  the diff shows; it does not enumerate every view, resolve a themed color variable across the
  tree, prove a record collision from the schema, or audit catalog completeness beyond the gap the
  diff introduces.
- It does not **review wording quality** — clarity, tone, grammar, and typos in the source copy
  are a copy/editorial review's job; the i18n lens asks only whether text is *translatable*, not
  whether it reads well.
- It does not **flag developer-facing strings** — log lines, exception messages seen only by
  developers, internal CLI diagnostics, config keys, and test text are not user-facing.
- It does not **review beyond the rendered surface** — a security, correctness, or
  tenant-isolation smell it happens to notice is out of scope; another facet owns it.
- It does not **flag an already-sound surface** — a labelled control with a real `alt` and correct
  semantics, a label unique in its context or already showing its key, a string routed through the
  translation layer in a translatable shape — none is a finding; the cap and floor keep this facet
  to a real defect.
