
# Reviewing — Internationalization (translations) facet

Say this first, plainly: `Using the code-review i18n facet to review this change.`

## What this guarantees

One thing: given the change under review, this facet looks for **user-facing text hard-coded in a
source language** where the codebase already has — or plainly should have — a translation layer, and
for text that reaches the translation layer but breaks it (a sentence glued together from fragments
that cannot be reordered, a count with no plural handling, a locale-blind date/number/currency
format). It returns a short, ordered, self-contained list of findings, capped and floored, with a
durable record written to its artifact. It is **report-only**: it never edits code. Its concern is
*whether text shown to a person is translatable* — routed through a translation mechanism and shaped
so a translator can actually localize it — not whether the wording is good (copy review) or whether
the markup is perceivable (the accessibility facet's job).

This facet self-limits at the source (see `../../hard-stops.md`), under the shared `../../facet-contract.md`.

Its analysis stays inside a fixed boundary: it reasons about the strings and formatting **visible in
the diff** — the literal the change renders, the format call it adds — read against the translation
mechanism the surrounding code already uses. It does **no proactive** crawl of the whole codebase or
the message catalogs to prove a string is untranslated; a hard-coded string the diff shows is in
reach, and what the diff does not show is an accepted blind spot, not a defect this facet chases. It
reasons **statically** about the code in front of it — it runs no extractor, linter, or scanner.

## The workflow

1. **Relevance gate — first, before any lens work, and sharp.** Run the relevance gate before
   touching a single lens. This facet fires **only when the change introduces or alters text meant
   for a person** — a UI label, message, button, error shown to a user, email/notification body,
   or the like — in a project that localizes such text (a translation library, message catalog,
   `t()`/`__()`/`trans()`-style helper, resource bundle, or `.po`/`.json`/`.arb`/`.resx` files
   present in the repo), **or** in a project that has no such layer yet but is plainly adding
   user-facing copy that would need one. A change with no user-facing text — pure business logic,
   internal logs, config, a migration, developer-only CLI diagnostics, test fixtures, code
   comments — is **not** in scope: short-circuit and return `relevance: { skipped: <reason> }`,
   having spent almost nothing, and write an artifact recording the skip. When the project shows no
   sign of localizing and the change adds only a stray string or two, prefer to skip: absent a
   translation convention, this facet does not manufacture one.

2. **Apply the lenses.** For a change that passed the gate, work
   [references/i18n-checklist.md](references/i18n-checklist.md), across the diff-visible classes:
   - **Hard-coded user-facing string** — a literal shown to a person written inline instead of
     routed through the translation mechanism the surrounding code uses (`return "Order saved"`
     next to code that elsewhere calls `t("...")`; a Blade template with bare English between tags).
   - **Untranslatable message shape** — text that *does* reach the translation layer but cannot be
     localized correctly: a sentence concatenated from fragments (`t("You have") + count + t("items")`)
     that a translator cannot reorder; a count with no plural/`_n()` handling; an interpolation that
     assumes English word order.
   - **Locale-blind formatting** — a date, time, number, currency, or unit rendered with a fixed
     format or hard-coded symbol instead of a locale-aware formatter (`"$" . $amount`, `date("m/d/Y")`).
   - **Untranslated new-key gap** — a change that adds a translation key but leaves it defined in
     only the source locale when the project's convention is to add it across catalogs (flag the
     missing-locale gap the diff shows; do not crawl every catalog to prove it).

3. **Floor, then cap, then tally the cap's drops** per hard-stops.md §2–3 — drop below
   `caps.floor`, keep at most `caps.top_n`, and report `dropped` (how many genuine
   above-floor findings the cap held back) so nothing real vanishes unseen.
4. **Write the artifact and return** per facet-contract.md's Finding schema, to
   `findings.md`.

## What this does not do

- It does not **run an extractor or linter** — no i18n-lint, no catalog diff tool, no scanner; it
  reasons statically about the diff-visible code, the way every code-review facet reasons.
- It does not **crawl the message catalogs or the whole codebase** — its reach is the strings and
  formatting the diff shows; it does not enumerate every untranslated string in the project or audit
  catalog completeness beyond the gap the diff itself introduces.
- It does not **review wording quality** — clarity, tone, grammar, and typos in the source copy are
  a copy/editorial review's job; this facet asks only whether the text is *translatable*, not whether
  it reads well.
- It does not **flag developer-facing strings** — log lines, exception messages seen only by
  developers, internal CLI diagnostics, config keys, and test text are not user-facing; routing them
  through translation is not a finding.
- It does not **manufacture a translation layer** — in a project that legitimately ships in a single
  language with no localization convention, a plain string is not automatically a defect; the
  relevance gate keeps this facet to changes where translation is actually the norm or the clear need.
