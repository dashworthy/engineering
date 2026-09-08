# Verbosity checklist — prose a capable agent didn't need

The lens for the verbosity check. The target is a reference card for an expert, not onboarding for a
new hire.

## The tells

- A paragraph defining an ordinary term the agent already knows.
- An explanation of a common file format (JSON, CSV, a diff).
- A "why this matters" preamble before the actual instruction.
- An example that repeats what the sentence already said, adding no new shape.
- Throat-clearing — a sentence about the topic's importance that carries no instruction.
- A restatement: the same rule said twice in two nearby paragraphs.

## Confirm before cutting

Read the sentence and ask what the agent would do differently without it. If nothing, it is
verbosity. If it closes a specific failure — a rationalization the agent would otherwise reach for, an
easy-to-miss constraint, a cliff — it earns its place even when it reads as obvious. Compliance prose
that looks redundant but holds a pressured agent to a rule is **not** verbosity; leave it to
`auditing-force-calibration` and `auditing-compliance-framing` to judge.

## Fix shapes

- **Delete** — the sentence carries nothing.
- **Compress** — two sentences to one; a paragraph to a clause.
- **Replace a described format with a two-line example** — show the shape instead of narrating it.
- **Down-layer** *(hand to progressive disclosure, don't apply here)* — when the content is needed
  but rarely, it belongs in a reference, not deleted. Flag it and note the sibling check owns the
  move, so the two checks don't both edit the same lines.

## Weight

A cut's saving is weighted by where it lands: a verbose clause in a `description` is paid every turn,
in `SKILL.md` every load, in a reference only when reached. Rank a description trim above a body trim
above a reference trim of the same raw size.
