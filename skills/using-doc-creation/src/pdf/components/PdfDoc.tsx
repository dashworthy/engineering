import { useMemo, type ReactNode } from 'react';
import { Document, Page, StyleSheet, Text } from '@react-pdf/renderer';
import { createTw } from 'react-pdf-tailwind';
import { FONT, PAGE, TYPE, TwProvider, registerFonts, shadcnConfig, type PdfTheme } from '../theme.js';

/**
 * The react-pdf document root. Unlike the HTML path (where a headless-Chrome print leaves the
 * page margin unpainted), react-pdf has a true paged model: the `<Page>` owns its own
 * `backgroundColor` and `padding`, so every printed page is the ground color to the paper edge
 * with a uniform doc-like inset — no fixed-layer tricks, no white margin band. Content longer than
 * one page flows and paginates automatically.
 */
export function PdfDoc({
  theme,
  title,
  cover,
  frontMatter,
  children,
}: {
  theme: PdfTheme;
  title: string;
  /**
   * An optional full-bleed cover rendered as its own dedicated first `<Page>` — no page inset, so a
   * `CoverPage`'s tinted hero bleeds to the paper edge. Content `children` start on the page after.
   */
  cover?: ReactNode;
  /**
   * Optional front matter — a table of contents and any other prelims — rendered on its own inset
   * `<Page>` between the cover and the body. It is deliberately **unnumbered**: page numbers start
   * on the first body page, so the printed "1" is the first page of real content, not the ToC. Put
   * the `Toc` here, not in `children`.
   */
  frontMatter?: ReactNode;
  children: ReactNode;
}): JSX.Element {
  registerFonts();
  const tw = useMemo(() => createTw(shadcnConfig(theme)), [theme]);
  const ground = tw('bg-background').backgroundColor;
  const styles = StyleSheet.create({
    page: {
      // The page ground + base ink are the vanilla ShadCN `background` / `foreground` tokens.
      backgroundColor: ground,
      color: tw('text-foreground').color,
      fontFamily: FONT.sans,
      fontSize: TYPE.body,
      lineHeight: 1.5,
      paddingVertical: PAGE.paddingV,
      paddingHorizontal: PAGE.paddingH,
    },
    // The cover page carries no inset — the cover fills it corner to corner and paints its own ground.
    coverPage: {
      backgroundColor: ground,
      color: tw('text-foreground').color,
      fontFamily: FONT.sans,
      fontSize: TYPE.body,
      lineHeight: 1.5,
      padding: 0,
    },
    // The page-number furniture: pinned into the bottom margin, centered, muted mono. `fixed`
    // repeats it on every body page; `render` fills the live number per page (react-pdf's
    // dynamic-content API). It lives only on the body `<Page>`, and it reads `subPageNumber` /
    // `subPageTotalPages` — which restart at 1 for that `<Page>`'s own flow — so numbering counts
    // only body pages. The cover and front-matter pages carry no such element, so they are unnumbered.
    pageNumber: {
      position: 'absolute',
      bottom: 24,
      left: 0,
      right: 0,
      textAlign: 'center',
      fontFamily: FONT.mono,
      fontSize: TYPE.eyebrow,
      color: tw('text-muted-foreground').color,
    },
  });
  return (
    <TwProvider value={tw}>
      <Document title={title}>
        {cover && (
          <Page size="A4" style={styles.coverPage}>
            {cover}
          </Page>
        )}
        {frontMatter && (
          <Page size="A4" style={styles.page}>
            {frontMatter}
          </Page>
        )}
        <Page size="A4" style={styles.page}>
          <Text
            style={styles.pageNumber}
            fixed
            render={({ subPageNumber, subPageTotalPages }) => `${subPageNumber} / ${subPageTotalPages}`}
          />
          {children}
        </Page>
      </Document>
    </TwProvider>
  );
}
