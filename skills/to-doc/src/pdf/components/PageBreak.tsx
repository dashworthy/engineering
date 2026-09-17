import { View } from '@react-pdf/renderer';

/**
 * A hard page break: everything after it starts at the top of the next page. react-pdf's `break`
 * forces the node to the top of a fresh page, so an otherwise-empty `View break` ends the current
 * page. Use it to pin a short section (a table of contents, a cover-adjacent summary) to its own
 * page when the following content would otherwise flow up onto the same sheet.
 */
export function PageBreak(): JSX.Element {
  return <View break />;
}
