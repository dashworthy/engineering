import { describe, it, expect } from 'vitest';
import TestRenderer from 'react-test-renderer';
import { PdfDoc } from '../../src/pdf/components/PdfDoc.js';
import { Section } from '../../src/pdf/components/Section.js';
import { P } from '../../src/pdf/components/prose.js';

/** The react-pdf `Page` nodes of a rendered document, in order. */
function pages(node: ReturnType<typeof TestRenderer.create>['toJSON'] extends never ? never : any) {
  const out: any[] = [];
  const walk = (n: any) => {
    if (!n || typeof n !== 'object') return;
    if (n.type === 'PAGE') out.push(n);
    (n.children ?? []).forEach(walk);
  };
  (Array.isArray(node) ? node : [node]).forEach(walk);
  return out;
}

/** All plain-string text anywhere in a subtree. */
function textOf(n: any): string {
  const acc: string[] = [];
  const walk = (x: any) => {
    if (typeof x === 'string') return acc.push(x);
    if (!x || typeof x !== 'object') return;
    (x.children ?? []).forEach(walk);
  };
  walk(n);
  return acc.join(' ');
}

/** The fixed, dynamic-`render` TEXT node in a subtree, if any (the page-number furniture). */
function pageNumberNode(n: any): any {
  let found: any = null;
  const walk = (x: any) => {
    if (!x || typeof x !== 'object' || found) return;
    if (x.type === 'TEXT' && x.props?.fixed && typeof x.props?.render === 'function') found = x;
    (x.children ?? []).forEach(walk);
  };
  walk(n);
  return found;
}

function render(cover: JSX.Element, frontMatter: JSX.Element) {
  return TestRenderer.create(
    <PdfDoc theme="light" title="T" cover={cover} frontMatter={frontMatter}>
      <Section eyebrow="e" title="t">
        <P>BODY</P>
      </Section>
    </PdfDoc>,
  ).toJSON();
}

describe('PdfDoc page numbers', () => {
  const tree = render(<P>COVER</P>, <P>FRONTMATTER</P>);
  const ps = pages(tree);

  it('lays out cover, front matter, and body as three separate pages', () => {
    expect(ps).toHaveLength(3);
    expect(textOf(ps[0])).toContain('COVER');
    expect(textOf(ps[1])).toContain('FRONTMATTER');
    expect(textOf(ps[2])).toContain('BODY');
  });

  it('numbers only the body page — cover and front matter carry no page number', () => {
    expect(pageNumberNode(ps[0])).toBeNull(); // cover
    expect(pageNumberNode(ps[1])).toBeNull(); // front matter (ToC lives here)
    expect(pageNumberNode(ps[2])).not.toBeNull(); // body
  });

  it('renders body-relative numbering via subPageNumber (first body page reads 1)', () => {
    const node = pageNumberNode(ps[2]);
    expect(node.props.render({ subPageNumber: 1, subPageTotalPages: 4 })).toBe('1 / 4');
    expect(node.props.render({ subPageNumber: 3, subPageTotalPages: 4 })).toBe('3 / 4');
  });

  it('omits the front-matter page entirely when none is given', () => {
    const bare = TestRenderer.create(
      <PdfDoc theme="light" title="T" cover={<P>COVER</P>}>
        <P>BODY</P>
      </PdfDoc>,
    ).toJSON();
    const bareP = pages(bare);
    expect(bareP).toHaveLength(2); // cover + body only
    expect(pageNumberNode(bareP[1])).not.toBeNull(); // body still numbered
  });
});
