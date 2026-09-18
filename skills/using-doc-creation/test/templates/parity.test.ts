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

describe('template parity — Markdown mirrors its PDF sibling', () => {
  it('feature-doc: every PDF TOC section has a matching Markdown heading', () => {
    const pdf = read('references/templates/pdf/feature-doc.pdf.tsx');
    const md = read('references/templates/markdown/feature-doc.md');

    // The PDF template's TOC array is the canonical, ordered section list. Each row is
    // `{ title: '…', page: '…', link: '…' }` — anchoring on `link:` isolates the TOC rows from other
    // `title:` keys (cover, cards) in the file.
    const tocTitles = [...pdf.matchAll(/title:\s*'([^']+)'[^}]*link:/g)].map((m) => m[1]);
    expect(tocTitles.length, 'expected the feature-doc PDF TOC to define its sections').toBeGreaterThanOrEqual(9);

    const headings = markdownHeadings(md);
    for (const title of tocTitles) {
      expect(headings, `Markdown feature-doc is missing the "${title}" section`).toContain(title);
    }
  });

  it('code-review-handoff: the finding-report scaffold appears in both formats', () => {
    const pdf = read('references/templates/pdf/code-review-handoff.pdf.tsx');
    const md = read('references/templates/markdown/code-review-handoff.md');

    // The handoff is finding-driven (sections vary with the findings), so parity is on the fixed
    // scaffold every finding report carries. These labels are literals in the PDF template's WIRING;
    // the Markdown must carry the same ones.
    const scaffold = ['How to read this', 'Current code', 'Proposed fix', 'Why this fixes it'];
    for (const label of scaffold) {
      expect(pdf, `the PDF template no longer carries the "${label}" scaffold label`).toContain(label);
      expect(md, `Markdown code-review-handoff is missing the "${label}" scaffold`).toContain(label);
    }
  });
});
