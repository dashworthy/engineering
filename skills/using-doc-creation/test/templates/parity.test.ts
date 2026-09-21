import { describe, it, expect } from 'vitest';
import { readFileSync } from 'node:fs';
import { resolve, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';

// The parity contract: each Markdown template must carry the same sections as its PDF sibling, so a
// reader gets the same document whichever format they pick (no PDF section dropped from the Markdown).
// We read the contract FROM the PDF template — its own TOC / scaffold labels — rather than restating
// it here, so the test tracks the templates as they evolve instead of a hand-maintained copy.

const SKILL_ROOT = resolve(dirname(fileURLToPath(import.meta.url)), '..', '..'); // test/templates -> skill root
const read = (rel: string) => readFileSync(resolve(SKILL_ROOT, rel), 'utf8');
const markdownHeadings = (md: string) =>
  [...md.matchAll(/^#{2,6}\s+(.+?)\s*$/gm)].map((m) => m[1].trim());
// A PDF template's TOC array is `[{ title: '…', page: '…', link: '…' }, …]`. Anchoring on `link:`
// isolates TOC rows from other `title:` keys (cover, cards) in the file.
const tocTitles = (pdf: string) => [...pdf.matchAll(/title:\s*'([^']+)'[^}]*link:/g)].map((m) => m[1]);

// TOC-driven templates: a fixed, ordered section list the Markdown must mirror heading-for-heading.
const TOC_DRIVEN = [
  { name: 'feature-doc', min: 9 },
  { name: 'spec', min: 9 },
];

// Scaffold-driven templates: sections vary with the content (findings, tasks), so parity is on the
// fixed labels every such document carries. These are literals in the PDF template's WIRING.
const SCAFFOLD_DRIVEN = [
  { name: 'code-review-handoff', labels: ['How to read this', 'Current code', 'Proposed fix', 'Why this fixes it'] },
  { name: 'plan', labels: ['Global Constraints', 'Done when'] },
];

describe('template parity — Markdown mirrors its PDF sibling', () => {
  for (const { name, min } of TOC_DRIVEN) {
    it(`${name}: every PDF TOC section has a matching Markdown heading`, () => {
      const pdf = read(`references/templates/pdf/${name}.pdf.tsx`);
      const md = read(`references/templates/markdown/${name}.md`);

      const titles = tocTitles(pdf);
      expect(titles.length, `expected the ${name} PDF TOC to define its sections`).toBeGreaterThanOrEqual(min);

      const headings = markdownHeadings(md);
      for (const title of titles) {
        expect(headings, `Markdown ${name} is missing the "${title}" section`).toContain(title);
      }
    });
  }

  for (const { name, labels } of SCAFFOLD_DRIVEN) {
    it(`${name}: the document scaffold appears in both formats`, () => {
      const pdf = read(`references/templates/pdf/${name}.pdf.tsx`);
      const md = read(`references/templates/markdown/${name}.md`);
      for (const label of labels) {
        expect(pdf, `the PDF template no longer carries the "${label}" scaffold label`).toContain(label);
        expect(md, `Markdown ${name} is missing the "${label}" scaffold`).toContain(label);
      }
    });
  }
});
