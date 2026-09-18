# Verifying the PDF — always look at it

A clean exit code means the render did not throw. It does **not** mean the PDF is right. Rasterize
every theme you rendered to images and read them before claiming success.

## Render, then rasterize

```bash
# render (light by default; add --theme dark for the dark PDF too) — from step 3 of the skill
cd "$SKILL" && node --import tsx src/pdf/render.ts "$RUNDIR"

# rasterize to PNGs to inspect (needs poppler: brew install poppler)
pdftoppm -png -r 110 "$RUNDIR/pdf-light.pdf" /tmp/lt
# only if you rendered dark:
pdftoppm -png -r 110 "$RUNDIR/pdf-dark.pdf"  /tmp/dk
```

Open the `/tmp/lt-*.png` and `/tmp/dk-*.png` pages (Read them if you are an agent).

## The three checks

1. **Diagrams render as diagrams** — every `Mermaid` appears as an actual diagram (not code, not a
   blank box), fully inside its card, nothing clipped at the card or page edge.
2. **No overflow** — no table, code block, diagram, or long token runs past the page edge. Wide
   content should fit or wrap.
3. **No large gaps** — a card bumped whole to the next page is fine occasionally; a mostly-empty
   page is not. Prefer splitting a `Section` or moving a large card earlier over leaving a hole.

Check **both** themes — a tint that reads in light can wash out in dark and vice versa.

## When something is wrong

- **`--theme must be "light" or "dark"`** — you passed a bad `--theme` value; it's rejected rather
  than coerced.
- **A mermaid syntax error** aborts the render and names the offending diagram — fix the diagram
  source in `pdf.tsx` and re-render.
- **`no pdf.tsx in <run>`** — you pointed `render` at a directory that has no `pdf.tsx`; author the
  document there first.
- **A diagram looks small** — judge it by rasterizing that page at `-r 300` and zooming; the PDF is
  vector, so it stays sharp.

Fix and re-render until all three checks hold in every theme you rendered. Light is the default; if
you also rendered `--theme dark`, do a final pass on both.
