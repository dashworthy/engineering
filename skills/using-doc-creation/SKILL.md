---
name: using-doc-creation
description: Turn a source document into shareable documentation in one of two formats — a polished, print-ready **PDF** (hand-written JSX from the @engineering/using-doc-creation component library: ShadCN-styled cover, sections, callouts, badges, tables, comparison/panel/key cards, phase & flow sequences, syntax-highlighted code, and mermaid diagrams as real vector images; light by default, dark via `--theme dark`) or plain portable **Markdown** (GFM: headings, tables, fenced code, mermaid as fenced code-blocks) copied from a ready template. Use when asked to make a designed/branded PDF, export a README or doc to PDF, or produce a portable Markdown doc for a repo or wiki.
---

# using-doc-creation

Say this first, plainly: `Using the using-doc-creation skill to author documentation from the source document.`

You turn a source document (a README, a spec, a request) into shareable documentation. **Decide the
format first** (below), then follow that format's workflow.

- `$SKILL` is this skill's base directory (shown as "Base directory for this skill" when the skill is
  invoked) — the same as `${CLAUDE_PLUGIN_ROOT}/skills/using-doc-creation`.
- `$PROJECT` is the directory you are working in (the invoking project's root).
- `$RUNDIR` is the per-render working directory the run-context script prints (PDF format only).

## Choose a format

Pick the format the reader actually needs, then jump to its section:

| Format | Selection | What it is | Reach for it when | Workflow |
|---|---|---|---|---|
| **PDF** | **Default** | An A4, designed, print-ready document: cover, ShadCN-styled components, real vector mermaid diagrams. Light by default; dark opt-in. | The doc is a handoff, a leadership/architecture-review artifact, or anything where the *look* matters and the mermaid diagrams must render as diagrams. | [PDF format](#pdf-format) — author `pdf.tsx`, render, inspect. |
| **Markdown** | Fallback | Plain portable GFM: headings, tables, fenced code, mermaid as ` ```mermaid ` code-blocks. No styling, no build step. | The doc lives in a repo or wiki, must be version-controlled and diff-able, and needs to render anywhere with nothing installed. | [Markdown format](#markdown-format) — copy a `.md` template, fill it, done. |

**When a caller defers the choice** — a pipeline phase that hands off its doc *by path* (e.g. `spec`,
`plan`) rather than a human picking — the format decision is made **here**, not by the caller. That
caller's Markdown already exists and always ships: it is the artifact downstream phases read (`plan`
reads the spec, `build` reads the plan), so a concession the pipeline depends on, not a format choice.
On top of that always-present Markdown, **render the PDF by default** as the designed copy — offer the
human the choice via `engineering:using-questions`, recommended answer (PDF) first — and **skip the PDF
only when it can't be produced** (no Node/Chromium, a render failure, or the human declines). Markdown
always ships; the PDF is the optional presentation copy. The caller supplies only the path; every
decision about format lives here.

If a ready template fits (see [Templates](#templates)), start from it in the chosen format rather than
authoring from scratch.

---

## PDF format

An A4 PDF that looks designed: a cover from the doc's title, sectioned prose, ShadCN-styled
callouts/badges/tables, comparison and key-box cards, phase and flow sequences, syntax-highlighted
code, and **real vector mermaid diagrams** — light or dark, chosen at render time. You author the
document as a small React (`*.pdf.tsx`) module using a fixed component library; the builder paginates
it to PDF with `@react-pdf/renderer` (no HTML, no browser print). Your job is to author it, **render
it, then look at the PDF** and iterate.

### One-time setup (PDF only)

```bash
cd "$SKILL" && npm install
```

- **Node ≥ 18.**
- **A Chromium-family browser** is needed **only if the document uses `Mermaid`** — auto-detected
  (`CHROME_PATH` / `PUPPETEER_EXECUTABLE_PATH`, then standard install paths, then puppeteer's own
  Chromium). A doc with no diagrams needs no browser. Chrome is used **only** to rasterize diagrams,
  never for page layout.
- Fonts (Inter + IBM Plex Mono) are bundled and embedded — no network needed to render.

### 1. Scaffold a run directory

Obtain a fresh per-render working directory under the current run, following the standard
`.engineering/` convention:

```bash
sh "${CLAUDE_PLUGIN_ROOT}/scripts/run-context.sh" using-doc-creation <slug> --fresh
```

`<slug>` is a short kebab-case handle for the document (e.g. `api-guide`); it names a **new** run and
is ignored once a run is already active. `--fresh` returns a fresh numbered leaf
`.engineering/<run>/using-doc-creation/<NNN>/`, so each render keeps its own directory. The command prints that
absolute path — call it `$RUNDIR`. You author `pdf.tsx` there and the rendered PDFs land beside it.

### 2. Author `pdf.tsx`

Write `$RUNDIR/pdf.tsx`. It **default-exports a builder** `(theme) => <PdfDoc …>`,
so one authored document renders in either theme. The builder **may be async**: because react-pdf
renders synchronously, anything async — Shiki code highlighting (`highlightCode`) and mermaid
rasterization (`rasterizeMermaid`) — is awaited **up front** and the result passed to the component
as data.

Import **only** from the bare specifier `@engineering/using-doc-creation`. Keep the file **self-contained**: no
relative imports, no local asset files — code and diagrams become inline data via `highlightCode` /
`rasterizeMermaid`. (At render time the wrapper stages the file inside the package so the bare
import resolves; a relative import would not survive that.)

```tsx
// $RUNDIR/pdf.tsx
import {
  PdfDoc, Cover, Section, P, B, KeyBox, Table, CodeBlock, Mermaid,
  highlightCode, rasterizeMermaid, type PdfTheme,
} from '@engineering/using-doc-creation';

export default async (theme: PdfTheme) => {
  // Pre-compute async assets before building the tree.
  const setup = await highlightCode('npm install', 'bash', theme);
  const flow = await rasterizeMermaid('flowchart LR\n  A[Start] --> B[(Store)]', theme);

  return (
    <PdfDoc theme={theme} title="My Document">
      <Cover eyebrow="Spec · 2026-09-15" title="My Document"
             lede="One line under the title." chips={['v1', 'Approved']} />
      <Section eyebrow="Overview" title="What this is" deck="A short deck under the title.">
        <P>Body copy with <B>bold</B> where it earns it.</P>
        <KeyBox role="positive" title="Tip">A tip in the positive role.</KeyBox>
        <CodeBlock code={setup} />
        <Mermaid diagram={flow} title="Flow" caption="Start to store." />
      </Section>
    </PdfDoc>
  );
};
```

**This is the reader's document, not an ad for the tool.** Never add a "Generated by
@engineering/using-doc-creation" line, a repo link, or any other tool/skill attribution — that branding is noise
the reader did not ask for, and it makes a doc meant for their team or leadership look auto-generated.
**Never create a page footer at all.** There is no `Footer` component; do not hand-roll a
bottom-of-page provenance strip either. Any author, date, or confidentiality metadata belongs in the
cover (`CoverPage`'s `meta` strip or `Cover`'s chips), not a footer.

**Page numbers are automatic.** `PdfDoc` numbers the body pages from 1 (bottom-centered, muted mono);
the cover and the optional `frontMatter` page (where the `Toc` goes) are unnumbered. Do not add a
page-number element yourself — that is the one piece of page furniture the root already owns.

**Which component for what** — the full catalog, each with its props and a decision matrix of when
to reach for it, is in **[references/authoring.md](references/authoring.md)**. The fixture
`src/docs/gallery.pdf.tsx` exercises every component and is worth skimming as a worked example.

### 3. Render (light by default)

```bash
cd "$SKILL" && node --import tsx src/pdf/render.ts "$RUNDIR"
```

Run it from `$SKILL` (so `tsx` and the package resolve); `$RUNDIR` is absolute, so the cwd change is
safe. This reads `$RUNDIR/pdf.tsx` and writes **`$RUNDIR/pdf-light.pdf`** — **light is the default**. Add
`--theme dark` to also render **`$RUNDIR/pdf-dark.pdf`** (or `--theme light` to be explicit). A misspelled
theme is rejected rather than coerced; a diagram with bad mermaid syntax aborts the render naming it.

### 4. Verify — always look at the PDF

Do **not** claim success from the exit code alone. Rasterize and inspect every theme you rendered
(light by default; both, if you passed `--theme dark`), and check diagrams render as diagrams (fully
inside their cards), nothing overflows the page, and there are no large empty gaps. The full protocol
is in **[references/verifying.md](references/verifying.md)**.

Fix and re-render until it holds.

---

## Markdown format

Plain, portable **GitHub-Flavored Markdown** — headings, tables, fenced code, and mermaid kept as
` ```mermaid ` fenced code-blocks. It renders anywhere (GitHub, a wiki, any Markdown viewer) with **no
build step, no render, and no run directory**. It deliberately does **not** reproduce the PDF's visual
styling: no callout boxes, badges, or cards, and no embedded HTML/CSS — that is the price of portability.

The workflow is just three moves:

1. **Copy** the matching template from `references/templates/markdown/` (see [Templates](#templates))
   to wherever the doc belongs (e.g. a repo path, or `$RUNDIR` if you want it beside a PDF).
2. **Fill** it: follow the template's header comment, replace every placeholder, and delete any
   section the doc doesn't need. Keep mermaid diagrams as ` ```mermaid ` fenced blocks — do not try to
   render them to images.
3. **Done.** There is nothing to compile or inspect beyond reading the Markdown back. Preview it in a
   GFM viewer if you want to confirm tables and fenced blocks render.

No template fits? Write the Markdown by hand in plain GFM, mirroring the section shape of whichever
PDF template is closest.

---

## Templates

Start from a ready template instead of authoring from scratch when one fits. Each template carries its
own fill-in instructions in a header comment. **The same document type exists in both formats** — pick
the row for your document, then the column for your chosen format.

| Document type | PDF template | Markdown template | Use it for |
|---|---|---|---|
| Code-review finding handoff | `references/templates/pdf/code-review-handoff.pdf.tsx` | `references/templates/markdown/code-review-handoff.md` | Reconciled code-review findings as a report: cover/title, a contents list, and one section per finding (current code, proposed fix, why it works). The PDF template layers type-specific views from the sibling `references/templates/pdf/finding-blocks/` (security, concurrency, data-safety, api-contract); the Markdown template folds those in inline. |
| Spec (Tier-1) | `references/templates/pdf/spec.pdf.tsx` | `references/templates/markdown/spec.md` | A Tier-1 spec: cover + page-numbered ToC + §0 ELI5 through §8 open questions (goals & Deferred as tables). The format contract is `references/spec-format.md`. |
| Plan | `references/templates/pdf/plan.pdf.tsx` | `references/templates/markdown/plan.md` | An implementation plan: cover + ToC, Global Constraints, one section per task (TDD-wired steps + verification), and a Done-when. |

No template fits? PDF — author `pdf.tsx` from the component library directly (step 2 above); Markdown —
write plain GFM mirroring the closest template's sections.

## Where the rest lives

- **[references/authoring.md](references/authoring.md)** — the PDF component catalog + when-to-use matrix.
- **[references/verifying.md](references/verifying.md)** — the PDF inspection protocol.
- **[references/templates/pdf/](references/templates/pdf/)** — ready-to-fill PDF templates (see **Templates** above).
- **[references/templates/markdown/](references/templates/markdown/)** — ready-to-fill Markdown templates.
- **[references/spec-format.md](references/spec-format.md)** — the Tier-1 spec format contract (relocated here; the `spec` skill reads it).
- **[README.md](README.md)** — the package reference (component list, styling boundary, CLI).
