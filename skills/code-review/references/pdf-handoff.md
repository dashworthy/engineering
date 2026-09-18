# Designed PDF handoff

Turn the reconciled code-review findings into a print-ready, ShadCN-styled PDF for a team or
leadership, rendered in both light and dark, via `engineering:using-pdf-creation`.

## Build the doc

Invoke `engineering:using-pdf-creation` and **start from its template**
`references/templates/code-review-handoff.pdf.tsx`:

1. Scaffold a run dir:
   `sh "${CLAUDE_PLUGIN_ROOT}/scripts/run-context.sh" using-pdf-creation <slug> --fresh`.
2. Copy the template to `<RUNDIR>/pdf.tsx`.
3. Fill its DATA section from the reconciled findings — one `Entry` per finding, `EVIDENCE` from
   real in-repo code, `DEV_NOTES` from a docblock at an unverified boundary.
4. The template opens with a full-bleed `CoverPage` and an auto-built, page-numbered table of
   contents; because react-pdf resolves a page number only after layout, fill the ToC's `PAGES` on
   a **second pass** — render once, read the page each finding lands on, enter it, then re-render.
5. For finding types that carry a type-specific view, layer the matching block from the template's
   sibling `references/templates/finding-blocks/` (security → an exploit / attack-path section,
   concurrency → an interleaving timeline, data-safety → a before/after state table, api-contract → a
   breaking-change matrix); each is a paste-in fragment, and
   `references/templates/finding-blocks/README.md` says where each part goes.
6. Then render and *look at both themes* per using-pdf-creation's verifying protocol.

The same discipline the report holds carries into the doc: evidence — and any exploit — is real, a
developer note is narration not proof, and every sample keeps its `path:line` caption.

## Verification tests are opt-in

Before building the doc, ask the human — as a structured choice, following
`engineering:using-questions` for how to shape and ask it and its degraded-run fallback — whether
to build verification tests for the findings. On **yes**, write a real characterization test per
finding that asserts *current* behaviour (so it passes today), run them, and fill `PROOFS` with only
the tests that actually pass — a finding whose test was not built or did not pass simply has no Proof
block; never fake a proof. On **no**, leave `PROOFS` empty and omit every Proof block. Building
characterization tests writes new test files only; it never edits the reviewed code, so the "does not
fix what it finds" line still holds.
