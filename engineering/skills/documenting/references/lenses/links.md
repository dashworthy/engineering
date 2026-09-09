# Links lens

Review the doc for one thing: does every link and index entry resolve? The whole point of the doc
— and the toc — is to save a reader (and an agent) a grep by pointing straight at the right file; a
dead link spends that trust.

Check:

- **The toc row.** `docs/toc.md` has a row for this feature, and its link resolves to the feature's
  `README.md`.
- **The reference table.** Every entry in the feature doc's `## References` table points at a
  sub-doc file that exists under the feature folder.
- **In-doc links.** Any other relative link in the doc resolves to a real file.

Verify against the actual `docs/` tree, not against what the doc claims exists. A link to a file
that is not there is a finding, as is a sub-doc on disk that no reference-table row points to
(an orphan the reader will never find).

Do **not** judge prose, accuracy, or scope. Stay on: does every pointer land?

Return each finding in the shared grammar: file and location, what's wrong, why it bites. An empty
return means every link and index entry resolves.
