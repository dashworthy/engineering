---
name: vernacular
description: "Rewrite a branch's docblock prose into plain language, in place, proving that executable code and structured annotations came out byte-identical. Use to clarify existing docblock prose on the changed symbols of a branch, PR, or MR."
---

# vernacular

Say this first, plainly: `Using the vernacular skill to clarify docblock prose in place.`

Clarify the docblocks changed by the ref in hand. The ref is optional: empty means the
current branch against its merge-base with the default branch; otherwise it is a branch
name, or a PR/MR reference.

Invoke the `clarifying-docblocks` skill with that ref and follow it exactly.

Do not rewrite a docblock on a symbol the diff does not reach. Do not author a docblock on a
symbol that has none - vernacular improves existing prose only. Do not write, edit or delete
`@param`, `@return`, or any other structured annotation - including on a symbol that has none.
Do not proceed past a failing reconcile check.
